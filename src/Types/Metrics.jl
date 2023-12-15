"""
    OPSMetrics{T<:AbstractFloat}

A struct to store the metrics of the OPS algorithm. This object is returned by the \
[`opsmetrics`](@ref) function.

# Fields
- `Sn::Vector{T}`: The cumulative return of investment during the investment period.
- `MER::T`: The investments's Mean excess return (MER).
- `IR::T`: The Information Ratio (IR) of portfolio for the investment period.
- `APY::T`: The Annual Percentage Yield (APY) of investment.
- `Ann_Std::T`: The Annualized Standard Deviation (σₚ) of investment.
- `Ann_Sharpe::T`: The Annualized Sharpe Ratio (SR) of investment.
- `MDD::T`: The Maximum Drawdown (MDD) of investment.
- `Calmar::T`: The Calmar Ratio of investment.
- `AT::T`: The Average Turnover (AT) of the investment.
"""
struct OPSMetrics{T<:AbstractFloat}
  Sn::Vector{T}
  MER::T
  IR::T
  APY::T
  Ann_Std::T
  Ann_Sharpe::T
  MDD::T
  Calmar::T
  AT::T
end
