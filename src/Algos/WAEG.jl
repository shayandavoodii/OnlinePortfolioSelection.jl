function pₜ₊₁ηⱼfunc(βₜ₊₁::AbstractFloat, Gₜηⱼ::AbstractVector)
  numer = βₜ₊₁.^Gₜηⱼ
  return numer./sum(numer)
end

@inline Gₜηⱼfunc(Gₜ₋₁::AbstractVector, bₜ::AbstractMatrix, xₜ::AbstractVector) =
  [Gₜ₋₁[ηⱼ]+sum(log.(bₜ[:, ηⱼ].*xₜ)) for ηⱼ=axes(bₜ, 2)]

function bₜ₊₁ηⱼfunc!(bₜ::AbstractMatrix, η::AbstractVector, xₜ::AbstractVector)
  m, k   = axes(bₜ)
  𝐛ₜηⱼxₜ = [sum(bₜ[:, ηⱼ].*xₜ) for ηⱼ=k]
  xₜηⱼ   = xₜ*transpose(η)
  for ηⱼ ∈ k
    for i ∈ m
      bₜ[i, ηⱼ] = bₜ[i, ηⱼ]*exp(xₜηⱼ[i, ηⱼ]/𝐛ₜηⱼxₜ[ηⱼ])
    end
    bₜ[:, ηⱼ] = bₜ[:, ηⱼ]./sum(bₜ[:, ηⱼ])
  end
  return bₜ
end

@inline bₜ₊₁func(bₜ₊₁::AbstractMatrix, pₜ₊₁::AbstractVector) =
  sum([pₜ₊₁[ηⱼ]*bₜ₊₁[:, ηⱼ] for ηⱼ=axes(bₜ₊₁, 2)])

"""
    waeg(x::AbstractMatrix, ηₘᵢₙ::AbstractFloat, ηₘₐₓ::AbstractFloat, k::Integer)

Run Weak Aggregating Exponential Gradient (WAEG) algorithm.

# Arguments
- `x::AbstractMatrix`: matrix of relative prices.
- `ηₘᵢₙ::AbstractFloat`: minimum learning rate.
- `ηₘₐₓ::AbstractFloat`: maximum learning rate.
- `k::Integer`: number of EG experts.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(4, 8);

julia> m = waeg(rel_pr, 0.01, 0.2, 20);

julia> m.b
4×8 Matrix{Float64}:
 0.25  0.238126  0.24158   0.2619    0.261729  0.27466   0.25148   0.256611
 0.25  0.261957  0.259588  0.248465  0.228691  0.24469   0.256674  0.246801
 0.25  0.245549  0.247592  0.254579  0.27397   0.259982  0.272341  0.290651
 0.25  0.254368  0.25124   0.235057  0.23561   0.220668  0.219505  0.205937

julia> sum(m.b, dims=1) .|> isapprox(1.) |> all
true
```

# References
> [Boosting Exponential Gradient Strategy for Online Portfolio Selection: An Aggregating Experts’ Advice Method](https://doi.org/10.1007/s10614-019-09890-2)
"""
function waeg(x::AbstractMatrix, ηₘᵢₙ::AbstractFloat, ηₘₐₓ::AbstractFloat, k::Integer)
  ηₘₐₓ>ηₘᵢₙ || ArgumentError("`ηₘₐₓ` must be greater than ηₘᵢₙ.") |> throw
  1>ηₘₐₓ>0. || ArgumentError("`ηₘₐₓ` must be in the range (0, 1).") |> throw
  1>ηₘᵢₙ>0. || ArgumentError("`ηₘᵢₙ` must be in the range (0, 1).") |> throw
  k>1       || ArgumentError("`k` must be greater than 1.") |> throw
  n_assets, n_periods = size(x)
  ϵ = (ηₘₐₓ - ηₘᵢₙ)/(k-1)
  η = [ηₘᵢₙ + (i-1)*ϵ for i=1:k]
  bη = (eg(x, eta=val).b for val=η)
  b = similar(x)
  b[:, 1] .= 1/n_assets
  Gη = zeros(k)
  for t ∈ 1:n_periods-1
    bₜη  = stack(b[:, t] for b in bη, dims=2)
    Gη  .= Gₜηⱼfunc(Gη, bₜη, x[:, t])
    βₜ₊₁ = exp(1/√t)
    pₜ₊₁ = pₜ₊₁ηⱼfunc(βₜ₊₁, Gη)
    bₜ₊₁ηⱼfunc!(bₜη, η, x[:, t])
    b[:, t+1] = bₜ₊₁func(bₜη, pₜ₊₁)
  end
  return OPSAlgorithm(n_assets, b, "WAEG")
end
