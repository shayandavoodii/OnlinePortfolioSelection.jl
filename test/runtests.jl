using OPS
using JuMP
using Ipopt
using Test
using Statistics

push!(LOAD_PATH,"../src/")

@testset "CORN.jl" begin
  @info "Run unit tests in CORN.jl"
  include("CORN.jl")
end
