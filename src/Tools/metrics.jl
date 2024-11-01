function conditionset1(weights, rel_pr)
  _, n_periods = size(rel_pr)
  n_periods_w = size(weights, 2)
  n_periods<n_periods_w && ArgumentError("The number of samples in the \
    `weights` argument ($(n_periods_w)) does not match the number of samples in \
    the `rel_pr` argument ($n_periods)"
  ) |> throw
  size(weights, 1) ≠ size(rel_pr, 1) && ArgumentError("The number of stocks in \
    the `weights` argument ($(size(weights, 1))) does not match the number of stocks in \
    the `rel_pr` argument ($(size(rel_pr, 1)))"
  ) |> throw
end

function alignperiods(weights, rel_pr)
  _, n_periods = size(rel_pr)
  n_periods_w = size(weights, 2)
  if n_periods_w<n_periods
    rel_pr    = rel_pr[:, end-n_periods_w+1:end]
    n_periods = size(rel_pr, 2)
  end
  return rel_pr, n_periods
end

"""
    b̂func(rel_pr::AbstractMatrix, weights::AbstractMatrix)

This function is also known as the `b̃` in the literature.
"""
function b̂func(rel_pr::AbstractMatrix, weights::AbstractMatrix)
  n_assets, n_periods = size(rel_pr)
  b̂ = Matrix{Float64}(undef, n_assets, n_periods)
  for t ∈ 1:n_periods
    product_ = weights[:, t] .* rel_pr[:, t]
    b̂[:, t] = (product_)/sum(product_)
  end
  return b̂
end

