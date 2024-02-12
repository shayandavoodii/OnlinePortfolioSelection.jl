"""
    Rₜ₋ₖfunc(x̃ₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}, xₜ₋ₖ::AbstractMatrix)

Calculate increasing factor for each trend portfolio of the last `w` days.

# Arguments
- `x̃ₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}`: Trend portfolio matrix of size `n_assets` × \
  `n_samples` × `L`.
- `xₜ₋ₖ::AbstractMatrix`: Matrix of price relatives of size `n_assets` × `n_samples`.

!!! note
    `n_samples` should be equal to window size.

# Returns
- `::AbstractMatrix`: Matrix of increasing factors of size `L` × `n_samples`.

# Example
```julia
julia> w = 5;
julia> n_assets = 3;
julia> L = 2;

julia> xtilde = rand(n_assets, w, L)
3×5×2 Array{Float64, 3}:
[:, :, 1] =
 0.0626616  0.102233  0.882604  0.626009  0.374298
 0.827046   0.258492  0.147517  0.149698  0.231086
 0.100223   0.976301  0.849384  0.571656  0.647513

[:, :, 2] =
 0.291535   0.676601  0.369414  0.250701  0.928354
 0.705389   0.416841  0.618538  0.262529  0.891767
 0.0398054  0.857242  0.334703  0.855026  0.784749

julia> x = rand(n_assets, w)
3×5 Matrix{Float64}:
 0.622336  0.834217   0.94768    0.282759  0.562024
 0.966708  0.0800924  0.0591124  0.924836  0.397604
 0.743712  0.775209   0.876839   0.400159  0.671006

julia> Rₜ₋ₖfunc(xtilde, x)
2×5 Matrix{Float64}:
 1.03365e-311  1.03365e-311  6.9531e-310  5.0e-324  3.23791e-318
 0.892941      1.26236       0.680131     0.65583   1.4029
```
"""
function Rₜ₋ₖfunc(x̃ₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}, xₜ₋ₖ::AbstractMatrix)
  size(xₜ₋ₖ) == (size(x̃ₜ₋ₖ, 1), size(x̃ₜ₋ₖ, 2)) || DimensionMismatch("Inner matrices of x̃ₜ₋ₖ \
  should have the same size as xₜ₋ₖ. Got $(size(x̃ₜ₋ₖ, 1)), $(size(x̃ₜ₋ₖ, 2)) and \
  $(size(xₜ₋ₖ)).") |> throw
  _, n_samples, L = size(x̃ₜ₋ₖ)
  Rₜ₋ₖ            = similar(xₜ₋ₖ, L, n_samples)
  for l ∈ L
    for t ∈ 1:n_samples
      Rₜ₋ₖ[l, t] = (x̃ₜ₋ₖ[:, t, l].*xₜ₋ₖ[:, t]) |> sum
    end
  end
  return Rₜ₋ₖ
end

"""
    x̃ₜ₊₁starfunc(Rₜ₋ₖ::AbstractMatrix, x̃ₜ₊₁::AbstractMatrix)

Find the adaptive input. This is equivalent to: ``{{\\mathbf{\\tilde x}}_{*,t + 1,}}* \\triangleq \\mathop {\\arg \\max }\\limits_{1 \\leqslant l \\leqslant L} \\mathop {\\min }\\limits_{0 \\leqslant k \\leqslant w - 1} {R_{l,t - k}}``.

# Arguments
- `Rₜ₋ₖ::AbstractMatrix`: Matrix of increasing factors of size `L` × `n_samples`.
- `x̃ₜ₊₁::AbstractMatrix`: Matrix of size `n_assets` × `L` that contains predicted price \
  relative for the next day by all trend represenations.

# Returns
- `::AbstractVector`: Adaptive input vector of size `n_assets`.

# Example
```julia
julia> L = 3;
julia> n_assets = 4;

julia> Rₜ₋ₖ = rand(L, 5)
3×5 Matrix{Float64}:
 0.204184     0.0507078  0.817117  0.164597  0.974871
 0.360578     0.611104   0.796089  0.967095  0.999698
 0.000279774  0.211965   0.896843  0.426071  0.924256

julia> x̃ₜ₊₁ = rand(n_assets, L)
4×3 Matrix{Float64}:
 0.74363   0.808025  0.693484
 0.87213   0.476383  0.64431
 0.604862  0.538741  0.927497
 0.932915  0.380412  0.0648827

julia> x̃ₜ₊₁starfunc(Rₜ₋ₖ, x̃ₜ₊₁)
3-element Vector{Float64}:
 0.8721302004004499
 0.47638314192090503
 0.6443102603468842
```
"""
function x̃ₜ₊₁starfunc(Rₜ₋ₖ::AbstractMatrix, x̃ₜ₊₁::AbstractMatrix)
  idx = minimum(Rₜ₋ₖ, dims=2) |> vec |> argmax
  return x̃ₜ₊₁[:, idx]
