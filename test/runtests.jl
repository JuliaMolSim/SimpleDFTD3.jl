using SimpleDFTD3
using LinearAlgebra
using Test

include("testcases.jl")
include("finite_difference.jl")

@testset "SimpleDFTD3.jl" begin
    include("test_lowlevel.jl")
    include("test_dispersion.jl")
    include("test_gcp.jl")
    include("test_features.jl")
end
