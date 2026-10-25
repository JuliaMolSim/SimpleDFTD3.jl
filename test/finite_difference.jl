function fd_gradient(f, x; h=1e-5)
    g = zero(x)
    for i in eachindex(x)
        xp = copy(x); xp[i] += h
        xm = copy(x); xm[i] -= h
        g[i] = (f(xp) - f(xm)) / 2h
    end
    g
end

# dE/dε_ij for the deformation x → (I + ε) x of positions and lattice
function fd_sigma(f, positions, lattice; h=1e-5)
    sigma = zeros(3, 3)
    deform(x, ε) = isnothing(x) ? nothing : (I + ε) * x
    for i in 1:3, j in 1:3
        ε = zeros(3, 3); ε[i, j] = h
        sigma[i, j] = (f(deform(positions, ε), deform(lattice, ε)) -
                       f(deform(positions, -ε), deform(lattice, -ε))) / 2h
    end
    sigma
end
