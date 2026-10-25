# Canonical mapping of functional names used by Libxc to the identifiers used by simple-dftd3
# As new methods in simple-dftd3 become available, this should be extended.
const LIBXC_TO_D3 = Dict{Set{Symbol},String}(
    Set([:lda_x])                                    => "slaterdiracexchange",
    Set([:gga_c_bmk, :hyb_mgga_x_bmk])               => "bmk",
    Set([:gga_c_hyb_tau_hcth, :hyb_mgga_x_tau_hcth]) => "tauhcthhyb",
    Set([:gga_c_lyp, :gga_x_b88])                    => "blyp",
    Set([:gga_c_lyp, :gga_x_mpw91])                  => "mpwlyp",
    Set([:gga_c_lyp, :gga_x_optx])                   => "olyp",
    Set([:gga_c_n12, :gga_x_n12])                    => "n12",
    Set([:gga_c_n12_sx, :hyb_gga_x_n12_sx])          => "n12sx",
    Set([:gga_c_p86, :gga_x_b88])                    => "bp",
    Set([:gga_c_pbe, :gga_x_b88])                    => "bpbe",
    Set([:gga_c_pbe, :gga_x_optx])                   => "opbe",
    Set([:gga_c_pbe, :gga_x_pbe])                    => "pbe",
    Set([:gga_c_pbe, :gga_x_pbe_r])                  => "revpbe",
    Set([:gga_c_pbe, :gga_x_rpbe])                   => "rpbe",
    Set([:gga_c_pbe, :gga_x_rpw86])                  => "rpw86pbe",
    Set([:gga_c_pbe_sol, :gga_x_pbe_sol])            => "pbesol",
    Set([:gga_c_pw91, :gga_x_mpw91])                 => "mpwpw",
    Set([:gga_c_pw91, :gga_x_pw91])                  => "pw91",
    Set([:gga_c_sogga11_x, :hyb_gga_x_sogga11_x])    => "sogga11x",
    Set([:gga_c_tau_hcth, :mgga_x_tau_hcth])         => "tauhcth",
    Set([:gga_xc_b97_3c])                            => "b973c",
    Set([:gga_xc_b97_d])                             => "b97d",
    Set([:gga_xc_hcth_120])                          => "hcth120",
    Set([:gga_xc_hcth_407])                          => "hcth407",
    Set([:gga_xc_xlyp])                              => "xlyp",
    Set([:hyb_gga_xc_b1lyp])                         => "b1lyp",
    Set([:hyb_gga_xc_b3lyp3])                        => "b3lyp3",
    Set([:hyb_gga_xc_b3lyp5])                        => "b3lyp",
    Set([:hyb_gga_xc_b3lyp])                         => "b3lyp",
    Set([:hyb_gga_xc_b3p86])                         => "b3p",
    Set([:hyb_gga_xc_b3pw91])                        => "b3pw91",
    Set([:hyb_gga_xc_b97_1])                         => "b971",
    Set([:hyb_gga_xc_b97_2])                         => "b972",
    Set([:hyb_gga_xc_bhandhlyp])                     => "bhlyp",
    Set([:hyb_gga_xc_cam_b3lyp])                     => "camb3lyp",
    Set([:hyb_gga_xc_hse03])                         => "hse03",
    Set([:hyb_gga_xc_hse06])                         => "hse06",
    Set([:hyb_gga_xc_hse_sol])                       => "hsesol",
    Set([:hyb_gga_xc_lc_wpbe])                       => "lcwpbe",
    Set([:hyb_gga_xc_mpw1lyp])                       => "mpw1lyp",
    Set([:hyb_gga_xc_mpw1pw])                        => "mpw1pw",
    Set([:hyb_gga_xc_o3lyp])                         => "o3lyp",
    Set([:hyb_gga_xc_pbe38])                         => "pbe38",
    Set([:hyb_gga_xc_pbeh])                          => "pbe0",
    # Note: :hyb_gga_xc_wb97x has no D3 corrections used during fit, should not get any
    #       during application
    Set([:hyb_gga_xc_wb97x_d3])                      => "wb97x",
    Set([:hyb_gga_xc_x3lyp])                         => "x3lyp",
    Set([:mgga_c_m06_l, :mgga_x_m06_l])              => "m06l",
    Set([:mgga_c_m11_l, :mgga_x_m11_l])              => "m11l",
    Set([:mgga_c_mn12_l, :mgga_x_mn12_l])            => "mn12l",
    Set([:mgga_c_mn15_l, :mgga_x_mn15_l])            => "mn15l",
    Set([:mgga_c_pkzb, :mgga_x_pkzb])                => "pkzb",
    Set([:mgga_c_r2scan, :mgga_x_r2scan])            => "r2scan",
    Set([:mgga_c_revtpss, :mgga_x_revtpss])          => "revtpss",
    Set([:mgga_c_rscan, :mgga_x_rscan])              => "rscan",
    Set([:mgga_c_scan, :mgga_x_scan])                => "scan",
    Set([:mgga_c_tpss, :mgga_x_tpss])                => "tpss",
    Set([:hyb_mgga_xc_b88b95])                       => "b1b95",
    Set([:hyb_mgga_x_cf22d, :mgga_c_cf22d])          => "cf22d",
    Set([:hyb_mgga_xc_mpw1b95])                      => "mpw1b95",
    Set([:hyb_mgga_xc_mpw1kcis])                     => "mpw1kcis",
    Set([:hyb_mgga_xc_mpwb1k])                       => "mpwb1k",
    Set([:hyb_mgga_xc_mpwkcis1k])                    => "mpwkcis1k",
    Set([:hyb_mgga_xc_pbe1kcis])                     => "pbe1kcis",
    Set([:hyb_mgga_xc_pw6b95])                       => "pw6b95",
    Set([:hyb_mgga_xc_pwb6k])                        => "pwb6k",
    Set([:hyb_mgga_xc_r2scan0])                      => "r2scan0",
    Set([:hyb_mgga_xc_r2scan50])                     => "r2scan50",
    Set([:hyb_mgga_xc_r2scanh])                      => "r2scanh",
    Set([:hyb_mgga_xc_revtpssh])                     => "revtpssh",
    Set([:hyb_mgga_xc_tpss0])                        => "tpss0",
    Set([:hyb_mgga_xc_tpss1kcis])                    => "tpss1kcis",
    Set([:hyb_mgga_xc_tpssh])                        => "tpssh",
    Set([:hyb_mgga_x_m05_2x, :mgga_c_m05_2x])        => "m052x",
    Set([:hyb_mgga_x_m05, :mgga_c_m05])              => "m05",
    Set([:hyb_mgga_x_m06_2x, :mgga_c_m06_2x])        => "m062x",
    Set([:hyb_mgga_x_m06_hf, :mgga_c_m06_hf])        => "m06hf",
    Set([:hyb_mgga_x_m06, :mgga_c_m06])              => "m06",
    Set([:hyb_mgga_x_m08_hx, :mgga_c_m08_hx])        => "m08hx",
    Set([:hyb_mgga_x_m11, :mgga_c_m11])              => "m11",
    Set([:hyb_mgga_x_mn12_sx, :mgga_c_mn12_sx])      => "mn12sx",
    Set([:hyb_mgga_x_mn15, :mgga_c_mn15])            => "mn15",
)


"""
    dftd3_method_name([libxc_symbol]) -> String

Canonical simple dftd3 method name for a DFT functional identified by a list of
Libxc identifier `Symbol`s as used by the
[Libxc.jl](https://github.com/JuliaMolSim/Libxc.jl) library to select functionals.

Examples:

```julia
dftd3_method_name([:gga_x_pbe, :gga_c_pbe])   # "pbe"
dftd3_method_name(:hyb_gga_xc_b3lyp)          # "b3lyp"
```
"""
function dftd3_method_name(xc::Set{Symbol})
    if haskey(LIBXC_TO_D3, xc)
        return LIBXC_TO_D3[xc]
    else
        throw(ArgumentError("No DFTD3 method name known for the Libxc functionals " *
                            "$(sort!(collect(xc)))"))
    end
end
dftd3_method_name(xc::AbstractVector{Symbol}) = dftd3_method_name(Set(xc))
dftd3_method_name(xc::Symbol) = dftd3_method_name(Set([xc]))

