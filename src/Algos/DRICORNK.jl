"""
    dricornk(
      x::AbstractMatrix{T},
      relpr_market::AbstractVector{T},
      horizon::M,
      k::M,
      w::M,
      p::M;
      lambda::T=1e-3,
      init_budg=1,
      progress::Bool=false
    ) where {T<:AbstractFloat, M<:Integer}

Run the DRICORNK algorithm.

# Arguments
- `x::AbstractMatrix{T}`: A matrix of relative prices of the assets.
- `relpr_market::AbstractVector{T}`: A vector of relative prices of the market in the same period.
- `horizon::M`: The investment horizon.
- `k::M`: The number of experts.
- `w::M`: maximum length of time window to be examined.
- `p::M`: maximum number of correlation coefficient thresholds.

## Keyword Arguments
- `lambda::T=1e-3`: The regularization parameter.
- `init_budg=1`: The initial budget for investment.
- `progress::Bool=false`: Whether to show the progress bar.

!!! warning "Beware!"
    `x` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection

julia> stocks_ret, market_ret = rand(10, 100), rand(100);

julia> m_dricornk = dricornk(stocks_ret, market_ret, 5, 2, 4, 3);

julia> sum(m_dricornk.b, dims=1) .|> isapprox(1.) |> all
true
```

See [`cornk`](@ref), and [`cornu`](@ref).

# Reference
> [DRICORN-K: A Dynamic RIsk CORrelation-driven Non-parametric Algorithm for Online Portfolio Selection](https://www.doi.org/10.1007/978-3-030-66151-9_12)
"""
function dricornk(
  x::AbstractMatrix{T},
  relpr_market::AbstractVector{T},
  horizon::M,
  k::M,
  w::M,
  p::M;
  lambda::T=1e-3,
  init_budg=1,
  progress::Bool=false
) where {T<:AbstractFloat, M<:Integer}

  n_assets, n_samples = size(x)
  p<2 && ArgumentError("The value of `p` should be more than 1.") |> throw
  n_experts = w*(p+1)
  k>n_experts && ArgumentError(
    "The value of k ($k) shouldn't be more than number of experts ($n_experts)"
  ) |> throw
  n_samples>2horizon+19 || ArgumentError("
    Insufficient number of data points for `x` is provided. Considering the current \
    value of `horizon` ($horizon), at least $(2horizon+20) data points is need. \
    $(n_samples) is provided. Either provide more data points or decrease the value of \
    `horizon` ($horizon). If you're willing to decrease the `horizon`, you should pass \
    ($(ceil(Integer, (n_samples-19)/2)-1)).
  ") |> throw
  length(relpr_market)==n_samples || ArgumentError("
    Insufficient number of data points for `relpr_market` ($(length(relpr_market))) \
    is provided. The same number of data points as `x` \
    ($(n_samples)) is required.
  ") |> throw

  # Market's return
  market_ret = log.(relpr_market)
  # Stocks' return
  asset_ret  = log.(x)
  P          = (iszero(pᵢ) ? 0. : (pᵢ-1)/pᵢ for pᵢ=0:p)
  q          = 1/k
  weights    = zeros(T, n_assets, horizon)
  Sₜ_        = zeros(T, n_experts, horizon+1)
  Sₜ_[:, 1] .= init_budg
  progress && (start = time())
  for t ∈ 0:horizon-1
    bₜ = Matrix{T}(undef, n_assets, n_experts)
    expert = 1
    for ω ∈ 1:w
      for ρ ∈ P
        b = dricorn_expert(
          x,
          asset_ret,
          market_ret,
          horizon,
          ω,
          ρ,
          t,
          n_assets,
          lambda
        )

        bₜ[:, expert]    = b
        Sₜ_[expert, t+2] = S(
          Sₜ_[expert, t+1], b, x[:, end-horizon+t+1]
        )

        expert += 1
      end
    end

    idx_top_k       = sortperm(Sₜ_[:, t+2], rev=true)[1:k]
    weights[:, t+1] = final_weights(q, Sₜ_[idx_top_k, t+2], bₜ[:, idx_top_k])
    progress && progressbar(stdout, horizon, t+1, start_time=start)
  end

  return OPSAlgorithm(n_assets, weights, "DRICORN-K")
end

"""
    dricorn_expert(
      relative_prices::AbstractMatrix{T},
      asset_ret::AbstractMatrix{T},
      market_ret::AbstractVector{T},
      horizon::S,
      w::S,
      rho::T,
      t::S,
      n_assets::S,
      lambda::T
    ) where {T<:AbstractFloat, S<:Integer}

Create an expert to perform the algorithm according to the given parameters.

# Arguments
- `relative_prices::AbstractMatrix{T}`: A matrix of relative prices of the assets.
- `asset_ret::AbstractMatrix{T}`: A matrix of assets' returns.
- `market_ret::AbstractVector{T}`: A vector of market's returns.
- `horizon::S`: The investment horizon.
- `w::S`: length of time window to be examined.
- `rho::T`: The correlation coefficient threshold.
- `t::S`: The current period index.
- `n_assets::S`: The number of assets.
- `lambda::T`: The regularization parameter.

# Returns
- `weight::AbstractVector{T}`: The weights of the assets for the period `t`.
"""
function dricorn_expert(
  relative_prices::AbstractMatrix{T},
  asset_ret::AbstractMatrix{T},
  market_ret::AbstractVector{T},
  horizon::S,
  w::S,
  rho::T,
  t::S,
  n_assets::S,
  lambda::T
) where {T<:AbstractFloat, S<:Integer}

  horizon≥size(relative_prices, 2) && ArgumentError("""The "horizon" ($horizon) is \
    bigger than data samples $(size(relative_prices, 2)).\nYou should either decrease \
    the "horizon" or add more data samples. (At least $(horizon-size(relative_prices, 2)) \
    more data samples are needed)."""
  ) |> throw

  shift            = horizon+t
  ρ                = rho
  relative_prices_ = relative_prices[:, 1:end-shift]
  n_periods        = size(relative_prices_, 2)
  # Coefficient behind βₚ. Check if the market return is at least 20% higher
  # than the return of 20 days before the current time window. If it is, then
  # the coefficient is 1. Otherwise, it is -1.
  market_ret[end-shift]/market_ret[end-shift-20] ≥ 1.2 ? c = 1 : c = -1
  # index of similar time windows
  idx_tws = locate_sim(relative_prices_, w, n_periods, ρ)
  isempty(idx_tws) && return fill(1/n_assets, n_assets)
  # index of a day after similar time windows
  idx_days = idx_tws.+w
  # Calculate β of each asset through the last month (20 days)
  β = zeros(T, n_assets, length(idx_days))
  for i ∈ 1:n_assets
    β[i, :] .= cor(
      asset_ret[i, end-shift-20:end-shift],
      market_ret[end-shift-20:end-shift]
    )/var(market_ret[end-shift-20:end-shift])
  end

  model = Model(Optimizer)
  set_silent(model)

  @variable(model, 0<=b[i=1:n_assets]<=1)
  @constraint(model, sum(b) == 1)
  @expression(model, h, (b' * relative_prices_[:, idx_days] .+ lambda*c.*(b'*β)))
  @NLobjective(model, Max, prod(h[i] for i=eachindex(h)))
  optimize!(model)
  weight = value.(b)
  weight = round.(abs.(weight), digits=3)
  isapprox(1., sum(weight), atol=1e-2) || normalizer!(weight)

  return weight
end
