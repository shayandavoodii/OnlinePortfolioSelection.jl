# COV_EXCL_START
function Base.show(io::IO, metrics::OPSMetrics)
  println()
  println(io, "            Cumulative Wealth: ", metrics.Sn[end])
  println(io, "        Mean Excessive Return: ", metrics.MER)
  println(io, "            Information Ratio: ", metrics.IR)
  println(io, "  Annualized Percentage Yield: ", metrics.APY)
  println(io, "Annualized Standard Deviation: ", metrics.Ann_Std)
  println(io, "      Annualized Sharpe Ratio: ", metrics.Ann_Sharpe)
  println(io, "             Maximum Drawdown: ", metrics.MDD)
  println(io, "                 Calmar Ratio: ", metrics.Calmar)
  println(io, "             Average Turnover: ", metrics.AT)
end
# COV_EXCL_STOP
