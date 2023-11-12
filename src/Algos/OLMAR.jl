"""
    olmar(rel_pr::AbstractMatrix, horizon::Int, ω::Int, ϵ::Int)

Run the Online Moving Average Reversion algorithm.

# Arguments
- `rel_pr::AbstractMatrix`: Matrix of relative prices.
- `horizon::Int`: Investment horizon.
- `ω::Int`: Window size.
- `ϵ::Int`: Reversion threshold.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection

julia> adj = [
        1.315 1.326 1.358 1.39461 1.424 1.4015 1.52531
        1.215 1.111 1.215 1.35614 1.454 1.2158 1.32561
       ];

julia> m_olmar = olmar(adj, 2, 3);

julia> m_olmar.b
2×7 AbstractMatrix:
 0.5  0.5  1.0  1.0  1.0  1.0  0.0
 0.5  0.5  0.0  0.0  0.0  0.0  1.0

julia> all(sum(m_olmar.b, dims=1) .≈ 1.0)
true
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
    # rel_pr_       = rel_pr[:, 1:t-1]
    x̃ₜ₊₁        = pred_relpr(rel_pr[:, end-horizon-ω+1+t:end-horizon+t], ω)
    x̄ₜ₊₁        = mean(rel_pr[:, end-horizon+t])
    nominator   = ϵ-sum(b[:, t].*x̃ₜ₊₁)
    denominator = (x̃ₜ₊₁.-x̄ₜ₊₁).^2 |> sum
    # λₜ₊₁        = iszero(denominator) ? 0. : max(0., nominator/denominator)
    λₜ₊₁        = max(0., nominator/denominator)
    bₜ₊₁        = b[:, t] .+ λₜ₊₁.*(x̃ₜ₊₁.-x̄ₜ₊₁)
    bₜ₊₁        = bₜ₊₁ |> OnlinePortfolioSelection.normptf
    b[:, t+1]   = bₜ₊₁
  end
  any(b .< 0.) && b |> positify! |> normalizer!
  return OPSAlgorithm(nassets, b, "OLMAR")
end

function pred_relpr(relpr::AbstractMatrix, ω::Int)
  n = size(relpr, 2)
  return 1/ω * sum(relpr[:, idx]./relpr[:, end] for idx=1:n)
end
