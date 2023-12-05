auxfunc(t::Integer, τ::Real) = exp(-(t^2)/(2τ^2))

"""
    lfunc(τ::Real, ϵ::AbstractFloat)

Calculate the window width.

# Arguments
- `τ::Real`: The parameter of gaussian function.
- `ϵ::AbstractFloat`: A parameter to control the weighted range.

# Returns
- `::Int`: The window width
"""
lfunc(τ::Real, ϵ::AbstractFloat) = floor(Int, √(-2τ^2*log(ϵ)))

"""
    pp1(prices::AbstractMatrix, τ::Real, l::Integer)

``pp1`` function.

# Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `τ::Real`: The parameter of gaussian function.
- `l::Integer`: The window width.

# Returns
- `::AbstractVector`: The vector of ``pp1`` values.
"""
function pp1(prices::AbstractMatrix, τ::Real, l::Integer)
  _, n_samples = size(prices)
  numerator_   = similar(prices)
  container    = map(auxfunc, l:-1:1, fill(τ, l))
  denominator_ = sum(container)
  for i=1:n_samples
    numerator_[:, i] = container[i] .* prices[:, i]
  end
  numerator = sum(numerator_, dims=2) |> vec
  return numerator ./ denominator_
end

"""
    pp2(prices::AbstractMatrix, τ::Real, l::Integer)

``pp2`` function.

# Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `τ::Real`: The parameter of gaussian function.
- `l::Integer`: The window width.

# Returns
- `::AbstractVector`: The vector of ``pp2`` values.
"""
function pp2(prices::AbstractMatrix, τ::Real, l::Integer)
  _, n_samples = size(prices)
  numerator_   = similar(prices)
  container    = map(auxfunc, l:-1:2, fill(τ, l-1))
  denominator_ = sum(i->exp(-(i^2)/(2τ^2)), l:-1:1)
  for i ∈ 1:n_samples-1
    numerator_[:, i] = container[i] .* prices[:, i+1]
  end
  pp1vec      = pp1(prices, τ, l)
  numerator   = sum(numerator_, dims=2) |> vec
  numerator .+= exp(-1/(2τ^2)).*pp1vec
  return numerator ./ denominator_
end

"""
    x̂ₜ₊₁func(prices::AbstractMatrix, τ::Real, l::Integer)

Predict the next price relative.

# Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `τ::Real`: The parameter of gaussian function.
- `l::Integer`: The window width.

# Returns
- `::AbstractVector`: The next price relative.
"""
function x̂ₜ₊₁func(prices::AbstractMatrix, τ::Real, l::Integer)
  return (pp1(prices[:, 2:end], τ, l) .+ pp2(prices[:, 1:end-1], τ, l))./2prices[:, end]
end

"""
    passiveagressive(x̂ₜ₊₁::AbstractVector, 𝛿::Integer, bₜ::AbstractVector)

The ``PassiveAgressive`` function.

# Arguments
- `x̂ₜ₊₁::AbstractVector`: The next price relative.
- `𝛿::Integer`: Hyperparameter.
- `bₜ::AbstractVector`: Current portfolio.

# Returns
- `::AbstractVector`: The updated portfolio.
"""
function passiveagressive(x̂ₜ₊₁::AbstractVector, 𝛿::Integer, bₜ::AbstractVector)
  x̄ₜ₊₁ = sum(x̂ₜ₊₁) / length(x̂ₜ₊₁)
  wₜ₊₁ = max((𝛿-sum(x̂ₜ₊₁.*bₜ))/norm(x̂ₜ₊₁.-x̄ₜ₊₁)^2, 0.)
  bₜ₊ = bₜ .+ wₜ₊₁ .* (x̂ₜ₊₁ .- x̄ₜ₊₁)
  return normptf(bₜ₊)
end

