# Follow the Loser (FL)

The "Follow the Loser" (FL) strategy, introduced by [borodin2003can](@citet), involves reallocating investment weight from a stock with a superior past performance to a stock with unfavorable performance. This approach is grounded in the belief that a stock exhibiting undesirable past performance may offer a favorable return in the future. Presently, this package includes the following FL strategies:

1. [Reweighted Price Relative Tracking System for Automatic Portfolio Optimization (RPRT)](@ref)
2. [Anti-Correlation (Anticor)](@ref)
3. [Online Moving Average Reversion (OLMAR)](@ref)
4. [Passive Aggressive Mean Reversion (PAMR)](@ref)
5. [Confidence Weighted Mean Reversion (CWMR)](@ref)
6. [Gaussian Weighting Reversion (GWR)](@ref)

## Reweighted Price Relative Tracking System for Automatic Portfolio Optimization (RPRT)

RPRT, a "Follow the Loser" (FL) strategy introduced by [8411138](@citet), automatically allocates distinct weights to price relative predictions based on each asset's performance during the price prediction phase. These weights are continually adjusted. In the portfolio optimization phase, the authors introduced a novel tracking system with a flexible increasing factor to maximize future wealth in the next period. Their study resulted in the design of an efficient algorithm to address portfolio optimization objectives, suitable for large-scale and time-limited scenarios. Through extensive experiments involving six benchmark datasets from real financial markets, encompassing varied assets and time spans, RPRT demonstrated superior performance compared to other state-of-the-art systems. It showcased better cumulative wealth, mean excess return, annual percentage yield, and typical risk metrics. Additionally, RPRT exhibited resilience to substantial transaction costs and delivered swift performance, highlighting its effectiveness and efficiency as an online portfolio selection system.

See [`rprt`](@ref).

### Run RPRT

**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data. In this case, the data is collected as noted in the [Fetch Data](@ref) section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

julia> window_length, threshold, epsilon = 2, 0.6, 40;

# Let's run the algorithm for the last 5 days of the data.
julia> prices = prices[:, end-4:end];

julia> m_rprt = rprt(prices, w=window_length, theta=threshold, epsilon=epsilon);

# Get the weights of the assets for each day
juila> m_rprt.b
5×5 Matrix{Float64}:
 0.2  0.2  0.0  0.0  0.0
 0.2  0.2  0.0  0.0  0.0
 0.2  0.2  0.0  0.0  0.0
 0.2  0.2  1.0  1.0  1.0
 0.2  0.2  0.0  0.0  0.0
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_rprt.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822800308067
 0.985480892911241
 0.9646654456994471
 0.9392966194100733
 0.9448257537201438
```

The outcome reveals an approximate loss of ~6.3% if an investment were made during the provided period. It's important to note that in this scenario, [`sn`](@ref) automatically considers the last 5 relative prices. Next, let's examine the algorithm's performance based on several significant metrics.

```julia
julia> results = opsmetrics(m_rprt.b, rel_price)

            Cumulative Return: 0.945
                          APY: -0.943
