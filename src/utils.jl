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

# from Iterators.jl
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


# myrand(a::AbstractArray) = a[_myrand(length(a))]

# for generic iterables with length
myrand(itr) = nth(itr, _myrand(length(itr)))

_myrand{T<:Integer}(n::T) = ceil(T, rand() * n)

#used in flow and dismantling
# immutable GreaterThan2 end
# immutable LessThan2 end
# DataStructures.compare(c::GreaterThan2, x, y) = x[2] > y[2]
# DataStructures.compare(c::LessThan2, x, y) = x[2] < y[2]
