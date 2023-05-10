using OnlinePortfolioSelection
using JuMP
using Ipopt
using Test
using Statistics

# push!(LOAD_PATH,"../src/")

@testset "CORN.jl" begin
  @info "Run unit tests in CORN.jl"
  include("CORN.jl")
end

@testset "DRICORNK.jl" begin
  @info "Run unit tests in DRICORNK.jl"
  include("DRICORNK.jl")
end

@testset "metrics.jl" begin
  @info "Run unit tests in metrics.jl"
  include("metrics.jl")
end

@testset "UP.jl" begin
  @info "Run unit tests in UP.jl"
  include("UP.jl")
end

@testset "RPRT.jl" begin
  @info "Run unit tests in RPRT.jl"
  include("RPRT.jl")
end

@testset "EG.jl" begin
  @info "Run unit tests in EG.jl"
  include("EG.jl")
end

@testset "CRP.jl" begin
  @info "Run unit tests in CRP.jl"
  include("CRP.jl")
end

@testset "BS.jl" begin
  @info "Run unit tests in BS.jl"
  include("BS.jl")
end