Annualized Standard Deviation: 0.202
      Annualized Sharpe Ratio: -4.760
             Maximum Drawdown: 0.061
                 Calmar Ratio: -15.531

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.06070338058992675
```

It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`mer`](@ref), [`ir`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`ann_std`](@ref), [`calmar`](@ref), and [`mdd`](@ref). See [Performance evaluation](@ref) section for more information.

## Anti-Correlation (Anticor)

Anticor is an FL strategy introduced by [borodin2003can](@citet). The strategy aims to capitalize on the mean-reversion attribute of asset prices. It transfers wealth from asset $i$ to asset $j$ within two consecutive market windows of size $w$ if the growth rate of asset $i$ exceeds that of asset $j$ in the most recent window. It is also contingent on a positive correlation between asset $i$ in the second last window and asset $j$ in the last window. The extent of wealth transferred from asset $i$ to $j$ depends on the correlation strength between the assets and the degree of "self-anti-correlations" for each asset $i$. [[1](https://rdrr.io/github/ngloe/olpsR/man/alg_Anticor.html)]

See [`anticor`](@ref).

### Run Anticor

**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data. In this case, the data is collected as noted in the [Fetch Data](@ref) section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

julia> window_size = 2;

# Let's run the algorithm for the last 15 days of the data.
julia> m_anticor = anticor(prices[:, end-14:end], window_size);

# Get the weights of the assets for each day
juila> m_anticor.b
5×15 Matrix{Float64}:
 0.2  0.2  0.2  0.2  0.266667   0.0  …  0.0  0.0  0.0  0.0  0.0  0.0  0.0   
 0.2  0.2  0.2  0.2  0.0333333  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0   
 0.2  0.2  0.2  0.2  0.0        0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0   
 0.2  0.2  0.2  0.2  0.433333   1.0     1.0  1.0  1.0  1.0  1.0  1.0  1.0
 0.2  0.2  0.2  0.2  0.266667   0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_anticor.b, rel_price)
16-element Vector{Float64}:
 1.0
 1.0026929997309684
 0.9931968903246916
 0.9939468872805755
 0.9941204319128776
 ⋮
 0.9528191316023853
 0.9355287642277988
 0.9157684119500683
 0.8916854826115842
 0.8969343557511426
```

The outcome suggests that if we had invested in the given period, our wealth would have decreased by approximately 10.3%. Note that in this instance, [`sn`](@ref) automatically considers the last 15 relative prices.

Let's now assess the algorithm's performance based on several key metrics.

```julia
julia> results = opsmetrics(m_anticor.b, rel_price)

            Cumulative Return: 0.8969343557511426
                          APY: -0.8391655504688253
Annualized Standard Deviation: 0.1618626725690273
      Annualized Sharpe Ratio: -5.307990636954478
             Maximum Drawdown: 0.11070937679745295
                 Calmar Ratio: -7.579895892685864

julia> results.MDD
0.11070937679745295
```

It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`mer`](@ref), [`ir`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`ann_std`](@ref), [`calmar`](@ref), and [`mdd`](@ref). See [Performance evaluation](@ref) section for more information.

## Online Moving Average Reversion (OLMAR)

The OLMAR algorithm, short for On-Line Moving Average Reversion [li2012online](@cite), introduces a novel approach to online portfolio selection. It incorporates multi-period mean reversion by utilizing “Moving Average Reversion” (MAR), which predicts next price relatives through moving averages. As far as the available literature indicates, OLMAR is the initial algorithm to employ moving averages within the framework of online portfolio selection [LI2015104](@cite). While relatively straightforward, OLMAR includes a reasonable updating strategy and has been empirically validated through extensive real-market experiments. [li2012online](@citet) proposed two different variant of the algorithm, namely 'OLMAR' and 'BAH(OLMAR)'. The difference between these two variants is that the latter one defines several OLMAR experts with different window sizes and combines them to achieve a final portfolio. **In this package, both variants are provided (See [`olmar`](@ref)).**

### Run OLMAR

Let's run the algorithm on the real market data:

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "GOOG", "META"];

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> horizon = 5;
julia> windows = 3;
julia> epsilon = 4;

julia> m_olmar = olmar(rel_pr, horizon, windows, epsilon);

julia> m_olmar.b
5×5 Matrix{Float64}:
 0.2  1.0         0.484825  1.97835e-8  0.0
 0.2  1.95724e-8  0.515175  0.0         0.0
 0.2  0.0         0.0       1.0         1.0
 0.2  0.0         0.0       0.0         0.0
 0.2  0.0         0.0       0.0         1.9851e-8
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> sn(m_olmar.b, rel_pr)
6-element Vector{Float64}:
 1.0
 0.9979181552890171
 1.017717331692027
 1.0184883306518602
 1.0060091504010344
 1.0065266263361812
