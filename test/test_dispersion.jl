@testset "DispersionModel" begin
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)

    @test_throws DimensionMismatch DispersionModel(MB16_NUMBERS, MB16_POSITIONS[:, 1:3])
    @test_throws DimensionMismatch DispersionModel(MB16_NUMBERS, permutedims(MB16_POSITIONS))
    @test_throws ArgumentError DispersionModel(CO_NUMBERS, CO_POSITIONS; periodic=(true, true, true))
    @test_throws DimensionMismatch DispersionModel(CO_NUMBERS, CO_POSITIONS; lattice=ones(2, 2))

    # Integer inputs are converted
    @test DispersionModel(Int32[1, 1], [0 0; 0 0; 0 2]) isa DispersionModel

    # Overlapping atoms are rejected by the library
    @test_throws DFTD3Error DispersionModel([1, 1], zeros(3, 2))

    # Periodicity: a lattice implies full periodicity by default
    d = RationalDamping("pbe"; atm=false)
    e3d  = dispersion(DispersionModel(CO_NUMBERS, CO_POSITIONS; lattice=CO_LATTICE), d).energy
    e3d_explicit = dispersion(DispersionModel(CO_NUMBERS, CO_POSITIONS; lattice=CO_LATTICE,
                                              periodic=(true, true, true)), d).energy
    eslab = dispersion(DispersionModel(CO_NUMBERS, CO_POSITIONS; lattice=CO_LATTICE,
                                       periodic=(true, true, false)), d).energy
    emol = dispersion(DispersionModel(CO_NUMBERS, CO_POSITIONS), d).energy
    @test e3d == e3d_explicit
    @test e3d < eslab < emol < 0
end

@testset "update_structure!" begin
    d = RationalDamping("pbe0"; atm=true)
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    ref = dispersion(m, d).energy

    # Translation invariance and update equals a fresh model
    update_structure!(m, MB16_POSITIONS .+ [0.1, 0.0, 0.0])
    @test dispersion(m, d).energy ≈ ref atol=1e-12
    update_structure!(m, 1.05MB16_POSITIONS)
    @test dispersion(m, d).energy ≈ dispersion(DispersionModel(MB16_NUMBERS, 1.05MB16_POSITIONS), d).energy

    @test_throws DimensionMismatch update_structure!(m, zeros(3, 3))
    @test_throws DFTD3Error update_structure!(m, zeros(3, 16))

    # Lattice updates
    mp = DispersionModel(CO_NUMBERS, CO_POSITIONS; lattice=CO_LATTICE)
    update_structure!(mp, 1.1CO_POSITIONS; lattice=1.1CO_LATTICE)
    @test dispersion(mp, d).energy ≈
          dispersion(DispersionModel(CO_NUMBERS, 1.1CO_POSITIONS; lattice=1.1CO_LATTICE), d).energy
    @test_throws DimensionMismatch update_structure!(mp, CO_POSITIONS; lattice=ones(2, 2))
end

@testset "Finalization" begin
    d = RationalDamping("pbe0")
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    finalize(m)
    @test m.ptr == C_NULL && m.ptr_struct == C_NULL
    @test_throws ArgumentError dispersion(m, d)
    @test_throws ArgumentError update_structure!(m, MB16_POSITIONS)
    @test_throws ArgumentError set_ghost_atoms!(m, [1])
    finalize(m)  # idempotent

    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    finalize(d)
    @test d.ptr == C_NULL
    @test_throws ArgumentError dispersion(m, d)
end

@testset "Output buffers" begin
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    d = RationalDamping("pbe0"; atm=true)
    res = dispersion(m, d)
    @test size(res.gradient) == (3, 16)
    @test size(res.sigma) == (3, 3)

    gradient = zeros(3, 16)
    sigma = zeros(3, 3)
    @test dispersion!(gradient, sigma, m, d) ≈ res.energy
    @test gradient ≈ res.gradient
    @test sigma ≈ res.sigma
    @test dispersion!(nothing, nothing, m, d) ≈ res.energy
    gradient .= 0
    @test dispersion!(gradient, nothing, m, d) ≈ res.energy
    @test gradient ≈ res.gradient
    sigma .= 0
    @test dispersion!(nothing, sigma, m, d) ≈ res.energy
    @test sigma ≈ res.sigma

    @test_throws DimensionMismatch dispersion!(zeros(3, 2), nothing, m, d)
    @test_throws DimensionMismatch dispersion!(nothing, zeros(2, 2), m, d)
    @test_throws MethodError dispersion!(zeros(Float32, 3, 16), nothing, m, d)
end


