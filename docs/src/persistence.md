# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `save` function and
read with the `load` function. Currently supported common graph formats are `gml, graphml, gexf, dot, net`.

```@autodocs
Modules = [LightGraphs]
Pages   = [ "persistence/common.jl"]
Private = false
```

## Examples

```julia
save(STDOUT, g)
save("mygraph.gml", g, "mygraph", :gml)

dg = load("multiplegraphs.graphml", :graphml)
dg = load("mygraph.gml", "mygraph", :gml)

g = laoadgraph("mygraph.gml",  :gml)

```
