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

## Prefill stage

- modify the NeuPIMs to support prefill stage!