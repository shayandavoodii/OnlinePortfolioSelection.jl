"""
  wᵢᵗ⁺¹func(
    model::EGE,
    η::AbstractFloat,
    vᵗ::AbstractVector,
    _::AbstractVector,
    wᵗ::AbstractVector,
    xᵗ::AbstractVector
  )

  wᵢᵗ⁺¹func(
    model::EGR,
    η::AbstractFloat,
    _::AbstractVector,
    mᵗ::AbstractVector,
    wᵗ::AbstractVector,
    xᵗ::AbstractVector
  )

  wᵢᵗ⁺¹func(
    model::EGA,
    η::AbstractFloat,
    vᵗ::AbstractVector,
    mᵗ::AbstractVector,
    wᵗ::AbstractVector,
    xᵗ::AbstractVector
  )

Calculate the weights for the next period using the EGM framework.

# Method 1: EGE
## Arguments
- `model::EGE`: EGM framework with `gamma1` parameter. See [`EGE`](@ref) type.
- `η::AbstractFloat`: learning rate.
- `vᵗ::AbstractVector`: vector of size `n_assets`.
- `_::AbstractVector`: dummy vector of size `n_assets`.
- `wᵗ::AbstractVector`: vector of size `n_assets` containing the weights for the current period.
- `xᵗ::AbstractVector`: vector of size `n_assets` containing the relative prices for the current period.

## Returns
- `::AbstractVector`: vector of size `n_assets` containing the weights for the next period.

# Method 2: EGR
## Arguments
- `model::EGR`: EGM framework with `gamma2` parameter. See [`EGR`](@ref) type.
- `η::AbstractFloat`: learning rate.
- `_::AbstractVector`: dummy vector of size `n_assets`.
- `mᵗ::AbstractVector`: vector of size `n_assets`.
- `wᵗ::AbstractVector`: vector of size `n_assets` containing the weights for the current period.
- `xᵗ::AbstractVector`: vector of size `n_assets` containing the relative prices for the current period.

## Returns
- `::AbstractVector`: vector of size `n_assets` containing the weights for the next period.

# Method 3: EGA
## Arguments
- `model::EGA`: EGM framework with `gamma1` and `gamma2` parameters. See [`EGA`](@ref) type.
- `η::AbstractFloat`: learning rate.
- `vᵗ::AbstractVector`: vector of size `n_assets`.
- `mᵗ::AbstractVector`: vector of size `n_assets`.
- `wᵗ::AbstractVector`: vector of size `n_assets` containing the weights for the current period.
- `xᵗ::AbstractVector`: vector of size `n_assets` containing the relative prices for the current period.

## Returns
- `::AbstractVector`: vector of size `n_assets` containing the weights for the next period.
"""
function wᵢᵗ⁺¹func(
  model::EGE,
  η::AbstractFloat,
  vᵗ::AbstractVector,
  _::AbstractVector,
  wᵗ::AbstractVector,
  xᵗ::AbstractVector
)
  γ₁         = model.gamma1
  gᵗ         = xᵗ./sum(xᵗ.*wᵗ)
  vᵗ⁺¹       = vᵗ .= γ₁*vᵗ.+(1-γ₁).*gᵗ
  numerator_ = wᵗ.*exp.(η.*vᵗ⁺¹)
  return numerator_/sum(numerator_)
end

function wᵢᵗ⁺¹func(
  model::EGR,
  η::AbstractFloat,
  _::AbstractVector,
  mᵗ::AbstractVector,
  wᵗ::AbstractVector,
  xᵗ::AbstractVector
)
  γ₂         = model.gamma2
  gᵗ         = xᵗ./sum(xᵗ.*wᵗ)
  mᵗ⁺¹       = mᵗ .= γ₂*mᵗ.+(1-γ₂).*(gᵗ.^2)
  numerator_ = ((wᵗ.*exp.(η.*gᵗ))./(sqrt.(mᵗ⁺¹).+1e-8))
  return numerator_/sum(numerator_)
