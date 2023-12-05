using OnlinePortfolioSelection
using JuMP
using Ipopt
using Test
using Statistics

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

@testset "Anticor.jl" begin
  @info "Run unit tests in Anticor.jl"
  include("Anticor.jl")
end

@testset "OLMAR.jl" begin
  @info "Run unit tests in OLMAR.jl"
  include("OLMAR.jl")
end

@testset "BK.jl" begin
  @info "Run unit tests in BK.jl"
  include("BK.jl")
end

@testset "LOAD.jl" begin
  @info "Run unit tests in LOAD.jl"
  include("LOAD.jl")
end

@testset "MRvol.jl" begin
  @info "Run unit tests in MRvol.jl"
  include("MRvol.jl")
end

@testset "CW-OGD.jl" begin
  @info "Run unit tests in CW-OGD.jl"
  include("CW-OGD.jl")
end

@testset "uniform.jl" begin
  @info "Run unit tests in uniform.jl"
  include("uniform.jl")
end

@testset "CLUSLOG.jl" begin
  @info "Run unit tests in CLUSLOG.jl"
  include("CLUSLOG.jl")
end

@testset "PAMR.jl" begin
  @info "Run unit tests in PAMR.jl"
  include("PAMR.jl")
end

@testset "PPT.jl" begin
  @info "Run unit tests in PPT.jl"
  include("PPT.jl")
end

@testset "CWMR.jl" begin
  @info "Run unit tests in CWMR.jl"
  include("CWMR.jl")
end

@testset "CAEG.jl" begin
  @info "Run unit tests in CAEG.jl"
  include("CAEG.jl")
end

@testset "IndivFuncs.jl" begin
  @info "Run unit tests in IndivFuncs.jl"
  include("IndivFuncs.jl")
end

@testset "OLDEM.jl" begin
  @info "Run unit tests in OLDEM.jl"
  include("OLDEM.jl")
end

@testset "AICTR.jl" begin
  @info "Run unit tests in AICTR.jl"
  include("AICTR.jl")
end

@testset "EGM.jl" begin
  @info "Run unit tests in EGM.jl"
  include("EGM.jl")
end

@testset "TPPT.jl" begin
  @info "Run unit tests in TPPT.jl"
  include("TPPT.jl")
end

@testset "GWR.jl" begin
  @info "Run unit tests in GWR.jl"
  include("GWR.jl")
end
