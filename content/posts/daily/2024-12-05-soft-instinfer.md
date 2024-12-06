+++

[taxonomies]
tags = ["llm", "pim","accelerator"]
authors = ["Jiangqiu Shen"]
+++

## [SOFA: A Compute-Memory Optimized Sparsity Accelerator via Cross-Stage Coordinated Tiling](/pdf/sofa.pdf)

### Motivation

1.	Bottlenecks in Transformers: As sequence lengths increase, the attention module becomes the dominant bottleneck in Transformer-based inference, surpassing the feed-forward network (FFN).
2.	Limitations of Existing Sparse Accelerators:

    -	Current accelerators struggle with the demands of high-throughput and large-scale token parallelism.
    -	They focus on stage-wise optimization, leading to inefficiencies in memory access and computation.

### Proposed Solution: SOFA

SOFA addresses the above challenges using a cross-stage compute-memory optimized approach:
1.	Differential Leading Zero Summation (DLZS): A novel multiplier-free, log-based computation paradigm to predict sparsity efficiently, significantly reducing overhead during the pre-compute stage.
2.	Sphere-Search Aided Distributed Sorting (SADS): Divides sequences into sub-segments for lightweight sorting, minimizing comparisons and enabling fine-grained tiling.
3.	Sorted-Updating FlashAttention (SU-FA): Reduces the computational cost of softmax and attention updates by leveraging cross-stage tiling and distributed sorting information.

### flashattention

![flashattention](/img/flashatt.png)
![flashattention2](/img/falshatt_paper.png)
- in line5, it update the max of the scores of m_i
- in line7, 
## [instinfer](/pdf/instinfer.pdf)