"""
    sn(weights::AbstractMatrix{T}, rel_pr::AbstractMatrix{T}; init_inv::T=1.) where T<:AbstractFloat

Calculate the cumulative wealth of the portfolio during a period of time. Also, \
see [`mer`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), \
[`calmar`](@ref), and [`opsmetrics`](@ref).

The formula for calculating the cumulative wealth of the portfolio is as follows:

```math
{S_n} = {S_0}\\prod\\limits_{t = 1}^T {\\left\\langle {{b_t},{x_t}} \\right\\rangle }
```

where ``S_0`` is the initial budget, ``n`` is the investment horizon, ``b_t`` is the vector \
of weights of the period ``t``, and ``x_t`` is the relative price of the ``t``-th period.

# Arguments
- `weights::AbstractMatrix{T}`: the weights of the portfolio.
- `rel_pr::AbstractMatrix{T}`: the relative price of the stocks.

## Keyword Arguments
- `init_inv::T=1`: the initial investment.

!!! warning "Beware!"
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

!!! note
    If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last \
    `size(weights, 2)` columns of `rel_pr` will be used.

# Returns
- `all_sn::Vector{T}`: the cumulative wealth of investment during the investment period.
"""
function sn(weights::AbstractMatrix{T}, rel_pr::AbstractMatrix{T}; init_inv::T=1.) where T<:AbstractFloat
  n_periods = size(rel_pr, 2)
  conditionset1(weights, rel_pr)
  rel_pr, n_periods = alignperiods(weights, rel_pr)
  all_sn            = zeros(T, n_periods+1)
  all_sn[1]         = init_inv
  for t ∈ 2:n_periods+1
      all_sn[t] = all_sn[t-1] * (rel_pr[:, t-1]' * weights[:, t-1])
  end

  return all_sn
end

"""
    mer(
      weights::AbstractMatrix{T},
      rel_pr::AbstractMatrix{T},
      𝘷::T=0.
    ) where T<:AbstractFloat

Calculate the investments's Mean excess return (MER). Also, see [`sn`](@ref), [`ann_std`](@ref), \
[`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), [`calmar`](@ref), and [`opsmetrics`](@ref).

# Arguments
- `weights::AbstractMatrix{T}`: the weights of the portfolio.
- `rel_pr::AbstractMatrix{T}`: the relative price of the stocks.
- `𝘷::T=0.`: the transaction cost rate.

!!! warning
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

!!! note
    If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last \
    `size(weights, 2)` columns of `rel_pr` will be used.

# Returns
- `MER::AbstractFloat`: the investments's Mean excess return (MER).
"""
function mer(
  weights::AbstractMatrix{T},
  rel_pr::AbstractMatrix{T},
  𝘷::T=0.
) where T<:AbstractFloat
  n_assets, n_periods = size(rel_pr)
  conditionset1(weights, rel_pr)
  rel_pr, n_periods = alignperiods(weights, rel_pr)
  b̃ = b̂func(rel_pr, weights)
  R = Vector{Float64}(undef, n_periods)
  Rstar = Vector{Float64}(undef, n_periods)
  bstar = ones(n_assets)/n_assets
  for t ∈ 1:n_periods
    product_ = rel_pr[:, t].*weights[:, t]
    second_term = 1-((𝘷/2)*(sum(abs.(weights-b̃))))
    R[t] = sum(product_)*second_term - 1
    Rstar[t] = sum(rel_pr[:, t].*bstar) - 1
  end
  MER = 1/n_periods * sum(R) - sum(Rstar)
  return MER
end

"""
    ir(
      weights::AbstractMatrix{S},
      rel_pr::AbstractMatrix{S},
      rel_pr_market::AbstractVector{S};
      init_inv::S=1.
    ) where S<:AbstractFloat

Calculate the Information Ratio (IR) of portfolio. Also, see [`sn`](@ref), [`mer`](@ref), \
[`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), [`calmar`](@ref), and \
[`opsmetrics`](@ref).

The formula for calculating the Information Ratio (IR) of portfolio is as follows:

```math
IR = \\frac{{{{\\bar R}_s} - {{\\bar R}_m}}}{{\\sigma \\left( {{R_s} - {R_m}} \\right)}}
```

where ``R_s`` represents the portfolio's daily return, ``R_m`` represents the market's daily \
return, ``\\bar R_s`` represents the portfolio's average daily return, ``\\bar R_m`` represents \
the market's average daily return, and ``\\sigma`` represents the standard deviation of the \
portfolio's daily excess return over the market. Note that in this package, the logarithmic \
return is used.

# Arguments
- `weights::AbstractMatrix{S}`: the weights of the portfolio.
- `rel_pr::AbstractMatrix{S}`: the relative price of the stocks.
- `rel_pr_market::AbstractVector{S}`: the relative price of the market.

## Keyword Arguments
- `init_inv::S=1`: the initial investment.

!!! warning
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

!!! note
    If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last \
    `size(weights, 2)` columns of `rel_pr` will be used. The size of `rel_pr_market` will \
    automatically be adjusted to the size of `w`.

# Returns
- `::AbstractFloat`: the Information Ratio (IR) of portfolio for the investment period.

# References
> [Adaptive online portfolio strategy based on exponential gradient updates](https://doi.org/10.1007/s10878-021-00800-7)
"""
function ir(
  weights::AbstractMatrix{S},
  rel_pr::AbstractMatrix{S},
  rel_pr_market::AbstractVector{S};
  init_inv::S=1.
) where S<:AbstractFloat

  rel_pr_market, _ = alignperiods(weights, rel_pr_market')
  sn_              = sn(weights, rel_pr, init_inv=init_inv)
  ret_prtf         = @. sn_[2:end]/sn_[1:end-1] |> log
  ret_market       = @. rel_pr_market |> log
  numerator_       = mean(ret_prtf) - mean(ret_market)
  denominator_     = std(ret_prtf.-ret_market)
  return numerator_/denominator_
end

"""
    ann_std(cum_ret::AbstractVector{AbstractFloat}; dpy)

Calculate the Annualized Standard Deviation (``\\sigma_p``) of portfolio. Also, see [`sn`](@ref), \
[`mer`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), [`calmar`](@ref), and \
[`opsmetrics`](@ref).

# Arguments
- `cum_ret::AbstractVector{AbstractFloat}`: the cumulative wealth of investment during the \
investment period.

## Keyword Arguments
- `dpy`: the number of days in a year.

# Returns
- `::AbstractFloat`: the Annualized Standard Deviation (``\\sigma_p``) of portfolio.
"""
function ann_std(cum_ret::AbstractVector{<:AbstractFloat}; dpy)
  return (cum_ret |> diff |> std) * sqrt(dpy)
end

"""
    apy(Sn::AbstractFloat, n_periods::S; dpy::S=252) where S<:Int

Calculate the Annual Percentage Yield (APY) of investment. Also, see [`sn`](@ref), [`mer`](@ref), \
[`ann_std`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), [`calmar`](@ref), and [`opsmetrics`](@ref).

# Arguments
- `Sn::AbstractFloat`: the cumulative wealth of investment.
- `n_periods::S`: the number investment periods.
- `dpy::S=252`: the number of days in a year.

# Returns
- `::AbstractFloat`: the APY of investment.
"""
function apy(Sn::AbstractFloat, n_periods::S; dpy::S=252) where S<:Int
  y = n_periods/dpy
  return (Sn)^(1/y) - 1
end

"""
    ann_sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:AbstractFloat

Calculate the Annualized Sharpe Ratio of investment. Also, see [`sn`](@ref), [`mer`](@ref), \
[`ann_std`](@ref), [`apy`](@ref), [`mdd`](@ref), [`calmar`](@ref), and [`opsmetrics`](@ref).

# Arguments
- `APY::T`: the APY of investment.
- `Rf::T`: the risk-free rate of return.
- `sigma_prtf::T`: the standard deviation of the portfolio ``\\sigma_p``.

# Returns
- `::AbstractFloat`: the Annualized Sharpe Ratio of investment.
"""
ann_sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:AbstractFloat = (APY - Rf)/sigma_prtf;

"""
    mdd(Sn::AbstractVector{T}) where T<:AbstractFloat

Calculate the Maximum Drawdown (MDD) of investment. Also, see [`sn`](@ref), [`mer`](@ref), \
[`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`calmar`](@ref), and [`opsmetrics`](@ref).

# Arguments
- `Sn::AbstractVector{T}`: the cumulative wealth of investment during the investment period. \
  see [`sn`](@ref).

# Returns
- `::AbstractFloat`: the MDD of investment.
"""
function mdd(Sn::AbstractVector{T}) where T<:AbstractFloat
  max_sn    = (maximum(Sn[1:t]) for t=eachindex(Sn))
  max_dd    = similar(Sn)
  for (t, snₜ) ∈ enumerate(max_sn)
    max_dd[t] = (snₜ - Sn[t])/snₜ
  end
  return maximum(max_dd)
end

"""
    calmar(APY::T, MDD::T) where T<:AbstractFloat

Calculate the Calmar Ratio of investment. Also, see [`sn`](@ref), [`mer`](@ref), [`ann_std`](@ref), \
[`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`opsmetrics`](@ref).

# Arguments
- `APY::T`: the APY of investment.
- `MDD::T`: the MDD of investment.

# Returns
- `::AbstractFloat`: the Calmar Ratio of investment.
"""
calmar(APY::T, MDD::T) where T<:AbstractFloat = APY/MDD;

"""
    at(rel_pr::AbstractMatrix, b::AbstractMatrix)

Calculate the average turnover of the portfolio. Also, see [`sn`](@ref), [`mer`](@ref), \
[`ir`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and \
[`calmar`](@ref).

# Arguments
- `rel_pr::AbstractMatrix`: The relative price of the stocks.
- `b::AbstractMatrix`: The weights of the portfolio.

# Returns
- `::AbstractFloat`: the average turnover of the portfolio.
"""
function at(rel_pr::AbstractMatrix, b::AbstractMatrix)
  conditionset1(b, rel_pr)
  rel_pr, _ = alignperiods(b, rel_pr)
  T         = size(b, 2)
  turnover_ = 0.
  b̂ₜ₊₁      = b̂func(rel_pr, b)
  for t ∈ 2:T
    turnover_ += norm(b[:, t] .- b̂ₜ₊₁[:, t-1], 1)
  end
  return turnover_/(2*(T-1))
end

"""
    opsmetrics(
      weights::AbstractMatrix{T},
      rel_pr::AbstractMatrix{T},
      rel_pr_market::AbstractVector{T};
      init_inv::T=1.,
      Rf::T=0.02
      dpy::S=252,
      v::T=0.
      dpy::S=252
    ) where {T<:AbstractFloat, S<:Int}

Calculate the metrics of an OPS algorithm. Also, see [`sn`](@ref), [`mer`](@ref), \
[`ir`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), \
and [`calmar`](@ref).

# Arguments
- `weights::AbstractMatrix{T}`: the weights of the portfolio.
- `rel_pr::AbstractMatrix{T}`: the relative price of the stocks.
- `rel_pr_market::AbstractVector{T}`: the relative price of the market.

## Keyword Arguments
- `init_inv::T=1`: the initial investment.
- `Rf::T=0.02`: the risk-free rate of return.
- `dpy::S=252`: the number of days in a year.
- `v::T=0.`: the transaction cost rate.

!!! warning
    The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

!!! note
    If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` \
    columns of `rel_pr` will be used.

# Returns
- `::OPSMetrics`: An [`OPSMetrics`](@ref) object.
"""
function opsmetrics(
  weights::AbstractMatrix{T},
  rel_pr::AbstractMatrix{T},
  rel_pr_market::AbstractVector{T};
  init_inv::T=1.,
  Rf::T=0.02,
  dpy::S=252,
  v::T=0.
) where {T<:AbstractFloat, S<:Int}

  rel_pr, n_periods = alignperiods(weights, rel_pr)

  all_sn     = sn(weights, rel_pr, init_inv=init_inv)
  MER        = mer(weights, rel_pr, v)
  IR         = ir(weights, rel_pr, rel_pr_market, init_inv=init_inv)
  σₚ         = ann_std(all_sn, dpy=dpy)
  APY        = apy(all_sn[end], n_periods, dpy=dpy)
  ann_Sharpe = ann_sharpe(APY, Rf, σₚ)
  MDD        = mdd(all_sn)
  Calmar     = calmar(APY, MDD)
  AT         = at(rel_pr, weights)

  return OPSMetrics(all_sn, MER, IR, APY, σₚ, ann_Sharpe, MDD, Calmar, AT)
end
