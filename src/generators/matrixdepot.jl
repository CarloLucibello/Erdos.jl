
"""
    MDGraph(name::String, x...)

Returns a `Graph` built after a call to `matrixdepot(name, x...[,:read])`.
"""
function MDGraph(a::String, x...)
    a in matrixdepot("symmetric") || error("Valid matrix not found in collection")
    external = a in matrixdepot("data")
    m = external? matrixdepot(a, x..., :read) : matrixdepot(a, x...)
    m == nothing && error("Invalid matrix parameters specified")

    return Graph(m)
end

"""
    MDDiGraph(name::String, x...)

Returns a `DiGraph` built after a call to `matrixdepot(name, x... [,:read])`.
"""
function MDDiGraph(a::String, x...)
    a in matrixdepot("all") || error("Valid matrix not found in collection")
    external = a in matrixdepot("data")
    m = external? matrixdepot(a, x..., :read) : matrixdepot(a, x...)
    m == nothing && error("Invalid matrix parameters specified")

    return DiGraph(m)
end
