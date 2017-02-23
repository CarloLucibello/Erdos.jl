# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `writegraph` function and
read with the `readgraph` function. Currently supported common graph formats are
[GraphML](http://en.wikipedia.org/wiki/GraphML), [GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [Gexf](http://gexf.net/format), [DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [Pajek .net](http://gephi.org/users/supported-graph-formats/pajek-net-format/),
[graph-tool gt](https://graph-tool.skewed.de/static/doc/gt_format.html)


## Examples

```julia
writegraph("mygraph.gml", g) #format is inferred by the name
writegraph("mygraph.graphml", g)

g = readgraph("mygraph.dot")
g = readgraph("mygraph.net")
```

```@autodocs
Modules = [Erdos]
Pages   = [ "persistence/common.jl"]
Private = false
```