end

algname(::EGE) = "EGE"
algname(::EGR) = "EGR"
algname(::EGA) = "EGA"

function wᵢᵗ⁺¹func(
  model::EGA,
  η::AbstractFloat,
  vᵗ::AbstractVector,
  mᵗ::AbstractVector,
  wᵗ::AbstractVector,
  xᵗ::AbstractVector
)
  γ₁         = model.gamma1
  γ₂         = model.gamma2
  gᵗ         = xᵗ./sum(xᵗ.*wᵗ)
  vᵗ⁺¹       = vᵗ .= γ₁*vᵗ.+(1-γ₁).*gᵗ
  mᵗ⁺¹       = mᵗ .= γ₂*mᵗ.+(1-γ₂).*(gᵗ.^2)
  numerator_ = (wᵗ.*exp.(η.*vᵗ⁺¹))./(sqrt.(mᵗ⁺¹).+1e-8)
  return numerator_/sum(numerator_)
end

"""
    egm(rel_pr::AbstractMatrix, model::EGMFramework, η::AbstractFloat=0.05)

Run the Exponential Gradient with Momentum (EGM) algorithm. This framework contains three \
variants: [`EGE`](@ref), [`EGR`](@ref) and [`EGA`](@ref).

# Arguments
- `rel_pr::AbstractMatrix`: matrix of size `n_assets` by `n_periods` containing the \
  relative prices.
- `model::EGMFramework`: EGM framework. [`EGE`](@ref), [`EGR`](@ref) or [`EGA`](@ref) can \
  be used.
- `η::AbstractFloat=0.05`: learning rate.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-01-12")["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1]
3×7 Matrix{Float64}:
 0.900393  1.04269  0.997774  1.01906  1.01698   1.0032    0.990182
 0.963212  1.04651  1.00128   1.00725  1.0143    0.993574  0.992278
 0.971516  1.05379  0.997833  1.00738  0.998495  0.995971  0.987723

julia> # EGE variant
julia> variant = EGE(0.5)

julia> model = egm(rel_pr, variant);

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.33294   0.332704  0.332576  0.332576  0.332634  0.332711
 0.333333  0.333493  0.333564  0.333619  0.333614  0.333647  0.33363
 0.333333  0.333567  0.333732  0.333805  0.33381   0.333719  0.333659

julia> # EGR variant
julia> variant = EGR(0.)

julia> model = egm(rel_pr, variant);

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.348653  0.350187  0.350575  0.348072  0.345816  0.344006
 0.333333  0.327     0.327299  0.326573  0.327852  0.326546  0.327824
 0.333333  0.324347  0.322514  0.322853  0.324077  0.327638  0.328169

julia> # EGA variant
julia> variant = EGA(0.5, 0.)

julia> model = egm(rel_pr, variant);

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.349056  0.350429  0.350706  0.348071  0.345757  0.343929
 0.333333  0.326833  0.327223  0.326516  0.327857  0.326514  0.327842
 0.333333  0.324111  0.322348  0.322779  0.324072  0.327729  0.328229
```

# References
> [Exponential Gradient with Momentum for Online Portfolio Selection](https://doi.org/10.1016/j.eswa.2021.115889)
"""
function egm(rel_pr::AbstractMatrix, variant::EGMFramework, η::AbstractFloat=0.05)
  η>0 || ArgumentError("η must be positive") |> throw
  n_assets, n_periods = size(rel_pr)
  b                   = ones(n_assets, n_periods)/n_assets
  vₜ                  = zeros(n_assets)
  mₜ                  = zeros(n_assets)

  for t ∈ 1:n_periods-1
    b[:, t+1] = wᵢᵗ⁺¹func(variant, η, vₜ, mₜ, b[:, t], rel_pr[:, t])
  end

  return OPSAlgorithm(n_assets, b, algname(variant))
end
