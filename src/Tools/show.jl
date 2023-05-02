using Printf

function Base.show(io::IO, metrics::OPSMetrics)
  Printf.@printf(io, "%29s: %.3f\n", "Cumulative Return", metrics.Sn[end])
  Printf.@printf(io, "%29s: %.3f\n", "APY", metrics.APY)
  Printf.@printf(io, "%s: %.3f\n", "Annualized Standard Deviation", metrics.Ann_Std)
  Printf.@printf(io, "%29s: %.3f\n", "Annualized Sharpe Ratio", metrics.Ann_Sharpe)
  Printf.@printf(io, "%29s: %.3f\n", "Maximum Drawdown", metrics.MDD)
  Printf.@printf(io, "%29s: %.3f\n", "Calmar Ratio", metrics.Calmar)
end
