"""
    function ktpt(
      prices::AbstractMatrix,
      horizon::S,
      w::S,
      q::S,
      η::S,
      ν::T,
      p̂ₜ::AbstractVector,
      b̂ₜ::Union{Nothing, AbstractVector{T}}
    ) where {S<:Integer, T<:AbstractFloat}

Run kernel-based trend pattern tracking system for portfolio optimization model.

!!! note "Important note"
    In order to use this function, you have to install the \
    [Lasso.jl](https://github.com/JuliaStats/Lasso.jl) package first, and \
    then import it along with the OnlinePortfolioSelection.jl package:
    ```julia
    julia> using Pkg; Pkg.add("Lasso")
    julia> using Lasso, OnlinePortfolioSelection
    ```

# Arguments
- `prices::AbstractMatrix`: Matrix of daily prices of assets.
- `horizon::S`: The horizon to run the algorithm for.
- `w::S`: The window size.
- `q::S`: Coefficient.
- `η::S`: Step size to optimize the portfolio.
- `ν::T`: is a mixing parameter that tunes the proportion of ℓ1 and ℓ2 regularization.
- `p̂ₜ::AbstractVector`: The vector of size `n_assets` at time `t`.
- `b̂ₜ::Union{Nothing, AbstractVector{T}}`: The vector of portfolio weights at time `t`.


!!! warning "Beware!"
    `prices` should be a matrix of size `n_assets` × `n_periods`.


# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance, Lasso

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers];

julia> prices = stack(querry, dims=1);

julia> h, w, q, eta, v, phat_t, bhat_t = 5, 5, 6, 1000, 0.5, rand(length(tickers)), nothing

julia> model = ktpt(prices, h, w, q, eta, v, phat_t, bhat_t);

julia> model.b
4×5 Matrix{Float64}:
 0.25  0.0  1.0  1.0  1.0
 0.25  0.0  0.0  0.0  0.0
 0.25  1.0  0.0  0.0  0.0
 0.25  0.0  0.0  0.0  0.0
```

# Reference
> [A kernel-based trend pattern tracking system for portfolio optimization](https://doi.org/10.1007/s10618-018-0579-5)
"""
function ktpt end
