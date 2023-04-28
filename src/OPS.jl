module OPS

include("Algos/CRP.jl")
include("Algos/EG.jl")
include("Algos/RPRT.jl")
include("Algos/UP.jl")
include("Algos/CORN.jl")
include("Algos/DRICORNK.jl")
include("Tools/metrics.jl")
include("Types/Algorithms.jl")

export UP, EG, RPRT, UP, CORNU, CORNK, DRICORNK, CRP
export OPSMetrics, Sn, APY, MDD, Calmar, Ann_Sharpe
export OPSAlgorithm


end #module
