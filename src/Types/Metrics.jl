"""
    OPSMetrics{T<:AbstractFloat}

A struct to store the metrics of the OPS algorithm.

# Fields
- `Sn::Vector{T}`: the cumulative return of investment during the investment period.
- `MER::T`: the investments's Mean excess return (MER).
- `IR::T`: the Information Ratio (IR) of portfolio for the investment period.
- `APY::T`: the Annual Percentage Yield (APY) of investment.
- `Ann_Std::T`: the Annualized Standard Deviation (σₚ) of investment.
- `Ann_Sharpe::T`: the Annualized Sharpe Ratio (SR) of investment.
- `MDD::T`: the Maximum Drawdown (MDD) of investment.
- `Calmar::T`: the Calmar Ratio of investment.
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
end
