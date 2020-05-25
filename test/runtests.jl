#!/usr/bin/env julia

using FountainCodes, Test, Random
Random.seed!(123) # reproducible tests
println("Starting tests")

@time @testset "Numerical function inversion" begin include("Numinv_test.jl") end
@time @testset "GF256" begin include("GF256_test.jl") end
@time @testset "CodedMvNormal" begin include("CodedMvNormal_test.jl") end
@time @testset "Soliton distribution" begin include("Soliton_test.jl") end
@time @testset "Gray sequence" begin include("Gray_test.jl") end
@time @testset "QMatrix" begin include("QMatrix_test.jl") end
@time @testset "Decoder" begin include("Decoder_test.jl") end
@time @testset "LT" begin include("LT_test.jl") end
@time @testset "LTQ" begin include("LTQ_test.jl") end
@time @testset "R10" begin include("R10_test.jl") end

# @time @testset "RQ" begin include("RQ_test.jl") end
# @time @testset "LDPC codes" begin include("LDPC_test.jl") end
# @testset "Benchmarks" begin include("Benchmarks.jl") end
