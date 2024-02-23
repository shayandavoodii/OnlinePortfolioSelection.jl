using OnlinePortfolioSelection
using JuMP
using Ipopt
using Test
using Statistics

@testset "Algorithms" begin
  @info "Run unit tests in CORN.jl"
  include("CORN.jl")
  @info "Run unit tests in DRICORNK.jl"
  include("DRICORNK.jl")
  @info "Run unit tests in UP.jl"
  include("UP.jl")
  @info "Run unit tests in RPRT.jl"
  include("RPRT.jl")
  @info "Run unit tests in EG.jl"
  include("EG.jl")
  @info "Run unit tests in CRP.jl"
  include("BCRP.jl")
  @info "Run unit tests in BS.jl"
  include("BS.jl")
  @info "Run unit tests in Anticor.jl"
  include("Anticor.jl")
  @info "Run unit tests in OLMAR.jl"
  include("OLMAR.jl")
  @info "Run unit tests in BK.jl"
  include("BK.jl")
  @info "Run unit tests in LOAD.jl"
  include("LOAD.jl")
  @info "Run unit tests in MRvol.jl"
  include("MRvol.jl")
  @info "Run unit tests in CW-OGD.jl"
  include("CW-OGD.jl")
  @info "Run unit tests in uniform.jl"
  include("uniform.jl")
  @info "Run unit tests in CLUSLOG.jl"
  include("CLUSLOG.jl")
  @info "Run unit tests in PAMR.jl"
  include("PAMR.jl")
  @info "Run unit tests in PPT.jl"
  include("PPT.jl")
  @info "Run unit tests in CWMR.jl"
  include("CWMR.jl")
  @info "Run unit tests in CAEG.jl"
  include("CAEG.jl")
  @info "Run unit tests in IndivFuncs.jl"
  include("IndivFuncs.jl")
  @info "Run unit tests in OLDEM.jl"
  include("OLDEM.jl")
  @info "Run unit tests in AICTR.jl"
  include("AICTR.jl")
  @info "Run unit tests in EGM.jl"
  include("EGM.jl")
  @info "Run unit tests in TPPT.jl"
  include("TPPT.jl")
  @info "Run unit tests in GWR.jl"
  include("GWR.jl")
  @info "Run unit tests in ONS.jl"
  include("ONS.jl")
  @info "Run unit tests in DMR.jl"
  include("DMR.jl")
  @info "Run unit tests in RMR.jl"
  include("RMR.jl")
  @info "Run unit tests in SSPO.jl"
  include("SSPO.jl")
  @info "Run unit tests in WAEG.jl"
  include("WAEG.jl")
end

@testset "metrics.jl" begin
  @info "Run unit tests in metrics.jl"
  include("metrics.jl")
end
