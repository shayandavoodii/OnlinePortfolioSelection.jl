"""
    pred_relpr(model::SMA, prices::AbstractMatrix, w::Integer)
    pred_relpr(model::EMA, prices::AbstractMatrix)
    pred_relpr(model::PP, prices::AbstractMatrix, w::Integer)

# Method 1
Predict the price relative to the last `w` days using the Simple Moving Average (SMA). This \
is equivalent to: ``\\mathbf{\\hat{x}}_{S, t+1}\\left(w\\right)=frac{\\sum_{k=0}^{w-1}\\mathbf{p}_{t-k}}{w\\mathbf{p}_t}``.

## Arguments
- `model::SMA`: SMA object.
- `prices::AbstractMatrix`: matrix of prices.
- `w::Integer`: window size.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.239096  0.2753    0.139975  0.950548  0.825106  0.17642   0.718449
 0.906723  0.135535  0.760641  0.677338  0.591781  0.867636  0.422376
 0.273307  0.152385  0.638585  0.890082  0.11859   0.784191  0.648333

julia> pred_relpr(SMA(), prices, 3)
3-element Vector{Float64}:
 0.7980035595621227
 1.485084060218173
 0.7974884049616359
```

# Method 2
Predict the price relative to the last `w` days using the Exponential Moving Average (EMA). \
This is equivalent to: ``{{\\mathbf{\\hat x}}_{E,t + 1}}\\left( \\vartheta  \\right) = \\frac{{\\sum\\limits_{k = 0}^{t - 1} {{{\\left( {1 - \\vartheta } \\right)}^k}} \\vartheta {{\\mathbf{p}}_{t - k}} + {{\\left( {1 - \\vartheta } \\right)}^t}{{\\mathbf{p}}_0}}}{{{{\\mathbf{p}}_t}}}``.

## Arguments
- `model::EMA`: EMA object. See [`EMA`](@ref).
- `prices::AbstractMatrix`: matrix of prices.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.537567  0.993001  0.472032  0.17579   0.229753   0.869963  0.258598
 0.65217   0.275331  0.948194  0.655232  0.775169   0.319057  0.155682
 0.659132  0.544562  0.220759  0.115822  0.0839703  0.479326  0.84241

julia> pred_relpr(EMA(0.5), prices)
3-element Vector{Float64}:
 0.8220523618098609
 1.0906091418069135
 0.3469083043928794
```

# Method 3
Predict the price relative to the last `w` days using the Price Prediction (PP). This is \
equivalent to: ``{{\\mathbf{\\hat x}}_{M,t + 1}}\\left( w \\right) = \\frac{{\\mathop {\\max }\\limits_{0 \\leqslant k \\leqslant w - 1} {\\mathbf{p}}_{t - k}^{(i)}}}{{{{\\mathbf{p}}_t}}},\\quad i = 1,2, \\ldots ,d``.

## Arguments
- `model::PP`: PP object.
- `prices::AbstractMatrix`: Matrix of prices.
- `w::Integer`: window size.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.787617  0.956869  0.633786  0.941729  0.474008  0.365784  0.711252
 0.814631  0.174881  0.256391  0.321552  0.40781   0.289347  0.498401
 0.776178  0.385725  0.508909  0.1728    0.37207   0.392623  0.280829

julia> pred_relpr(PP(), prices, 3)
3-element Vector{Float64}:
 1.0
 1.0
 1.3980826646284876
"""
function pred_relpr(model::SMA, prices::AbstractMatrix, w::Integer)
  return sum(prices[:, end-w+1:end], dims=2) ./ (w*prices[:, end]) |> vec
end

function pred_relpr(model::EMA, prices::AbstractMatrix, _::Integer=0)
  n_assets, n_samples = size(prices)
  ϑ = model.v
  x̂ = zeros(eltype(prices), n_assets)
  for k ∈ 1:n_samples-1
    x̂ += (1-ϑ)^k * ϑ * prices[:, end-k+1]
  end
  x̂ += (1-ϑ)^n_samples * prices[:, 1]
  return x̂./prices[:, end]
end

function pred_relpr(model::PP, prices::AbstractMatrix, w::Integer)
  return maximum(prices[:, end-w+1:end], dims=2)./prices[:, end] |> vec
end

