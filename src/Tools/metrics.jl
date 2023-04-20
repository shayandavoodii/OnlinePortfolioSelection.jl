using Printf

"""
    OPSMetrics(APY::T, Ann_Sharpe::T, MDD::T, Calmar::T) where {T<:Float64}

A struct to store the metrics of the OPS algorithm.

# Fields
- `Sn::Vector{T}`: the cumulative return of investment during the investment period.
- `APY::T`: the Annual Percentage Yield (APY) of investment.
- `Ann_Std::T`: the Annualized Standard Deviation (σₚ) of investment.
- `Ann_Sharpe::T`: the Annualized Sharpe Ratio (SR) of investment.
- `MDD::T`: the Maximum Drawdown (MDD) of investment.
- `Calmar::T`: the Calmar Ratio of investment.
"""
struct OPSMetrics{T<:Float64}
  Sn::Vector{T}
  APY::T
  Ann_Std::T
  Ann_Sharpe::T
  MDD::T
  Calmar::T
end;

function Base.show(io::IO, metrics::OPSMetrics)
  # println("-"^10, " Metrics ", "-"^10, " " ,"-"^1, " Value ", "-"^1)
  @printf(io, "%29s: %.3f\n", "Cumulative Return", metrics.Sn[end])
  @printf(io, "%29s: %.3f\n", "APY", metrics.APY)
  @printf(io, "%s: %.3f\n", "Annualized Standard Deviation", metrics.Ann_Std)
  @printf(io, "%29s: %.3f\n", "Annualized Sharpe Ratio", metrics.Ann_Sharpe)
  @printf(io, "%29s: %.3f\n", "Maximum Drawdown", metrics.MDD)
  @printf(io, "%29s: %.3f\n", "Calmar Ratio", metrics.Calmar)
end;

"""
    Sn(weights::Matrix{T}, rel_pr::Matrix{T}; init_inv::T=1.) where T<:Float64

Calculate the cumulative return of investment during a period of time.

# Arguments
- `weights::Matrix{T}`: the weights of the portfolio.
- `rel_pr::Matrix{T}`: the relative price of the stocks.
- `init_inv::T=1`: the initial investment.

!!! warning
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

# Returns
- `all_sn::Vector{T}`: the cumulative return of investment during the investment period.
"""
function Sn(weights::Matrix{T}, rel_pr::Matrix{T}; init_inv::T=1.) where T<:Float64
  n_periods = size(rel_pr, 2)

  if size(weights, 2) ≠ n_periods
    rel_pr = rel_pr[:, end-size(weights, 2)+1:end]
    n_periods = size(rel_pr, 2)
  end

  all_sn = zeros(T, n_periods+1)
  all_sn[1] = init_inv

  for t ∈ 2:n_periods+1
      all_sn[t] = all_sn[t-1] * (rel_pr[:, t-1]' * weights[:, t-1])
  end

  all_sn
end;

"""
    APY(Sn::Float64, n_periods::S; dpy::S=252) where S<:Int

Calculate the Annual Percentage Yield (APY) of investment.

# Arguments
- `Sn::Float64`: the cumulative return of investment.
- `n_periods::S`: the number investment periods.
- `dpy::S=252`: the number of days in a year.

# Returns
- `::Float64`: the APY of investment.
"""
function APY(Sn::Float64, n_periods::S; dpy::S=252) where S<:Int
  y = n_periods/dpy
  (Sn)^(1/y) - 1
end;

"""
    Ann_Sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:Float64

Calculate the Annualized Sharpe Ratio of investment.

# Arguments
- APY::T: the APY of investment.
- Rf::T: the risk-free rate of return.
- sigma_prtf::T: the standard deviation of the portfolio ``\\sigma_p``.

# Returns
- `::Float64`: the Annualized Sharpe Ratio of investment.
"""
Ann_Sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:Float64 = (APY - Rf)/sigma_prtf;

"""
    MDD(Sn::Vector{T}) where T<:Float64

Calculate the Maximum Drawdown (MDD) of investment.

# Arguments
- `Sn::Vector{T}`: the cumulative return of investment during the investment period.

# Returns
- `::Float64`: the MDD of investment.
"""
function MDD(Sn::Vector{T}) where T<:Float64
  n_periods = length(Sn)
  max_sn = zeros(T, n_periods)
  max_sn[1] = Sn[1]

  for t ∈ 2:n_periods
      max_sn[t] = max(max_sn[t-1], Sn[t])
  end

  max_dd = zeros(T, n_periods)

  for t ∈ 1:n_periods
      max_dd[t] = (max_sn[t] - Sn[t])/max_sn[t]
  end

  maximum(max_dd)
end;

"""
    Calmar(APY::T, MDD::T) where T<:Float64

Calculate the Calmar Ratio of investment.

# Arguments
- `APY::T`: the APY of investment.
- `MDD::T`: the MDD of investment.

# Returns
- `::Float64`: the Calmar Ratio of investment.
"""
Calmar(APY::T, MDD::T) where T<:Float64 = APY/MDD;

"""
    OPSMetrics(
      weights::Matrix{T},
      rel_pr::Matrix{T};
      init_inv::T=1.,
      Rf::T=0.02
    ) where T<:Float64

Calculate the metrics of an OPS algorithm.

# Arguments
- `weights::Matrix{T}`: the weights of the portfolio.
- `rel_pr::Matrix{T}`: the relative price of the stocks.
- `init_inv::T=1`: the initial investment.
- `Rf::T=0.02`: the risk-free rate of return.

!!! warning
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

# Returns
- `::OPSMetrics`: the metrics of the OPS algorithm.
"""
function OPSMetrics(
  weights::Matrix{T},
  rel_pr::Matrix{T};
  init_inv::T=1.,
  Rf::T=0.02,
  dpy::S=252
) where {T<:Float64, S<:Int}

  all_sn = Sn(weights, rel_pr, init_inv=init_inv)
  n_periods = size(rel_pr, 2)
  σₚ = std(diff(all_sn)) * sqrt(dpy)
  apy = APY(all_sn[end], n_periods, dpy=dpy)
  ann_Sharpe = Ann_Sharpe(apy, Rf, σₚ)
  MDD_ = MDD(all_sn)
  calmar = Calmar(apy, MDD_)

  OPSMetrics(all_sn, apy, σₚ, ann_Sharpe, MDD_, calmar)
end;
