+++


description = "Heterogeneous Graph Neural Networks"
[taxonomies]
tags = ["gnn", "graph","hgnn","machine learning"]
authors = ["Jiangqiu Shen"]

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
## my example of graph
- ![graph](/img/nmp.png)

1. the graph:
  - ![graph](/img/nmp-graph.png)
  - frist round it will generate these instance:
  - (a1,a2) - b1 - (c1,c2) = (a1 - b1 - c1),(a1 - b1 - c2),(a2 - b1 - c1),(a2 - b1 - c2)
  - (a3) - b2 - (c3)
  - (a2) - b3 - (c2)
  - there are total 6 instance, 3 in the frist dimm, 3 in the second dimm,marked as t1-t6
  - t1 = (a1 - b1 - c1)
  - t2 = (a1 - b1 - c2)
  - t3 = (a2 - b1 - c1)
  - t4 = (a2 - b1 - c2)
  - t5 = (a3 - b2 - c3)
  - t6 = (a2 - b3 - c2)
  - when go to stage 2 there need some computation:
  - the core vertex is now d1,d1,d3,
  - (t1,t2,t3,t4,t6) - d1 - e1
  - (t1,t3,t5) - d2 - e2
  - (t1,t3,t5) - d3 - e3
2. the analysis
   1. how to find the related t when make d as the core vertex?
      in this paper, this is not mentioned, we can assume a simple method: to create a vertual node named T and creat the vertual edge between T and D. 
   2. so the question is: how and when to create the edge, and what infomation needed? we can create the edge when we create the instance. like when we create the instance t1 = (a1 - b1 -c1), we go through the edge list of all c1's neighbors, and add the instance address and the start vertex(a1) to the edge list. the address is used to load the data, the start vertex is used to decide which DIMM to load the data. ( it might be a overhead, because for each instance generated, we need to write all it's neighbor's edge list!!)
   3. the total number of aggregation times in this example:
      1. stage 1: 6 instance, 2 + 1 +2 +1 +2 +2 = 10
      2. stage 2: 5 + 3 + 3 = 11
      3. total: 23
   4. the total number of aggregation times whith no data reuse: the total number of instance = 11. each instance need 4 times aggregation, so the total number of aggregation times = 44
   5. total saved times = 44 - 23 = 21
   6. the optimal time should be: 23 for this graph.
3. the problems:
   1. the edge list modification
   2. the inbanlance
   3. the inefficiency of the reuse the instance result
      when the struct contains duplicated path. like A B C B A (which is common). there are alot of duplicated instance and temp result.