end

"""
    𝜙̃𝐱ₜ₊₁func(𝐱tildestarₜ₊₁::AbstractVector, x̃ₜ₊₁::AbstractMatrix)

Calculate the radial basis functions (RBFs) according to the adaptive input. This is \
equivalent to: ``{\\phi _l}\\left( {{{{\\mathbf{\\tilde x}}}_{*,t + 1}}} \\right) = \\exp \\left( {\\frac{{ - \\left\\| {{{{\\mathbf{\\tilde x}}}_{*,t + 1}} - {{{\\mathbf{\\tilde x}}}_{l,t + 1}}} \\right\\|}}{{2\\sigma _l^2}}} \\right)`` but for all `l`s.

# Arguments
- `𝐱tildestarₜ₊₁::AbstractVector`: Adaptive input vector of size `n_assets`.
- `x̃ₜ₊₁::AbstractMatrix`: Trend portfolio matrix of size `n_assets` × `L`.
- `σ::AbstractVector`: Vector of size `L` that contains the standard deviation of each trend \
  representation.

# Returns
- `::AbstractVector`: RBF vector of size `L`.

# Example
```julia
julia> L = 3;
julia> n_assets = 4;

julia> x̃ₜ₊₁ = rand(n_assets, L)
4×3 Matrix{Float64}:
 0.647745   0.739863  0.231505
 0.385852   0.927448  0.0295866
 0.0133715  0.100727  0.997905
 0.595816   0.55963   0.966507

julia> σ = rand(L)
3-element Vector{Float64}:
 0.9755652559849591
 0.35284376884288293
 0.8726181556237484

julia> 𝐱tildestarₜ₊₁ = rand(n_assets)
4-element Vector{Float64}:
 0.500268351693092
 0.8319583529990461
 0.7933692801827517
 0.7365147886447777

julia> 𝜙̃𝐱ₜ₊₁func(𝐱tildestarₜ₊₁, x̃ₜ₊₁, σ)
3-element Vector{Float64}:
 0.6162763264755031
 0.04725733131841852
 0.5536363309330233
```
"""
function 𝜙̃𝐱ₜ₊₁func(𝐱tildestarₜ₊₁::AbstractVector, x̃ₜ₊₁::AbstractMatrix, σ::AbstractVector)
  _, L = size(x̃ₜ₊₁)
  𝝓 = similar(𝐱tildestarₜ₊₁, L)
  for l ∈ 1:L
    𝝓[l] = exp((-1*norm(𝐱tildestarₜ₊₁ .- x̃ₜ₊₁[:, l])^2)/(2σ[l]^2))
  end
  return 𝝓
end

"""
    cₜ₊₁func(𝝓::AbstractVector, X̂ₜ₊₁::AbstractMatrix, ϵ::Integer)

Calculate cₜ₊₁.

# Arguments
- `𝝓::AbstractVector`: RBF vector of size `L`.
- `X̂ₜ₊₁::AbstractMatrix`: Trend portfolio matrix of size `n_assets` × `L`.
- `ϵ::Integer`: Update strength.

# Returns
- `::AbstractVector`: cₜ₊₁ vector of size `n_assets`.

# Example
```julia
julia> L = 3;
julia> n_assets = 4;
julia> ϵ = 1000;

julia> X̂ₜ₊₁ = rand(n_assets, L)
4×3 Matrix{Float64}:
 0.739091  0.212907  0.959206
 0.112392  0.230282  0.311946
 0.250967  0.858067  0.273636
 0.170039  0.953957  0.143767

julia> 𝝓 = rand(L)
3-element Vector{Float64}:
 0.41388402155934445
 0.021648162982974672
 0.8610515460044412

julia> cₜ₊₁func(𝝓, X̂ₜ₊₁, ϵ)
4-element Vector{Float64}:
  857.1254080659875
 -255.13035020505242
 -203.4129133205605
 -398.58214454037454

"""
function cₜ₊₁func(𝝓::AbstractVector, X̂ₜ₊₁::AbstractMatrix, ϵ::Integer)
  n_assets, L = size(X̂ₜ₊₁)
  𝚽 = diagm(𝝓)
  val  = (I - fill(1/n_assets, n_assets, n_assets))*X̂ₜ₊₁*𝚽*ones(L, 1)
  if all(val.==0)
    return zeros(n_assets)
  else
    return (ϵ*(I - fill(1/n_assets, n_assets, n_assets))*X̂ₜ₊₁*𝚽*ones(L, 1))/norm(val) |> vec
  end
end

