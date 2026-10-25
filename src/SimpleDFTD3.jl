"""
Julia bindings to [s-dftd3](https://github.com/dftd3/simple-dftd3), the library
implementation of the DFT-D3 dispersion correction and the geometric
counterpoise correction (gCP).

Key structures and functions are [`DispersionModel`](@ref) and [`GeometricCounterpoise`](@ref)
as well as [`dispersion`](@ref), [`pairwise_dispersion`](@ref), [`dispersion_hessian`](@ref),
[`counterpoise`](@ref), [`counterpoise_hessian`](@ref).

All quantities are in atomic units (Bohr, Hartree).
"""
module SimpleDFTD3

include("gen/LibSDFTD3.jl")
using .LibSDFTD3

include("error_handling.jl")
include("models.jl")
include("damping.jl")
include("compute.jl")
include("libxc.jl")

const simple_dftd3_version = let
    v = LibSDFTD3.dftd3_get_version()
    VersionNumber(v ÷ 10000, (v ÷ 100) % 100, v % 100)
end

export DFTD3Error
export DispersionModel, GeometricCounterpoise, update_structure!, dispersion_identifier
export set_realspace_cutoff!, set_ewald_summation!, set_ghost_atoms!, set_work_partition!
export AbstractDamping, ZeroDamping, RationalDamping, ModifiedZeroDamping,
       ModifiedRationalDamping, OptimizedPowerDamping, CSODamping, ZDamping
export dispersion, dispersion!, pairwise_dispersion, dispersion_hessian
export counterpoise, counterpoise!, counterpoise_hessian
export dftd3_method_name

end