@testset "Dispersion derivatives ($label)" for (label, numbers, positions, lattice) in (
        ("molecule", MB16_NUMBERS, MB16_POSITIONS, nothing),
        ("periodic", CO_NUMBERS, CO_POSITIONS, CO_LATTICE))

    d = RationalDamping("pbe0"; atm=true)
    m = DispersionModel(numbers, positions; lattice)

    # Hard real-space cutoffs make the periodic energy discontinuous (triples
    # entering/leaving the cutoff), which spoils finite differences: use smooth ones.
    set_realspace_cutoff!(m; width2=5.0, width3=5.0)
    res = dispersion(m, d)

    ref_grad = fd_gradient(positions) do x
        m_fd = DispersionModel(numbers, x; lattice)
        set_realspace_cutoff!(m_fd; width2=5.0, width3=5.0)
        dispersion(m_fd, d).energy
    end
    @test res.gradient ≈ ref_grad atol=1e-8 

    ref_stress = fd_sigma(positions, lattice) do x, l
        m_fd = DispersionModel(numbers, x; lattice=l)
        set_realspace_cutoff!(m_fd; width2=5.0, width3=5.0)
        dispersion(m_fd, d).energy
    end
    @test res.sigma ≈ res.sigma' atol=1e-12

    # The D3 coordination number has a hard cutoff and its counting function
    # does not decay to zero, so under strain lattice images enter or leave
    # the coordination number  sphere. The analytical strain derivative ignores this,
    # which leaves a small mismatch that shrinks with the CN cutoff.
    @test res.sigma ≈ ref_stress atol=5e-5

    hres = dispersion_hessian(m, d)
    @test hres.energy ≈ res.energy
    @test size(hres.hessian) == (3length(numbers), 3length(numbers))
    @test hres.hessian ≈ hres.hessian' atol=1e-12
    k = length(numbers) > 2 ? 7 : 1   # spot check one column
    xp = copy(positions); xp[k] += 1e-5
    xm = copy(positions); xm[k] -= 1e-5
    col = vec(dispersion(update_structure!(m, xp), d).gradient -
              dispersion(update_structure!(m, xm), d).gradient) / 2e-5
    @test hres.hessian[:, k] ≈ col atol=1e-7
end

@testset "Real-space cutoffs" begin
    d = RationalDamping("pbe0"; atm=true)
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    ref = dispersion(m, d).energy
    set_realspace_cutoff!(m; disp2=8.0, disp3=8.0, width2=4.0, width3=4.0)
    @test !(dispersion(m, d).energy ≈ ref)
end

@testset "Ghost atoms" begin
    d = RationalDamping("pbe0"; atm=true)
    full = dispersion(DispersionModel(MB16_NUMBERS, MB16_POSITIONS), d)

    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    set_ghost_atoms!(m, [1, 2])
    res = dispersion(m, d)
    @test abs(res.energy) < abs(full.energy)
    # Pair energies involving ghost atoms vanish
    p = pairwise_dispersion(m, d)
    @test all(iszero, p.pair2[1:2, :])
    @test all(iszero, p.pair2[:, 1:2])

    # Cumulative: adding further ghosts reduces the energy further
    set_ghost_atoms!(m, [3])
    @test abs(dispersion(m, d).energy) < abs(res.energy)

    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    set_ghost_atoms!(m, 1:16)
    @test dispersion(m, d).energy == 0.0
    @test_throws BoundsError set_ghost_atoms!(m, [0])
    @test_throws BoundsError set_ghost_atoms!(m, [17])
end

@testset "Pairwise decomposition sums up to total" begin
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    d = RationalDamping("pbe0"; atm=true)
    e_total = dispersion(m, d).energy
    pw = pairwise_dispersion(m, d)

    @test size(pw.pair2) == size(pw.pair3) == (16, 16)
    @test pw.pair2 ≈ pw.pair2'
    @test sum(pw.pair2) + sum(pw.pair3) ≈ e_total rtol=1e-10
end

@testset "Work partition" begin
    d = RationalDamping("pbe0"; atm=true)
    m = DispersionModel(CAFFEINE_NUMBERS, CAFFEINE_POSITIONS)
    ref = dispersion(m, d)
    ref_hess = dispersion_hessian(m, d).hessian

    nparts = 3
    models = map(1:nparts) do ipart
        m = DispersionModel(CAFFEINE_NUMBERS, CAFFEINE_POSITIONS)
        set_work_partition!(m, ipart, nparts)
    end
    parts = [dispersion(m, d) for m in models]

    @test sum(r.energy for r in parts) ≈ ref.energy atol=1e-12
    @test sum(r.gradient for r in parts) ≈ ref.gradient atol=1e-12
    @test sum(r.sigma for r in parts) ≈ ref.sigma atol=1e-12
    @test sum(dispersion_hessian(m, d).hessian for m in models) ≈ ref_hess atol=1e-12
    @test !(parts[1].energy ≈ ref.energy)

    @test_throws ArgumentError set_work_partition!(m, 0, 2)
    @test_throws ArgumentError set_work_partition!(m, 3, 2)
end

@testset "Ewald summation" begin
    d = RationalDamping("pbe"; atm=false)
    model() = DispersionModel(CO_NUMBERS, CO_POSITIONS; lattice=CO_LATTICE)

    converged = dispersion(set_realspace_cutoff!(model(); disp2=400.0), d).energy
    truncated = dispersion(model(), d).energy
    ewald = dispersion(set_ewald_summation!(model(); kcut=10.0, mesh=-1), d).energy
    mesh  = dispersion(set_ewald_summation!(model(); kcut=10.0), d).energy
    @test ewald ≈ converged atol=1e-7
    @test mesh ≈ ewald atol=1e-8
    @test !isapprox(truncated, converged; atol=1e-6)
end
