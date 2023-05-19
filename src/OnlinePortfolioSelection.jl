module OnlinePortfolioSelection

include("Algos/CRP.jl")
include("Algos/EG.jl")
include("Algos/RPRT.jl")
include("Algos/UP.jl")
include("Algos/CORN.jl")
include("Algos/DRICORNK.jl")
include("Algos/BS.jl")
include("Algos/Anticor.jl")
include("Types/Algorithms.jl")
include("Tools/metrics.jl")
include("Tools/show.jl")
include("Algos/BS.jl")
include("Tools/tools.jl")
include("Tools/cornfam.jl")

export up, eg, cornu, cornk, dricornk, crp, bs, rprt, anticor
export OPSMetrics, sn, apy, ann_std, ann_sharpe, mdd, calmar
export OPSAlgorithm

using PrecompileTools

if VERSION≥v"1.9.0-rc3"
  @setup_workload begin
    adj_close = rand(3, 23)
    market_adjclose = rand(23)

    @compile_workload begin
      cornu(adj_close, 1, 2)
      cornk(adj_close, 1, 2, 2, 2)
      dricornk(adj_close, market_adjclose, 1, 2, 2, 2)
    end
  end
end

end #module
