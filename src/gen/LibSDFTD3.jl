module LibSDFTD3

using simple_dftd3_jll
export simple_dftd3_jll

#
# Automatically generated from include/s-dftd3.h by gen/generate.jl.
# Do not edit by hand.
#
# All quantities are in atomic units (Bohr, Hartree) and arrays are column-major,
# i.e. `positions` (3 × natoms), `lattice` (3 × 3, lattice vectors as columns) and
# `gradient` (3 × natoms). No error checking is performed at this level.
#

mutable struct _dftd3_error end

"""
Error handle class
"""
const dftd3_error = Ptr{_dftd3_error}

"""
    dftd3_delete_error(error)

Delete error handle object
"""
function dftd3_delete_error(error)
    ccall((:dftd3_delete_error, libsdftd3), Cvoid, (Ptr{dftd3_error},), error)
end

mutable struct _dftd3_structure end

"""
Molecular structure data class
"""
const dftd3_structure = Ptr{_dftd3_structure}

"""
    dftd3_delete_structure(mol)

Delete molecular structure data
"""
function dftd3_delete_structure(mol)
    ccall((:dftd3_delete_structure, libsdftd3), Cvoid, (Ptr{dftd3_structure},), mol)
end

mutable struct _dftd3_model end

"""
Dispersion model class
"""
const dftd3_model = Ptr{_dftd3_model}

"""
    dftd3_delete_model(disp)

Delete dispersion model
"""
function dftd3_delete_model(disp)
    ccall((:dftd3_delete_model, libsdftd3), Cvoid, (Ptr{dftd3_model},), disp)
end

mutable struct _dftd3_param end

"""
Damping parameter class
"""
const dftd3_param = Ptr{_dftd3_param}

"""
    dftd3_delete_param(param)

Delete damping parameters
"""
function dftd3_delete_param(param)
    ccall((:dftd3_delete_param, libsdftd3), Cvoid, (Ptr{dftd3_param},), param)
end

mutable struct _dftd3_gcp end

"""
Counter-poisecorrection parameters class
"""
const dftd3_gcp = Ptr{_dftd3_gcp}

"""
    dftd3_delete_gcp(gcp)

Delete counter-poise parameters
"""
function dftd3_delete_gcp(gcp)
    ccall((:dftd3_delete_gcp, libsdftd3), Cvoid, (Ptr{dftd3_gcp},), gcp)
end

"""
    dftd3_get_version()

Obtain library version as major * 10000 + minor * 100 + patch
"""
function dftd3_get_version()
    ccall((:dftd3_get_version, libsdftd3), Cint, ())
end

"""
    dftd3_has_feature(feature)

Query whether an optional feature is available in this build.

Currently only "mpi" is defined, unknown features are not available.
"""
function dftd3_has_feature(feature)
    ccall((:dftd3_has_feature, libsdftd3), Bool, (Ptr{Cchar},), feature)
end

"""
    dftd3_new_error()

Create new error handle object
"""
function dftd3_new_error()
    ccall((:dftd3_new_error, libsdftd3), dftd3_error, ())
end

"""
    dftd3_check_error(error)

Check error handle status
"""
function dftd3_check_error(error)
    ccall((:dftd3_check_error, libsdftd3), Cint, (dftd3_error,), error)
end

"""
    dftd3_get_error(error, buffer, buffersize)

Get error message from error handle
"""
function dftd3_get_error(error, buffer, buffersize)
    ccall((:dftd3_get_error, libsdftd3), Cvoid, (dftd3_error, Ptr{Cchar}, Ptr{Cint}), error, buffer, buffersize)
end

"""
    dftd3_new_structure(error, natoms, numbers, positions, lattice, periodic)

Create new molecular structure data (quantities in Bohr)
"""
function dftd3_new_structure(error, natoms, numbers, positions, lattice, periodic)
    ccall((:dftd3_new_structure, libsdftd3), dftd3_structure, (dftd3_error, Cint, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Bool}), error, natoms, numbers, positions, lattice, periodic)
end

"""
    dftd3_update_structure(error, mol, positions, lattice)

Update coordinates and lattice parameters (quantities in Bohr)
"""
function dftd3_update_structure(error, mol, positions, lattice)
    ccall((:dftd3_update_structure, libsdftd3), Cvoid, (dftd3_error, dftd3_structure, Ptr{Cdouble}, Ptr{Cdouble}), error, mol, positions, lattice)
