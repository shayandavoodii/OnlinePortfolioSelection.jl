"""
    bcrp(rel_pr::AbstractMatrix{T}) where T<:AbstractFloat

Run Best Constant Rebalanced Portfolio (BCRP) algorithm.

# Arguments
- `rel_pr::AbstractMatrix{T}`: Relative price matrix.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object

# Example
```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(3, 8);

julia> m_bcrp = bcrp(rel_pr);

julia> m_bcrp.b
3×8 Matrix{Float64}:
 8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9
 1.0         1.0         1.0         1.0         1.0         1.0         1.0         1.0
 0.0         0.0         0.0         0.0         0.0         0.0         0.0         0.0

julia> sum(m_bcrp.b, dims=1) .|> isapprox(1.) |> all
true
```

# References
> [Universal Portfolios](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-9965.1991.tb00002.x)
"""
function bcrp(rel_pr::AbstractMatrix{T}) where T<:AbstractFloat
  n_assets, n_periods = size(rel_pr)
  𝐛   = bₜfunc(rel_pr)
  any(𝐛.<0.) && 𝐛 |> positify! |> normalizer!
  b    = stack(𝐛 for _=1:n_periods)
  return OPSAlgorithm(n_assets, b, "BCRP")
end

function bₜfunc(x::AbstractMatrix)
  n_assets, n_periods = size(x)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, 0. ≤ b[i=1:n_assets] ≤ 1.)
  @constraint(model, sum(b) == 1.)
  obj = -Inf
  𝐛 = similar(x, n_assets)
  for t ∈ 1:n_periods
    @NLobjective(model, Max, sum((b[i] * x[i, t]) for i=1:n_assets))
    optimize!(model)
    val = objective_value(model)
    if val>obj
      𝐛  .=value.(b)
      obj = val
    end
  end
  return 𝐛
end
