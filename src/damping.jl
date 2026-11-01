abstract type AbstractDamping end

function free!(d::AbstractDamping)
    if d.ptr != C_NULL
        LibSDFTD3.dftd3_delete_param(Ref(d.ptr))
        d.ptr = C_NULL
    end
    nothing
end

#
# RationalDamping
#
mutable struct RationalDamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::RationalDamping) = "D3(BJ)"

"""
    RationalDamping(; s6=1.0, s8, s9=1.0, a1, a2, alp=14.0)
    RationalDamping(method; atm=false)

Rational (Becke-Johnson) damping, D3(BJ).

The original scheme was proposed by Becke and Johnson and implemented in a
slightly adjusted form using only the C8/C6 ratio in the critical for DFT-D3.
The rational damping scheme has the advantage of damping the dispersion energy
to finite value, rather than removing it at short distances.

The second signature loads the damping parameters stored in simple-dftd3 for a
quantum-chemical `method` (case-insensitive, aliases and dashes accepted). With
`atm=true` the three-body Axilrod-Teller-Muto term is included (`s9 = 1`), otherwise
it is disabled (`s9 = 0`). Use [`dftd3_method_name`](@ref) to obtain `method` from
Libxc functional identifiers.
"""
function RationalDamping(; s6::Float64=1.0, s8::Float64, s9::Float64=1.0,
                           a1::Float64, a2::Float64, alp::Float64=14.0)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_rational_damping(err, s6, s8, s9, a1, a2, alp)
    end
    finalizer(free!, RationalDamping(ptr))
end
function RationalDamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_rational_damping(err, method, atm))
    finalizer(free!, RationalDamping(ptr))
end

#
# ZeroDamping
#
mutable struct ZeroDamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::ZeroDamping) = "D3(0)"

"""
    ZeroDamping(; s6=1.0, s8, s9=1.0, rs6, rs8=1.0, alp=14.0)
    ZeroDamping(method; atm=false)

Zero (Chai-Head-Gordon) damping, D3(0).

Original DFT-D3 damping function based on a variant proposed by Chai and Head-Gordon.
Since it is damping the dispersion energy to zero at short distances it is usually
called zero damping scheme for simplicity. However, due to this short-range limit
of the dispersion energy a repulsive contribution to the gradient can arise, which
is considered artificial.

The second signature loads damping parameters for a quantum-chemical `method`
with Axilrod-Teller-Muto term `atm=true` or not. See [`RationalDamping`](@ref)
for details.
"""
function ZeroDamping(; s6::Float64=1.0, s8::Float64, s9::Float64=1.0,
                     rs6::Float64, rs8::Float64=1.0, alp::Float64=14.0)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_zero_damping(err, s6, s8, s9, rs6, rs8, alp)
    end
    finalizer(free!, ZeroDamping(ptr))
end
function ZeroDamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_zero_damping(err, method, atm))
    finalizer(free!, ZeroDamping(ptr))
end

#
# ModifiedRationalDamping
#
mutable struct ModifiedRationalDamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::ModifiedRationalDamping) = "D3M(BJ)"

"""
    ModifiedRationalDamping(; s6=1.0, s8, s9=1.0, a1, a2, alp=14.0)
    ModifiedRationalDamping(method; atm=false)

Modified rational damping, D3M(BJ).

The functional form of the damping function is *unmodified* compared to
[`RationalDamping`](@ref). The second signature loads parameters from the
library, see [`RationalDamping`](@ref) for details. However, for a number of
functionals new parameters were introduced. This constructor allows to
automatically load the reparameterized damping function from the library.
"""
function ModifiedRationalDamping(; s6::Float64=1.0, s8::Float64,
                                   s9::Float64=1.0, a1::Float64,
                                   a2::Float64, alp::Float64=14.0)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_mrational_damping(err, s6, s8, s9, a1, a2, alp)
    end
    finalizer(free!, ModifiedRationalDamping(ptr))
end
function ModifiedRationalDamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_mrational_damping(err, method, atm))
    finalizer(free!, ModifiedRationalDamping(ptr))
end

#
# ModifiedZeroDamping
#
mutable struct ModifiedZeroDamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::ModifiedZeroDamping) = "D3M(0)"

"""
    ModifiedZeroDamping(; s6=1.0, s8, s9=1.0, rs6, rs8=1.0, alp=14.0, bet)
    ModifiedZeroDamping(method; atm=false)

Modified zero damping, D3M(0).

This scheme adds an additional offset parameter to the zero damping scheme
of the original DFT-D3. For `bet=0.0` this is identical to [`ZeroDamping`](@ref).
See [`RationalDamping`](@ref) for details on the second constructor.
"""
function ModifiedZeroDamping(; s6::Float64=1.0, s8::Float64, s9::Float64=1.0,
                               rs6::Float64, rs8::Float64=1.0,
                               alp::Float64=14.0, bet::Float64)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_mzero_damping(err, s6, s8, s9, rs6, rs8, alp, bet)
    end
    finalizer(free!, ModifiedZeroDamping(ptr))
