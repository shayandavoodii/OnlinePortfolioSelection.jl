using JuMP
using Statistics
using Ipopt

include("../Tools/tools.jl")
include("../Tools/cornfam.jl")

"""
    CORN

A `CORN` object that contains the weights of the portfolio, Sₙ, and the number of assets.

# Fields
- `n_asset::Int`: Number of assets in the portfolio.
- `b::Matrix{Float64}`: Weights of the created portfolios.
- `budgets::Vector{Float64}`: Budget during the investment horizon.
- `type::String`: The type of CORN algorithm. It can be either "CORN-U" or "CORN-K".

The formula for calculating the cumulative return of the portfolio is as follows:

```math
{S_n} = {S_0}\\prod\\limits_{t = 1}^T {\\left\\langle {{b_t},{x_t}} \\right\\rangle }
```

where ``S₀`` is the initial budget, ``n`` is the investment horizon, ``b_t`` is the vector \
of weights of the period ``t``, and ``x_t`` is the relative price of the ``t``-th period.
"""
struct CORN
  n_asset::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
  type::String
end

"""
    CORNU(
      adj_close::Matrix{T},
      horizon::M,
      w::M,
      rho::T;
      initial_budget=1
    ) where {T<:Float64, M<:Int}

Run CORN-U algorithm.

# Arguments
- `adj_close::Matrix{T}`: Adjusted close prices of assets.
- `horizon::M`: The number of periods to invest.
- `w::M`: maximum length of time window to be examined.
- `rho::T`: The correlation coefficient threshold.
- `initial_budget=1`: The initial budget for investment.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `CORN`: An object of type `CORN`.

# Reference
- [1] [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)

# Examples
```julia
julia> using OPS

julia> adj_close = rand(5, 100);

julia> model = CORNU(adj_close, 10, 5, 0.5);

julia> model.budgets
11-element Vector{Float64}:
   1.0
   2.712148607094074
   3.9049548118405513
   9.079571226009149
  15.550023500498401
  60.15172309699462
  32.32354281989587
 110.76798827023994
 148.34814522333753
 206.383234246206
 463.69154027959627

julia> model.type
"CORN-U"
```
"""
function CORNU(
  adj_close::Matrix{T},
  horizon::M,
  w::M,
  rho::T;
  initial_budget=1
) where {T<:Float64, M<:Int}

  0≤rho<1 || ArgumentError("The value of `rho` should be in the range of [0, 1).") |> throw
  n_experts = w
  # Calculate relative prices
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets = size(relative_prices, 1)
  q = 1/w
  Sₜ = Vector{T}(undef, horizon+1)
  Sₜ[1] = initial_budget
  # Store the budgets of experts in each period t
  Sₜ_ = zeros(T, n_experts, horizon+1)
  Sₜ_[:, 1] .= initial_budget
  weights = zeros(T, n_assets, horizon)
  for t ∈ 0:horizon-1
    bₜ = Matrix{T}(undef, n_assets, n_experts)
    for ω ∈ 1:w
      b = corn_expert(relative_prices, horizon, ω, rho, t, n_assets)
      bₜ[:, ω] = b
      Sₜ_[ω, t+2] = S(Sₜ_[ω, t+1], b, relative_prices[:, end-horizon+t+1])
    end
    weights[:, t+1] = final_weights(q, Sₜ_[:, t+2], bₜ)
    Sₜ[t+2] = Sₜ[t+1] * sum(weights[:, t+1] .* relative_prices[:, end-horizon+t+1])
  end
  return CORN(n_assets, weights, Sₜ, "CORN-U")
end

