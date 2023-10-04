module OnlinePortfolioSelection

using Statistics
using LinearAlgebra
using JuMP
using Ipopt
using PrecompileTools

include("Algos/CRP.jl")
include("Algos/EG.jl")
include("Algos/RPRT.jl")
include("Algos/UP.jl")
include("Algos/CORN.jl")
include("Algos/DRICORNK.jl")
include("Algos/BS.jl")
include("Algos/BK.jl")
include("Algos/LOAD.jl")
include("Algos/Anticor.jl")
include("Algos/OLMAR.jl")
include("Types/Algorithms.jl")
include("Tools/metrics.jl")
include("Tools/show.jl")
include("Tools/tools.jl")
include("Tools/cornfam.jl")

export up, eg, cornu, cornk, dricornk, crp, bs, rprt, anticor, olmar, bk, load
export OPSMetrics, sn, apy, ann_std, ann_sharpe, mdd, calmar
export OPSAlgorithm, opsmethods

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
  println("        up: Universal Portfolio - Call `up`")
  println("        eg: Exponential Gradient - Call `eg`")
  println("     cornu: CORN-U - Call `cornu`")
  println("     cornk: CORN-K - Call `cornk`")
  println("  dricornk: DRICORN-K - Call `dricornk`")
  println("       crp: Constant Rebalanced Portfolio - Call `crp`")
  println("        bs: Best Stock - Call `bs`")
  println("      rprt: Reweighted Price Relative Tracking - Call `rprt`")
  println("   anticor: Anticor - Call `anticor`")
  println("     olmar: On-Line Moving Average Reversion - Call `olmar`")
  println("     Bᵏ: Best-Known-Constant Rebalanced Portfolio - Call `bk`")
  println("     LOAD: Local adaptive learning system - Call `load`")
end
# COV_EXCL_STOP

end #module
