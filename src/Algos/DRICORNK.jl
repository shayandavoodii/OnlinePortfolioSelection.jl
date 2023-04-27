using JuMP
using Statistics
using Ipopt

include("../Tools/tools.jl")
include("../Tools/cornfam.jl")

"""
    DRICORNK

A `DRICORNK` object that contains the weights of the portfolio, Sₙ, and the number of assets.

# Fields
- `n_asset::Int`: Number of assets in the portfolio.
- `b::Matrix{Float64}`: Weights of the created portfolios.
- `budgets::Vector{Float64}`: Budget during the investment horizon.

The formula for calculating the cumulative return of the portfolio is as follows:

```math
{S_n} = {S_0}\\prod\\limits_{t = 1}^T {\\left\\langle {{b_t},{x_t}} \\right\\rangle }
```

where ``S₀`` is the initial budget, ``n`` is the investment horizon, ``b_t`` is the vector \
of weights of the period ``t``, and ``x_t`` is the relative price of the ``t``-th period.
"""
struct DRICORNK
  n_asset::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
end;

"""
    DRICORNK(
      adj_close::Matrix{T},
      adj_close_market::Vector{T},
      horizon::M,
      k::M,
      w::M,
      p::M;
      lambda::T=1e-3,
      initial_budget=1
    ) where {T<:Float64, M<:Int}

Run the DRICORNK algorithm.

# Arguments
- `adj_close::Matrix{T}`: A matrix of adjusted close prices of the assets.
- `adj_close_market::Vector{T}`: A vector of adjusted close prices of the market in the same period.
- `horizon::M`: The investment horizon.
- `k::M`: The number of experts.
- `w::M`: maximum length of time window to be examined.
- `p::M`: maximum number of correlation coefficient thresholds.
- `lambda::T=1e-3`: The regularization parameter.
- `initial_budget=1`: The initial budget for investment.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::DRICORNK`: An object of type `DRICORNK`.

# Reference
- [1] [DRICORN-K: A Dynamic RIsk CORrelation-driven Non-parametric Algorithm for Online Portfolio Selection](https://www.doi.org/10.1007/978-3-030-66151-9_12)

# Example
```julia
julia> using OPS

julia> stocks_adj, market_adj = rand(10, 100), rand(100);

julia> dricornk = DRICORNK(stocks_adj, market_adj, 5, 2, 4, 3);

julia> dricornk.budgets
6-element Vector{Float64}:
   1.0
   3.473117165390519
   5.68035943256069
  16.98710435236131
 108.58630004976507
 323.6896116088503
```
"""
function DRICORNK(
  adj_close::Matrix{T},
  adj_close_market::Vector{T},
  horizon::M,
  k::M,
  w::M,
  p::M;
  lambda::T=1e-3,
  initial_budget=1
) where {T<:Float64, M<:Int}

  p<2 && ArgumentError("The value of `p` should be more than 1.") |> throw

  n_experts = w*(p+1)

  k>n_experts && ArgumentError(
    "The value of k ($k) is more than number of experts ($n_experts)"
  ) |> throw

  # Calculate relative prices
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]

  # Market's return
  market_ret = log.(adj_close_market[2:end] ./ adj_close_market[1:end-1])

  # Stocks' return
  asset_ret = log.(relative_prices)

  n_assets = size(relative_prices, 1)

  P = (iszero(pᵢ) ? 0. : (pᵢ-1)/pᵢ for pᵢ=0:p)

  q = 1/k

  weights = zeros(T, n_assets, horizon)

  Sₜ = Vector{T}(undef, horizon+1)
  Sₜ[1] = initial_budget

  Sₜ_ = zeros(T, n_experts, horizon+1)
  Sₜ_[:, 1] .= initial_budget

  for t ∈ 0:horizon-1
    bₜ = Matrix{T}(undef, n_assets, n_experts)
    expert = 1
    for ω ∈ 1:w
      for ρ ∈ P
        b = dricorn_expert(relative_prices, asset_ret, market_ret, horizon, ω, ρ, t, n_assets, lambda)
        bₜ[:, expert] = b
        Sₜ_[expert, t+2] = S(
          Sₜ_[expert, t+1], b, relative_prices[:, end-horizon+t+1]
        )
        expert += 1
      end
    end
    idx_top_k = sortperm(Sₜ_[:, t+2], rev=true)[1:k]
    weights[:, t+1] = final_weights(q, Sₜ_[idx_top_k, t+2], bₜ[:, idx_top_k])
    Sₜ[t+2] = Sₜ[t+1] * sum(weights[:, t+1] .* relative_prices[:, end-horizon+t+1])
  end

  DRICORNK(n_assets, weights, Sₜ)
