# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `writegraph` function and
read with the `readgraph` function. Currently supported common graph formats are
[GraphML](http://en.wikipedia.org/wiki/GraphML), [GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [Gexf](http://gexf.net/format), [DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [Pajek NET](http://gephi.org/users/supported-graph-formats/pajek-net-format/),
[graph-tool gt](https://graph-tool.skewed.de/static/doc/gt_format.html)


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
