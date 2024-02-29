
function reactive_path(xi::AbstractVector, coords::Matrix, sigma; method=QuantilePath(0.05))
    #=if method == :quantile
        eps = max(quantile(xi, q), 1 - quantile(xi, 1 - q))
        from = findall(xi .< eps)
        to = findall(xi .> 1 - eps)
    elseif method == :full
        from = 1
        to = length(xi)
    elseif isa(method, FromToPath)
        from = method.s1
        to = method.s2
    end
    =#
    xi = Flux.cpu(xi)

    from, to = fromto(method, xi)

    ids, = shortestchain(coords, xi, from, to; sigma)

    path = coords[:, ids]
    return ids, path
end

# find path from s1 to s2
struct FromToPath
    s1::Int
    s2::Int
end

# find a path between the top and bottom q percentile of xi
struct QuantilePath
    q::Float64
end

# find a path between the first and last frame
struct FullPath end

struct MaxPath end

function fromto(q::QuantilePath, xi)
    q = q.q
    from = findall(xi .< quantile(xi, q))
    to = findall(xi .> quantile(xi, 1 - q))
    return from, to
end

fromto(f::FromToPath, xi) = (f.s1, f.s2)
fromto(::FullPath, xi) = (1, length(xi))
fromto(f::MaxPath, xi) = (argmin(xi), argmax(xi))


# compute the shortest chain through the samples xs with reaction coordinate xi
function shortestchain(xs, xi, from, to; sigma=1)
    dxs = pairwise(Euclidean(), xs, dims=2)
    d = size(xs, 1)
    logp = onsager_machlup(dxs, xi, sigma, d)

    is = shortestpath(-logp, from, to)

    dx = [dxs[is[i], is[i+1]] for i in 1:length(is)-1]
    dt = xi[is[1:end-1]] - xi[is[2:end]]
    is, dx, dt
end

# compute the shortest through the matrix A from ind s1 to s2
function shortestpath(A::AbstractMatrix, s1::AbstractVector{<:Integer}, s2::AbstractVector{<:Integer})
    g = Graphs.SimpleDiGraph(A)
    bf = Graphs.bellman_ford_shortest_paths(g, s1, A)
    j = s2[bf.dists[s2]|>argmin]
    return Graphs.enumerate_paths(bf, j)
end

shortestpath(A::AbstractMatrix, s1::Integer, s2::Integer) = shortestpath(A, [s1], [s2])

# path probabilities c.f. https://en.wikipedia.org/wiki/Onsager-Machlup_function
function onsager_machlup(dxs, xi, sigma=1, d=1)
    logp = zero(dxs)
    for c in CartesianIndices(dxs)
        i, j = Tuple(c)
        dt = xi[j] - xi[i]
        if dt > 0
            v = dxs[i, j] / dt
            L = 1 / 2 * (v / sigma)^2
            s = (-d / 2) * log(2 * pi * sigma^2 * dt)
            logp[c] = (s - L * dt)
        else
            logp[c] = -Inf
        end
    end
    return logp
end

function plot_reactive_path(ids, xi)
    xi = Flux.cpu(xi)
    plot(xi)
    scatter!(ids, xi[ids])
    plot!(ids, xi[ids])
    plot(plot!(), plot(xi[ids]))
end

# visualization of what shortestchain does in 1d
function visualize_shortestpath(; n=1000, sigma=0.1)
    xs = rand(1, n)
    xi = rand(n)
    xi[1] = 0
    xi[end] = 1
    is, dx, dt = shortestchain(xs, xi, 1, n; sigma)
    scatter(xi, xs[1, :])
    plot!(xi[is], xs[1, is], xlabel="t", ylabel="x", label="reaction path")
    plot!(yticks=[0, 1], xticks=[0, 1], legend=false)
end