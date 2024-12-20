# Follow the Loser (FL)

The "Follow the Loser" (FL) strategy, introduced by [borodin2003can](@citet), involves reallocating investment weight from a stock with a superior past performance to a stock with unfavorable performance. This approach is grounded in the belief that a stock exhibiting undesirable past performance may offer a favorable return in the future. Presently, this package includes the following FL strategies:

1. [Reweighted Price Relative Tracking System for Automatic Portfolio Optimization (RPRT)](@ref)
2. [Anti-Correlation (Anticor)](@ref)
3. [Online Moving Average Reversion (OLMAR)](@ref)
4. [Passive Aggressive Mean Reversion (PAMR)](@ref)
5. [Confidence Weighted Mean Reversion (CWMR)](@ref)
6. [Gaussian Weighting Reversion (GWR)](@ref)
7. [Distributed Mean Reversion (DMR)](@ref)
8. [Robust Median Reversion (RMR)](@ref)
9. [Short-term portfolio optimization with loss control (SPOLC)](@ref)
10. [Transaction Cost Optimization (TCO)](@ref)


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

julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> horizon, window_length, v, epsilon = 7, 3, 0.6, 40;

julia> m_rprt = rprt(rel_price, horizon, window_length, v, epsilon);

# Get the weights of the assets for each day
juila> m_rprt.b
5×7 Matrix{Float64}:
 0.2  0.0         0.0         0.0         0.0        0.0         0.0
 0.2  1.98902e-8  1.0         1.0         1.0        1.98959e-8  1.9889e-8
 0.2  0.0         0.0         0.0         0.0        0.0         0.0
 0.2  0.0         0.0         0.0         2.0457e-8  1.0         1.0
 0.2  1.0         1.99133e-8  1.98933e-8  0.0        0.0         0.0
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> sn(m_rprt.b, rel_price)
8-element Vector{Float64}:
 1.0
 1.0010783376762362
 0.9979108682071396
 0.9675830381758964
 0.9769305815452377
 0.9844087616434942
 0.9585207785955709
 0.9641629932083053
```

The outcome reveals an approximate loss of ~3.6% if an investment were made during the provided period. It's important to note that in this scenario, [`sn`](@ref) automatically considers the last 5 relative prices. Next, let's examine the algorithm's performance based on several significant metrics.  
You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

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

            Cumulative Wealth: 0.8969343557511426
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

            Cumulative Wealth: 1.0065266263361812
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

            Cumulative Wealth: 1.0099455075377595
        Mean Excessive Return: -0.008744240554973382
  Annualized Percentage Yield: 0.6467067326806284
Annualized Standard Deviation: 0.16828625245124013
      Annualized Sharpe Ratio: 3.7240518672920873
             Maximum Drawdown: 0.008831430868281412
                 Calmar Ratio: 73.22785427708125
```

As can be seen, 'BAH(OLMAR)' has a better performance in terms of the cumulative wealth, annualized sharpe ratio, and calmar ratio compared to the 'OLMAR' algorithm. However, the maximum drawdown is slightly higher than the 'OLMAR' algorithm. In this case, 'BAH(OLMAR)' algorithm performed better than the 'OLMAR' algorithm in terms of the 'Mean Excessive Return' and 'Annualized Percentage Yield' metrics.

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

            Cumulative Wealth: 1.4768989860970627
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

            Cumulative Wealth: 1.4875128237671749
                          MER: -0.41530107834650865
                          APY: 0.48986807082085115
Annualized Standard Deviation: 0.2365856617445457
      Annualized Sharpe Ratio: 1.9860378154623461
             Maximum Drawdown: 0.1399713874022588
                 Calmar Ratio: 3.4997729172537
```

In this case, the algorithm has a better performance in terms of the cumulative wealth, annualized sharpe ratio, and calmar ratio. However, the maximum drawdown is slightly higher than the PAMR algorithm. The same procedure can be applied to the PAMR-2 algorithm (see [`PAMR2`](@ref)).

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

## Distributed Mean Reversion (DMR)

[ZHONG2023](@citet) proposed a novel mean reversion strategy in which they have allowed short-sells unlike other Online Portfolio Selection (OPS) strategies proposed in the literature. For each investment period ($k$), they have constructed a network of assets that have correlations more than a threshold ($\eta$) with other assets. Furthermore they select the $n$ assets that have the highest centrality degree in the network for investment. Finally, they combine portfolios selected by $n$ defined trading machines to form the final portfolio. See [`dmr`](@ref).

Let's run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> assets = [
         "MSFT", "META", "GOOG", "AAPL", "AMZN", "TSLA", "NVDA", "PYPL", "ADBE", "NFLX", "MMM", "ABT", "ABBV", "ABMD", "ACN", "ATVI", "ADSK", "ADP", "AZN", "AMGN", "AVGO", "BA"
       ]

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2021-01-01")["adjclose"] for ticker=assets]

julia> prices = stack(querry, dims=1)

julia> x = prices[:, 2:end]./prices[:, 1:end-1]

julia> eta = 0.

julia> alpha = nothing

julia> n = 10

julia> w = 4

julia> horizon = 50

julia> model = dmr(x, horizon, eta, alpha, n, w);

julia> model.b
22×50 Matrix{Float64}:
 0.0454545  0.0910112   0.0909008    …  0.0907232    0.090959     0.0909736
 0.0454545  0.00706777  0.00706777      0.00706777   0.00706777   0.0978817
 0.0454545  0.0954079   0.095159        0.00432265   0.00432265   0.0955929
 0.0454545  0.0964977   0.0962938       0.0960025    0.0967765    0.0966751
 0.0454545  0.00476753  0.0957164       0.0956522    0.0957777    0.00476753
 0.0454545  0.00550015  0.00550015   …  0.00550015   0.00550015   0.00550015
 0.0454545  0.00426904  0.0952782       0.0949815    0.0945237    0.00426904
 0.0454545  0.00317911  0.00317911      0.00317911   0.00317911   0.00317911
 0.0454545  0.0944016   0.00350562      0.00350562   0.0938131    0.00350562
 0.0454545  0.00150397  0.00150397      0.0921901    0.0918479    0.0912083
 0.0454545  0.0956671   0.0959533    …  0.0960898    0.0962863    0.0960977
 0.0454545  0.00365637  0.0945089       0.00365637   0.00365637   0.00365637
 0.0454545  0.0909954   0.000375678     0.000375678  0.000375678  0.000375678
 0.0454545  0.00487068  0.00487068      0.0958842    0.00487068   0.0951817
 0.0454545  0.0970559   0.00595991      0.096872     0.0972911    0.0973644
 0.0454545  0.00523895  0.00523895   …  0.00523895   0.00523895   0.0963758
 0.0454545  0.00764483  0.00764483      0.00764483   0.00764483   0.00764483
 0.0454545  0.0971981   0.0971457       0.0974226    0.0975877    0.0973244
 0.0454545  0.00218155  0.0930112       0.0934464    0.00218155   0.00218155
 0.0454545  0.0914433   0.0915956       0.000654204  0.000654204  0.000654204
 0.0454545  0.0937513   0.00289981   …  0.00289981   0.0937545    0.00289981
 0.0454545  0.00669052  0.00669052      0.00669052   0.00669052   0.00669052
```

