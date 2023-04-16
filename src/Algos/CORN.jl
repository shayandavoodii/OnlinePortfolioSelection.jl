using JuMP
using Statistics
using Ipopt

include("../Tools/tools.jl")

struct CORN
  n_asset::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
  type::String
end;

"""
    CORNU(
      adj_close::Matrix{Float64},
      horizon::Int,
      w::Int,
      rho::Float64;
      initial_budget=1
    )

Run CORN-U algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: Adjusted close prices of assets.
- `horizon::Int`: The number of periods to invest.
- `w::Int`: maximum length of time window to be examined.
- `rho::Float64`: The correlation coefficient threshold.
- `initial_budget=1`: The initial budget for investment.

# Returns
- `CORN`: An object of type `CORN`.

# Reference
- [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)

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
  adj_close::Matrix{Float64},
  horizon::Int,
  w::Int,
  rho::Float64;
  initial_budget=1
)

  0≤rho<1 || throw(ArgumentError("The value of `rho` should be in the range of [0, 1)."))

  n_experts = w

  # Calculate relative prices
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]

  n_assets = size(relative_prices, 1)

  q = 1/w

  Sₜ = Vector{Float64}(undef, horizon+1)
  Sₜ[1] = initial_budget

  # Store the budgets of experts in each period t
  Sₜ_ = zeros(Float64, n_experts, horizon+1)
  Sₜ_[:, 1] .= initial_budget

  weights = zeros(Float64, n_assets, horizon)

  for t ∈ 0:horizon-1
    bₜ = Matrix{Float64}(undef, n_assets, n_experts)
    for ω ∈ 1:w
      b = corn_expert(relative_prices, horizon, ω, rho, t, n_assets)
      bₜ[:, ω] = b
      Sₜ_[ω, t+2] = S(Sₜ_[ω, t+1], b, relative_prices[:, end-horizon+t+1])
    end
    weights[:, t+1] = final_weights(q, Sₜ_[:, t+2], bₜ)
    Sₜ[t+2] = Sₜ[t+1] * sum(weights[:, t+1] .* relative_prices[:, end-horizon+t+1])
  end

  CORN(n_assets, weights, Sₜ, "CORN-U")
end;

"""
    CORNK(
      adj_close::Matrix{Float64},
      horizon::Int,
      k::Int,
      w::Int,
      p::Int;
      initial_budget=1
    )

Run CORN-K algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: Adjusted close prices of assets.
- `horizon::Int`: The number of periods to invest.
- `k::Int`: The number of top experts to be selected.
- `w::Int`: maximum length of time window to be examined.
- `p::Int`: maximum number of correlation coefficient thresholds.
- `initial_budget=1`: The initial budget for investment.

# Returns
- `CORN`: An object of type `CORN`.

# Reference
- [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)

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
  horizon::Int,
  k::Int,
  w::Int,
  p::Int;
  initial_budget=1
)

  p<2 && throw(ArgumentError("The value of `p` should be more than 1."))

  n_experts = w*(p+1)

  k>n_experts && throw(ArgumentError(
    "The value of k ($k) is more than number of experts ($n_experts)"
  ))

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

  CORN(n_assets, weights, Sₜ, "CORN-K")
end;

"""
    corn_expert(
      relative_prices::Matrix{Float64},
      horizon::Int,
      w::Int,
      rho::Float64,
      t::Int,
      n_assets::Int
    )

Create an expert to perform the algorithm according to the given parameters.

# Arguments
- `relative_prices::Matrix{Float64}`: Relative prices of assets.
- `horizon::Int`: The number of periods to invest.
- `w::Int`: length of time window to be examined.
- `rho::Float64`: correlation coefficient threshold.
- `t::Int`: index of the period to perform the algorithm.
- `n_assets::Int`: number of assets.

# Returns
- `Vector{Float64}`: Weights of assets.
"""
function corn_expert(
  relative_prices::Matrix{Float64},
  horizon::Int,
  w::Int,
  rho::Float64,
  t::Int,
  n_assets::Int
)

  horizon≥size(relative_prices, 2) && throw(ArgumentError("""The "horizon" ($horizon) is \
    bigger than data samples $(size(relative_prices, 2)).\nYou should either decrease \
    the "horizon" or add more data samples. (At least $(horizon-size(relative_prices, 2)) \
    more data samples are needed)."""
  ))

  ρ = rho

  relative_prices_ = relative_prices[:, 1:end-horizon+t]

  n_periods = size(relative_prices_, 2)

  # index of similar time windows
  idx_tws = locate_sim(relative_prices_, w, n_periods, ρ)

  if isempty(idx_tws)
    return fill(1/n_assets, n_assets)
  end
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
  # @show sum(weight)
  @assert isapprox(1., sum(weight), atol=1e-2)
  weight = weight ./ sum(weight)
  return weight
end;

"""
    locate_sim(rel_price::Matrix{Float64}, w::Int, T::Int, ρ::Float64)

Find similar time windows based on the correlation coefficient threshold.

# Arguments
- `rel_price::Matrix{Float64}`: Relative prices of assets.
- `w::Int`: length of time window.
- `T::Int`: Total number of periods.
- `ρ::Float64`: correlation coefficient threshold.

# Returns
- `Vector{Int}`: Index of similar time windows.
"""
function locate_sim(rel_price::Matrix{Float64}, w::Int, T::Int, ρ::Float64)
  idx_day_after_tw = Vector{Int}()

  # current time window
  curr_tw = Base.Flatten(rel_price[:, end-w+1:end])

  # Number of time windows
  n_tw = T-w+1

  # n_tw-1: because we don't want to calculate corr between the
  # currrent w and itself. So, the current time window is excluded.
  for idx_tw=1:n_tw-1
    twᵢ = Base.Flatten(rel_price[:, idx_tw:w+idx_tw-1])
    if cor(collect(curr_tw), collect(twᵢ))≥ρ
      push!(idx_day_after_tw, idx_tw)
    end
  end

  idx_day_after_tw
end;

"""
    S(prev_s, w::T, rel_pr::T) where {T<:Vector{Float64}}

Calculate the budget of the current period.

# Arguments
- `prev_s::Float64`: Budget of the previous period.
- `w::Vector{Float64}`: Weights of assets.
- `rel_pr::Vector{Float64}`: Relative prices of assets in the current period.

# Returns
- `Float64`: Budget of the current period.
"""
S(prev_s, w::T, rel_pr::T) where {T<:Vector{Float64}} = prev_s*sum(w.*rel_pr);

"""
    final_weights(q::T, s::Vector{T}, b::Matrix{T})::Vector{T} where T<:Float64

Calculate the final weights of assets according to the experts.

# Arguments
- `q::T`: The portion of contribution made by each of the experts.
- `s::Vector{T}`: Total wealth achieved by each expert in the current period.
- `b::Matrix{T}`: Weights of assets achieved by each expert in the current period.

# Returns
- `Vector{T}`: Final weights of assets in the current period.
"""
function final_weights(q::T, s::Vector{T}, b::Matrix{T})::Vector{T} where T<:Float64
  numerator_ = zeros(T, size(b, 1))
  denominator_ = zero(T)
  for idx_expert ∈ eachindex(s)
    qs = q*s[idx_expert]
    numerator_+=qs*b[:, idx_expert]
    denominator_+=qs
  end

  numerator_/denominator_
end;
