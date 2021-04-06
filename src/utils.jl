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
    return res
end

sample!(a::AbstractArray, k::Integer; exclude = ()) = sample!(getRNG(), a, k; exclude = exclude)

getRNG(seed::Integer = -1) = seed >= 0 ? MersenneTwister(seed) : Random.GLOBAL_RNG

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

# for generic iterables with length
myrand(itr) = nth(itr, rand(1:length(itr)))

#used in flow and dismantling
struct GreaterThan2 <: Base.Order.Ordering end
Base.Order.lt(c::GreaterThan2, x, y) = x[2] > y[2]

struct LessThan2 <: Base.Order.Ordering end
Base.Order.lt(c::LessThan2, x, y) = x[2] < y[2]


signedtype(::Type{T}) where {T<:Integer} = typeof(signed(T(0)))
signedtype(::Type{T}) where {T<:AbstractFloat} = T