"""
    CORNK(
      adj_close::Matrix{Float64},
      horizon::T,
      k::T,
      w::T,
      p::T;
      initial_budget=1
    ) where T<:Int

Run CORN-K algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: Adjusted close prices of assets.
- `horizon::T`: The number of periods to invest.
- `k::T`: The number of top experts to be selected.
- `w::T`: maximum length of time window to be examined.
- `p::T`: maximum number of correlation coefficient thresholds.
- `initial_budget=1`: The initial budget for investment.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `CORN`: An object of type `CORN`.

# Reference
- [1] [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)

# Examples
```julia
julia> using OPS

julia> adj_close = rand(5, 100);

julia> model = CORNK(adj_close, 10, 3, 5, 3);

julia> model.budgets
11-element Vector{Float64}:
    1.0
    0.9245593797606169
    1.2661989745602595
    1.9287471593384662
   13.920366533737552
   34.95772014332745
   37.275738278098444
  151.14402066138192
  186.3883800018429
  208.7067031619314
 8593.328131580158

julia> model.type
"CORN-K"
```
"""
function CORNK(
  adj_close::Matrix{Float64},
  horizon::T,
  k::T,
  w::T,
  p::T;
  initial_budget=1
) where T<:Int

  p<2 && ArgumentError("The value of `p` should be more than 1.") |> throw
  n_experts = w*(p+1)
  k>n_experts && ArgumentError(
    "The value of k ($k) is more than number of experts ($n_experts)"
  ) |> throw

  # Calculate relative prices
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets = size(relative_prices, 1)
  P = (iszero(pᵢ) ? 0. : (pᵢ-1)/pᵢ for pᵢ∈0:p)
  q = 1/k
  weights = zeros(Float64, n_assets, horizon)
  Sₜ = Vector{Float64}(undef, horizon+1)
  Sₜ[1] = initial_budget
  Sₜ_ = zeros(Float64, n_experts, horizon+1)
  Sₜ_[:, 1] .= initial_budget
  for t ∈ 0:horizon-1
    bₜ = Matrix{Float64}(undef, n_assets, n_experts)
    expert = 1
    for ω ∈ 1:w
      for ρ ∈ P
        b = corn_expert(relative_prices, horizon, ω, ρ, t, n_assets)
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

  return CORN(n_assets, weights, Sₜ, "CORN-K")
end

"""
    corn_expert(
      relative_prices::Matrix{T},
      horizon::S,
      w::S,
      rho::T,
      t::S,
      n_assets::S
    ) where {T<:Float64, S<:Int}

Create an expert to perform the algorithm according to the given parameters.

# Arguments
- `relative_prices::Matrix{T}`: Relative prices of assets.
- `horizon::S`: The number of periods to invest.
- `w::S`: length of time window to be examined.
- `rho::T`: correlation coefficient threshold.
- `t::S`: index of the period to perform the algorithm.
- `n_assets::S`: number of assets.

# Returns
- `Vector{Float64}`: Weights of assets.
"""
function corn_expert(
  relative_prices::Matrix{T},
  horizon::S,
  w::S,
  rho::T,
  t::S,
  n_assets::S
) where {T<:Float64, S<:Int}

  horizon≥size(relative_prices, 2) && ArgumentError("""The "horizon" ($horizon) is \
    bigger than data samples $(size(relative_prices, 2)).\nYou should either decrease \
    the "horizon" or add more data samples. (At least $(horizon-size(relative_prices, 2)) \
    more data samples are needed)."""
  ) |> throw

  ρ = rho
  relative_prices_ = relative_prices[:, 1:end-horizon+t]
  n_periods = size(relative_prices_, 2)
  # index of similar time windows
  idx_tws = locate_sim(relative_prices_, w, n_periods, ρ)
  isempty(idx_tws) && return fill(1/n_assets, n_assets)
  # index of a day after similar time windows
  idx_days = idx_tws.+w
  model = Model(Ipopt.Optimizer)
  set_silent(model)
  @variables(model, begin
    0<=b[i=1:n_assets]<=1
  end)
  @constraint(model, sum(b[i] for i = 1:n_assets) == 1)
  h = [sum(b.*relative_prices_[:, idx]) for idx∈idx_days]
  @NLobjective(model, Max, *(h...))
  optimize!(model)
  weight = value.(b)
  weight = round.(abs.(weight), digits=3)
  isapprox(1., sum(weight), atol=1e-2) || normalizer!(weight)
  return weight
end
