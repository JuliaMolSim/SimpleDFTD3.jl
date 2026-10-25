# SimpleDFTD3.jl

| **Build Status**                       |  **License**                     |
|:-------------------------------------- |:-------------------------------- |
| ![][ci-img] [![][ccov-img]][ccov-url]  | [![][license-img]][license-url]  |

[ci-img]: https://github.com/JuliaMolSim/SimpleDFTD3.jl/workflows/CI/badge.svg

[ccov-img]: https://codecov.io/gh/JuliaMolSim/SimpleDFTD3.jl/branch/master/graph/badge.svg?token=ZL7RUND4YE
[ccov-url]: https://codecov.io/gh/JuliaMolSim/SimpleDFTD3.jl

[license-img]: https://img.shields.io/github/license/JuliaMolSim/SimpleDFTD3.jl.svg?maxAge=2592000
[license-url]: https://github.com/JuliaMolSim/SimpleDFTD3.jl/blob/master/LICENSE


Julia bindings to [simple-dftd3](https://github.com/dftd3/simple-dftd3), the
library implementation of the DFT-D3 dispersion correction and the geometric
counterpoise correction (gCP).

## Usage

SimpleDFTD3 expects all quantities in atomic units (Bohr, Hartree).

```julia
using SimpleDFTD3

# Water, coordinates as 3 × natoms matrix in Bohr
numbers   = [8, 1, 1]
positions = [0.0   0.0    0.0
             0.0   1.43  -1.43
             0.22 -0.89  -0.89]

model   = DispersionModel(numbers, positions)
damping = RationalDamping("pbe0"; atm=true)  # D3(BJ) with three-body term

res = dispersion(model, damping)
res.energy      # Hartree
res.gradient    # 3 × natoms, Hartree/Bohr (forces are -gradient)
res.sigma       # 3 × 3 strain derivative, Hartree (virial is -sigma)

# Move the atoms and recompute, reusing the model
update_structure!(model, positions .* 1.01)
dispersion(model, damping).energy
```

### Damping parameters
Damping parameters can either be loaded from the internal library of simple-dftd3
or fully customised. To load the data from the library construct a damping struct
(`RationalDamping`, `ZeroDamping`, `ModifiedRationalDamping`, `ModifiedZeroDamping`,
`OptimizedPowerDamping`, `CSODamping` or `ZDamping`) with a string identifying the
quantum-chemical method:
```julia
RationalDamping("B3LYP"; atm=false)          # without three-body term (default)
RationalDamping("HF"; atm=true)              # including three-body term
```
For the string some internal aliases work (e.g. `PBE0` and `PBEh` map to the
same parameters). Using the function `dftd3_method_name` the method string can
also be selected with the functional identifiers used by
[Libxc.jl](https://github.com/JuliaMolSim/Libxc.jl):
```julia
dftd3_method_name([:gga_x_pbe, :gga_c_pbe])  # "pbe"
RationalDamping(dftd3_method_name(:hyb_gga_xc_b3lyp))
```
Full customisation is available by passing the parameters verbatim:
```julia
RationalDamping(s8=0.7875, a1=0.4289, a2=4.4407)  # s6=1, s9=1, alp=14 by default
```
`dispersion_identifier(damping)` returns a short label such as `"D3(BJ)"`.


### Periodic systems

```julia
lattice = [10.0 0 0; 0 10.0 0; 0 0 10.0]              # lattice vectors as columns
model = DispersionModel(numbers, positions; lattice)  # fully periodic by default
set_ewald_summation!(model; tolerance=1e-16)          # Ewald summation of the two-body term

update_structure!(model, positions; lattice=1.01lattice)  # positions and lattice can be updated
```

### Further options and properties

```julia
model = DispersionModel(numbers, positions)
set_realspace_cutoff!(model; disp2=60.0, disp3=40.0, cn=40.0, width2=5.0, width3=5.0)
set_ghost_atoms!(model, [1, 2])      # 1-based indices, disables their contributions
set_work_partition!(model, 1, 4)     # evaluate only part 1 of 4 of the interaction loops

dispersion!(gradient, nothing, model, damping)  # in-place, `nothing` skips an output
pairwise_dispersion(model, damping)  # (; pair2, pair3), natoms × natoms
dispersion_hessian(model, damping)   # (; energy, hessian), 3natoms × 3natoms
```

### Geometric counterpoise correction
```julia
gcp = GeometricCounterpoise(numbers, positions, "b3lyp"; basis="631gd")
counterpoise(gcp)            # (; energy, gradient, sigma)
counterpoise_hessian(gcp)    # (; energy, hessian)
```
The gCP methods and basis sets are case-sensitive and have no aliases.
`update_structure!`, `set_realspace_cutoff!(gcp; bas, srb)` and `set_work_partition!`
work as for `DispersionModel`.

## Low-level interface
`SimpleDFTD3.LibSDFTD3` contains `ccall` wrappers for the complete C API of
[`s-dftd3.h`](https://github.com/dftd3/simple-dftd3/blob/main/include/s-dftd3.h),
with the same names and arguments in `src/gen/LibSDFTD3.jl`, which is generated
automatically.

## Notes
- With hard real-space cutoffs (the default), the energy of periodic systems is
  slightly discontinuous as atoms move across the cutoff. Use smooth cutoffs
  (`width2`, `width3` in `set_realspace_cutoff!`) for applications that need smooth energies.
- simple-dftd3 does not report unknown method/basis combinations when computing the
  geometric counterpoise corrections. The correction is then silently zero.
- MPI parallelisation of simple-dftd3 is not exposed.