"""
    gwr(
      prices::AbstractMatrix,
      horizon::Integer,
      τ::Real=2.8,
      𝛿::Integer=50,
      ϵ::AbstractFloat=0.005
    )

    gwr(
      prices::AbstractMatrix,
      horizon::Integer,
      τ::AbstractVector{<:Real},
      𝛿::Integer=50,
      ϵ::AbstractFloat=0.005
    )

Run the Gaussian Weighting Reversion (GWR) Strategy.

!!! warning "Beware!"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

# Method 1
Run 'GWR' variant.

## Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `horizon::Integer`: The investment horizon.
- `τ::Real=2.8`: The parameter of gaussian function.
- `𝛿::Integer=50`: Hyperparameter.
- `ϵ::AbstractFloat=0.005`: A parameter to control the weighted range.

## Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

## Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "GOOG", "META"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-23")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1)
3×14 Matrix{Float64}:
 154.78    152.852  153.247   151.85   154.269  156.196   155.473   157.343   156.235  157.246  160.128  161.024   160.446  159.675
  68.3685   68.033   69.7105   69.667   70.216   70.9915   71.4865   71.9615   71.544   71.96    72.585   74.0195   74.22    74.2975
 209.78    208.67   212.6     213.06   215.22   218.3     218.06    221.91    219.06   221.15   221.77   222.14    221.44   221.32

julia> h = 3

julia> model = gwr(prices, h);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  0.333333  1.4095e-11
 0.333333  0.333333  0.0
 0.333333  0.333333  1.0
```

# Method 2
Run 'GWR-A' variant.

## Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `horizon::Integer`: The investment horizon.
- `τ::AbstractVector{<:Real}`: The parameters of gaussian function.
- `𝛿::Integer=50`: Hyperparameter.
- `ϵ::AbstractFloat=0.005`: A parameter to control the weighted range.

## Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

## Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "GOOG", "META"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-23")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1)
3×14 Matrix{Float64}:
 154.78    152.852  153.247   151.85   154.269  156.196   155.473   157.343   156.235  157.246  160.128  161.024   160.446  159.675
  68.3685   68.033   69.7105   69.667   70.216   70.9915   71.4865   71.9615   71.544   71.96    72.585   74.0195   74.22    74.2975
 209.78    208.67   212.6     213.06   215.22   218.3     218.06    221.91    219.06   221.15   221.77   222.14    221.44   221.32

julia> h = 3

julia> model = gwr(prices, h, [2, 3, 4]);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  0.0  1.20769e-11
 0.333333  0.0  0.0
 0.333333  1.0  1.0
```

# Reference
> [Gaussian Weighting Reversion Strategy for Accurate On-line Portfolio Selection](https://doi.org/10.1109/TSP.2019.2941067)
"""
function gwr(
  prices::AbstractMatrix,
  horizon::Integer,
  τ::Real=2.8,
  𝛿::Integer=50,
  ϵ::AbstractFloat=0.005
)

  n_assets, n_samples = size(prices)
  horizon>0 || ArgumentError("`horizon` must be a positive value.") |> throw
  τ>0       || ArgumentError("`τ` must be a positive value.") |> throw
  𝛿>0       || ArgumentError("`𝛿` must be a positive value.") |> throw
  ϵ>0       || ArgumentError("`ϵ` must be a positive value.") |> throw
  l = lfunc(τ, ϵ)
  l>0         || ArgumentError("window width `l` must be a positive value. Change the content \
  of `τ` vector and/or the `ϵ` value`.") |> throw
  n_samples-horizon+1-l>0 || ArgumentError("The number of samples is insufficient. With \
  tha passed arguments, at least $(-(n_samples-horizon+1-l)+1) data points are needed. \
  Either provide more data samples, or change the `τ` and/or `ϵ` values") |> throw
  b = ones(n_assets, horizon)/n_assets
  for t ∈ 1:horizon-1
    x̂ₜ₊₁      = x̂ₜ₊₁func(prices[:, end-horizon+t-l:end-horizon+t], τ, l)
    bₜ₊₁      = passiveagressive(x̂ₜ₊₁, 𝛿, b[:, t])
    b[:, t+1] = bₜ₊₁
  end
  any(b.<0.) && b |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, "GWR")
end

function gwr(
  prices::AbstractMatrix,
  horizon::Integer,
  τ::AbstractVector{<:Real},
  𝛿::Integer=50,
  ϵ::AbstractFloat=0.005
)

  n_assets, n_samples = size(prices)
  horizon>0    || ArgumentError("`horizon` must be a positive value.") |> throw
  𝛿>0          || ArgumentError("`𝛿` must be a positive value.") |> throw
  ϵ>0          || ArgumentError("`ϵ` must be a positive value.") |> throw
  all(τ .> 0.) || ArgumentError("All elements of `τ` must be positive.") |> throw
  m           = length(τ)
  m>1         || ArgumentError("The length of `τ` must be greater than 1.") |> throw
  k           = rand(1:m)
  l           = lfunc(τ[k], ϵ)
  l>0         || ArgumentError("window width `l` must be a positive value. Change the content \
  of `τ` vector and/or the `ϵ` value`.") |> throw
  n_samples-horizon+1-lfunc(maximum(τ), ϵ)>0 || ArgumentError("The number of samples is insufficient. With \
  tha passed arguments, at least $(-(n_samples-horizon+1-l)+1) data points are needed. \
  Either provide more data samples, or decrease the maximum value of `τ` and/or `ϵ` value.") |> throw
  b           = ones(n_assets, horizon)/n_assets
  s̄           = zeros(m)
  N           = zeros(m)
  for t ∈ 1:horizon-1
    xₜ₊₁      = prices[:, end-horizon+t]./prices[:, end-horizon+t-1]
    sₜ        = sum(b[:, t].*xₜ₊₁)
    s̄[k]      = (s̄[k] * N[k] + sₜ)/(N[k] + 1)
    N[k]      = N[k] + 1
    ζ         = 1/t
    CIₖ       = sqrt(((1+N[k])/N[k]^2)*(1+2log((n_assets*sqrt(1+N[k]))/ζ)))
    k         = argmax(s̄ .+ CIₖ)
    x̂ₜ₊₁      = x̂ₜ₊₁func(prices[:, end-horizon+t-l:end-horizon+t], τ[k], l)
    bₜ₊₁      = passiveagressive(x̂ₜ₊₁, 𝛿, b[:, t])
    b[:, t+1] = bₜ₊₁
  end
  any(b.<0.) && b |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, "GWR-A")
end
