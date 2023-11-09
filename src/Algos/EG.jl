"""
    eg(rel_pr::Matrix{Float64}; eta=0.05)

Exponential Gradient (EG) algorithm.

Calculate the Exponential Gradient (EG) weights and budgets
using the given historical prices and parameters and return
an EG object.

# Arguments
- `rel_pr::Matrix{Float64}`: Historical relative prices.

## Keyword Arguments
- `eta=0.05`: Learning rate.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: OPSAlgorithm object.

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> typeof(rel_pr), size(rel_pr)
(Matrix{Float64}, (3, 10))

julia> m_eg = eg(rel_pr);

julia> m_eg.b
3×10 Matrix{Float64}:
 0.333333  0.334092  0.325014  0.331234  0.314832  0.324674  0.326467  0.357498  0.353961  0.340167
 0.333333  0.345278  0.347718  0.337116  0.359324  0.363286  0.36466   0.348263  0.345386  0.355034
 0.333333  0.32063   0.327267  0.331649  0.325843  0.31204   0.308873  0.294239  0.300652  0.304799

julia> sum(m_eg.b, dims=1) .|> isapprox(1.0) |> all
true
```

# References
> [On-Line Portfolio Selection Using Multiplicative Updates](https://onlinelibrary.wiley.com/doi/10.1111/1467-9965.00058)
"""
function eg(rel_pr::Matrix{Float64}; eta=0.05)
  # Calculate relative prices
  n_assets, n_periods = size(rel_pr)

  # Initialiate Vector of weights
  b = ones(n_assets, n_periods)/n_assets

  # Calculate weights
  @inbounds for t ∈ 1:n_periods-1
    last_b   = @view b[:, t]
    last_rel = @view rel_pr[:, t]
    w        = last_b .* exp.(
      eta.*last_rel/sum(last_rel.*last_b)
    )
    b[:, t+1] = w
  end
  normalizer!(b)
  return OPSAlgorithm(n_assets, b, "EG")
end
