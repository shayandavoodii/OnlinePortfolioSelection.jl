"""
    cornu(
      x::AbstractMatrix{T},
      horizon::M,
      w::M;
      rho::T=0.2,
      init_budg=1,
      progress::Bool=false
    ) where {T<:AbstractFloat, M<:Integer}

Run CORN-U algorithm.

# Arguments
- `x::AbstractMatrix{T}`: price relative matrix of assets.
- `horizon::M`: The number of periods to invest.
- `w::M`: maximum length of time window to be examined.

## Keyword Arguments
- `rho::T=0.2`: The correlation coefficient threshold.
- `init_budg=1`: The initial budget for investment.
- `progress::Bool=false`: Whether to show the progress bar.

!!! warning "Beware!"
    `x` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> x = rand(5, 100);

julia> model = cornu(x, 10, 5, 0.5);

julia> model.alg
"CORN-U"

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

See [`cornk`](@ref), and [`dricornk`](@ref).

# Reference
> [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)
"""
function cornu(
  x::AbstractMatrix{T},
  horizon::M,
  w::M;
  rho::T=0.2,
  init_budg=1,
  progress::Bool=false
) where {T<:AbstractFloat, M<:Integer}
  n_assets, _ = size(x)
  0≤rho<1 || ArgumentError("The value of `rho` should be in the range of [0, 1).") |> throw
  n_experts  = w
  q          = 1/w
  # Store the budgets of experts in each period t
  Sₜ_        = zeros(T, n_experts, horizon+1)
  Sₜ_[:, 1] .= init_budg
  weights    = zeros(T, n_assets, horizon)
  bₜ         = similar(x, n_assets, n_experts)
  progress && (start = time())
  for t ∈ 0:horizon-1
    for ω ∈ 1:w
      b           = corn_expert(x, horizon, ω, rho, t, n_assets)
      bₜ[:, ω]    = b
      Sₜ_[ω, t+2] = S(Sₜ_[ω, t+1], b, x[:, end-horizon+t+1])
    end
    progress && progressbar(stdout, horizon, t+1, start_time=start)
    weights[:, t+1] = final_weights(q, Sₜ_[:, t+2], bₜ)
  end

  return OPSAlgorithm(n_assets, weights, "CORN-U")
end

"""
    cornk(
      x::AbstractMatrix{<:AbstractFloat},
      horizon::T,
      k::T,
      w::T,
      p::T;
      init_budg=1,
      progress::Bool=false
    ) where T<:Integer

Run CORN-K algorithm.

# Arguments
- `x::AbstractMatrix{<:AbstractFloat}`: price relative matrix of assets.
- `horizon::T`: The number of periods to invest.
- `k::T`: The number of top experts to be selected.
- `w::T`: maximum length of time window to be examined.
- `p::T`: maximum number of correlation coefficient thresholds.

## Keyword Arguments
- `init_budg=1`: The initial budget for investment.
- `progress::Bool=false`: Whether to show the progress bar.

!!! warning "Beware!"
    `x` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> x = rand(5, 100);

julia> model = cornk(x, 10, 3, 5, 3);

julia> model.alg
"CORN-K"

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

See [`cornu`](@ref), and [`dricornk`](@ref).

# Reference
> [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)
"""
function cornk(
  x::AbstractMatrix{<:AbstractFloat},
  horizon::T,
  k::T,
  w::T,
  p::T;
  init_budg=1,
  progress::Bool=false
) where T<:Integer
  p<2 && ArgumentError("The value of `p` should be more than 1.") |> throw
  n_experts = w*(p+1)
  k>n_experts && ArgumentError(
    "The value of k ($k) is more than number of experts ($n_experts)"
  ) |> throw
  n_assets   = size(x, 1)
  P          = (iszero(pᵢ) ? 0. : (pᵢ-1)/pᵢ for pᵢ∈0:p)
  q          = 1/k
  weights    = similar(x, n_assets, horizon)
  Sₜ_        = similar(x, n_experts, horizon+1)
  Sₜ_[:, 1] .= init_budg
  bₜ = similar(x, n_assets, n_experts)
  progress && (start = time())
  for t ∈ 0:horizon-1
    expert = 1
    for ω ∈ 1:w
      for ρ ∈ P
        b                = corn_expert(x, horizon, ω, ρ, t, n_assets)
        bₜ[:, expert]    = b
        Sₜ_[expert, t+2] = S(
          Sₜ_[expert, t+1], b, x[:, end-horizon+t+1]
        )
        expert += 1
      end
    end

    idx_top_k       = sortperm(Sₜ_[:, t+2], rev=true)[1:k]
    weights[:, t+1] = final_weights(q, Sₜ_[idx_top_k, t+2], bₜ[:, idx_top_k])
    progress && progressbar(stdout, horizon, t+1, start_time=strat)
  end

  return OPSAlgorithm(n_assets, weights, "CORN-K")
end

"""
    corn_expert(
      relative_prices::Matrix{T},
      horizon::S,
      w::S,
      rho::T,
      t::S,
      n_assets::S
    ) where {T<:AbstractFloat, S<:Int}

Create an expert to perform the algorithm according to the given parameters.

# Arguments
- `relative_prices::Matrix{T}`: Relative prices of assets.
- `horizon::S`: The number of periods to invest.
- `w::S`: length of time window to be examined.
- `rho::T`: correlation coefficient threshold.
- `t::S`: index of the period to perform the algorithm.
- `n_assets::S`: number of assets.

# Returns
- `::Vector{AbstractFloat}`: Weights of assets.
"""
function corn_expert(
  relative_prices::Matrix{T},
  horizon::S,
  w::S,
  rho::T,
  t::S,
  n_assets::S
) where {T<:AbstractFloat, S<:Int}

  horizon≥size(relative_prices, 2) && ArgumentError("""The "horizon" ($horizon) is \
    bigger than data samples $(size(relative_prices, 2)).\nYou should either decrease \
    the "horizon" or add more data samples. (At least $(horizon-size(relative_prices, 2)) \
    more data samples are needed)."""
  ) |> throw

  ρ                = rho
  relative_prices_ = relative_prices[:, 1:end-horizon+t]
  n_periods        = size(relative_prices_, 2)

  # index of similar time windows
  idx_tws = locate_sim(relative_prices_, w, n_periods, ρ)
  isempty(idx_tws) && return fill(1/n_assets, n_assets)

  # index of a day after similar time windows
  idx_days = idx_tws.+w
  model    = Model(Optimizer)
  set_silent(model)

  @variable(model, 0<=b[i=1:n_assets]<=1)
  @constraint(model, sum(b[i] for i = 1:n_assets) == 1)
  h = [sum(b.*relative_prices_[:, idx]) for idx∈idx_days]
  @NLobjective(model, Max, *(h...))
  optimize!(model)
  weight = value.(b)
  weight = round.(abs.(weight), digits=3)
  isapprox(1., sum(weight), atol=1e-2) || normalizer!(weight)

  return weight
end
