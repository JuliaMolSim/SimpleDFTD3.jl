#
# DispersionModel
#

"""
    DispersionModel(numbers, positions; lattice=nothing, periodic=nothing)

D3 dispersion model constructed from molecular or periodic structure.
Contains the required information to evaluate all dispersion related properties,
like C6 coefficients. 

- `numbers`: atomic numbers (length `natoms`)
- `positions`: `3 × natoms` matrix of Cartesian coordinates in Bohr
- `lattice`: `3 × 3` matrix with the lattice vectors (Bohr) as columns, or `nothing`
  for a molecule
- `periodic`: periodicity along each lattice vector. Defaults to fully periodic if a
  lattice is given and non-periodic otherwise.

Use [`update_structure!`](@ref) to change positions or the lattice, use [`set_realspace_cutoff!`](@ref),
[`set_ewald_summation!`](@ref), [`set_ghost_atoms!`](@ref) and [`set_work_partition!`](@ref)
to modify details of the dispersion evaluation, use [`dispersion`](@ref), [`dispersion!`](@ref),
[`pairwise_dispersion`](@ref) and [`dispersion_hessian`](@ref) to evaluate.
"""
mutable struct DispersionModel
    ptr_struct::LibSDFTD3.dftd3_structure
    ptr::LibSDFTD3.dftd3_model
    n_atoms::Int
end

function DispersionModel(numbers::AbstractVector{<:Integer}, positions::AbstractMatrix{<:Real};
                         lattice=nothing, periodic=nothing)
    nums = convert(Vector{Cint}, numbers)
    (; pos, lat) = _checked_c_conversion(positions, lattice, length(nums))

    if isnothing(periodic)
        periodic = isnothing(lat) ? (false, false, false) : (true, true, true)
    end
    periodic = NTuple{3,Bool}(periodic)
    if any(periodic) && isnothing(lat)
        throw(ArgumentError("A lattice is required for periodic structures"))
    end

    ptr_struct = with_error() do err
        LibSDFTD3.dftd3_new_structure(err, length(nums), nums, pos,
                                      something(lat, C_NULL), collect(Bool, periodic))
    end
    model = finalizer(free!, DispersionModel(ptr_struct, C_NULL, length(nums)))
    model.ptr = with_error(err -> LibSDFTD3.dftd3_new_d3_model(err, ptr_struct))
    model
end

function free!(m::DispersionModel)
    if m.ptr_struct != C_NULL
        LibSDFTD3.dftd3_delete_structure(Ref(m.ptr_struct))
        m.ptr_struct = C_NULL
    end

    if m.ptr != C_NULL
        LibSDFTD3.dftd3_delete_model(Ref(m.ptr))
        m.ptr = C_NULL
    end
    nothing
end


"""
    set_realspace_cutoff!(model; disp2=60.0, disp3=40.0, cn=40.0, width2=0.0, width3=0.0)

Set real-space cutoffs (Bohr) for the two-body and three-body dispersion terms and the
coordination number, and the widths of the smooth switching functions applied
at the two-body and three-body cutoffs (zero means a hard cutoff).
"""
function set_realspace_cutoff!(m::DispersionModel;
                               disp2=60.0, disp3=40.0, cn=40.0, width2=0.0, width3=0.0)
    GC.@preserve m with_error() do err
        LibSDFTD3.dftd3_set_model_realspace_cutoff_smooth(err, checked_ptr(m), disp2, disp3,
                                                          cn, width2, width3)
    end
    m
end

"""
    set_ghost_atoms!(model, indices)

Mark the atoms with the given 1-based `indices` as ghost atoms, i.e. disable their
dispersion contributions. Calls are cumulative; ghost atoms cannot be reset.
"""
function set_ghost_atoms!(m::DispersionModel, indices)
    n = m.n_atoms
    for i in indices
        1 ≤ i ≤ n || throw(BoundsError(1:n, i))
    end
    idx = Cint[i - 1 for i in indices]
    GC.@preserve m with_error() do err
        LibSDFTD3.dftd3_set_model_ghost_index(err, checked_ptr(m), idx, length(idx))
    end
    m
