function T̃func(p::AbstractMatrix, μ::AbstractVector)
  firstterm  = sum(1/norm(x.-μ) for x=eachcol(p) if x!=μ).^-1
  secondterm = sum(x/norm(x.-μ) for x=eachcol(p) if x!=μ) |> vec
  return firstterm*secondterm
end

function 𝑇func(μ::AbstractVector, p::AbstractMatrix)
  η = any(map(x->x==μ, eachcol(p)))
  R̃ = sum((x.-μ)/norm(x.-μ) for x=eachcol(p) if x!=μ) |> vec
  γ = norm(R̃)
  T̃ = T̃func(p, μ)
  return max(0., 1-η/γ)*T̃.+min(1., η/γ)*μ
end

function x̂ₜ₊₁func(::RMRVariant, p::AbstractMatrix, m::Integer, τ)
  n_assets = size(p, 1)
  𝜇        = similar(p, n_assets, m)
  𝜇[:, 1]  = median(p, dims=2)
  𝜇ᵢ       = similar(p, n_assets)
  for i ∈ 2:m
    𝜇[:, i] = 𝜇ᵢ = 𝑇func(𝜇[:, i-1], p)
    norm(𝜇[:, i-1].-𝜇[:, i], 1)≤τ*norm(𝜇[:, i], 1) && break
  end
  p̂ₜ₊₁ = 𝜇ᵢ
  return p̂ₜ₊₁./p[:, end]
end

function updtportf(ϵ, x̂ₜ₊₁::AbstractVector, bₜ::AbstractVector)
  x̄ₜ₊₁ = mean(x̂ₜ₊₁)
  αₜ₊₁ = min(0., (sum(x̂ₜ₊₁.*bₜ)-ϵ)/norm(x̂ₜ₊₁.-x̄ₜ₊₁)^2)
  bₜ₊₁ = bₜ .- αₜ₊₁*(x̂ₜ₊₁.-x̄ₜ₊₁) |> normptf
  return bₜ₊₁
end

"""
    rmr(p::AbstractMatrix, horizon::Integer, w::Integer, ϵ, m, τ)

Run Robust Median Reversion (RMR) algorithm.

# Arguments
- `p::AbstractMatrix`: Prices matrix.
- `horizon::Integer`: Number of periods to run the algorithm.
- `w::Integer`: Window size.
- `ϵ`: Reversion threshold.
- `m`: Maxmimum number of iterations.
- `τ`: Toleration level.

# Returns
- `OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers];

julia> prices = stack(querry, dims=1);

julia> horizon = 5

julia> window = 5

julia> ϵ = 5

julia> m = 7

julia> τ = 1e6

julia> model = rmr(prices, horizon, window, ϵ, m, τ);

julia> model.b
4×5 Matrix{Float64}:
 0.25  1.0         1.0       1.0         1.0
 0.25  0.0         0.0       0.0         0.0
 0.25  0.0         0.0       0.0         0.0
 0.25  1.14513e-8  9.979e-9  9.99353e-9  1.03254e-8
```

# Reference
> [Robust Median Reversion Strategy for Online Portfolio Selection](https://www.doi.org/10.1109/TKDE.2016.2563433)
"""
function rmr(p::AbstractMatrix, horizon::Integer, w::Integer, ϵ, m, τ)
  horizon>0 || ArgumentError("`horizon` should be positive. Got $horizon.") |> throw
  w>0 || ArgumentError("`w` should be positive. Got $w.") |> throw
  ϵ>0 || ArgumentError("`ϵ` should be positive. Got $ϵ.") |> throw
  m>0 || ArgumentError("`m` should be positive. Got $m.") |> throw
  τ>0 || ArgumentError("`τ` should be positive. Got $τ.") |> throw
  n_assets, n_samples = size(p)
  n_samples≥horizon+w-1 || ArgumentError("Not enough samples. Got $n_samples, need at least \
  $(horizon+w-1).") |> throw

  b        = similar(p, n_assets, horizon)
  b[:, 1] .= 1/n_assets
  for t ∈ 1:horizon-1
    x̂ₜ₊₁      = x̂ₜ₊₁func(RMR(), p[:, end-horizon-w+t+1:end-horizon+t], m, τ)
    b[:, t+1] = updtportf(ϵ, x̂ₜ₊₁, b[:, t])
  end
  any(b.<0.) && b |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, "RMR")
end
