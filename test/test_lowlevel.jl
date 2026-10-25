using SimpleDFTD3: LibSDFTD3
using Test

@testset "Low-level API" begin
    @test SimpleDFTD3.simple_dftd3_version == v"1.6.0"
    @test LibSDFTD3.dftd3_get_version() == 10600
    @test LibSDFTD3.dftd3_has_feature("mpi") isa Bool

    # Raw handle life cycle, mirroring the C API test
    err = LibSDFTD3.dftd3_new_error()
    @test LibSDFTD3.dftd3_check_error(err) == 0
    nums = Cint[1, 1]
    xyz = [0.0 0.0; 0.0 0.0; 0.0 1.4]
    mol = LibSDFTD3.dftd3_new_structure(err, 2, nums, xyz, C_NULL, C_NULL)
    @test LibSDFTD3.dftd3_check_error(err) == 0
    disp = LibSDFTD3.dftd3_new_d3_model(err, mol)
    param = LibSDFTD3.dftd3_new_rational_damping(err, 1.0, 0.7875, 0.0, 0.4289, 4.4407, 14.0)
    energy = Ref(0.0)
    LibSDFTD3.dftd3_get_dispersion(err, mol, disp, param, energy, C_NULL, C_NULL)
    @test LibSDFTD3.dftd3_check_error(err) == 0
    @test energy[] < 0

    # Errors are reported through the handle
    LibSDFTD3.dftd3_load_rational_damping(err, "not-a-functional", true)
    @test LibSDFTD3.dftd3_check_error(err) != 0

    LibSDFTD3.dftd3_delete_param(Ref(param))
    LibSDFTD3.dftd3_delete_model(Ref(disp))
    LibSDFTD3.dftd3_delete_structure(Ref(mol))
    LibSDFTD3.dftd3_delete_error(Ref(err))
end

@testset "Error handling" begin
    e = @test_throws DFTD3Error SimpleDFTD3.with_error() do err
        LibSDFTD3.dftd3_load_rational_damping(err, "not-a-functional", true)
    end
    @test occursin("not-a-functional", e.value.msg)
    @test occursin("DFTD3Error", sprint(showerror, e.value))
end
