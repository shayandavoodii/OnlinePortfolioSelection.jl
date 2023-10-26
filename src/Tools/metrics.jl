"""
    OPSMetrics(Sn::Vector{T}, APY::T, Ann_Sharpe::T, MDD::T, Calmar::T) where {T<:Float64}

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
end

"""
    sn(weights::Matrix{T}, rel_pr::Matrix{T}; init_inv::T=1.) where T<:Float64

Calculate the cumulative return of investment during a period of time.

# Arguments
- `weights::Matrix{T}`: the weights of the portfolio.
- `rel_pr::Matrix{T}`: the relative price of the stocks.

## Keyword Arguments
- `init_inv::T=1`: the initial investment.

!!! warning "Beware!"
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

!!! note
    If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` columns of `rel_pr` will be used.

# Returns
- `all_sn::Vector{T}`: the cumulative return of investment during the investment period.
"""
function sn(weights::Matrix{T}, rel_pr::Matrix{T}; init_inv::T=1.) where T<:Float64
  n_periods = size(rel_pr, 2)
  n_periods<size(weights, 2) && ArgumentError("The number of samples in the \
    `weights` argument ($(size(weights, 2))) does not match the number of samples in \
    the `rel_pr` argument ($n_periods)"
  ) |> throw
  size(weights, 1) ≠ size(rel_pr, 1) && ArgumentError("The number of stocks in \
    the `weights` argument ($(size(weights, 1))) does not match the number of stocks in \
    the `rel_pr` argument ($(size(rel_pr, 1)))"
  ) |> throw

  if size(weights, 2)<n_periods
    rel_pr    = rel_pr[:, end-size(weights, 2)+1:end]
    n_periods = size(rel_pr, 2)
  end

  all_sn    = zeros(T, n_periods+1)
  all_sn[1] = init_inv
  for t ∈ 2:n_periods+1
      all_sn[t] = all_sn[t-1] * (rel_pr[:, t-1]' * weights[:, t-1])
  end

  return all_sn
end

"""
    ann_std(cum_ret::Vector{Float64}; dpy)

Calculate the Annualized Standard Deviation (σₚ) of portfolio.

# Arguments
- `cum_ret::Vector{Float64}`: the cumulative return of investment during the investment period.

## Keyword Arguments
- `dpy`: the number of days in a year.

# Returns
- `::Float64`: the Annualized Standard Deviation (σₚ) of portfolio.
"""
function ann_std(cum_ret::Vector{Float64}; dpy)
  return (cum_ret |> diff |> std) * sqrt(dpy)
end

"""
    apy(Sn::Float64, n_periods::S; dpy::S=252) where S<:Int

Calculate the Annual Percentage Yield (APY) of investment.

# Arguments
- `Sn::Float64`: the cumulative return of investment.
- `n_periods::S`: the number investment periods.
- `dpy::S=252`: the number of days in a year.

# Returns
- `::Float64`: the APY of investment.
"""
function apy(Sn::Float64, n_periods::S; dpy::S=252) where S<:Int
  y = n_periods/dpy
  return (Sn)^(1/y) - 1
end

"""
    ann_sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:Float64

Calculate the Annualized Sharpe Ratio of investment.

# Arguments
- `APY::T`: the APY of investment.
- `Rf::T`: the risk-free rate of return.
- `sigma_prtf::T`: the standard deviation of the portfolio ``sigma_p``.

# Returns
- `::Float64`: the Annualized Sharpe Ratio of investment.
"""
ann_sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:Float64 = (APY - Rf)/sigma_prtf;

"""
    mdd(Sn::Vector{T}) where T<:Float64

Calculate the Maximum Drawdown (MDD) of investment.

# Arguments
- `Sn::Vector{T}`: the cumulative return of investment during the investment period.

# Returns
- `::Float64`: the MDD of investment.
"""
function mdd(Sn::Vector{T}) where T<:Float64
  n_periods = length(Sn)
  max_sn    = zeros(T, n_periods)
  max_sn[1] = Sn[1]

  for t ∈ 2:n_periods
      max_sn[t] = max(max_sn[t-1], Sn[t])
  end

  max_dd = zeros(T, n_periods)
  for t ∈ 1:n_periods
      max_dd[t] = (max_sn[t] - Sn[t])/max_sn[t]
  end

  return maximum(max_dd)
end

"""
    calmar(APY::T, MDD::T) where T<:Float64

Calculate the Calmar Ratio of investment.

# Arguments
- `APY::T`: the APY of investment.
- `MDD::T`: the MDD of investment.

# Returns
- `::Float64`: the Calmar Ratio of investment.
"""
calmar(APY::T, MDD::T) where T<:Float64 = APY/MDD;

"""
    OPSMetrics(
      weights::Matrix{T},
      rel_pr::Matrix{T};
      init_inv::T=1.,
      Rf::T=0.02
      dpy::S=252,
      v::T=0.
    ) where {T<:AbstractFloat, S<:Int}

Calculate the metrics of an OPS algorithm.

# Arguments
- `weights::Matrix{T}`: the weights of the portfolio.
- `rel_pr::Matrix{T}`: the relative price of the stocks.

## Keyword Arguments
- `init_inv::T=1`: the initial investment.
- `Rf::T=0.02`: the risk-free rate of return.
- `dpy::S=252`: the number of days in a year.

!!! warning
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

!!! note
    If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` \
    columns of `rel_pr` will be used.

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

  n_periods = size(rel_pr, 2)
  if size(weights, 2)<n_periods
    rel_pr    = rel_pr[:, end-size(weights, 2)+1:end]
    n_periods = size(rel_pr, 2)
  end

  all_sn     = sn(weights, rel_pr, init_inv=init_inv)
  σₚ         = ann_std(all_sn, dpy=dpy)
  APY        = apy(all_sn[end], n_periods, dpy=dpy)
  ann_Sharpe = ann_sharpe(APY, Rf, σₚ)
  MDD        = mdd(all_sn)
  Calmar     = calmar(APY, MDD)

  return OPSMetrics(all_sn, APY, σₚ, ann_Sharpe, MDD, Calmar)
end