You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## Robust Median Reversion (RMR)

Robust Median Reversion (RMR) [7465840](@cite) leverages the reversion phenomenon by precisely predicting the next price relative using a robust $\ell$1-median estimator, which offers more accuracy than a basic mean estimator. This algorithm has two variants, namely 'RMR' and 'RMR-Variant' which the former one is available in this package. The distinction between these two versions lies in their method of forecasting the next price relative vector for assets. See [`rmr`](@ref). Hopefully, the latter one will be added to the package in the near future.

Let's run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers];

julia> prices = stack(querry, dims=1);

julia> horizon = 5

julia> window = 5

julia> ϵ = 5

julia> m = 7

julia> τ = 1e6

julia> model = rmr(prices, horizon, window, ϵ, m, τ);

julia> model.b
4×5 Matrix{Float64}:
 0.25  1.0         1.0       1.0         1.0
 0.25  0.0         0.0       0.0         0.0
 0.25  0.0         0.0       0.0         0.0
 0.25  1.14513e-8  9.979e-9  9.99353e-9  1.03254e-8
```

You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.


## Short-term portfolio optimization with loss control (SPOLC)

Estimating covariance matrix in rapidly-changing financial markets is barely investigated in the loiterature of the OPS algorithms. [10.5555/3455716.3455813](@citet) proposed a novel online portfolio selection strategy called Short-term portfolio optimization with loss control (SPOLC) which addresses the issue and is very strong in controlling extreme losses. They proposed an innovative rank-one covariance estimate model which effectively catches the instantaneous risk structure of the current financial circumstance, and incorporate it in a short-term portfolio optimization (SPO) that minimizes the downside risk of the portfolio. See [`spolc`](@ref).

Let's run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-01-25")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> rel_pr = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> model = spolc(rel_pr, 0.025, 5);

julia> model.b
4×15 Matrix{Float64}:
 0.25  0.197923  0.244427  0.239965  …  0.999975    8.49064e-6  2.41014e-6
 0.25  0.272289  0.251802  0.276544     1.57258e-5  0.999983    0.999992
 0.25  0.269046  0.255524  0.240024     6.50008e-6  5.94028e-6  3.69574e-6
 0.25  0.260742  0.248247  0.243466     2.99939e-6  3.04485e-6  1.56805e-6

julia> tickers = ["MSFT", "TSLA", "GOOGL", "NVDA"];

julia> querry = [get_prices(ticker, startdt="2024-01-01", enddt="2024-03-01")["adjclose"] for ticker in tickers];

julia> pr = stack(querry, dims=1);

julia> r = pr[:, 2:end]./pr[:, 1:end-1];
```

You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## Transaction Cost Optimization (TCO)

Proportional transaction costs have also been investigated in the field of OPS algorithms. Transaction Cost Optimization (TCO) [1357831](@cite) is an algorithm that probes the aformentioned issue. The TCO framework integrates the L1 norm of successive allocations' differences with the goal of maximizing anticipated log return. This formulation is addressed through convex optimization, yielding two explicit portfolio update formulas, namely, TCO1 and TCO2. Both variants is implemented in this package and can be used for research purposes. See [`tco`](@ref).

```julia
# TCO1
julia> model = tco(r, 5, 5, 0.04, 10, TCO1, [0.05, 0.05, 0.7, 0.2]);

julia> model.b
4×5 Matrix{Float64}:
 0.05  0.05  0.052937  0.0540085  0.0537137
 0.05  0.05  0.073465  0.0783877  0.0781003
 0.7   0.7   0.669571  0.657286   0.66002
 0.2   0.2   0.204027  0.210318   0.208166

# TCO2
julia> model = tco(r, 5, 5, 0.04, 10, TCO2, [0.05, 0.05, 0.7, 0.2]);

julia> model.b
4×5 Matrix{Float64}:
 0.05  0.0809567  0.0850694  0.0871646  0.0865584
 0.05  0.0809567  0.0830907  0.0890398  0.0885799
 0.7   0.730957   0.756827   0.746137   0.748113
 0.2   0.10713    0.0750128  0.0776584  0.0767483
```

You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```