## v0.1 (changes from LigtGraphs 0.7.1)
- Edge is now its own type (not a Pair{Int,Int} anymore)
- drop lg graph format
- add Changelog
- remove member `vertices` from graph types
- remove graphmatrices (LinAlg submodule)
- bring in Matching, Interdiction, MatrixDepot, Community from LightGraphExtras
- change name to FatGraphs
- improved docs
- [I/O] drop support for multiple graphs and renamse save/load to readgraph/writegraph
