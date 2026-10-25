@testset "Geometric counterpoise" begin
    gcp(method; kwargs...) = GeometricCounterpoise(CAFFEINE_NUMBERS, CAFFEINE_POSITIONS,
                                                   method; kwargs...)

    # Reference from the s-dftd3 Python test suite
    g = gcp("b973c")
    res = counterpoise(g)
    @test res.energy ≈ -0.07653225860427701 rtol=1e-6
    @test size(res.gradient) == (3, 24)

    # In-place variants and skipped outputs
    gradient = zeros(3, 24)
    sigma = zeros(3, 3)
    @test counterpoise!(gradient, sigma, g) ≈ res.energy
    @test gradient ≈ res.gradient
    @test sigma ≈ res.sigma
    @test counterpoise!(nothing, nothing, g) ≈ res.energy
    @test_throws DimensionMismatch counterpoise!(zeros(3, 2), nothing, g)

    # Unknown or differently spelled methods silently give no correction
    @test counterpoise(gcp("not-a-method")).energy == 0.0
    @test counterpoise(gcp("B973c")).energy == 0.0

    # Method and basis
    @test counterpoise(gcp("b3lyp"; basis="631gd")).energy != 0.0

    # Cutoffs
    g = gcp("b973c")
    set_realspace_cutoff!(g)
    @test counterpoise(g).energy ≈ res.energy
    set_realspace_cutoff!(g; bas=10, srb=10)
    @test !(counterpoise(g).energy ≈ res.energy)

    # Structure updates
    g = gcp("b973c")
    update_structure!(g, CAFFEINE_POSITIONS .+ [0.0, 0.5, 0.0])
    @test counterpoise(g).energy ≈ res.energy atol=1e-12
    @test_throws DimensionMismatch update_structure!(g, zeros(3, 3))

    # Finalization
    finalize(g)
    @test_throws ArgumentError counterpoise(g)

    @testset "Derivatives ($method)" for method in ("hf3c", "b973c", "pbeh3c")
        positions = CAFFEINE_POSITIONS
        g = gcp(method)
        r = counterpoise(g)
        energy(x) = counterpoise!(nothing, nothing, update_structure!(g, x))
        @test r.gradient ≈ fd_gradient(energy, positions) atol=1e-8
        @test r.sigma ≈ fd_sigma((x,l) -> energy(x), positions, nothing) atol=1e-8

        update_structure!(g, positions)
        h = counterpoise_hessian(g)
        @test h.energy ≈ r.energy
        @test h.hessian ≈ h.hessian' atol=1e-12
        k = 7   # spot check one column
        xp = copy(positions); xp[k] += 1e-5
        xm = copy(positions); xm[k] -= 1e-5
        col = vec(counterpoise(update_structure!(g, xp)).gradient -
                  counterpoise(update_structure!(g, xm)).gradient) / 2e-5
        @test h.hessian[:, k] ≈ col atol=1e-7
    end

    @testset "Work partition" begin
        nparts = 2
        parts = [counterpoise(set_work_partition!(gcp("b973c"), ipart, nparts)) for ipart in 1:nparts]
        @test sum(r.energy for r in parts) ≈ res.energy atol=1e-12
        @test sum(r.gradient for r in parts) ≈ res.gradient atol=1e-12
        @test_throws ArgumentError set_work_partition!(gcp("b973c"), 0, 1)
    end
end
