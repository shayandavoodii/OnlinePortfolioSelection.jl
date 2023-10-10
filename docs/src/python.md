# Use `OnlinePortfolioSelection.jl` in Python

Generally, Julia packages can be used in a Python environtment easily using packages than can wrap Julia packages into Python packages. For example, [PyJulia](https://pyjulia.readthedocs.io/en/latest/index.html) is one of the most popular wrapper packages in this area. There is a comprehensive installation guide in the [PyJulia documentation](https://pyjulia.readthedocs.io/en/latest/installation.html). Please follow the instructions there to install PyJulia and Julia. Importing Julia packages into Python is discussed before (i.e., see [[1](https://stackoverflow.com/q/73070845/11747148), [2](https://blog.esciencecenter.nl/how-to-call-julia-code-from-python-8589a56a98f2)]). In this section, I'll show how to use `OnlinePortfolioSelection.jl` in Python. If you had issues with importing the package, please check [this](https://stackoverflow.com/questions/77264168/importerror-pkg-name-not-found-in-importing-a-julia-package-in-python-using-p) discussion.

1. Install PyJulia: `pip install julia`. Make sure the Julia path is registered in the system environment variable `PATH` (i.e., `julia` can be called in the command line). The Julia path is usually `\.julia\juliaup\julia-<VERSION>\bin` or `C:\Users\your-user-name\AppData\Local\Programs\Julia\Julia-<VERSION>\bin`.
2. Run Python
3. Enter the following commands in Python (Here, I run the [MRvol](@ref) algorithm as an example):

```python
>>> from julia import Pkg
>>> Pkg.add("OnlinePortfolioSelection")
>>> from julia import OnlinePortfolioSelection as OPS

# Generate a random relatvive price matrix. The rows are the assets, and the columns represent the time.
>>> import numpy as np
>>> rel_pr = np.random.rand(3, 100)
>>> rel_vol = np.random.rand(3, 100)
>>> horizon, Wmin, Wmax, lambdaa, eta = (10, 4, 10, 0.05, 0.01)
>>> model = OPS.mrvol(rel_pr, rel_vol, horizon, Wmin, Wmax, lambdaa, eta)
>>> type(model)
<class 'PyCall.jlwrap'>
>>> model.b
array([[0.33333333, 0.36104291, 0.3814967 , 0.26303273, 0.16525094,
        0.23471654, 0.28741473, 0.34746891, 0.41769629, 0.34582386],
      [0.33333333, 0.35745995, 0.24895616, 0.30306051, 0.36527706,
        0.2817696 , 0.36959982, 0.43371551, 0.48357232, 0.51374896],
      [0.33333333, 0.28149714, 0.36954713, 0.43390676, 0.469472  ,
        0.48351386, 0.34298546, 0.21881558, 0.09873139, 0.14042718]])
>>> type(model.b)
<class 'numpy.ndarray'>
>>> model.b.sum(axis=0)
array([1., 1., 1., 1., 1., 1., 1., 1., 1., 1.])
>>> model.alg
'MRvol'
>>> model.n_assets
3
```

As shown above, the `mrvol` function returns a `PyCall.jlwrap` object. The portfolio weights can be accessed by `model.b` which are automatically converted to a `numpy.ndarray` object. The other attributes of the `model` object can be accessed in the same way. In order to check the attributes of the `model` object, you can check the returned object by the [mrvol](@ref) function. Let's continue and calculate the performance of the algorithm according to some of the prominent metrics:

```python
>>> metrics = OPS.OPSMetrics(model.b, rel_pr)
>>> metrics

<PyCall.jlwrap             Cumulative Return: 0.0003879435247256176
                          APY: -1.0
Annualized Standard Deviation: 2.7595804965778328
      Annualized Sharpe Ratio: -0.36962139762362656
             Maximum Drawdown: 0.9996120564752744
                 Calmar Ratio: -1.0003880940833123

>>> metrics.Sn
array([1.00000000e+00, 5.75525607e-01, 1.45701657e-01, 7.12853019e-02,
       4.30702987e-02, 2.03865521e-02, 1.53802433e-02, 7.10270166e-03,
       1.97878448e-03, 8.65966074e-04, 3.87943525e-04])
```

As shown above, the `OPSMetrics` function returns a `PyCall.jlwrap` object. The cumulative wealth of portfolios can be accessed by `metrics.Sn` which are automatically converted to a `numpy.ndarray` object. The other attributes of the `metrics` object can be accessed in the same way. In order to check the attributes of the `metrics` object, you can check the returned object by the [`OPSMetrics`](@ref) function. It's worth mentioning that you can get the documentation of each function through Python. For example, you can get the documentation of the [`mrvol`](@ref) function using the following commands:

```python
>>> from julia import Main as jl
>>> jl.Docs.doc(OPS.mrvol)
<PyCall.jlwrap mrvol(       rel*pr::AbstractMatrix{T},       rel*vol::AbstractMatrix{T},       horizon::S,       Wₘᵢₙ::S,       Wₘₐₓ::S,       λ::T,       η::T     ) where {T<:AbstractFloat, S<:Integer}

Run MRvol algorithm.

# Arguments

  * `rel_pr::AbstractMatrix{T}`: Relative price matrix where it represents proportion of the closing price to the opening price of each asset in each day.
  * `rel_vol::AbstractMatrix{T}`: Relative volume matrix where 𝘷ᵢⱼ represents the tᵗʰ trading volume of asset 𝑖 divided by the (t - 1)ᵗʰ trading volume of asset 𝑖.
  * `horizon::S`: Investment horizon. The last `horizon` days of the data will be used to run the algorithm.
  * `Wₘᵢₙ::S`: Minimum window size.
  * `Wₘₐₓ::S`: Maximum window size.
  * `λ::T`: Trade-off parameter in the loss function.
  * `η::T`: Learning rate.

# Returns

  * `OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2019-01-01", "2020-01-01";

julia> querry_open_price = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker in tickers];

julia> open_pr = reduce(hcat, querry_open_price) |> permutedims;

julia> querry_close_pr = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> close_pr = reduce(hcat, querry_close_pr) |> permutedims;

julia> querry_vol = [get_prices(ticker, startdt=startdt, enddt=enddt)["vol"] for ticker in tickers];

julia> vol = reduce(hcat, querry_vol) |> permutedims;

julia> rel_pr = (close_pr ./ open_pr)[:, 2:end];

julia> rel_vol = vol[:, 2:end] ./ vol[:, 1:end-1];

julia> size(rel_pr) == size(rel_vol)
true

julia> horizon = 100; Wₘᵢₙ = 4; Wₘₐₓ = 10; λ = 0.05; η = 0.01;

julia> r = mrvol(rel_pr, rel_vol, horizon, Wₘᵢₙ, Wₘₐₓ, λ, η);

julia> r.b
3×100 Matrix{Float64}:
 0.333333  0.0204062  0.0444759  …  0.38213   0.467793
 0.333333  0.359864   0.194139      0.213264  0.281519
 0.333333  0.61973    0.761385      0.404606  0.250689
```

# References

  * [1] [Online portfolio selection of integrating expert strategies based on mean reversion and trading volume](https://doi.org/10.1016/j.eswa.2023.121472)
```
