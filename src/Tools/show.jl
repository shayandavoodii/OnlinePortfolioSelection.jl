# COV_EXCL_START
function Base.show(io::IO, metrics::OPSMetrics)
  println()
  println(io, "            Cumulative Return: ", metrics.Sn[end])
  println(io, "                          APY: ", metrics.APY)
  println(io, "Annualized Standard Deviation: ", metrics.Ann_Std)
  println(io, "      Annualized Sharpe Ratio: ", metrics.Ann_Sharpe)
  println(io, "             Maximum Drawdown: ", metrics.MDD)
  println(io, "                 Calmar Ratio: ", metrics.Calmar)
end
# COV_EXCL_STOP
