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
_insert_and_dedup!(v::Vector{Int}, x::Int) = isempty(splice!(v, searchsorted(v,x), x))

function countfirst(itr, v)
    c = 0
    found = false
    @inbounds for x in itr
        c +=1
        x == v && (found=true; break)
    end
    return found ? c : 0
end
