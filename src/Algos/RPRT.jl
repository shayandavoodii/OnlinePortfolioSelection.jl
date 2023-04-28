using Statistics
using LinearAlgebra
include("../Tools/tools.jl");
include("../Types/Algorithms.jl");

"""
    RPRT(
      adj_close::Matrix{T};
      w::Int64=5,
      init_budg::Int=1.,
      theta::T=0.8,
      epsilon=50
    ) where T<:Float64

Run RPRT algorithm.

# Arguments
- `adj_close::Matrix{T}`: Adjusted close prices of assets.
- `w::Int64=5`: maximum length of time window to be examined.
- `init_budg::Int=1.`: The initial budget for investment.
- `theta::T=0.8`: The threshold for the relative price.
- `epsilon=50`: The threshold for the condition of the portfolio.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, budgets, alg)`: An object of type `OPSAlgorithm`.

# Reference
- [1] [Reweighted Price Relative Tracking System for Automatic Portfolio Optimization](https://ieeexplore.ieee.org/document/8411138/)

# Examples
```julia
julia> using OPS

julia> typeof(adj_close), size(adj_close)
(Matrix{Float64}, (3, 10))

julia> rprt = RPRT(adj_close);

julia> rprt.b
3×10 Matrix{Float64}:
 0.333333  0.333333  0.333333  0.333333  0.0       0.0369806  0.315476  0.382559  0.942964   0.678569
 0.333333  0.333333  0.333333  0.333333  0.464174  0.694045   0.137325  0.392694  0.0313677  0.0
 0.333333  0.333333  0.333333  0.333333  0.535826  0.268975   0.547199  0.224747  0.0256685  0.321431

julia> sum(rprt.b, dims=1) .|> isapprox(1.) |> all
true
```
"""
function RPRT(
  adj_close::Matrix{T};
  w::Int64=5,
  init_budg=1.,
  theta::T=0.8,
  epsilon=50
) where T<:Float64

  w≥2 || ArgumentError("Window length (w) must be greater than 1") |> throw
  n_assets, n_periods = size(adj_close)
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  θ, ϵ= theta, epsilon
  ϕ = relative_prices[:, 1]
  # Initialize the weights
  b = zeros(n_assets, n_periods)
  last_b = ones(n_assets)/n_assets

  for t ∈ axes(adj_close, 2)
    if t<w
      b[:, t] = last_b
      continue
    end
    last_relative_price = relative_prices[:, t-w+(w-1)]
    prediction = predict_relative_price(relative_prices[:, t-w+1:t-1])
    # predicted d
    dₚ = vec(prediction) |> diagm
    # predicted γ
    γₚ = θ * last_relative_price ./ (θ*last_relative_price+ϕ)
    # predicted ϕ
    ϕₚ = γₚ + (-γₚ.+1).*(ϕ./last_relative_price)
    ϕ = ϕₚ
    # Update the b
    meanϕₚ = mean(ϕₚ)
    condition = norm(ϕₚ .- meanϕₚ)^2
    λ = iszero(condition) ? 0 : max(0., ϵ.-(ϕₚ'*b[:, t])/condition)
    w_ = iszero(λ) ? b[:, t] : b[:, t] .+ (dₚ*(ϕₚ .- meanϕₚ)).*λ
    clamp!(w_, -1e10, 1e10)
    b[:, t] = simplex_proj(w_)
  end
  normalizer!(b)

  Snₜ = Sn(relative_prices, b, init_budg)

  return OPSAlgorithm(n_assets, b, Snₜ, "RPRT")
end

function predict_relative_price(relative_price::Matrix{Float64})
  return mean(relative_price, dims=2)./relative_price[:, end]
end
