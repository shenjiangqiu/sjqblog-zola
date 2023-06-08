+++

[taxonomies]
authors = ["Jiangqiu Shen"]
tags = ["research", "pim","gearbox","fulcrum","spmv"]
+++



rethink the spmspm in memory, the backgrouds, challenges, and possible solutions.

# background
## spmspm workflow
### Gamma:
>Gamma performs SpMSpM's computation using specialized processing elements with simple high-radix mergers, and performs many merges in parallel to achieve high throughput. Gamma uses a novel on-chip storage structure that combines features of both caches and explicitly managed buffers. Gamma uses simple processing elements (PEs) that linearly combine sparse input rows to produce each output row. Gamma's processing elements are organized into a two-level hierarchy, with a small number of high-radix PEs at the top level and a larger number of low-radix PEs at the bottom level. The top-level PEs perform a small number of high-radix merges, while the bottom-level PEs perform many low-radix merges in parallel. Gamma's on-chip storage structure is organized into a hierarchy of caches and explicitly managed buffers, with each level of the hierarchy storing a different subset of the input and output matrices (research.nvidia.com)
  (dl.acm.org)
  (people.csail.mit.edu)


### row wise algorithm
> The Gustavson algorithm is a row-wise algorithm for sparse matrix-matrix multiplication. In this algorithm, each nonzero value in a row is multiplied by the nonzero values corresponding to the column index. These values are summed and stored in a temporary row buffer based on their column indices (bing.com)


## Gamma details