end

"""
    dftd3_new_d3_model(error, mol)

Create new D3 dispersion model
"""
function dftd3_new_d3_model(error, mol)
    ccall((:dftd3_new_d3_model, libsdftd3), dftd3_model, (dftd3_error, dftd3_structure), error, mol)
end

"""
    dftd3_set_model_realspace_cutoff(error, model, disp2, disp3, cn)

Set realspace cutoffs (quantities in Bohr)

deprecated: removed with the v2 API, use [`dftd3_set_model_realspace_cutoff_smooth`](@ref)
"""
function dftd3_set_model_realspace_cutoff(error, model, disp2, disp3, cn)
    ccall((:dftd3_set_model_realspace_cutoff, libsdftd3), Cvoid, (dftd3_error, dftd3_model, Cdouble, Cdouble, Cdouble), error, model, disp2, disp3, cn)
end

"""
    dftd3_set_model_ghost_index(error, model, ghost, nidx)

Disable dispersion contributions from selected atoms.
"""
function dftd3_set_model_ghost_index(error, model, ghost, nidx)
    ccall((:dftd3_set_model_ghost_index, libsdftd3), Cvoid, (dftd3_error, dftd3_model, Ptr{Cint}, Cint), error, model, ghost, nidx)
end

"""
    dftd3_set_model_realspace_cutoff_smooth(error, model, disp2, disp3, cn, width2, width3)

Set realspace cutoffs with smoothing widths (quantities in Bohr)
"""
function dftd3_set_model_realspace_cutoff_smooth(error, model, disp2, disp3, cn, width2, width3)
    ccall((:dftd3_set_model_realspace_cutoff_smooth, libsdftd3), Cvoid, (dftd3_error, dftd3_model, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, model, disp2, disp3, cn, width2, width3)
end

"""
    dftd3_set_model_ewald(error, model, rank, tolerance, kcut, mesh)

Evaluate the two-body dispersion energy by Ewald summation.

Requires three-dimensional periodic boundary conditions and a damping function supporting the reciprocal space summation, currently the rational and the zero damping function. The real space cutoff for the two-body interactions is ignored once this is enabled.

Non-positive arguments select the respective default, a vanishing rank derives the rank of the expansion from the tolerance and a vanishing reciprocal cutoff derives it from the damping radii.

The mesh selects how the reciprocal space sum is evaluated: zero derives a particle mesh from the reciprocal cutoff, a positive value interpolates the structure factors on a mesh of that many points per direction, rounded up to a power of two, and a negative value sums over the reciprocal lattice directly, which is exact but scales quadratically with the number of atoms.
"""
function dftd3_set_model_ewald(error, model, rank, tolerance, kcut, mesh)
    ccall((:dftd3_set_model_ewald, libsdftd3), Cvoid, (dftd3_error, dftd3_model, Cint, Cdouble, Cdouble, Cint), error, model, rank, tolerance, kcut, mesh)
end

"""
    dftd3_set_model_work_partition(error, model, part, nparts)

Assign an externally managed part of the interaction loops to this model.

The part index is zero based and must be smaller than nparts. Summing the results of all parts reproduces the complete calculation. Structure dependent quantities are evaluated for the full system on every part, only the pairwise, three-body and reciprocal space loops are partitioned.
"""
function dftd3_set_model_work_partition(error, model, part, nparts)
    ccall((:dftd3_set_model_work_partition, libsdftd3), Cvoid, (dftd3_error, dftd3_model, Cint, Cint), error, model, part, nparts)
end

"""
    dftd3_set_model_mpi_comm(error, model, comm)

Distribute the interaction loops of this model over an MPI communicator.

Communicators are passed as Fortran handles, use MPI\\_Comm\\_c2f to convert. Reports an error if the library was built without MPI support.
"""
function dftd3_set_model_mpi_comm(error, model, comm)
    ccall((:dftd3_set_model_mpi_comm, libsdftd3), Cvoid, (dftd3_error, dftd3_model, Cint), error, model, comm)
end

"""
    dftd3_new_zero_damping(error, s6, s8, s9, rs6, rs8, alp)

Create new zero damping parameters
"""
function dftd3_new_zero_damping(error, s6, s8, s9, rs6, rs8, alp)
    ccall((:dftd3_new_zero_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s8, s9, rs6, rs8, alp)
end

"""
    dftd3_load_zero_damping(error, method, atm)

Load zero damping parameters from internal storage
"""
function dftd3_load_zero_damping(error, method, atm)
    ccall((:dftd3_load_zero_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_new_rational_damping(error, s6, s8, s9, a1, a2, alp)

Create new rational damping parameters
"""
function dftd3_new_rational_damping(error, s6, s8, s9, a1, a2, alp)
    ccall((:dftd3_new_rational_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s8, s9, a1, a2, alp)
end

"""
    dftd3_load_rational_damping(error, method, atm)

Load rational damping parameters from internal storage
"""
function dftd3_load_rational_damping(error, method, atm)
    ccall((:dftd3_load_rational_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_new_mzero_damping(error, s6, s8, s9, rs6, rs8, alp, bet)

Create new modified zero damping parameters
"""
function dftd3_new_mzero_damping(error, s6, s8, s9, rs6, rs8, alp, bet)
    ccall((:dftd3_new_mzero_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s8, s9, rs6, rs8, alp, bet)
end

"""
    dftd3_load_mzero_damping(error, method, atm)

Load modified zero damping parameters from internal storage
"""
function dftd3_load_mzero_damping(error, method, atm)
    ccall((:dftd3_load_mzero_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_new_mrational_damping(error, s6, s8, s9, a1, a2, alp)

Create new modified rational damping parameters
"""
function dftd3_new_mrational_damping(error, s6, s8, s9, a1, a2, alp)
    ccall((:dftd3_new_mrational_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s8, s9, a1, a2, alp)
end

"""
    dftd3_load_mrational_damping(error, method, atm)

Load modified rational damping parameters from internal storage
"""
function dftd3_load_mrational_damping(error, method, atm)
    ccall((:dftd3_load_mrational_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_new_optimizedpower_damping(error, s6, s8, s9, a1, a2, alp, bet)

Create new optimized power damping parameters
"""
function dftd3_new_optimizedpower_damping(error, s6, s8, s9, a1, a2, alp, bet)
    ccall((:dftd3_new_optimizedpower_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s8, s9, a1, a2, alp, bet)
end

"""
    dftd3_load_optimizedpower_damping(error, method, atm)

Load optimized power damping parameters from internal storage
"""
function dftd3_load_optimizedpower_damping(error, method, atm)
    ccall((:dftd3_load_optimizedpower_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_new_cso_damping(error, s6, s9, a1, a2, a3, a4, alp)

Create new CSO damping parameters
"""
function dftd3_new_cso_damping(error, s6, s9, a1, a2, a3, a4, alp)
    ccall((:dftd3_new_cso_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s9, a1, a2, a3, a4, alp)
end

"""
    dftd3_load_cso_damping(error, method, atm)

Load CSO damping parameters from internal storage
"""
function dftd3_load_cso_damping(error, method, atm)
    ccall((:dftd3_load_cso_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_new_z_damping(error, s6, s8, s9, a1, alp)

Create new Z damping parameters
"""
function dftd3_new_z_damping(error, s6, s8, s9, a1, alp)
    ccall((:dftd3_new_z_damping, libsdftd3), dftd3_param, (dftd3_error, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), error, s6, s8, s9, a1, alp)
end

"""
    dftd3_load_z_damping(error, method, atm)

Load Z damping parameters from internal storage
"""
function dftd3_load_z_damping(error, method, atm)
    ccall((:dftd3_load_z_damping, libsdftd3), dftd3_param, (dftd3_error, Ptr{Cchar}, Bool), error, method, atm)
end

"""
    dftd3_load_gcp_param(error, mol, method, basis)

Load geometric counter-poise parameters from internal storage
"""
function dftd3_load_gcp_param(error, mol, method, basis)
    ccall((:dftd3_load_gcp_param, libsdftd3), dftd3_gcp, (dftd3_error, dftd3_structure, Ptr{Cchar}, Ptr{Cchar}), error, mol, method, basis)
end

"""
    dftd3_set_gcp_realspace_cutoff(error, gcp, bas, srb)

Set realspace cutoffs (quantities in Bohr)
"""
function dftd3_set_gcp_realspace_cutoff(error, gcp, bas, srb)
    ccall((:dftd3_set_gcp_realspace_cutoff, libsdftd3), Cvoid, (dftd3_error, dftd3_gcp, Cdouble, Cdouble), error, gcp, bas, srb)
end

"""
    dftd3_set_gcp_work_partition(error, gcp, part, nparts)

Assign an externally managed part of the interaction loops to these parameters.

The part index is zero based and must be smaller than nparts. Summing the results of all parts reproduces the complete calculation.
"""
function dftd3_set_gcp_work_partition(error, gcp, part, nparts)
    ccall((:dftd3_set_gcp_work_partition, libsdftd3), Cvoid, (dftd3_error, dftd3_gcp, Cint, Cint), error, gcp, part, nparts)
end

"""
    dftd3_set_gcp_mpi_comm(error, gcp, comm)

Distribute the counter-poise correction over an MPI communicator.

In contrast to the externally managed work partition the results are reduced over the communicator, every rank receives the complete result. Communicators are passed as Fortran handles, use MPI\\_Comm\\_c2f to convert. Reports an error if the library was built without MPI support.
"""
function dftd3_set_gcp_mpi_comm(error, gcp, comm)
    ccall((:dftd3_set_gcp_mpi_comm, libsdftd3), Cvoid, (dftd3_error, dftd3_gcp, Cint), error, gcp, comm)
end

"""
    dftd3_get_dispersion(error, mol, disp, param, energy, gradient, sigma)

Evaluate the dispersion energy and its derivatives
"""
function dftd3_get_dispersion(error, mol, disp, param, energy, gradient, sigma)
    ccall((:dftd3_get_dispersion, libsdftd3), Cvoid, (dftd3_error, dftd3_structure, dftd3_model, dftd3_param, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), error, mol, disp, param, energy, gradient, sigma)
end

"""
    dftd3_get_pairwise_dispersion(error, mol, disp, param, pair_energy2, pair_energy3)

Evaluate the pairwise representation of the dispersion energy
"""
function dftd3_get_pairwise_dispersion(error, mol, disp, param, pair_energy2, pair_energy3)
    ccall((:dftd3_get_pairwise_dispersion, libsdftd3), Cvoid, (dftd3_error, dftd3_structure, dftd3_model, dftd3_param, Ptr{Cdouble}, Ptr{Cdouble}), error, mol, disp, param, pair_energy2, pair_energy3)
end

"""
    dftd3_get_dispersion_hessian(error, mol, disp, param, energy, arg6)

Evaluate the analytical second derivatives of the dispersion energy. The hessian is symmetric, hence row- and column-major layout are equivalent.
"""
function dftd3_get_dispersion_hessian(error, mol, disp, param, energy, arg6)
    ccall((:dftd3_get_dispersion_hessian, libsdftd3), Cvoid, (dftd3_error, dftd3_structure, dftd3_model, dftd3_param, Ptr{Cdouble}, Ptr{Cdouble}), error, mol, disp, param, energy, arg6)
end

"""
    dftd3_get_counterpoise(error, mol, gcp, energy, gradient, sigma)

Evaluate the dispersion energy and its derivatives
"""
function dftd3_get_counterpoise(error, mol, gcp, energy, gradient, sigma)
    ccall((:dftd3_get_counterpoise, libsdftd3), Cvoid, (dftd3_error, dftd3_structure, dftd3_gcp, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), error, mol, gcp, energy, gradient, sigma)
end

"""
    dftd3_get_counterpoise_hessian(error, mol, gcp, energy, arg5)

Evaluate the analytical second derivatives of the counter-poise energy. The hessian is symmetric, hence row- and column-major layout are equivalent.
"""
function dftd3_get_counterpoise_hessian(error, mol, gcp, energy, arg5)
    ccall((:dftd3_get_counterpoise_hessian, libsdftd3), Cvoid, (dftd3_error, dftd3_structure, dftd3_gcp, Ptr{Cdouble}, Ptr{Cdouble}), error, mol, gcp, energy, arg5)
end

# Skipping MacroDefinition: SDFTD3_API_ENTRY extern

end # module
