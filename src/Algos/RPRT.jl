"""
    rprt(
      adj_close::Matrix{T};
      w::Int64=5,
      theta::T=0.8,
      epsilon=50
    ) where T<:Float64

Run RPRT algorithm.

# Arguments
- `adj_close::Matrix{T}`: Adjusted close prices of assets.
- `w::Int64=5`: maximum length of time window to be examined.
- `theta::T=0.8`: The threshold for the relative price.
- `epsilon=50`: The threshold for the condition of the portfolio.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: An object of type `OPSAlgorithm`.

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> typeof(adj_close), size(adj_close)
(Matrix{Float64}, (3, 7))

julia> m_rprt = rprt(adj_close);

julia> m_rprt.b
3×7 Matrix{Float64}:
 0.333333  0.333333  0.0  0.0  0.0  1.0  0.0
 0.333333  0.333333  1.0  1.0  1.0  0.0  1.0
 0.333333  0.333333  0.0  0.0  0.0  0.0  0.0

julia> sum(m_rprt.b, dims=1) .|> isapprox(1.) |> all
true
```

# Reference
- [1] [Reweighted Price Relative Tracking System for Automatic Portfolio Optimization](https://ieeexplore.ieee.org/document/8411138/)
"""
function rprt(
  adj_close::Matrix{T};
  w::Int64=5,
  theta::T=0.8,
  epsilon=50
) where T<:Float64

  w≥2 || ArgumentError("Window length (w) must be greater than 1") |> throw
  n_assets, n_periods = size(adj_close)
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  relative_prices = hcat(ones(n_assets), relative_prices)
  θ, ϵ = theta, epsilon
  ϕ = relative_prices[:, 1]
  # Initialize the weights
  b = fill(1/n_assets, n_assets, n_periods)

  for t ∈ 2:n_periods
    last_relative_price = relative_prices[:, t-1]
    prediction = predict_relative_price(relative_prices[:, max(t-w-1, 0)+1:t-1])
    # predicted d
    dₚ = vec(prediction) |> diagm
    # predicted γ
    γₚ = θ * last_relative_price ./ (θ*last_relative_price+ϕ)
    # predicted ϕ
    ϕₚ = γₚ + (-γₚ.+1).*(ϕ./last_relative_price)
    ϕ = ϕₚ
    meanϕₚ = mean(ϕₚ)
    Δ = ϕₚ .- meanϕₚ
    condition = norm(Δ)^2
    λ = iszero(condition) ? 0 : max(0., (ϵ-(ϕₚ'*b[:, t-1]))/condition)
    w_ = iszero(λ) ? b[:, t-1] : b[:, t-1] .+ λ*(dₚ'*Δ)
    clamp!(w_, -1e-10, 1e10)
    b[:, t] = simplex_proj(w_)
  end
  isapprox.(sum(b, dims=1), 1., atol=1e-7) |> all || normalizer!(b)

  return OPSAlgorithm(n_assets, b, "RPRT")
end

function predict_relative_price(relative_price::Matrix{Float64})
  return mean(relative_price, dims=2)./relative_price[:, end]
end
