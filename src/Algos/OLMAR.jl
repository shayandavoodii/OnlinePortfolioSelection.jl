"""
    olmar(adj_close::Matrix{<:Real}, ϵ::Int, ω::Int)::OPSAlgortihm

Run the Online Moving Average Reversion algorithm.

# Arguments
- `adj_close::Matrix{<:Real}`: matrix of adjusted closing prices.
- `ϵ::Int`: Reversion threshold.
- `ω::Int`: Window size.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgortihm(n_asset, b, alg)`: An `OPSAlgortihm` object.

# Example
```julia
julia> using OnlinePortfolioSelection

julia> adj = [
        1.315 1.326 1.358 1.39461 1.424 1.4015 1.52531
        1.215 1.111 1.215 1.35614 1.454 1.2158 1.32561
       ];

julia> m_olmar = olmar(adj, 2, 3);

julia> m_olmar.b
2×7 Matrix{Float64}:
 0.5  0.5  1.0  1.0  1.0  1.0  0.0
 0.5  0.5  0.0  0.0  0.0  0.0  1.0

julia> all(sum(m_olmar.b, dims=1) .≈ 1.0)
true
```

# References
- [1] [On-Line Portfolio Selection with Moving Average Reversion](https://doi.org/10.48550/arXiv.1206.4626)
"""
function olmar(adj_close::Matrix{<:Real}, ϵ::Int, ω::Int)::OPSAlgorithm
  ϵ>1 || ArgumentError("ϵ must be > 1") |> throw
  ω≥3 || ArgumentError("ω must be ≥ 3") |> throw
  nassets, nperiods = size(adj_close)
  b                 = fill(1/nassets, nassets, nperiods)
  rel_pr            = adj_close[:, 2:end]./adj_close[:, 1:end-1]
  rel_pr            = hcat(fill(1.0, nassets, 1), rel_pr)

  for day_idx ∈ 2:nperiods
    rel_pr_       = rel_pr[:, 1:day_idx-1]
    x̃ₜ₊₁          = pred_relpr(rel_pr_, ω)
    x̄ₜ₊₁          = mean(rel_pr_, dims=2)
    nominator     = ϵ-b[:, day_idx-1]'*x̃ₜ₊₁
    denominator   = (x̃ₜ₊₁.-x̄ₜ₊₁).^2 |> sum
    λₜ₊₁          = iszero(denominator) ? 0. : max(0., nominator/denominator)
    bₜ₊₁          = b[:, day_idx-1] .+ λₜ₊₁.*(x̃ₜ₊₁.-x̄ₜ₊₁)
    bₜ₊₁          = bₜ₊₁ |> vec |> simplex_proj
    sum(bₜ₊₁)≈1.0 || normalizer!(bₜ₊₁)
    b[:, day_idx] = bₜ₊₁
  end

  return OPSAlgorithm(nassets, b, "OLMAR")
end

function pred_relpr(relpr::Matrix{Float64}, ω::Int)::Vector{Float64}
  size(relpr, 2) < ω && return relpr[:, end]
  n = size(relpr, 2)
  return 1/ω .* sum(relpr[:, idx]./relpr[:, end] for idx=n:-1:n-ω+1)
end
