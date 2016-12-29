abstract AVertexMap{T}

eltype{T}(m::AVertexMap{T}) = Pair{Int, T}
valtype(m::AVertexMap{T}) = T

abstract AAssociativeVertexMap{T} <: AVertexMap{T}
typealias AAVM AAssociativeVertexMap{T}

#################
type VertexMap{G,T} <: AAVM
    g::G
    data::Dict{Int,T}

    VertexMap(g::G, data::Dict{Int,T}=Dict{Int,T}()) = new(g, data)
end

type DefaultVertexMap{G,T} <: AAVM
    g::G
    data::DefaultDict{Int,T}

    DefaultVertexMap(g::G, x::T) = new(g, DefaultDict(x, Dict{Int,T}()))
end

typealias VM1 Union{VertexMap, DefaultVertexMap}

@inline length(m::VM1) = length(m.data)
@inline get(m::VM1, i::Int, x) = get(m.data, i, x)

@inline getindex(m::VM1, i::Int) = getindex(m.data, i)
@inline setindex!(m::VM1, val, i::Int) = setindex!(m.data, val, i)
@inline haskey(m::VM1, i::Int) = haskey(m.data, i)

@inline start(m::VM1) = start(m.data)
@inline next(m::VM1, state) = state(m.data, state)
@inline done(m::VM1, state) = done(m.data, state)

################



###########

type ConstVertexMap{G,T} <: AAVM
    g::G
    data::T

    ConstVertexMap(data::T)
end
##########
