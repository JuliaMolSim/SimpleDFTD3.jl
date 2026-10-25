@testset "Loading damping parameters" begin
    # Case-insensitive, aliases, dashes
    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    ref = dispersion(m, RationalDamping("pbe0")).energy
    @test dispersion(m, RationalDamping("PBE0")).energy ≈ ref atol=1e-14
    @test dispersion(m, RationalDamping("pbeh")).energy ≈ ref atol=1e-14
    @test dispersion(m, RationalDamping("B3-LYP")).energy ≈
          dispersion(m, RationalDamping("b3lyp")).energy      atol=1e-14

    # Unknown methods
    err = @test_throws DFTD3Error RationalDamping("not-a-functional")
    @test occursin("not-a-functional", err.value.msg)
end

@testset "dispersion_identifier" begin
    @test dispersion_identifier(RationalDamping("pbe")) == "D3(BJ)"
    @test dispersion_identifier(ZeroDamping("pbe")) == "D3(0)"
    @test dispersion_identifier(ModifiedRationalDamping("pbe")) == "D3M(BJ)"
    @test dispersion_identifier(ModifiedZeroDamping("pbe")) == "D3M(0)"
    @test dispersion_identifier(OptimizedPowerDamping("pbe")) == "D3(op)"
    @test dispersion_identifier(CSODamping("pbe")) == "D3(CSO)"
    @test dispersion_identifier(ZDamping(s8=1.0, a1=200770.0)) == "D3(Z)"
end

@testset "Libxc mapping" begin
    @test dftd3_method_name([:gga_x_pbe, :gga_c_pbe]) == "pbe"
    @test dftd3_method_name([:gga_c_pbe, :gga_x_pbe]) == "pbe"
    @test dftd3_method_name(Set([:gga_x_pbe, :gga_c_pbe])) == "pbe"
    @test dftd3_method_name(:hyb_gga_xc_b3lyp) == "b3lyp"
    @test dftd3_method_name([:hyb_gga_xc_pbeh]) == "pbe0"
    @test dftd3_method_name([:gga_x_b88, :gga_c_lyp]) == "blyp"
    @test dftd3_method_name([:mgga_x_r2scan, :mgga_c_r2scan]) == "r2scan"
    @test dftd3_method_name([:hyb_gga_xc_wb97x_d3]) == "wb97x"

    err = @test_throws ArgumentError dftd3_method_name([:gga_x_pbe])
    @test occursin("gga_x_pbe", err.value.msg)
    @test_throws ArgumentError dftd3_method_name([:hyb_gga_xc_wb97x])
    @test_throws ArgumentError dftd3_method_name([:gga_x_pbe, :gga_c_pbe, :lda_x])
end

@testset "Reference energies" begin
    # Reference energies from the s-dftd3 Python test suite (python/dftd3/test_interface.py),
    # compared with the same relative tolerance as upstream (pytest.approx default)

    m = DispersionModel(MB16_NUMBERS, MB16_POSITIONS)
    energy(d) = dispersion(m, d).energy

    @test energy(RationalDamping("pbe0"; atm=true))         ≈ -0.02948923293249488 rtol=1e-6
    @test energy(RationalDamping("pbe0"; atm=false))        ≈ -0.02958913263417834 rtol=1e-6
    @test energy(ZeroDamping("b3lyp"; atm=true))            ≈ -0.02271427255517565 rtol=1e-6
    @test energy(ZeroDamping("b3lyp"; atm=false))           ≈ -0.02281417201916605 rtol=1e-6
    @test energy(ModifiedRationalDamping("pbe"; atm=true))  ≈ -0.06327406660942464 rtol=1e-6
    @test energy(ModifiedRationalDamping("pbe"; atm=false)) ≈ -0.06337396631110809 rtol=1e-6
    @test energy(ModifiedZeroDamping("bp"; atm=true))       ≈ -0.02601331686903629 rtol=1e-6
    @test energy(ModifiedZeroDamping("bp"; atm=false))      ≈ -0.02611321633302669 rtol=1e-6
    @test energy(OptimizedPowerDamping("b97d"; atm=true))   ≈ -0.07681029606751344 rtol=1e-6
    @test energy(OptimizedPowerDamping("b97d"; atm=false))  ≈ -0.07691018779028679 rtol=1e-6
    @test energy(ZDamping(s8=1.0, a1=200770.0, s9=1.0))     ≈ -0.00574149022453336 rtol=1e-6
    @test energy(ZDamping(s8=1.0, a1=200770.0, s9=0.0))     ≈ -0.00584138968852376 rtol=1e-6
end
