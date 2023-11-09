module OnlinePortfolioSelection

using Statistics
using LinearAlgebra
using JuMP
using Ipopt
using PrecompileTools
using DataStructures

include("Types/Algorithms.jl")
include("Types/Clustering.jl")
include("Types/PAMR.jl")
include("Types/CWMR.jl")
include("Algos/CRP.jl")
include("Algos/CW-OGD.jl")
include("Algos/EG.jl")
include("Algos/RPRT.jl")
include("Algos/UP.jl")
include("Algos/CORN.jl")
include("Algos/DRICORNK.jl")
include("Algos/BS.jl")
include("Algos/BK.jl")
include("Algos/LOAD.jl")
include("Algos/Anticor.jl")
include("Algos/MRvol.jl")
include("Algos/OLMAR.jl")
include("Algos/uniform.jl")
include("Algos/PAMR.jl")
include("Algos/CLUSLOG.jl")
include("Algos/PPT.jl")
include("Algos/cwmr.jl")
include("Tools/metrics.jl")
include("Tools/show.jl")
include("Tools/tools.jl")
include("Tools/cornfam.jl")

export up, eg, cornu, cornk, dricornk, crp, bs, rprt, anticor, olmar, bk, load, mrvol, cwogd
export uniform, cluslog, pamr, ppt, cwmr
export OPSMetrics, sn, mer, apy, ann_std, ann_sharpe, mdd, calmar
export OPSAlgorithm, KMNLOG, KMDLOG, ClusLogVariant, PAMR, PAMR1, PAMR2
export CWMRD, CWMRS, Var, Stdev
export opsmethods

@setup_workload begin
  adj_close = rand(3, 23)
  market_adjclose = rand(23)

  @compile_workload begin
    cornu(adj_close, 1, 2)
    cornk(adj_close, 1, 2, 2, 2)
    dricornk(adj_close, market_adjclose, 1, 2, 2, 2)
  end
end

# COV_EXCL_START
"""
    opsmethods()

Print the available methods in the package.

# Example
```julia
julia> using OnlinePortfolioSelection

julia> opsmethods()

      ===== OnlinePortfolioSelection.jl =====
            Currently available methods
       =====================================

        up: Universal Portfolio - Call `up`
        eg: Exponential Gradient - Call `eg`
     cornu: CORN-U - Call `cornu`
          ⋮
```
"""
function opsmethods()
  println("\n", " "^5, " ===== OnlinePortfolioSelection.jl =====")
  println(" "^5, " "^7, "Currently available methods")
  println(" "^6, " ", "="^37, "\n")
  println("        UP: Universal Portfolio - Call `up`")
  println("        EG: Exponential Gradient - Call `eg`")
  println("     CORNU: CORN-U - Call `cornu`")
  println("     CORNK: CORN-K - Call `cornk`")
  println("  DRICORNK: DRICORN-K - Call `dricornk`")
  println("       CRP: Constant Rebalanced Portfolio - Call `crp`")
  println("        BS: Best Stock - Call `bs`")
  println("      RPRT: Reweighted Price Relative Tracking - Call `rprt`")
  println("   ANTICOR: Anticor - Call `anticor`")
  println("     OLMAR: On-Line Moving Average Reversion - Call `olmar`")
  println("        Bᵏ: Best-Known-Constant Rebalanced Portfolio - Call `bk`")
  println("      LOAD: Local adaptive learning system - Call `load`")
  println("     MRvol: Mean Reversion with Volume - Call `mrvol`")
  println("    CW-OGD: Combination Weights based on Online Gradient Decent - Call `cwogd`")
  println("   uniform: Uniform Portfolio - Call `uniform`")
  println("   ClusLog: Clustering and logarithmic expected return - Call `cluslog`")
  println("      PAMR: Passive Aggressive Mean Reversion - Call `pamr`")
  println("       PPT: Peak Price Tracking - Call `ppt`")
  println("      CWMR: Confidence Weighted Mean Reversion - Call `cwmr`")
end
# COV_EXCL_STOP

end #module