```

The outcome highlights a potential gain of ~0.7% if an investment were made during the provided period. Note that in this instance, [`sn`](@ref) automatically considers the last 5 (`horizon=5`) relative prices. Next, let's examine the algorithm's performance based on several significant metrics.

```julia
julia> results = opsmetrics(m_olmar.b, rel_pr)

            Cumulative Return: 1.0065266263361812
        Mean Excessive Return: -0.009414275874519928
  Annualized Percentage Yield: 0.38801292579932145
Annualized Standard Deviation: 0.18519745676483274
      Annualized Sharpe Ratio: 1.9871381185683952
             Maximum Drawdown: 0.012252649220672674
                 Calmar Ratio: 31.66767601121445

julia> results.MDD
0.012252649220672674
```

It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key.

### Run BAH(OLMAR)

In order to run this variant, you have to pass a `Vector` of window sizes to the method as the third positional argument. Let's run the algorithm on the real market data:

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "GOOG", "META"];

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> horizon = 5;
julia> windows = [3, 5, 7];
julia> epsilon = 4;

julia> model = olmar(rel_pr, horizon, windows, epsilon);

julia> model.b
5×5 Matrix{Float64}:
 0.2  0.2  0.333333    0.162297  1.33072e-8
 0.2  0.2  1.31177e-8  0.555158  0.0
 0.2  0.2  6.57906e-9  0.0       0.667358
 0.2  0.2  0.0         0.0       0.332642
 0.2  0.2  0.666667    0.282545  0.0
```

Finally, let's assess the algorithm's performance based on several key metrics.

```julia
julia> results = opsmetrics(model.b, rel_pr)

            Cumulative Return: 1.0099455075377595
        Mean Excessive Return: -0.008744240554973382
  Annualized Percentage Yield: 0.6467067326806284
Annualized Standard Deviation: 0.16828625245124013
      Annualized Sharpe Ratio: 3.7240518672920873
             Maximum Drawdown: 0.008831430868281412
                 Calmar Ratio: 73.22785427708125
```

As can be seen, 'BAH(OLMAR)' has a better performance in terms of the cumulative return, annualized sharpe ratio, and calmar ratio compared to the 'OLMAR' algorithm. However, the maximum drawdown is slightly higher than the 'OLMAR' algorithm. In this case, 'BAH(OLMAR)' algorithm performed better than the 'OLMAR' algorithm in terms of the 'Mean Excessive Return' and 'Annualized Percentage Yield' metrics.

Note that one can individually investigate the performance of the algorithm regarding each metric. See [Performance evaluation](@ref) section for more information.

## Passive Aggressive Mean Reversion (PAMR)

The PAMR algorithm [Li2012-ks](@cite) is a machine learning model employed in the domain of quantitative finance, specifically designed for trading strategies in mean-reverting markets. PAMR employs a passive-aggressive learning approach to adjust portfolio weights in response to deviations from the mean, aiming to capitalize on mean reversion phenomena prevalent in financial markets. The algorithm's core component, the step size $\tau_t$, is determined by the ratio of the observed error $\ell_{\in}^t$ to the squared norm of the discrepancy between the current feature vector $\mathbf{x}_t$ and the mean feature vector $\bar{x}_t$ up to time $t$. The formula for the step size in PAMR is expressed as:

```math
\tau_t = \frac{{\ell_{\in}^t}}{{\left\| {\mathbf{x}_t - \bar{x}_t \mathbf{1}} \right\|^2}}
```

PAMR-1 and PAMR-2 are variants that modify the calculation of the step size for greater adaptability. PAMR-1 restricts the step size to a maximum value $(C)$, preventing excessively large updates and is expressed as:

```math
\tau_t = \min \left\{ C, \frac{{\ell_{\in}^t}}{{\left\| {\mathbf{x}_t - \bar{x}_t \mathbf{1}} \right\|^2}} \right\}
```

On the other hand, PAMR-2 incorporates a more nuanced approach by adding a term related to a constant $(C)$ in the denominator, providing more controlled updates and minimizing extreme adjustments:

```math
\tau_t = \frac{{\ell_{\in}^t}}{{\left\| {\mathbf{x}_t - \bar{x}_t \mathbf{1}} \right\|^2 + \frac{1}{{2C}}}}
```

