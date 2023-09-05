+++
[taxonomies]
tags = ["GPT","transformers","accelerators"]
authors = ["Jiangqiu Shen"]
+++

this post summarizes the recent progress of GPT-3 and its accelerators.

the papers included:

- Att is all you need [paper](/pdf/attAllYouNeed.pdf)
- Orca, [paper](/pdf/osdi22-yu.pdf)
- Fast Distributed Inference Serving for Large Language Models, [paper](/pdf/FastDist.pdf)
- DeepSpeed, [paper](/pdf/deepspeed.pdf)
- FlexGen High-throughput Generative Inference of Large Language Models with a Single GPU;   [paper](/pdf/flashgen.pdf)
- AttentionFlash, [paper](/pdf/FlashAtt.pdf)
- LightSeq2, [paper](/pdf/LightSeq2.pdf)
- FLAT.[paper](/pdf/Flat.pdf)
- Tabi: An Efficient Multi-Level Inference System for Large Language Models, 
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
### Specinfer

datasets: use the prompts/questions from these datasets to form our input prompts to simulate the real-world conversation trace

- Chatbot Instruction Prompts [link](https://huggingface.co/datasets/alespalla/chatbot_instruction_prompts)
- Chatgpt Prompts [link](https://huggingface.co/datasets/MohamedRashad/ChatGPT-prompts)
- WebQA 
- Alpaca [link](https://huggingface.co/datasets/vicgalle/alpaca-gpt4)
- PiQA [link](https://huggingface.co/datasets/piqa)



## Attation is all you need
