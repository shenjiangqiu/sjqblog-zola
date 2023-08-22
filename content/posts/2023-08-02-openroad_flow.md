
+++
title = "OpenRoad script flow"
[taxonomies]
tags = ["openroad"]
authors = ["Jiangqiu Shen"]
+++

this post contains the installation and usage tips of OpenRoad flow.

<!-- more -->


## installation
1. clone the repo 
```bash
git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
```
2. build the docker image
```bash
cd OpenROAD-flow-scripts
./build_openroad.sh --os=ubuntu22.04
```
3. run the docker image
```bash
docker run --rm -it -u 1000:1000 -v $(pwd)/flow:/OpenROAD-flow-scripts/flow openroad/flow-ubuntu22.04-builder
```

here is a justfile for help:
```justfile
run-docker:
    docker run --rm -it -u 1000:1000 -v $(pwd)/flow:/OpenROAD-flow-scripts/flow openroad/flow-ubuntu22.04-builder
build-docker:
    ./build_openroad.sh --os=ubuntu22.04
```
