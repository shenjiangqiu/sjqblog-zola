+++


description = "async in rust use a stackless manner and lazy execution, this post shares my understanding of async in Rust. this post includes: async trait, async/await, async block, why use `Pin<&mut Self>` instead of `&mut Self` in poll function?"
[taxonomies]
tags = ["rust", "async"]
authors = ["Jiangqiu Shen"]
+++



async in rust.
A good resource to learn: [the async book](https://rust-lang.github.io/async-book/)

this post shares my understanding of async in Rust. 
<!-- more -->
## async trait
an async block in Rust is a type that implements the `Future`` trait. so what is a future?
```rust
pub trait Future {
    type Output;
    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}
```
So a future can be `polled` and return a `Poll` type. `Poll` is an enum type:
```rust
pub enum Poll<T> {
    Ready(T),
    Pending,
}
```
So a future basically means a `function` that can be `polled` multiple times, and It can say that ***I'm ready*** or ***I'm not ready***. If it's ready, it will return a `Ready` with the result, otherwise, it will return a `Pending` and the executor will call it again later.

So when will the executor call it again? The executor will call it again when the future is ready to be polled again. So how does the executor know when the future is ready to be polled again? when the executor called the `poll`, it will pass a `waker` inside the `context` to the `Future`, and when the `Future` is ready to be polled again, it will call the `waker` to wake the executor: `waker.wake()`. So the executor will call the `poll` again.

## `async`/`await`, async block

let's look at an async block: note that all code is handwritten, not compiled. ignore some syntax errors~~
```rust
let addr=some_addr;
let my_task = async {
    let addr:Addr = process_addr(addr);
    let a = receive_some_http_request(addr).await;

    let a = process_http_request(a);
    let b = fetch_some_data_from_db(a).await;

    let c = process_db_data(b);
    let c = do_some_database_operation(b).await;

    let d = process_db_result(c);
    d
};

```

the rust compiler will compile the `my_task` to a state machine that implements the `Future`` trait. we can assume that it looks like this(ignore the syntax errors~~):
```rust
struct MyTask{
    addr:Addr,
    process_addr:impl Fn(Addr)->Addr,
    http_request_future:impl Fn(Addr)-> impl Future<Output=HttpRequest>,
    process_http_request:impl Fn(HttpRequest)->HttpRequest,
    db_future:impl Fn(HttpRequest)-> impl Future<Output=DbData>,
    process_db_data:impl Fn(DbData)->DbData,
    db_operation_future:impl Fn(DbData)-> impl Future<Output=DbResult>,
    process_db_result:impl Fn(DbResult)->DbResult,
    stage:MyTaskStage,
}
enum MyTaskStage{
    stage_1_before_http_request,
    stage_2_before_db_operation,
    stage_3_before_db_result,
    stage_4_before_return,
}
impl Future for MyTask{
    type Output=DbResult;
    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>{
        match self.stage{
            MyTaskStage::stage_1_before_http_request=>{
                match self.http_request_future(self.process_addr(self.addr)).poll(cx){
                    Poll::Ready(http_request)=>{
                        self.stage=MyTaskStage::stage_2_before_db_operation;
                        self.poll(cx)
                    }
                    Poll::Pending=>{
                        Poll::Pending
                    }
                }
            }
            MyTaskStage::stage_2_before_db_operation=>{
                match self.db_future(self.process_http_request(http_request)).poll(cx){
                    Poll::Ready(db_data)=>{
                        self.stage=MyTaskStage::stage_3_before_db_result;
                        self.poll(cx)
                    }
                    Poll::Pending=>{
                        Poll::Pending
                    }
                }
            }
            MyTaskStage::stage_3_before_db_result=>{
                match self.db_operation_future(self.process_db_data(db_data)).poll(cx){
                    Poll::Ready(db_result)=>{
                        self.stage=MyTaskStage::stage_4_before_return;
                        self.poll(cx)
                    }
                    Poll::Pending=>{
                        Poll::Pending
                    }
                }
            }
            MyTaskStage::stage_4_before_return=>{
                Poll::Ready(self.process_db_result(db_result))
            }
        }
    }
}
```

we can see that, the async block is equivalent to a state machine, and the `Future` trait is the interface of the state machine. the `poll` function is the `state transition` function of the state machine. the `waker` is the `state transition` trigger of the state machine.

when the executor first calls the `poll` function, the state machine will start from the first state, and when the state machine is ready to be polled again, it will call the `waker` to wake the executor, and the executor will call the `poll` function again, and the state machine will continue to run.

## why use `Pin<&mut Self>` instead of `&mut Self` in `poll` function?
before talking about this question, let's talk about `Pin` first. if we have a mutable reference, we can easily move the value that the reference point by mem::swawp. most time that's ok, but when the struct is self-referenced, it will cause problems. for example(note: this code is not compiled in safe rust, just ignore the syntax errors):
```rust
struct MyStruct{
    a:u32,
    b:&'self u32,
}
/// ignore the syntax errors.
let mut my_struct_1=MyStruct{a:1,b:&my_struct.a};
let mut my_struct_2=MyStruct{a:2,b:&my_struct.a};
mem::swap(&mut my_struct_1,&mut my_struct_2);
// now the error happens, my_struct_1.b point to my_struct_2.a, but my_struct_2.a is 2, not 1.
assert_eq!(my_struct_1.a,2);
assert_eq!(my_struct_2.a,1);
```
usually, we cannot have a struct that contains self-reference, but in the async block, the self-reference struct is common, for example:
```rust
let async_block = async {
    let a = 100;
    let c = some_future(&a).await;
    c
}

/// it might compiled to something like this:
struct SomeFuture<'a>{a:&'a u32};
struct AsyncBlock{
    a:u32,
    // the `some_future` state is self-referenced. it will contains a reference to `self.a`.
    some_future:impl Fn(&u32)->SomeFuture<'self>,
}
```
the above future might stop at the `some_future` state, and the `some_future` state is self-referenced. so if we use `&mut self` in the `poll` function, we can easily cause the self-reference problem. so the rust compiler uses `Pin` to solve this problem. `Pin` is a pointer that can't be moved, so we can use `Pin<&mut Self>` instead of `&mut Self` to avoid the self-reference problem.

extra: what if `Pin<&mut T>` and `T` are not self-referenced? In this case, we should be ok to use `&mut T`, but the rust compiler use `Pin<&mut T>` to make the code more general. Do we have a way to get a `&mut T`? The answer is yes, we can use `Pin::get_mut` to get a `&mut T` from a `Pin<&mut T>` if the T is `UnPin`. The future trait does not know the exact type of the future, so it needs to use `Pin<&mut Self>` to make the code more general. but in our implementation of the future trait, we can use `Pin::get_mut` to get a `&mut T` if the T is `UnPin`.
read `pin` to learn more about `Pin`. [pin](https://doc.rust-lang.org/std/pin/index.html); 