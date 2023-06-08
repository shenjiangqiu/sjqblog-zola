+++
description = "Heterogeneous Graph Neural Networks"
[taxonomies]
tags = ["gnn", "graph","hgnn","machine learning"]
+++
this post is about heterogeneous graph neural networks. related paper :[METANMP](/pdf/METANMP.pdf).
## Heterogeneous Graph Neural Networks
a heterogeneous graph is a graph that has different types of nodes and edges. for example, a social network graph can be a heterogeneous graph, it has different types of nodes: user, post, comment, etc. and different types of edges: user-user, user-post, user-comment, etc.
## the Features of HGNN
We summarize the characteristics of HGNNs as follows:
- Distinct Feature Dimensions. Different types of vertices and
edges in a heterogeneous graph have different dimensions
on their features.
- Metapath-based Aggregation. Traditional GNNs directly aggregate information based on the vertex’s neighbors, while
HGNNs leverage metapath instances to aggregate richer
structural and semantic information.
- Multi-level Aggregation. Traditional GNNs contain only one
aggregation and one combination in each layer. HGNNs
include structural (intra-metapath) and semantic aggregation
(inter-metapath).

## the workflow of METANMP
it use [roofline-model](@/posts/research/2023-06-07-roofline_model.md) to find the bottleneck of the model, and then optimize the bottleneck. We can see that both structural aggregation and semantic aggregation are memory bottlenecks, except for the feature projection being compute-intensive

### 3.1 Metapath Instance Generation via Cartesian
### 3.2 Relevant Metapath Instance Awareness
- ![reuse](/img/reuse.png)
- Redundant Computation Elimination. 

When a vertex in the
defined metapath has multiple type-matched neighbors, it scatters
out multiple metapath instances that exist redundant computation
among them. For example, ②-③ is sub-metapath instance for metapath A-B-A in Figure 6. The vertex ③ has three type-A neighbors,
so it can generate three instances, all of which contain redundant
computations for aggregating the vertices ② and ③. If we aggregate each instance independently, it is difficult to capture these
redundant computations, requiring significant detection overhead.
To efficiently eliminate redundant aggregation of these relevant
instances, we use a simple yet effective relevant instance-aware approach where each instance can be naturally exploited for shareable
computation during metapath instance generation. We inspect all
dependencies (a dependency contains at least two vertices) starting
from vertices of the first type in the metapath, and vertices on a dependency are aggregated directly. Once multiple sub-dependencies
are scattered from a dependency, that is, multiple instances are
generated. The previously aggregated result can be shared by these
metapath instances. We further illustrate this with the example
in Figure 6. At the beginning, we inspect all dependencies along
the vertex ②. The vertex ③ is a path along the vertex ② out of
the match type (③ and ② form a dependency), and we complete
the vertex aggregation on them. When we then match vertex ③’s
type-matched neighbor vertices along the metapath, we find that
it has multiple type-matched neighbors, which results in multiple
metapath instances and brings shareable aggregation computation
opportunity. The result of previous aggregation is then shared to
these metapath instances.
- Instance-driven Aggregation.

 Existing methods construct subgraphs to represent relevant metapath instances for each vertex
by pre-processing. They ignore the information carried by the instance itself. The first vertex of each meta-path instance implicitly
indicates which vertex they belong to. Therefore, instead of aggregating these related metapath instances using the gather-centered
approach based on subgraphs, it is more efficient to drive the aggregation by metapath instance itself
### 3.3 Near-Memory Processing