These variants aim to enhance the adaptability and stability of the PAMR algorithm, with PAMR-1 capping the maximum update size and PAMR-2 providing controlled updates to ensure smoother parameter adjustments in response to observed errors. **It is worth noting that all three variants of the PAMR algorithm are provided in this package.** See [`PAMR`](@ref).

### Run PAMR

Let's run the algorithm on the real market data:

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "META", "GOOG"]

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers]

julia> prices = stack(querry) |> permutedims

julia> rel_pr =  prices[:, 2:end]./prices[:, 1:end-1]

julia> model = PAMR()

julia> eps = 0.01

julia> result = PAMR(rel_pr, eps, model)

julia> result.b
5×251 Matrix{Float64}:
 0.2  0.224672  0.22704   0.230855  0.229743  …  0.0966823  0.0966057  0.0900667
 0.2  0.196884  0.197561  0.199825  0.203945     0.172787   0.171734   0.171626
 0.2  0.191777  0.190879  0.178504  0.178478     0.290126   0.289638   0.291135
 0.2  0.193456  0.193855  0.196363  0.189322     0.182514   0.181609   0.185527
 0.2  0.193211  0.190665  0.194453  0.198513     0.25789    0.260414   0.261645

julia> sum(result.b, dims=1) .|> isapprox(1.) |> all
true
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> sn(result.b, rel_pr)
252-element Vector{Float64}:
 1.0
 0.9561680212268941
 1.0019306281522522
 ⋮
 1.4741536647632398
 1.4768989860970627

julia> sn(result.b, rel_pr) |> last
1.4768989860970627
```

The result indicates that if we had invested in the given period, we would have gained ~47.7% of our wealth. Note that [`sn`](@ref) automatically takes the last 251 relative prices in this case.

Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> results = opsmetrics(result.b, rel_pr)

            Cumulative Return: 1.4768989860970627
                          MER: -0.4153297366246913
                          APY: 0.47919522668054726
Annualized Standard Deviation: 0.2379066078050204
      Annualized Sharpe Ratio: 1.9301491073206631
             Maximum Drawdown: 0.1390668593306162
                 Calmar Ratio: 3.445790240659086

julia> results.MDD
0.1390668593306162
```

Note that other variants of the algorithm can be used by changing the `model` parameter. For instance, let's use the PAMR-1 algorithm (see [`PAMR1`](@ref), and [`PAMR`](@ref)):

```julia
julia> model = PAMR1(0.01);

julia> result = PAMR(rel_pr, eps, model);

julia> results = opsmetrics(result.b, rel_pr)

            Cumulative Return: 1.4875128237671749
                          MER: -0.41530107834650865
                          APY: 0.48986807082085115
Annualized Standard Deviation: 0.2365856617445457
      Annualized Sharpe Ratio: 1.9860378154623461
             Maximum Drawdown: 0.1399713874022588
                 Calmar Ratio: 3.4997729172537
```

In this case, the algorithm has a better performance in terms of the cumulative return, annualized sharpe ratio, and calmar ratio. However, the maximum drawdown is slightly higher than the PAMR algorithm. The same procedure can be applied to the PAMR-2 algorithm (see [`PAMR2`](@ref)).

It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`mer`](@ref), [`ir`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`ann_std`](@ref), [`calmar`](@ref), and [`mdd`](@ref). See [Performance evaluation](@ref) section for more information.

## Confidence Weighted Mean Reversion (CWMR)

The CWMR algorithm [10.1145/2435209.2435213](@cite) combines the mean reversion principle, which assumes that the relative prices of assets tend to return to their historical or intrinsic mean over time, and the confidence weighted learning technique, which models the portfolio vector as a Gaussian distribution and updates it with confidence bounds. CWMR aims to exploit the power of mean reversion for online portfolio selection, and it can adapt to different market conditions and risk preferences. The paper evaluates the performance of CWMR on various real markets and shows that it outperforms the state-of-the-art techniques (see [`cwmr`](@ref)). **It is worth mentioning that all variants of this algorithm have been provided through this package.**

