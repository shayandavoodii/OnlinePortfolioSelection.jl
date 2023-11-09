
"""
    cwmr(
      rel_pr::AbstractMatrix,
      ϕ::AbstractFloat,
      ϵ::AbstractFloat,
      variant::Type{<:CWMRVariant},
      ptfdis::Type{<:PtfDisVariant}
    )

    cwmr(
      rel_pr::AbstractMatrix,
      ϕ::AbstractVector,
      ϵ::AbstractVector,
      variant::Type{<:CWMRVariant},
      ptfdis::Type{<:PtfDisVariant};
      adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing
    )

Run the Confidence Weighted Mean Reversion (CWMR) algorithm.

!!! note "Important note"
    In order to use this function, you have to install the \
    [Distributions.jl](https://github.com/JuliaStats/Distributions.jl) package first, and \
    then import it along with the OnlinePortfolioSelection.jl package:
    ```julia
    julia> using Pkg; Pkg.add("Distributions")
    julia> using Distributions, OnlinePortfolioSelection
    ```

# Methods
- `cwmr(rel_pr::AbstractMatrix, ϕ::AbstractFloat, ϵ::AbstractFloat, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant})`
- `cwmr(rel_pr::AbstractMatrix, ϕ::AbstractVector, ϵ::AbstractVector, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant}; adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing)`

# Method 1

Through this method, we can run the following variants of the CWMR algorithm: `CWMR-Var`, \
`CWMR-Stdev`, `CWMR-Var-s` and `CWMR-Stdev-s`.

## Arguments
- `rel_pr::AbstractMatrix`: Relative prices of the assets.
- `ϕ::AbstractFloat`: Learning rate.
- `ϵ::AbstractFloat`: Expert's weight.
- `variant::Type{<:CWMRVariant}`: Variant of the algorithm. It can be `CWMRD` or `CWMRS`.
- `ptfdis::Type{<:PtfDisVariant}`: Portfolio distribution. It can be `Var` or `Stdev`.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object that contains the result of running the algorithm.

## Example

Let's run all the variants of the first method, such as `CWMR-Var`, `CWMR-Stdev`, \
`CWMR-Var-s` and `CWMR-Stdev-s`:

```julia
julia> using OnlinePortfolioSelection, YFinance, Distributions

julia> tickers = ["AAPL", "MSFT", "AMZN"];

julia> startdt, enddt = "2019-01-01", "2019-01-10";

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker=tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> variant, ptf_distrib = CWMRS, Var;

julia> model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.344307  1.0         1.0         0.965464   0.0
 0.274593  2.76907e-8  0.0         0.0186898  1.0
 0.3811    2.73722e-8  2.23057e-9  0.0158464  2.21487e-7
```

# Method 2

Through this method, we can run the following variants of the CWMR algorithm: \
`CWMR-Var-Mix`, `CWMR-Stdev-Mix`, `CWMR-Var-s-Mix` and `CWMR-Stdev-s-Mix`.

## Arguments
- `rel_pr::AbstractMatrix`: Relative prices of the assets.
- `ϕ::AbstractVector`: A vector of learning rates.
- `ϵ::AbstractVector`: A vector of expert's weights.
- `variant::Type{<:CWMRVariant}`: Variant of the algorithm. It can be `CWMRD` or `CWMRS`.
- `ptfdis::Type{<:PtfDisVariant}`: Portfolio distribution. It can be `Var` or `Stdev`.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

## Keyword Arguments
- `adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing`: A vector of \
additional expert's portfolios.

!!! warning "Beware!"
    `adt_ptf` can be `nothing` or a vector of matrices of size `n_assets` × `n_periods`. As \
    noted in the paper, the additional expert's portfolios should be chosen from the set \
    of universal strategies, such as 'UP', 'EG', 'ONS', etc.

See [`eg`](@ref), and [`up`](@ref) for more details.

## Returns
- `OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object that contains the result of running the algorithm.

## Example
Let's run all the variants of the second method, such as `CWMR-Var-Mix`, `CWMR-Stdev-Mix`, \
`CWMR-Var-s-Mix` and `CWMR-Stdev-s-Mix`:

```julia
julia> variant, ptf_distrib = CWMRS, Var;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.329642  0.853456   0.863553   0.819096  0.0671245
 0.338512  0.0667117  0.0694979  0.102701  0.842985
 0.331846  0.0798325  0.0669491  0.078203  0.0898904
```

Now, let's pass two different 'EG' portfolios as additional expert's portfolios:

```julia
julia> variant, ptf_distrib = CWMRS, Var;

julia> eg1 = eg(rel_pr, eta=0.1).b;

julia> eg2 = eg(rel_pr, eta=0.2).b;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib, adt_ptf=[eg1, eg2]);

julia> model.b
3×5 Matrix{Float64}:
 0.318927  0.768507  0.721524  0.753618  0.135071
 0.338759  0.111292  0.16003   0.133229  0.741106
 0.342314  0.120201  0.118446  0.113154  0.123823
```

See [Confidence Weighted Mean Reversion (CWMR)](@ref) for more informaton and examples.

# References
> [Confidence Weighted Mean Reversion Strategy for Online Portfolio Selection](http://dx.doi.org/10.1145/2435209.2435213)
"""
function cwmr end
