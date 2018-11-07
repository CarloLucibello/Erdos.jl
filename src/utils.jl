"""
sample!([rng,] a, k; exclude = ())

Sample `k` element from array `a` without repetition and eventually excluding elements in `exclude`.
Pay attention, it changes the order of the elements in `a`.
"""
function sample!(rng::AbstractRNG, a::AbstractArray, k::Integer; exclude = ())
    length(a) < k + length(exclude) && error("Array too short.")
    res = Vector{eltype(a)}()
    sizehint!(res, k)
    n = length(a)
    i = 1
    while length(res) < k
        r = rand(rng, 1:n-i+1)
        if !(a[r] in exclude)
            push!(res, a[r])
            a[r], a[n-i+1] = a[n-i+1], a[r]
            i += 1
        end
    end
    res
end

sample!(a::AbstractArray, k::Integer; exclude = ()) = sample!(getRNG(), a, k; exclude = exclude)

getRNG(seed::Integer = -1) = seed >= 0 ? MersenneTwister(seed) : Base.Random.GLOBAL_RNG

# modified from http://stackoverflow.com/questions/25678112/insert-item-into-a-sorted-list-with-julia-with-and-without-duplicates
# returns true if insert succeeded, false if it was a duplicate
_insert_and_dedup!(v::Vector, x) = isempty(splice!(v, searchsorted(v,x), x))

function countfirst(itr, v)
    c = 0
    found = false
    @inbounds for x in itr
        c +=1
        x == v && (found=true; break)
    end
    return found ? c : 0
end

##############################################################3
# from Iterators.jl until the conflict with Base.Iterators is resolverd
"""
    nth(xs, n::Integer)

Return the n'th element of xs. Mostly useful for non indexable collections.
"""
function nth(xs, n::Integer)
    n > 0 || throw(BoundsError(xs, n))
    # catch, if possible
    applicable(length, xs) && (n ≤ length(xs) || throw(BoundsError(xs, n)))
    s = start(xs)
    i = 0
    while !done(xs, s)
        (val, s) = next(xs, s)
        i += 1
        i == n && return val
    end
    # catch iterators with no length but actual finite size less then n
    throw(BoundsError(xs, n))
end

nth(xs::AbstractArray, n::Integer) = xs[n]
# Filter out reccuring elements.

struct Distinct{I, J}
    xs::I

    # Map elements to the index at which it was first seen, so given an iterator
    # state (index) we can test if an element has previously been observed.
    seen::Dict{J, Int}
end

IteratorSize(::Type{T}) where {T<:Distinct} = SizeUnknown()

eltype(::Type{Distinct{I, J}}) where {I, J} = J

distinct(xs::I) where {I} = Distinct{I, eltype(xs)}(xs, Dict{eltype(xs), Int}())

function start(it::Distinct)
    start(it.xs), 1
end

function next(it::Distinct, state)
    s, i = state
    x, s = next(it.xs, s)
    it.seen[x] = i
    i += 1

    while !done(it.xs, s)
        y, t = next(it.xs, s)
        if !haskey(it.seen, y) || it.seen[y] >= i
            break
        end
        s = t
        i += 1
    end

    x, (s, i)
end

done(it::Distinct, state) = done(it.xs, state[1])

# Concatenate the output of n iterators
struct Chain{T<:Tuple}
    xss::T
end

IteratorSize(::Type{Chain{T}}) where {T} = _chain_is(T)

@generated function _chain_is(t::Type{T}) where T
    for itype in T.types
        if IteratorSize(itype) == IsInfinite()
            return :(IsInfinite())
        elseif IteratorSize(itype) == SizeUnknown()
            return :(SizeUnknown())
        end
    end
    return :(HasLength())
end

chain(xss...) = Chain(xss)

length(it::Chain{Tuple{}}) = 0
length(it::Chain) = sum(length, it.xss)

eltype(::Type{Chain{T}}) where {T} = typejoin([eltype(t) for t in T.parameters]...)

function start(it::Chain)
    i = 1
    xs_state = nothing
    while i <= length(it.xss)
        xs_state = start(it.xss[i])
        if !done(it.xss[i], xs_state)
            break
        end
        i += 1
    end
    return i, xs_state
end

function next(it::Chain, state)
    i, xs_state = state
    v, xs_state = next(it.xss[i], xs_state)
    while done(it.xss[i], xs_state)
        i += 1
        if i > length(it.xss)
            break
        end
        xs_state = start(it.xss[i])
    end
    return v, (i, xs_state)
end

done(it::Chain, state) = state[1] > length(it.xss)

#################


# myrand(a::AbstractArray) = a[_myrand(length(a))]

# for generic iterables with length
myrand(itr) = nth(itr, _myrand(length(itr)))

_myrand(n::T) where {T<:Integer} = ceil(T, rand() * n)

# to seed the R generator called by randbinomial  
seed_dsfmt(seed) =
    Random.DSFMT.dsfmt_gv_init_by_array(MersenneTwister(seed).seed+UInt32(1))

randbinomial(m::Integer,p::AbstractFloat) =
    convert(Int, StatsFuns.RFunctions.binomrand(m, p))


#used in flow and dismantling
struct GreaterThan2 end
struct LessThan2 end
compare(c::GreaterThan2, x, y) = x[2] > y[2]
compare(c::LessThan2, x, y) = x[2] < y[2]


signedtype(::Type{T}) where {T<:Integer} = typeof(signed(T(0)))
signedtype(::Type{T}) where {T<:AbstractFloat} = T
