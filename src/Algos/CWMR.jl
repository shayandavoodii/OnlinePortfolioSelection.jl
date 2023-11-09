
"""
    cwmr(rel_pr::AbstractMatrix, ϕ::AbstractFloat, ϵ::AbstractFloat, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant})
    cwmr(rel_pr::AbstractMatrix, ϕ::AbstractVector, ϵ::AbstractVector, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant}; adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing)

Run the Confidence Weighted Mean Reversion (CWMR) algorithm.

# Methods
- cwmr(rel_pr::AbstractMatrix, ϕ::AbstractFloat, ϵ::AbstractFloat, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant})
- cwmr(rel_pr::AbstractMatrix, ϕ::AbstractVector, ϵ::AbstractVector, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant}; adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing)

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
using OnlinePortfolioSelection, YFinance, Distributions

tickers = ["AAPL", "MSFT", "AMZN"];

startdt, enddt = "2019-01-01", "2019-01-10";

querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker=tickers];

prices = stack(querry) |> permutedims;

rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

variant, ptf_distrib = CWMRS, Var;

model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.344307  1.0         1.0         0.965464   0.0
 0.274593  2.76907e-8  0.0         0.0186898  1.0
 0.3811    2.73722e-8  2.23057e-9  0.0158464  2.21487e-7

variant, ptf_distrib = CWMRD, Var;

model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.333333  1.0  1.0  1.0          0.0
 0.333333  0.0  0.0  3.00489e-10  1.0
 0.333333  0.0  0.0  0.0          0.0

variant, ptf_distrib = CWMRS, Stdev;

model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.340764  1.0         1.0         1.0         0.00107058
 0.294578  1.086e-8    1.22033e-9  3.26914e-8  0.998929
 0.364658  1.39844e-8  0.0         6.78125e-9  6.94453e-8

variant, ptf_distrib = CWMRD, Stdev;

model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.333333  1.0  1.0  1.0          0.0
 0.333333  0.0  0.0  3.00475e-10  1.0
 0.333333  0.0  0.0  0.0          0.0
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

## Keyword Arguments
- `adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing`: A vector of \
additional expert's portfolios.

!!! warning "Beware!"
    `adt_ptf` can be `nothing` or a vector of matrices of size `n_assets` × `n_periods`. As \
    noted in the paper, the additional expert's portfolios should be chosen from the set \
    of universal strategies, such as 'UP', 'EG', 'ONS', etc.

See [`eg`](@ref), and [`up`](@ref) for more details.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object that contains the result of running the algorithm.

## Example
Let's run all the variants of the second method, such as `CWMR-Var-Mix`, `CWMR-Stdev-Mix`, \
`CWMR-Var-s-Mix` and `CWMR-Stdev-s-Mix`:

```julia
variant, ptf_distrib = CWMRS, Var;

model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.329642  0.853456   0.863553   0.819096  0.0671245
 0.338512  0.0667117  0.0694979  0.102701  0.842985
 0.331846  0.0798325  0.0669491  0.078203  0.0898904

variant, ptf_distrib = CWMRD, Var;

model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

model.b
0.333333  0.866506   0.866111   0.864635   0.0671175
0.333333  0.0667268  0.0669182  0.0676007  0.865363
0.333333  0.0667675  0.0669704  0.0677642  0.0675194

variant, ptf_distrib = CWMRS, Stdev;

model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.349565  0.832093   0.807798   0.82296    0.0730128
 0.289073  0.0859194  0.102561   0.109303   0.859462
 0.361362  0.0819874  0.0896411  0.0677375  0.0675254

variant, ptf_distrib = CWMRD, Stdev;

model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

model.b
3×5 Matrix{Float64}:
 0.333333  0.866506   0.866111   0.864635   0.0671175
 0.333333  0.0667268  0.0669182  0.0676007  0.865363
 0.333333  0.0667675  0.0669704  0.0677642  0.0675194
```

Now, let's pass two different 'EG' portfolios as additional expert's portfolios:

```julia
variant, ptf_distrib = CWMRS, Var;

eg1 = eg(rel_pr, eta=0.1).b;

eg2 = eg(rel_pr, eta=0.2).b;

model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib, adt_ptf=[eg1, eg2]);

model.b
3×5 Matrix{Float64}:
 0.318927  0.768507  0.721524  0.753618  0.135071
 0.338759  0.111292  0.16003   0.133229  0.741106
 0.342314  0.120201  0.118446  0.113154  0.123823
```

# References
> [Confidence Weighted Mean Reversion Strategy for Online Portfolio Selection](http://dx.doi.org/10.1145/2435209.2435213)
"""
function cwmr end