end
function ModifiedZeroDamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_mzero_damping(err, method, atm))
    finalizer(free!, ModifiedZeroDamping(ptr))
end


#
# OptimizedPowerDamping
#
mutable struct OptimizedPowerDamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::OptimizedPowerDamping) = "D3(op)"

"""
    OptimizedPowerDamping(; s6=1.0, s8, s9=1.0, a1, a2, alp=14.0, bet)
    OptimizedPowerDamping(method; atm=false)

Optimized power version of the rational damping parameters, D3(op).

The functional form of the damping function is modified by adding an additional
zero-damping like power function. For `bet=0.0` this damping is identical to
the [`RationalDamping`](@ref). See [`RationalDamping`](@ref) for details on the
second constructor.
"""
function OptimizedPowerDamping(; s6::Float64=1.0, s8::Float64, s9::Float64=1.0,
                               a1::Float64, a2::Float64,
                               alp::Float64=14.0, bet::Float64)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_optimizedpower_damping(err, s6, s8, s9, a1, a2, alp, bet)
    end
    finalizer(free!, OptimizedPowerDamping(ptr))
end
function OptimizedPowerDamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_optimizedpower_damping(err, method, atm))
    finalizer(free!, OptimizedPowerDamping(ptr))
end



#
# CSODamping
#
mutable struct CSODamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::CSODamping) = "D3(CSO)"

"""
    CSODamping(; s6=1.0, s9=1.0, a1, a2=2.5, a3=0.0, a4=6.25, alp=14.0)
    CSODamping(method; atm=false)

C6-scaled-only damping, D3(CSO). Reformulation of the D3(Becke-Johnson) dispersion
correction using only C6 dispersion coefficients with a sigmoidal interpolation
function. See [`RationalDamping`](@ref) for details on the second constructor.
"""
function CSODamping(; s6::Float64=1.0, s9::Float64=1.0, a1::Float64, a2::Float64=2.5,
                      a3::Float64=0.0, a4::Float64=6.25, alp::Float64=14.0)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_cso_damping(err, s6, s9, a1, a2, a3, a4, alp)
    end
    finalizer(free!, CSODamping(ptr))
end
function CSODamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_cso_damping(err, method, atm))
    finalizer(free!, CSODamping(ptr))
end

#
# ZDamping
#
mutable struct ZDamping <: AbstractDamping
    ptr::LibSDFTD3.dftd3_param
end
dispersion_identifier(::ZDamping) = "D3(Z)"

"""
    ZDamping(; s6=1.0, s8, s9=1.0, a1, alp=14.0)
    ZDamping(method; atm=false)

Z damping function for DFT-D3, based on the atomic-number damping form proposed
for XDM(Z). Note: s-dftd3 1.6 stores no Z-damping parameters, so this type can only
be constructed from explicit values.
"""
function ZDamping(; s6::Float64=1.0, s8::Float64, s9::Float64=1.0,
                    a1::Float64, alp::Float64=14.0)
    ptr = with_error() do err
        LibSDFTD3.dftd3_new_z_damping(err, s6, s8, s9, a1, alp)
    end
    finalizer(free!, ZDamping(ptr))
end
function ZDamping(method::AbstractString; atm::Bool=false)
    ptr = with_error(err -> LibSDFTD3.dftd3_load_z_damping(err, method, atm))
    finalizer(free!, ZDamping(ptr))
end

#
# Construction from an identifier
#
"""
    Damping(identifier, method; atm=false)

Load the damping parameters stored for `method` for the damping with the given
`identifier`. For example `Damping("D3(0)", "pbe")` gives `ZeroDamping("pbe")`.
"""
function Damping(identifier::AbstractString, method::AbstractString; atm::Bool=false)
    if identifier == "D3(BJ)"
        RationalDamping(method; atm)
    elseif identifier == "D3(0)"
        ZeroDamping(method; atm)
    elseif identifier == "D3M(BJ)"
        ModifiedRationalDamping(method; atm)
    elseif identifier == "D3M(0)"
        ModifiedZeroDamping(method; atm)
    elseif identifier == "D3(op)"
        OptimizedPowerDamping(method; atm)
    elseif identifier == "D3(CSO)"
        CSODamping(method; atm)
    elseif identifier == "D3(Z)"
        ZDamping(method; atm)
    else
        throw(ArgumentError("Unknown damping identifier \"$identifier\", expected one of " *
                            "D3(BJ), D3(0), D3M(BJ), D3M(0), D3(op), D3(CSO), D3(Z)."))
    end
end
