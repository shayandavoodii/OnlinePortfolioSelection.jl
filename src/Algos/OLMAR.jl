"""
    olmar(rel_pr::AbstractMatrix, horizon::Int, ω::Int, ϵ::Int)
    olmar(rel_pr::AbstractMatrix, horizon::Int, ω::AbstractVector{<:Int}, ϵ::Int)

# Method 1
Run the Online Moving Average Reversion algorithm (OLMAR).

## Arguments
- `rel_pr::AbstractMatrix`: Matrix of relative prices.
- `horizon::Int`: Investment horizon.
- `ω::Int`: Window size.
- `ϵ::Int`: Reversion threshold.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

## Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "GOOG", "META"];

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> horizon = 5;
julia> windows = 3;
julia> epsilon = 4;

julia> m_olmar = olmar(rel_pr, horizon, windows, epsilon);

julia> m_olmar.b
5×5 Matrix{Float64}:
 0.2  1.0         0.484825  1.97835e-8  0.0
 0.2  1.95724e-8  0.515175  0.0         0.0
 0.2  0.0         0.0       1.0         1.0
 0.2  0.0         0.0       0.0         0.0
 0.2  0.0         0.0       0.0         1.9851e-8

julia> all(sum(m_olmar.b, dims=1) .≈ 1.0)
true
```

# Method 2
Run BAH(OLMAR) algorithm.

## Arguments
- `rel_pr::AbstractMatrix`: Matrix of relative prices.
- `horizon::Int`: Investment horizon.
- `ω::AbstractVector{<:Int}`: Window sizes.
- `ϵ::Int`: Reversion threshold.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

## Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "GOOG", "META"];

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> horizon = 5;
julia> windows = [3, 5, 7];
julia> epsilon = 4;

julia> model = olmar(rel_pr, horizon, windows, epsilon);

julia> model.b
5×5 Matrix{Float64}:
 0.2  0.2  0.333333    0.162297  1.33072e-8
 0.2  0.2  1.31177e-8  0.555158  0.0
 0.2  0.2  6.57906e-9  0.0       0.667358
 0.2  0.2  0.0         0.0       0.332642
 0.2  0.2  0.666667    0.282545  0.0
```

# References
> [On-Line Portfolio Selection with Moving Average Reversion](https://doi.org/10.48550/arXiv.1206.4626)
"""
function olmar(rel_pr::AbstractMatrix, horizon::Int, ω::Int, ϵ::Int)
  nassets, n_samples = size(rel_pr)
  ϵ>1 || ArgumentError("ϵ must be > 1") |> throw
  ω≥3 || ArgumentError("ω must be ≥ 3") |> throw
  n_samples≥ω+horizon-1 || ArgumentError("n_samples must be ≥ ω+horizon-1. Insufficient /
  amount of data is provided. Either provide $(ω+horizon-1-n_samples) more data points or /
  decrease ω and/or horizon.") |> throw
  b        = similar(rel_pr, nassets, horizon)
  b[:, 1] .= 1/nassets

  @inbounds for t ∈ 1:horizon-1
    x̃ₜ₊₁        = pred_relpr(rel_pr[:, end-horizon-ω+1+t:end-horizon+t], ω)
    x̄ₜ₊₁        = mean(rel_pr[:, end-horizon+t])
    nominator   = ϵ-sum(b[:, t].*x̃ₜ₊₁)
    denominator = (x̃ₜ₊₁.-x̄ₜ₊₁).^2 |> sum
    λₜ₊₁        = max(0., nominator/denominator)
    bₜ₊₁        = b[:, t] .+ λₜ₊₁.*(x̃ₜ₊₁.-x̄ₜ₊₁)
    bₜ₊₁        = bₜ₊₁ |> OnlinePortfolioSelection.normptf
    b[:, t+1]   = bₜ₊₁
  end
  any(b .< 0.) && b |> positify! |> normalizer!
  return OPSAlgorithm(nassets, b, "OLMAR")
end

function olmar(rel_pr::AbstractMatrix, horizon::Int, ω::AbstractVector{<:Int}, ϵ::Int)
  nassets, n_samples = size(rel_pr)
  n_samples≥maximum(ω)+horizon-1 || ArgumentError("n_samples must be ≥ ω+horizon-1. Insufficient /
  amount of data is provided. Either provide $(maximum(ω)+horizon-1-n_samples) more data points or /
  decrease ω and/or horizon.") |> throw
  all(ω.≥3)         || ArgumentError("ω elements must be ≥ 3") |> throw
  all(unique(ω)==ω) || ArgumentError("ω elements must be unique") |> throw
  length(ω)≥2       || ArgumentError("ω must contain at least two values") |> throw
  b              = similar(rel_pr, nassets, horizon)
  b[:, 1]       .= 1/nassets
  n_experts      = length(ω)
  expert_weights = (olmar(rel_pr, horizon, ω[i], ϵ).b for i = 1:n_experts)
  expert_sn      = [sn(w, rel_pr) for w = expert_weights]
  numerator_     = zeros(nassets)
  denumerator_   = 0.
  for t ∈ 1:horizon-1
    for (idx, exp_w) ∈ enumerate(expert_weights)
      numerator_ .+= exp_w[:, t]*expert_sn[idx][t]
      denumerator_     += expert_sn[idx][t]
    end
    b[:, t+1]    = numerator_/denumerator_
    numerator_  .= 0.
    denumerator_ = 0.
  end

  return OPSAlgorithm(nassets, b, "BAH(OLMAR)")
end

function pred_relpr(relpr::AbstractMatrix, ω::Int)
  n = size(relpr, 2)
  return 1/ω * sum(relpr[:, idx]./relpr[:, end] for idx=1:n)
end
