"""
    circular_layout(g) -> x, y

Return two vectors representing the positions of the nodes of graph `g` 
when placed on the unit circonference of radius one centered at the origin.
"""
function circular_layout(g::AGraphOrDiGraph)
    # Discard the extra angle since it matches 0 radians.
    θ = range(0, stop=2pi, length=nv(g)+1)[1:end-1]
    return cos.(θ), sin.(θ)
end

"""
    spring_layout(g; 
                  k = 1 / √nv(g),
                  maxiter = 100,
                  inittemp = 2.0,
                  [x0, y0]) -> x, y

Return the positions of the nodes in graph `g` according to 
Fruchterman and Reingold's spring/repulsion model.
The forces as function of the distance `d` beetween two nodes 
are given by

    f_a(d) =  d / k # attractive force
    f_r(d) = -k^2 / d^2 # repulsive force:  

`maxiter` is the number of updates of the positions. 
`inittemp` controls displacement per iteration.

Initial positions can passed though the argument `x0` and `y0`.

The positions are rescaled to fit the [-1, +1]^2 box. 

This function is adapted from [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl).
"""
function spring_layout(g::AGraphOrDiGraph;
                       x0 = 2*rand(nv(g)) .- 1.0,
                       y0 = 2*rand(nv(g)) .- 1.0,
                       k = 1/√nv(g),
                       maxiters = 100,
                       inittemp = 2.0)

    x = copy(x0)
    y = copy(y0)
    nvg = nv(g)
    adj_matrix = adjacency_matrix(g)
    k² = k * k

    # Store forces and apply at end of iteration all at once
    force_x = zeros(nvg)
    force_y = zeros(nvg)

    # Iterate MAXITER times
    @inbounds for iter = 1:maxiters
        # Calculate forces
        for i = 1:nvg
            force_vec_x = 0.0
            force_vec_y = 0.0
            for j = 1:nvg
                i == j && continue
                d_x = x[j] - x[i]
                d_y = y[j] - y[i]
                dist²  = (d_x * d_x) + (d_y * d_y)
                dist = sqrt(dist²)

                if !(iszero(adj_matrix[i,j]) && iszero(adj_matrix[j,i]) )
                    # Attractive + repulsive force
                    # F_d = dist² / k - k² / dist # original FR algorithm
                    F_d = dist / k - k² / dist²
                else
                    # Just repulsive
                    # F_d = -k² / dist  # original FR algorithm
                    F_d = -k² / dist²
                end
                force_vec_x += F_d * d_x
                force_vec_y += F_d * d_y
            end
            force_x[i] = force_vec_x
            force_y[i] = force_vec_y
        end
        # Cool down
        temp = inittemp / iter
        # Now apply them, but limit to temperature
        for i = 1:nvg
            fx = force_x[i]
            fy = force_y[i]
            force_mag  = sqrt((fx * fx) + (fy * fy))
            scale      = min(force_mag, temp) / force_mag
            x[i] += force_x[i] * scale
            y[i] += force_y[i] * scale
        end
    end

    # Scale to unit square
    min_x, max_x = minimum(x), maximum(x)
    min_y, max_y = minimum(y), maximum(y)
    function scaler(z, a, b)
        2.0*((z - a) / (b - a)) - 1.0
    end
    map!(z -> scaler(z, min_x, max_x), x, x)
    map!(z -> scaler(z, min_y, max_y), y, y)

    return x, y
end

"""
    shell_layout(g, nlist) -> x, y

Position the nodes of `g` in concentric circles.

`nlist` is a vector of vectors containing the nodes
for each shell.
"""
function shell_layout(g::AGraphOrDiGraph, nlist::Vector{Vector{T}}) where T<:Integer
    if nv(g) == 1
        return [0.0], [0.0]
    end
    radius = length(nlist[1]) > 1 ? 1.0 : 0.0
    x = Float64[]
    y = Float64[]
    for nodes in nlist
        θ = range(0, stop=2pi, length=length(nodes)+1)[1:end-1]
        append!(x, radius * cos.(θ))
        append!(y, radius * sin.(θ))
        radius += 1.0
    end
    return x, y
end

