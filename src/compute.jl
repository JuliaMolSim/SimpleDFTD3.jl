"""
    dispersion!(gradient, sigma, model, damping) -> energy

In-place version of [`dispersion`](@ref). `gradient` (`3 × natoms`) and `sigma`
(`3 × 3`) are overwritten. Pass `nothing` to skip computing an output.
"""
function dispersion!(gradient::Union{Nothing,Matrix{Float64}},
                     sigma::Union{Nothing,Matrix{Float64}},
                     m::DispersionModel, d::AbstractDamping)
    if !isnothing(gradient) && size(gradient) != (3, m.n_atoms)
        throw(DimensionMismatch("gradient array should be of size (3, n_atoms)"))
    end
    if !isnothing(sigma) && size(sigma) != (3, 3)
        throw(DimensionMismatch("sigma should be of size (3, 3)"))
    end
    energy = Ref{Cdouble}(0.0)
    GC.@preserve m d with_error() do err
        LibSDFTD3.dftd3_get_dispersion(err, m.ptr_struct, checked_ptr(m), checked_ptr(d),
                                       energy, something(gradient, C_NULL),
                                       something(sigma, C_NULL))
    end
    energy[]
end

"""
    dispersion(model, damping) -> (; energy, gradient, sigma)

D3 dispersion energy (Hartree), its gradient with respect to the atomic positions
(`3 × natoms`, Hartree/Bohr) and the strain derivative `sigma` (`3 × 3`, Hartree).
Forces are `-gradient`, the virial is `-sigma`.
"""
function dispersion(m::DispersionModel, d::AbstractDamping)
    gradient = zeros(3, m.n_atoms)
    sigma = zeros(3, 3)
    energy = dispersion!(gradient, sigma, m, d)
    (; energy, gradient, sigma)
end

"""
    pairwise_dispersion(model, damping) -> (; pair2, pair3)

Pairwise decomposition (`natoms × natoms`, Hartree) of the two-body (`pair2`) and
three-body (`pair3`) dispersion energy. The total energy is `sum(pair2) + sum(pair3)`.
"""
function pairwise_dispersion(m::DispersionModel, d::AbstractDamping)
    pair2 = zeros(m.n_atoms, m.n_atoms)
    pair3 = zeros(m.n_atoms, m.n_atoms)
    GC.@preserve m d with_error() do err
        LibSDFTD3.dftd3_get_pairwise_dispersion(err, m.ptr_struct, checked_ptr(m),
                                                checked_ptr(d), pair2, pair3)
    end
    (; pair2, pair3)
end

"""
    dispersion_hessian(model, damping) -> (; energy, hessian)

D3 dispersion energy (Hartree) and its analytical Hessian with respect to the
atomic positions (`3natoms × 3natoms`, Hartree/Bohr², index `3(i-1) + α` for
atom `i` and Cartesian direction `α`).
"""
function dispersion_hessian(m::DispersionModel, d::AbstractDamping)
    energy = Ref{Cdouble}(0.0)
    hessian = zeros(3m.n_atoms, 3m.n_atoms)
    GC.@preserve m d with_error() do err
        LibSDFTD3.dftd3_get_dispersion_hessian(err, m.ptr_struct, checked_ptr(m), checked_ptr(d),
                                               energy, hessian)
    end
    (; energy=energy[], hessian)
end

"""
    counterpoise!(gradient, sigma, gcp::GeometricCounterpoise) -> energy

In-place version of [`counterpoise`](@ref). `gradient` (`3 × natoms`) and `sigma`
(`3 × 3`) are overwritten. Pass `nothing` to skip computing an output.
"""
function counterpoise!(gradient::Union{Nothing,Matrix{Float64}},
                       sigma::Union{Nothing,Matrix{Float64}}, g::GeometricCounterpoise)
    if !isnothing(gradient) && size(gradient) != (3, g.n_atoms)
        throw(DimensionMismatch("gradient array should be of size (3, n_atoms)"))
    end
    if !isnothing(sigma) && size(sigma) != (3, 3)
        throw(DimensionMismatch("sigma should be of size (3, 3)"))
    end
    energy = Ref{Cdouble}(0.0)
    GC.@preserve g with_error() do err
        LibSDFTD3.dftd3_get_counterpoise(err, g.ptr_struct, checked_ptr(g), energy,
                                         something(gradient, C_NULL), something(sigma, C_NULL))
    end
    energy[]
end

"""
    counterpoise(gcp::GeometricCounterpoise) -> (; energy, gradient, sigma)

Geometric counterpoise correction energy (Hartree), gradient (`3 × natoms`) and
strain derivative (`3 × 3`).
"""
function counterpoise(g::GeometricCounterpoise)
    gradient = zeros(3, g.n_atoms)
    sigma = zeros(3, 3)
    energy = counterpoise!(gradient, sigma, g)
    (; energy, gradient, sigma)
end

"""
    counterpoise_hessian(gcp::GeometricCounterpoise) -> (; energy, hessian)

Geometric counterpoise energy and its Hessian (`3natoms × 3natoms`), indexed like
[`dispersion_hessian`](@ref).
"""
function counterpoise_hessian(g::GeometricCounterpoise)
    energy = Ref{Cdouble}(0.0)
    hessian = zeros(3g.n_atoms, 3g.n_atoms)
    GC.@preserve g with_error() do err
        LibSDFTD3.dftd3_get_counterpoise_hessian(err, g.ptr_struct, checked_ptr(g), energy, hessian)
    end
    (; energy=energy[], hessian)
end