"""
    x̃ₗₜ₋ₖfunc!(
      prices::AbstractMatrix,
      t::Integer,
      w::Integer,
      model::AbstractVector{<:TrendRep},
      x̂ₗₜ₋ₖ::AbstractArray{<:AbstractFloat, 3},
      x̃ₗₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}
    )

Calculate the x̃ₗₜ₋ₖ and x̂ₗₜ₋ₖ matrices.

# Arguments
- `prices::AbstractMatrix`: Matrix of prices. All of prices.
- `t::Integer`: Current time index.
- `w::Integer`: Window size.
- `model::AbstractVector{<:TrendRep}`: Vector of trend representations.
- `x̂ₗₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}`: Trend portfolio matrix of size `n_assets` × \
  `w` × `L`.
- `x̃ₗₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}`: Trend portfolio matrix of size `n_assets` × \
  `w` × `L`.

# Returns
- `::Nothing`: This function does not return anything. It modifies `x̂ₗₜ₋ₖ` and \
  `x̃ₗₜ₋ₖ` in-place.

# Example
```julia
julia> w = 5;
julia> n_assets = 3;
julia> L = 2;

julia> prices = rand(n_assets, 10)
3×10 Matrix{Float64}:
 0.679706   0.914361  0.453334  0.136809  0.40834   0.151368  0.605332  0.557676   0.868429  0.609995
 0.748747   0.72342   0.903403  0.334875  0.759889  0.293846  0.543729  0.85303    0.960326  0.0649195
 0.0453778  0.610972  0.572445  0.46272   0.293183  0.542115  0.558918  0.0173409  0.825377  0.926941

julia> x̂ₗₜ₋ₖ = zeros(n_assets, w, L)
3×5×2 Array{Float64, 3}:
[:, :, 1] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

[:, :, 2] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

julia> x̃ₗₜ₋ₖ = zeros(n_assets, w, L)
3×5×2 Array{Float64, 3}:
[:, :, 1] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

[:, :, 2] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

julia> x̃ₗₜ₋ₖfunc!(prices, 10, w, [SMAP(), EMA(0.5)], x̂ₗₜ₋ₖ, x̃ₗₜ₋ₖ)

julia> x̂ₗₜ₋ₖ
3×5×2 Array{Float64, 3}:
[:, :, 1] =
 2.7274    0.579908   0.666884  0.596743  0.91568
 2.05239   1.04307    0.653053  0.710346  8.36683
 0.915464  0.869317  21.6169    0.542039  0.61939

[:, :, 2] =
 0.926056  0.353884  0.433194  0.393977  0.523863
 0.817487  0.476069  0.391311  0.430711  3.32349
 0.439166  0.461905  7.59502   0.326575  0.399592

julia> x̃ₗₜ₋ₖ
3×5×2 Array{Float64, 3}:
[:, :, 1] =
  0.837506    0.0824757  -1.50065e-10  0.3137    -4.02304e-10
  0.162494    0.54564    -9.78478e-9   0.427303   1.0
 -8.71267e-9  0.371884    1.0          0.258996  -9.38528e-9

[:, :, 2] =
 0.53182    0.256598  -4.50539e-10  0.343556  -3.53479e-9
 0.423251   0.378783  -9.31412e-9   0.38029    1.0
 0.0449295  0.364619   1.0          0.276154  -4.91079e-9
```
"""
function x̃ₗₜ₋ₖfunc!(
  prices::AbstractMatrix,
  t::Integer,
  w::Integer,
  model::AbstractVector{<:TrendRep},
  x̂ₗₜ₋ₖ::AbstractArray{<:AbstractFloat, 3},
  x̃ₗₜ₋ₖ::AbstractArray{<:AbstractFloat, 3}
)
  L = length(model)
  for idx_pred ∈ 1:w
    for idx_model ∈ 1:L
      x̂ₗₜ₋ₖ[:, idx_pred, idx_model] .= pred_relpr(
        model[idx_model],
        prices[:, t-w+idx_pred-w+1:t-w+idx_pred],
        w
      )
      x̃ₗₜ₋ₖ[:, idx_pred, idx_model] .= normptf(x̂ₗₜ₋ₖ[:, idx_pred, idx_model])
    end
  end

end

