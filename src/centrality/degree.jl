function _degree_centrality(g::ASimpleGraph, gtype::Integer; normalize=true)
   n_v = nv(g)
   c = zeros(n_v)
   for v in 1:n_v
       if gtype == 0    # count both in and out degree if appropriate
           deg = out_degree(g, v) + (is_directed(g) ? in_degree(g, v) : 0.0)
       elseif gtype == 1    # count only in degree
           deg = in_degree(g, v)
       else                 # count only out degree
           deg = out_degree(g, v)
       end
       s = normalize? (1.0 / (n_v - 1.0)) : 1.0
       c[v] = deg*s
   end
   return c
end

# TODO avoid repetition of this docstring
"""Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of the graph `g`, with optional (default) normalization."""
degree_centrality(g::ASimpleGraph; kws...) = _degree_centrality(g, 0; kws...)
"""Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of the graph `g`, with optional (default) normalization."""
in_degree_centrality(g::ASimpleGraph; kws...) = _degree_centrality(g, 1; kws...)
"""Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of the graph `g`, with optional (default) normalization."""
out_degree_centrality(g::ASimpleGraph; kws...) = _degree_centrality(g, 2; kws...)
