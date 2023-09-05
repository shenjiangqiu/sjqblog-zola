+++
[taxonomies]
tags = ["GPT","transformers","accelerators"]
authors = ["Jiangqiu Shen"]
+++

this post summarizes the recent progress of GPT-3 and its accelerators.

the papers included:

- Att is all you need [paper](/pdf/attAllYouNeed.pdf)
- Orca, [paper](/pdf/osdi22-yu.pdf)
    - important background:
        1. current serving system cannot handle iterative model efficiently
        2. current model excute the request at the granularity of request
    - chanllenges:
        1. Early finished and late joining for existing system
        2. batch forming: the iteration selection is not easy
    - summary:
        1. schedule at the granularity of iteration!
        2. selective batch forming.

- Fast Distributed Inference Serving for Large Language Models, [paper](/pdf/FastDist.pdf)
    - important background:
        1. the job completion time is important, so FCFS in orca is not good enough
    - summary:
        1. decide to continue or preempt it with another job based on the output
        2. first into a high priority queue, if not complete, go to the low priority queue

- DeepSpeed, [paper](/pdf/deepspeed.pdf)
    - summary:
        a system for single GPU, multi-GPU, and massive gpu

- FlexGen High-throughput Generative Inference of Large Language Models with a Single GPU;   [paper](/pdf/flashgen.pdf)
    - summary:
        - efficient offloading strategies on a single GPU machine.
- AttentionFlash, [paper](/pdf/FlashAtt.pdf)
    - problem:
        - perviouse paper ignore the memory pattern: the fast on-chip sram and offchip memory
    - summary:
        - instead compute all attention, compute a block of attention to reduce the memory for backpropagation
        - use softmax normalization factor to quickly recompute the attention instead of read them from HBM

- LightSeq2, [paper](/pdf/LightSeq2.pdf)

- FLAT.[paper](/pdf/Flat.pdf)
- Tabi: An Efficient Multi-Level Inference System for Large Language Models, 
- H2O [paper](/pdf/H2O.pdf)
    - important background:
        1. the KV cache is too big
        2. the KV cache are sparse(only 5% of the key-value pairs are used)

    - summary:
        1. Cannot remove H2(Heavy-hitter)
        2. use a gready algorithm in each decoding step to find out the H2
- Olive:[paper](/pdf/OliVe-%20Accelerating%20Large%20Language%20Models%20via%20Hardware-friendly%20Outlier-Victim%20Pair%20Quantization(ISCA23).pdf)
    - important background:
        1. the outliar is more important so need to use more bits to quantize it
        2. if to keep the outliar, the memory layout is influenced
    - summary:
        1. victim some normal values adjacent to the outliar
        2. the pair are still aligned in the memory

- TaskFusion:[paper](/pdf/TaskFusion-%20An%20Efficient%20Transfer%20Learning%20Architecture%20with%20Dual%20Delta%20Sparsity%20for%20Multi-Task%20Natural%20Language%20Processing(ISCA23).pdf)


<!-- more -->

## in memory
- TransPIM: A Memory-based Acceleration via Software-Hardware Co-Design for Transformer [paper](/pdf/TransPIM.pdf)
- Unleashing the Potential of PIM: Accelerating Large Batched Inference of Transformer-Based Generative Models [paper](/pdf/Unleashing.pdf)
- FACT [paper](/pdf/FACT.pdf)
- DFX [paper](/pdf/DFX.pdf)



## Benchmarks

### light2seq [paper](/pdf/LightSeq2.pdf)
- WMT14 for translation, model: Transformer, Fairseq with Apex optimization. Encoder + Decoder 
    - link: [link](https://huggingface.co/datasets/wmt14)
    - usage:
        ```python
        from datasets import inspect_dataset, load_dataset_builder

        inspect_dataset("wmt14", "./datasets")

        # %%
        import datasets

        builder = load_dataset_builder(
            "./datasets/wmt_utils.py",
            language_pair=("fr", "de"),
            subsets={
                datasets.Split.TRAIN: ["commoncrawl_frde"],
                datasets.Split.VALIDATION: ["euelections_dev2019"],
            },
        )
        builder.download_and_prepare()
        ds = builder.as_dataset()
        ```
- CIFAR-10 for image classification, model: ViT, Only Encoder
- GLUE for text classification, model: Only Encoder
- WIKITEXT for language modeling, model: Only Decoder
    - link: [link](https://huggingface.co/datasets/wikitext)
    - uasge:
        ```python
            from datasets import load_dataset, Audio

            dataset = load_dataset("wikitext", "wikitext-2-v1")
        ```
### S3, ncreasing GPU Utilization during Generative Inference for Higher Throughput [paper](/pdf/S3.pdf)
- Alpaca
    - url: [link](https://huggingface.co/datasets/vicgalle/alpaca-gpt4)
    - usage:
        ```python
        from datasets import load_dataset

        dataset = load_dataset("vicgalle/alpaca-gpt4", "alpaca")
        ```
### H2O, High-throughput Hardware for Large-scale Language Models [paper](/pdf/H2O.pdf)
- OPT,LLaMA,GPT-neoX-20B
    - COPA [link](https://huggingface.co/datasets/pkavumba/balanced-copa)
    - MathQA [link](https://huggingface.co/datasets/math_qa)
    - OpenBookQA [link](https://huggingface.co/datasets/openbookqa)
    - PiQA [link](https://huggingface.co/datasets/piqa)
    - RTE [glue](https://huggingface.co/datasets/glue/viewer/rte/train)
        - example:
            ```python
            from datasets import load_dataset

            dataset = load_dataset("glue", "rte")
            ```
    - Winogrande [winogrande](https://huggingface.co/datasets/winogrande)
    - XSUM [xsum](https://huggingface.co/datasets/xsum)
    - CNN/Daily Mail [cnn_dailymail](https://huggingface.co/datasets/cnn_dailymail)
### Specinfer[paper](/pdf/SpecInfer.pdf)

datasets: use the prompts/questions from these datasets to form our input prompts to simulate the real-world conversation trace

- Chatbot Instruction Prompts [link](https://huggingface.co/datasets/alespalla/chatbot_instruction_prompts)
- Chatgpt Prompts [link](https://huggingface.co/datasets/MohamedRashad/ChatGPT-prompts)
- WebQA 
- Alpaca [link](https://huggingface.co/datasets/vicgalle/alpaca-gpt4)
- PiQA [link](https://huggingface.co/datasets/piqa)

## Model implementations
- Llama:
    -  official [link](https://github.com/facebookresearch/llama/blob/main/llama/generation.py)
- OPT
    - official [link](https://github.com/facebookresearch/metaseq/tree/main/projects/OPT)
- GPT-Neox
    - official [link](https://github.com/EleutherAI/gpt-neox)
- GPT-2
    - openai [link](https://github.com/openai/gpt-2)


## Attation is all you need
