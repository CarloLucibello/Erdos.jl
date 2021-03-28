using Documenter
using Erdos

# Copy the list of features from the README to the
# Getting Started page in docs, to avoid duplication.
readme = readlines("README.md")
indexbase = readlines("docs/src/indexbase.md")
idx_features = findfirst(==("## Features"), readme) + 1
open("docs/src/index.md", "w") do f
    for l in indexbase
        println(f, l)
    end
    for l in readme[idx_features:end]
        println(f, l)
    end
end

cp("datasets/README.md", "docs/src/datasets.md", force=true)

makedocs(
    modules     = [Erdos],
    format      = Documenter.HTML(), 
    sitename    = "Erdos",
    doctest     = false,
    pages       = Any[
        "Getting Started" => "index.md",
        "Graph Types" => "graph_types.md",
        "Basic Interface" => "core.md",
        "Edge And Vertex Maps" => "maps.md",
        "Network Types" => "network_types.md",
        "Property Interface for Networks" => "network_interface.md",
        "Operators" => "operators.md",
        "Traversals" => "traversals.md",
        "Distance" => "distance.md",
        "Shortest Paths" => "shortestpaths.md",
        "Linear Algebra" => "linalg.md",
        "Reading / Writing Graphs" => "persistence.md",
        "Graph Datasets" => "datasets.md",
        "Deterministic Graphs" => "deterministicgraphs.md",
        "Random Graphs" => "randomgraphs.md",
        "Centrality Measures" => "centrality.md",
        "Community Structures" => "community.md",
        "Flow and Cut" => "flow.md",
        "Matching" => "matching.md",
        "Dismantling" => "dismantling.md",
        "Spanning Trees" => "spanningtrees.md",
    ]
)

deploydocs(
    repo   = "github.com/CarloLucibello/Erdos.jl.git",
    target = "build"
)