end;

"""
    dricorn_expert(
      relative_prices::Matrix{T},
      asset_ret::Matrix{T},
      market_ret::Vector{T},
      horizon::S,
      w::S,
      rho::T,
      t::S,
      n_assets::S,
      lambda::T
    ) where {T<:Float64, S<:Int}

Create an expert to perform the algorithm according to the given parameters.

# Arguments
- `relative_prices::Matrix{T}`: A matrix of relative prices of the assets.
- `asset_ret::Matrix{T}`: A matrix of assets' returns.
- `market_ret::Vector{T}`: A vector of market's returns.
- `horizon::S`: The investment horizon.
- `w::S`: length of time window to be examined.
- `rho::T`: The correlation coefficient threshold.
- `t::S`: The current period index.
- `n_assets::S`: The number of assets.
- `lambda::T`: The regularization parameter.

# Returns
- `weight::Vector{T}`: The weights of the assets for the period `t`.
"""
function dricorn_expert(
  relative_prices::Matrix{T},
  asset_ret::Matrix{T},
  market_ret::Vector{T},
  horizon::S,
  w::S,
  rho::T,
  t::S,
  n_assets::S,
  lambda::T
) where {T<:Float64, S<:Int}

  horizon≥size(relative_prices, 2) && ArgumentError("""The "horizon" ($horizon) is \
    bigger than data samples $(size(relative_prices, 2)).\nYou should either decrease \
    the "horizon" or add more data samples. (At least $(horizon-size(relative_prices, 2)) \
    more data samples are needed)."""
  ) |> throw

  ρ = rho

  relative_prices_ = relative_prices[:, 1:end-horizon+t]

  n_periods = size(relative_prices_, 2)

  # Coefficient behind βₚ. Check if the market return is at least 20% higher
  # than the return of 20 days before the current time window. If it is, then
  # the coefficient is 1. Otherwise, it is -1.
  market_ret[end-horizon+t]/market_ret[end-horizon+t-20] ≥ 1.2 ? c = 1 : c = -1

  # index of similar time windows
  idx_tws = locate_sim(relative_prices_, w, n_periods, ρ)

  isempty(idx_tws) && return fill(1/n_assets, n_assets)

  # index of a day after similar time windows
  idx_days = idx_tws.+w

  # Calculate β of each asset through the last month (20 days)
  β = zeros(T, n_assets, length(idx_days))
  for i ∈ 1:n_assets
    β[i, :] .= cor(asset_ret[i, end-horizon+t-20:end-horizon+t], market_ret[end-horizon+t-20:end-horizon+t])/var(market_ret[end-horizon+t-20:end-horizon+t])
  end

  model = Model(Ipopt.Optimizer)
  set_silent(model)

  @variables(model, begin
    0<=b[i=1:n_assets]<=1
  end)

  @constraint(model, sum(b) == 1)

  @expression(model, h, (b' * relative_prices_[:, idx_days] .+ lambda*c.*(b'*β)))

  @NLobjective(model, Max, prod(h[i] for i=eachindex(h)))

  optimize!(model)

  weight = value.(b)

  weight = round.(abs.(weight), digits=3)
  isapprox(1., sum(weight), atol=1e-2) || normalizer!(weight)
  return weight
end;