!!! note
    In order to use this algorithm, you have to install [`Distributions.jl`](https://github.com/JuliaStats/Distributions.jl) package. After a successful installation and importing, you can use this algorithm.

Let's run the algorithm on the real market data. The deterministic versions of the algorithm are known by by CWMR-Var and CWMR-Stdev and the stochastic ones by CWMR-Var-s and CWMR-Stdev-s. Furthermore, mixed variants are denoted by CWMR-Var-Mix and CWMR-Stdev-Mix for deterministic ones, and CWMR-Var-Mix-s and CWMR-Stdev-Mix-s for stochastic ones. Let's run all the variants of the first method, such as 'CWMR-Var', 'CWMR-Stdev', 'CWMR-Var-s' and 'CWMR-Stdev-s':

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

julia> variant, ptf_distrib = CWMRD, Var;

julia> model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.333333  1.0  1.0  1.0          0.0
 0.333333  0.0  0.0  3.00489e-10  1.0
 0.333333  0.0  0.0  0.0          0.0

julia> variant, ptf_distrib = CWMRS, Stdev;

julia> model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.340764  1.0         1.0         1.0         0.00107058
 0.294578  1.086e-8    1.22033e-9  3.26914e-8  0.998929
 0.364658  1.39844e-8  0.0         6.78125e-9  6.94453e-8

julia> variant, ptf_distrib = CWMRD, Stdev;

julia> model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.333333  1.0  1.0  1.0          0.0
 0.333333  0.0  0.0  3.00475e-10  1.0
 0.333333  0.0  0.0  0.0          0.0

julia> variant, ptf_distrib = CWMRS, Var;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.329642  0.853456   0.863553   0.819096  0.0671245
 0.338512  0.0667117  0.0694979  0.102701  0.842985
 0.331846  0.0798325  0.0669491  0.078203  0.0898904

julia> variant, ptf_distrib = CWMRD, Var;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
0.333333  0.866506   0.866111   0.864635   0.0671175
0.333333  0.0667268  0.0669182  0.0676007  0.865363
0.333333  0.0667675  0.0669704  0.0677642  0.0675194

julia> variant, ptf_distrib = CWMRS, Stdev;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.349565  0.832093   0.807798   0.82296    0.0730128
 0.289073  0.0859194  0.102561   0.109303   0.859462
 0.361362  0.0819874  0.0896411  0.0677375  0.0675254

julia> variant, ptf_distrib = CWMRD, Stdev;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.333333  0.866506   0.866111   0.864635   0.0671175
 0.333333  0.0667268  0.0669182  0.0676007  0.865363
 0.333333  0.0667675  0.0669704  0.0677642  0.0675194

# Now, let's pass two different 'EG' portfolios as additional expert's portfolios:

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

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> sn(model.b, rel_pr)
6-element Vector{Float64}:
 1.0
 0.9494421425374454
 0.9899730968369733
 0.9912079696970942
 1.010103241988922 
 1.0244230620335244
```

The result indicates that if we had invested in the given period, we would have gained ~2.4% of our wealth. Note that [`sn`](@ref) automatically takes the last 6 relative prices in this case. Check out the [Performance evaluation](@ref) section for more information.

## Gaussian Weighting Reversion (GWR)

[8834832](@citet) presented a new online portfolio selection strategy called Gaussian Weighting Reversion (GWR), which improves the reversion estimator to form optimal portfolios and overcomes the shortcomings of existing on-line portfolio selection strategies. The proposed algorithm contains two variants, namely 'GWR' and 'GWR-A' which both are available in this package. See [`gwr`](@ref).

Let's run the algorithm on the real market data.

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

julia> # GWR Variant
julia> model = gwr(prices, h);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  0.333333  1.4095e-11
 0.333333  0.333333  0.0
 0.333333  0.333333  1.0

julia> # GWR-A Variant
julia> model = gwr(prices, h, [2, 3, 4]);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  0.0  1.20769e-11
 0.333333  0.0  0.0
 0.333333  1.0  1.0
```

You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```