end

"""
    set_ewald_summation!(model; rank=0, tolerance=0.0, kcut=0.0, mesh=0)

Evaluate the two-body dispersion energy by Ewald summation. Requires a fully
periodic structure and zero or rational damping; the two-body real-space cutoff is
ignored then.

- `rank`: rank of the expansion (`0`: derived from `tolerance`)
- `tolerance`: target accuracy
- `kcut`: reciprocal-space cutoff (`0`: derived from the damping radii)
- `mesh`: Selects how the reciprocal space sum is evaluated. `0` derives a particle mesh
  from the reciprocal cutoff `kcut`, which scales as O(N log N) and is the default.
  A positive value interpolates the structure factors on a mesh of that many points per
  direction, rounded up to a power of two, and a negative value sums over the reciprocal
  lattice directly, which is exact but scales quadratically with the number of atoms.

"""
function set_ewald_summation!(m::DispersionModel; rank=0, tolerance=0.0, kcut=0.0, mesh=0)
    GC.@preserve m with_error() do err
        LibSDFTD3.dftd3_set_model_ewald(err, checked_ptr(m), rank, tolerance, kcut, mesh)
    end
    m
end

"""
    set_work_partition!(model, ipart, nparts)

Restrict the interaction loops to part `ipart` (1-based) of `nparts`. Summing the
results over all parts reproduces the full calculation. Structure dependent quantities
are evaluated for the full system on every part, only the pairwise, three-body and
reciprocal space loops are partitioned.
"""
function set_work_partition!(m::DispersionModel, ipart, nparts)
    1 ≤ ipart ≤ nparts || throw(ArgumentError("partition must satisfy 1 ≤ ipart ≤ nparts"))
    GC.@preserve m with_error() do err
        LibSDFTD3.dftd3_set_model_work_partition(err, checked_ptr(m), ipart - 1, nparts)
    end
    m
end

#
# GeometricCounterpoise
#

"""
    GeometricCounterpoise(numbers, positions, method::AbstractString;
                          lattice=nothing, periodic=nothing, basis=nothing)

Holds all required information to evaluate the geometric counterpoise (gCP)
correction for the given geometry. The counterpoise correction is a method to correct the
interaction energy in a supermolecular calculation for the basis set superposition error (BSSE).

- `numbers`: atomic numbers (length `natoms`)
- `positions`: `3 × natoms` matrix of Cartesian coordinates in Bohr
- `method`: Quantum-chemical method described as a string, e.g. a composite method
  (`"hf3c"`, `"pbeh3c"`, `"hse3c"`, `"b973c"`, `"r2scan3c"`, `"b3pbe3c"`) or a method
  (`"hf"`, `"b3lyp"`, `"blyp"`, `"pbe"`, `"tpss"`, `"pw6b95"`, `"dft"`, `"gga"`)
  to be combined with a `basis`. Unlike the names of the damping parameters, these names
  are case-sensitive and have no aliases.
- `lattice`: `3 × 3` matrix with the lattice vectors (Bohr) as columns, or `nothing`
  for a molecule
- `periodic`: periodicity along each lattice vector. Defaults to fully periodic if a
  lattice is given and non-periodic otherwise.
- `basis`: Gaussian basis used for the species in structure (e.g. `"631gd"`, `"svp"`,
  `"def2tzvp"`, `"minis"`).

Use [`update_structure!`](@ref) to change positions or the lattice, use [`set_realspace_cutoff!`](@ref)
and [`set_work_partition!`](@ref) to modify details of the gCP evaluation, use [`counterpoise`](@ref),
[`counterpoise!`](@ref) and [`counterpoise_hessian`](@ref) to evaluate.

!!! warning
    s-dftd3 does not report unknown method/basis combinations; the
    correction then silently vanishes.
"""
mutable struct GeometricCounterpoise
    ptr_struct::LibSDFTD3.dftd3_structure
    ptr::LibSDFTD3.dftd3_gcp
    n_atoms::Int
