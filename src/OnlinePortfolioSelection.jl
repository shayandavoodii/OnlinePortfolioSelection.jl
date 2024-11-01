module OnlinePortfolioSelection

using Statistics:      cor, var, mean, median, std
using LinearAlgebra:   I, norm, Symmetric, diagm, tr, diagind, svd
using JuMP:            Model, @variable, @constraint, @NLobjective, @expression, @objective
using JuMP:            value, @NLconstraint, set_silent, optimize!, optimizer_with_attributes, objective_value
using Ipopt:           Optimizer
using PrecompileTools: @setup_workload, @compile_workload
using StatsBase:       sample

include("Types/Algorithms.jl")
include("Types/Clustering.jl")
include("Types/PAMR.jl")
include("Types/CWMR.jl")
include("Types/AICTR.jl")
include("Types/EGM.jl")
include("Types/RMR.jl")
include("Types/TCO.jl")
include("Types/Metrics.jl")
include("Algos/BCRP.jl")
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
include("Algos/CWMR.jl")
include("Algos/CAEG.jl")
include("Algos/OLDEM.jl")
include("Algos/AICTR.jl")
include("Algos/EGM.jl")
include("Algos/TPPT.jl")
include("Algos/GWR.jl")
include("Algos/ONS.jl")
include("Algos/DMR.jl")
include("Algos/RMR.jl")
include("Algos/SSPO.jl")
include("Algos/KTPT.jl")
include("Algos/WAEG.jl")
include("Algos/MAEG.jl")
include("Algos/SPOLC.jl")
include("Algos/TCO.jl")
include("Tools/metrics.jl")
include("Tools/show.jl")
include("Tools/tools.jl")
include("Tools/cornfam.jl")

export up, eg, cornu, cornk, dricornk, bcrp, bs, rprt, anticor, olmar, bk, load, mrvol, cwogd
export uniform, cluslog, pamr, ppt, cwmr, caeg, oldem, aictr, egm, tppt, gwr, ons, dmr, rmr, sspo
export waeg, maeg, spolc, tco
export opsmetrics, sn, mer, apy, ann_std, ann_sharpe, mdd, calmar, ir, at, ttest
export OPSAlgorithm, OPSMetrics, KMNLOG, KMDLOG, PAMR, PAMR1, PAMR2
export CWMRD, CWMRS, Var, Stdev
export SMAP, SMAR, EMA, PP
export EGE, EGR, EGA, ktpt
export TCO1, TCO2
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

Print the available algorithms in the package.

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
  println("      BCRP: Best Constant Rebalanced Portfolio - Call `crp`")
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
  println("      CAEG: Continuous Aggregating Exponential Gradient - Call `caeg`")
  println("     OLDEM: Online Low Dimension Ensemble Method - Call `oldem`")
  println("     AICTR: Adaptive Input and Composite Trend Representation - Call `aictr`")
  println("       EGM: Exponential Gradient with Momentum - Call `egm`")
  println("      TPPT: Trend Promote Price Tracking - Call `tppt`")
  println("       GWR: Gaussian Weighting Reversion - Call `gwr`")
  println("       ONS: Online Newton Step - Call `ons`")
  println("       DMR: Distributed Mean Reversion (DMR) - Call `dmr`")
  println("       RMR: Robust Median Reversion - Call `rmr`")
  println("      SSPO: Short-term Sparse Portfolio Optimization - Call `sspo`")
  println("      WAEG: Weak Aggregating Exponential Gradient - Call `waeg`")
  println("      MAEG: Moving-window-based Adaptive Exponential Gradient - Call `maeg`")
  println("     SPOLC: loss control strategy for short-term portfolio optimization (SPOLC) - Call `spolc`")
  println("       TCO: Transaction Cost Optimization - Call `tco`")
  println("      KTPT: kernel-based trend pattern tracking system - Call `ktpt`")
end
# COV_EXCL_STOP

end #module