"""
    aictr(
      prices::AbstractMatrix,
      horizon::Integer,
      w::Integer,
      ϵ::Integer,
      σ::AbstractVector,
      trend_model::AbstractVector{<:TrendRep};
      bt::AbstractVector = ones(size(prices, 1))/size(prices, 1)
    )

Run the Adaptive Input and Composite Trend Representation (AICTR) algorithm.

# Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `horizon::Integer`: Number investing days.
- `w::Integer`: Window size.
- `ϵ::Integer`: Update strength.
- `σ::AbstractVector`: Vector of size `L` that contains the standard deviation of each trend \
  representation.
- `trend_model::AbstractVector{<:TrendRep}`: Vector of trend representations. [`SMAP`](@ref), \
  [`EMA`](@ref), and [`PP`](@ref) are supported.

## Keyword Arguments
- `bt::AbstractVector`: Initial portfolio vector of size `n_assets`.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG", "AMZN", "META", "TSLA", "BRK-A", "NVDA", "JPM", "JNJ"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-12-31")["adjclose"] for ticker ∈ tickers];

julia> prices = stack(querry) |> permutedims;

julia> horizon = 5;

julia> w = 3;

julia> ϵ = 500;

julia> σ = [0.5, 0.5];

julia> models = [SMAP(), EMA(0.5)];

julia> bt = [0.3, 0.3, 0.4];

julia> model = aictr(prices, horizon, w, ϵ, σ, models)

julia> model.b
10×5 Matrix{Float64}:
 0.1  0.0         0.0         0.0         0.0
 0.1  0.0         0.0         0.0         0.0
 0.1  1.0         6.92439e-8  0.0         0.0
 0.1  0.0         0.0         0.0         0.0
 0.1  0.0         1.0         0.0         0.0
 0.1  0.0         0.0         0.0         0.0
 0.1  6.92278e-8  0.0         0.0         0.0
 0.1  0.0         0.0         6.95036e-8  1.0
 0.1  0.0         0.0         0.0         0.0
 0.1  0.0         0.0         1.0         6.95537e-8
```

# References
> [Radial Basis Functions With Adaptive Input and Composite Trend Representation for Portfolio Selection](https://www.doi.org/10.1109/TNNLS.2018.2827952)
"""
function aictr(
  prices::AbstractMatrix,
  horizon::Integer,
  w::Integer,
  ϵ::Integer,
  σ::AbstractVector,
  trend_model::AbstractVector{<:TrendRep};
  bt::AbstractVector = ones(size(prices, 1))/size(prices, 1)
)
  horizon>1          || ArgumentError("`horizon` should be greater than 1. Got $(horizon).") |> throw
  w>0                || ArgumentError("Window size should be positive. Got $(w).") |> throw
  ϵ>0                || ArgumentError("Update strength should be positive. Got $(ϵ).") |> throw
  all(1. .≥ σ .> 0.) || ArgumentError("Standard deviation vector should be positive and less \
  than or eaual to 1. Got $(σ).") |> throw
  all(1. .≥ bt .> 0.) || ArgumentError("Initial portfolio vector should not contain values \
  less than 0. and greater than 1. Got $(bt).") |> throw
  sum(bt) ≈ 1. || ArgumentError("Initial portfolio vector should sum to 1. Got sum(bt) = \
  $(sum(bt)).") |> throw
  n_assets, n_samples = size(prices)
  n_samples > (horizon-1)+(2w) || DomainError("Inadequate number of samples are provided. \
  Expected at least $((horizon-1)+(2w)+1) samples but got $(n_samples). You can also decrease \
  `horizon` and/or `w`.") |> throw
  L         = length(trend_model)
  length(σ) == L || DimensionMismatch("Length of σ should be equal to the number of trend \
  representations. Got $(length(σ)) and $(L).") |> throw
  rel_pr    = prices[:, 2:end]./prices[:, 1:end-1]
  b         = similar(prices, n_assets, horizon)
  b[:, 1]   = bt
  x̂ₗₜ₋ₖ     = similar(prices, n_assets, w, L)
  x̃ₗₜ₋ₖ     = similar(x̂ₗₜ₋ₖ)
  x̃ₜ₊₁      = similar(prices, n_assets, L, horizon+w)

  for t ∈ 1:horizon-1
    x̃ₗₜ₋ₖfunc!(prices, n_samples-horizon+t, w, trend_model, x̂ₗₜ₋ₖ, x̃ₗₜ₋ₖ)
    x̂ₜ₊₁      = pred_relpr.(trend_model, Ref(prices[:, end-horizon-w+t+1:end-horizon+t]), w)
    x̃ₜ₊₁      = normptf.(x̂ₜ₊₁) |> stack
    xₜ₋ₖ      = rel_pr[:, end-horizon+1-w+t:end-horizon+t]
    Rₜ₋ₖ      = Rₜ₋ₖfunc(x̃ₗₜ₋ₖ, xₜ₋ₖ)
    x̃ₜ₊₁star  = x̃ₜ₊₁starfunc(Rₜ₋ₖ, x̃ₜ₊₁)
    𝝓         = 𝜙̃𝐱ₜ₊₁func(x̃ₜ₊₁star, x̃ₜ₊₁, σ)
    cₜ₊₁      = cₜ₊₁func(𝝓, stack(x̂ₜ₊₁), ϵ)
    bₜ₊₁      = b[:, t] .+ cₜ₊₁
    b[:, t+1] = normptf(bₜ₊₁)
  end
  any(b.<0) && b |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, "AICTR")
end