end

function GeometricCounterpoise(numbers::AbstractVector{<:Integer},
                               positions::AbstractMatrix{<:Real},
                               method::AbstractString;
                               lattice=nothing, periodic=nothing, basis=nothing)
    nums = convert(Vector{Cint}, numbers)
    (; pos, lat) = _checked_c_conversion(positions, lattice, length(nums))

    if isnothing(periodic)
        periodic = isnothing(lat) ? (false, false, false) : (true, true, true)
    end
    periodic = NTuple{3,Bool}(periodic)
    if any(periodic) && isnothing(lat)
        throw(ArgumentError("A lattice is required for periodic structures"))
    end

    ptr_struct = with_error() do err
        LibSDFTD3.dftd3_new_structure(err, length(nums), nums, pos,
                                      something(lat, C_NULL), collect(Bool, periodic))
    end
    gcp = finalizer(free!, GeometricCounterpoise(ptr_struct, C_NULL, length(nums)))
    gcp.ptr = with_error() do err
        LibSDFTD3.dftd3_load_gcp_param(err, ptr_struct, method,
                                       isnothing(basis) ? C_NULL : string(basis))
    end
    gcp
end

function free!(g::GeometricCounterpoise)
    if g.ptr_struct != C_NULL
        LibSDFTD3.dftd3_delete_structure(Ref(g.ptr_struct))
        g.ptr_struct = C_NULL
    end

    if g.ptr != C_NULL
        LibSDFTD3.dftd3_delete_gcp(Ref(g.ptr))
        g.ptr = C_NULL
    end
    nothing
end

"""
    set_realspace_cutoff!(gcp; bas=60.0, srb=60.0)

Set real-space cutoffs (Bohr) for the basis set incompleteness term and the
short-range bond correction of the geometric counterpoise correction.
"""
function set_realspace_cutoff!(g::GeometricCounterpoise; bas=60.0, srb=60.0)
    GC.@preserve g with_error() do err
        LibSDFTD3.dftd3_set_gcp_realspace_cutoff(err, checked_ptr(g), bas, srb)
    end
    g
end

"""
    set_work_partition!(gcp, ipart, nparts)

Restrict the interaction loops to part `ipart` (1-based) of `nparts`. Summing the
results over all parts reproduces the full calculation.
"""
function set_work_partition!(g::GeometricCounterpoise, ipart, nparts)
    1 ≤ ipart ≤ nparts || throw(ArgumentError("partition must satisfy 1 ≤ ipart ≤ nparts"))
    GC.@preserve g with_error() do err
        LibSDFTD3.dftd3_set_gcp_work_partition(err, checked_ptr(g), ipart - 1, nparts)
    end
    g
end

#
# Functions valid to both
#

"""
    update_structure!([model,gcp], positions; lattice=nothing)

Update the positions (`3 × natoms`, Bohr) and optionally the lattice of the structural
information stored in the `DispersionModel` or the `GeometricCounterpoise`.
The atomic numbers and the periodicity cannot be changed.
"""
function update_structure!(m::Union{DispersionModel,GeometricCounterpoise},
                 positions::AbstractMatrix{<:Real}; lattice=nothing)
    (; pos, lat) = _checked_c_conversion(positions, lattice, m.n_atoms)
    checked_ptr(m)
    GC.@preserve m with_error() do err
        LibSDFTD3.dftd3_update_structure(err, m.ptr_struct, pos, something(lat, C_NULL))
    end
    m
end

function _checked_c_conversion(positions, lattice, n_atoms)
    size(positions) == (3, n_atoms) ||
        throw(DimensionMismatch("positions must be a 3 × $n_atoms matrix, got $(size(positions))"))
    pos = convert(Matrix{Cdouble}, positions)

    if !isnothing(lattice)
        size(lattice) == (3, 3) ||
            throw(DimensionMismatch("lattice must be a 3 × 3 matrix, got $(size(lattice))"))
        lat = convert(Matrix{Cdouble}, lattice)
    else
        lat = nothing
    end

    (; pos, lat)
end
