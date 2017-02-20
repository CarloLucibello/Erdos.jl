function parsenode(f::IO)
    d = Dict{Any,Any}()
    i = 0
    while true
        line = readline(f)
        println(line)
        if line == "" || endswith(line,'}')
            return d
        end
        if endswith(line,'{')
            d[line] = parsenode(f)
        else
            d[i] = line
            i+=1
        end
    end
    return d #never gets here
end


function readdot(str::String)
    f = open(str,"r")
    d = Dict{Any,Any}()
    d["root"] = parsenode(f)
    close(f)
    return d
end
