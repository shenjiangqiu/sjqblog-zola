+++
[taxonomies]
tags = ["rust", "tokio"]
authors = ["Jiangqiu Shen"]
+++
This post shows how to simulate prefill and generation stage in NeuPIMs.

current NeuPIMs only support generate 1 token.


- the orca mode: when to prefill and when to generate.
- when new reqeust arrived, can the current generation stage cover the prefill stage?
- how to simulate different seq len efficiently?
<!-- more -->
# implement Prefill + generation stage in NewPIMs.

## modification of the main function
### current main function
- current main function read the tracefile and simulate the generation stage.
- the tracefile only contains the input len and the channel id.
### expected main function
- read the real tracefile: shareGPT and simulate the ORCA mode.
- dynamic assign the requests to channels.
- simulate the situation when a request ended in generation stage and new request arrived.
- simulate the generation stage for differnt output len.
### modifications
- [x] change the tracefile format. it should generated from real tracefile.
  - [x] analyze the tracefile: ShareGPT
- [ ] in main function, generate the inital prefill task and an initial generation task.
- [ ] generate a several generation tasks until any of the task is finished.
  - [ ] for each generation task, the PIM rows should be different(that is, if the row didnot change, reuse the previous row result).
- [ ] simulate the new arrived prefill, see if it can be covered by the last generation stage.(accumulated prefill time and accumulated generation time)
## Prefill stage

- [ ] modify the NeuPIMs to support prefill stage!
  - [ ] support the Q with size > 1
  - [ ] support the program that generate code for MHA 
  - [ ] support the program support QKV gen for each request.
  - [ ] support the program FFN for each request.
  - [ ] support Projection.


## Analysis ShareGPT tracefile
- Total tasks: 723670
- Average generation history: 6735
- Average prefill history: 6725
- Average generation history weighted: 7353
- Average prefill history weighted: 9048
- Average generation size: 222
- Average prefill size: 59

- the average generation size is 222, the batch size is 512, so for each iteration, there might be 2 prifill task come in.
- the average prefill size is 59, the average perfill history is 9048.
- the average generation size is 222, the average generation history is 7353.
- for each iteration, the the batch size is 512, the history is 7353, so the total computation is QKVGEN + 2 * MHA + 2 *FFN. =
-  512 * 4096 * 4096 * 3 + 7353*4096*512*2 + 512 * 4096 * 4 * 4096 *2
- = 125329997824
- for each prefill task, the computation is QKVGEN + MHA + FFN =
-  59 * 4096 * 4096 * 3 + 59 * 4096 * 9048*2 + 59 * 4096 * 4 * 4096 * 2
- = 15261564928
- the prefill time is much smaller than the generation time. so the prefill time can be ignored.

