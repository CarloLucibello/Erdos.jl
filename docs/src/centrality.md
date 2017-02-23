# Centrality Measures

[Centrality measures](https://en.wikipedia.org/wiki/Centrality) describe the
importance of a vertex to the rest of the graph using some set of criteria.
Centrality measures implemented in *Erdos.jl* include the following:


```@index
Order = [:type, :function]
Pages   = ["centrality.md"]
```

```@autodocs
Modules = [Erdos]
Pages   = [
            "centrality/betweenness.jl",
            "centrality/closeness.jl",
            "centrality/degree.jl",
            "centrality/katz.jl",
            "centrality/pagerank.jl",
            "centrality/kcore.jl"
            ]
Private = false
```
