
# """
#     matrixdepot(name::String, G, x...)
#
# Returns a `(di)graph` of type `G` built after a call to `matrixdepot(name, x...[,:read])`.
#
# E.g.
    # g = matrixdepot("hilb", Graph, 4)
    # g = matrixdepot("baart", DiGraph, 4)
# """
function matrixdepot{G<:AGraph}(a::String, ::Type{G}, x...)
    a in matrixdepot("symmetric") || error("Valid matrix not found in collection")
    external = a in matrixdepot("data")
    m = external? matrixdepot(a, x..., :read) : matrixdepot(a, x...)
    m == nothing && error("Invalid matrix parameters specified")

    return G(m)
end

function matrixdepot{G<:ADiGraph}(a::String, ::Type{G}, x...)
    a in matrixdepot("all") || error("Valid matrix not found in collection")
    external = a in matrixdepot("data")
    m = external? matrixdepot(a, x..., :read) : matrixdepot(a, x...)
    m == nothing && error("Invalid matrix parameters specified")

    return G(m)
end
