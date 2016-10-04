# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `writegraph` function and
read with the `readgraph` function. Currently supported common graph formats are `gml, graphml, gexf, dot` and `Pajek .NET`.

```@autodocs
Modules = [FatGraphs]
Pages   = [ "persistence/common.jl"]
Private = false
```

## Examples

```julia
writegraph(STDOUT, g)
writegraph("mygraph.gml", g, :gml)
writegraph("mygraph.dot.gzip", g, :dot, compress=true)

g = readgraph("mygraph.dot.gzip", :dot)
g = readgraph("mygraphs.graphml", :graphml)
g = readgraph("mygraph.gml", :gml)
```
