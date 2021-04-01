# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `writegraph` function and
read with the `readgraph` function. Currently supported common graph formats are
[GraphML](http://en.wikipedia.org/wiki/GraphML), [GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [Gexf](http://gexf.net/format), [DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [Pajek .net](http://gephi.org/users/supported-graph-formats/pajek-net-format/),
[graph-tool gt](https://graph-tool.skewed.de/static/doc/gt_format.html).
If fast I/O and small memory footprint is a priority, use the `.gt` binary format.

For network types, when using appropriate formats (e.g. `.gml`, `.graphml`, `.gexf`) properties of graph, vertices, and edges  will be read/written as well.

## Examples

```jldoctest
julia> g = Graph(10, 20)
Graph{Int64}(10, 20)

julia> writegraph("mygraph.gml", g) #format is inferred from the extension

julia> h = readgraph("mygraph.gml")
Graph{Int64}(10, 20)

julia> g == h
true

julia> g = Network(10, 20)
Network(10, 20) with [] graph, [] vertex, [] edge properties

julia> gprop!(g, "A", rand());

julia> eprop!(g, "B", EdgeMap(g, e -> rand()));

julia> vprop!(g, "C", VertexMap(g, v -> rand()));

julia> writenetwork("mygraph.gml", g) #format is inferred from the extension

julia> h = readnetwork("mygraph.gml")
Network(10, 20) with ["A"] graph, ["C"] vertex, ["B"] edge properties

julia> g == h
true
```

## Methods

```@autodocs
Modules = [Erdos]
Pages   = [ "persistence/common.jl"]
Private = false
```
