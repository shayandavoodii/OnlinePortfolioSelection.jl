# Follow the Loser (FL)

The "Follow the Loser" (FL) strategy, introduced by Borodin and [Vincent (2004)](https://proceedings.neurips.cc/paper/2003/hash/8c9f32e03aeb2e3000825c8c875c4edd-Abstract.html), involves reallocating investment weight from a stock with a superior past performance to a stock with unfavorable performance. This approach is grounded in the belief that a stock exhibiting undesirable past performance may offer a favorable return in the future. Presently, this package includes the following FL strategies:

1. Reweighted Price Relative Tracking System for Automatic Portfolio Optimization
2. Anti-Correlation (Anticor)
3. Online Moving Average Reversion (OLMAR)
4. Passive Aggressive Mean Reversion (PAMR)

## Reweighted Price Relative Tracking System for Automatic Portfolio Optimization (RPRT)

RPRT, a "Follow the Loser" (FL) strategy introduced by [Lai et al. (2018)](https://doi.org/10.1109/TSMC.2018.2852651), automatically allocates distinct weights to price relative predictions based on each asset's performance during the price prediction phase. These weights are continually adjusted. In the portfolio optimization phase, the authors introduced a novel tracking system with a flexible increasing factor to maximize future wealth in the next period. Their study resulted in the design of an efficient algorithm to address portfolio optimization objectives, suitable for large-scale and time-limited scenarios. Through extensive experiments involving six benchmark datasets from real financial markets, encompassing varied assets and time spans, RPRT demonstrated superior performance compared to other state-of-the-art systems. It showcased better cumulative wealth, mean excess return, annual percentage yield, and typical risk metrics. Additionally, RPRT exhibited resilience to substantial transaction costs and delivered swift performance, highlighting its effectiveness and efficiency as an online portfolio selection system.

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
julia> results = OPSMetrics(m_rprt.b, rel_price)

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

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## Anti-Correlation (Anticor)

Anticor is an FL strategy introduced by [Borodin and El-Yaniv (2004)](https://www.doi.org/10.1613/jair.1336). The strategy aims to capitalize on the mean-reversion attribute of asset prices. It transfers wealth from asset $i$ to asset $j$ within two consecutive market windows of size $w$ if the growth rate of asset $i$ exceeds that of asset $j$ in the most recent window. It is also contingent on a positive correlation between asset $i$ in the second last window and asset $j$ in the last window. The extent of wealth transferred from asset $i$ to $j$ depends on the correlation strength between the assets and the degree of "self-anti-correlations" for each asset $i$. [[1](https://rdrr.io/github/ngloe/olpsR/man/alg_Anticor.html)]

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
julia> results = OPSMetrics(m_anticor.b, rel_price)

            Cumulative Return: 0.8969343557511426
                          APY: -0.8391655504688253
Annualized Standard Deviation: 0.1618626725690273
      Annualized Sharpe Ratio: -5.307990636954478
             Maximum Drawdown: 0.11070937679745295
                 Calmar Ratio: -7.579895892685864

julia> results.MDD
0.11070937679745295
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## Online Moving Average Reversion (OLMAR)

The OLMAR algorithm, short for On-Line Moving Average Reversion, introduces a novel approach to online portfolio selection. It incorporates multi-period mean reversion by utilizing “Moving Average Reversion” (MAR), which predicts next price relatives through moving averages. As far as the available literature indicates, OLMAR is the initial algorithm to employ moving averages within the framework of online portfolio selection [[1](https://www.sciencedirect.com/science/article/pii/S0004370215000168)]. While relatively straightforward, OLMAR includes a reasonable updating strategy and has been empirically validated through extensive real-market experiments.

See [`olmar`](@ref).

### Run OLMAR

Let's run the algorithm on the real market data. In this case, the data is collected as noted in the [Fetch Data](@ref) section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

julia> window_size = 3;
julia> eps = 2;

# Let's run the algorithm for the last 15 days of the data.
julia> m_olmar = olmar(prices[:, end-14:end], eps, window_size);

# Get the weights of the assets for each day
juila> m_olmar.b
5×15 Matrix{Float64}:
 0.2  0.2  0.0  0.0  0.0  0.0  …  0.0  0.0  0.0  0.0
 0.2  0.2  0.0  0.0  1.0  0.0     1.0  0.0  0.0  0.147231   
 0.2  0.2  0.0  0.0  0.0  1.0     0.0  0.0  0.0  0.0        
 0.2  0.2  1.0  1.0  0.0  0.0     0.0  1.0  1.0  0.0        
 0.2  0.2  0.0  0.0  0.0  0.0     0.0  0.0  0.0  0.852769
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_olmar.b, rel_price)
16-element Vector{Float64}:
 1.0
 1.0026929997309684
 0.9931968903246916
 0.9844182209638911
 0.979271976499212
 ⋮
 0.9390854420408513
 0.9192499651820158
 0.89507547776031
 0.886526969495664
```

The outcome highlights a potential loss of approximately 11.3% in our wealth had an investment been made during the specified period. It's essential to note that [`sn`](@ref) automatically considers the last 15 relative prices in this particular case.
Next, let's proceed to evaluate the algorithm's performance based on several key metrics.

```julia
julia> results = OPSMetrics(m_olmar.b, rel_price)
        
            Cumulative Return: 0.886526969495664
                          APY: -0.8678020275925177
Annualized Standard Deviation: 0.20186187705069908
      Annualized Sharpe Ratio: -4.398066839384139
             Maximum Drawdown: 0.11585403534927716
                 Calmar Ratio: -7.490477349159786

julia> results.MDD
0.11585403534927716
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## Passive Aggressive Mean Reversion (PAMR)

The Passive Aggressive Mean Reversion (PAMR) algorithm ([Li et al., 2012](https://www.doi.org/10.1007/s10994-012-5281-z)) is a machine learning model employed in the domain of quantitative finance, specifically designed for trading strategies in mean-reverting markets. PAMR employs a passive-aggressive learning approach to adjust portfolio weights in response to deviations from the mean, aiming to capitalize on mean reversion phenomena prevalent in financial markets. The algorithm's core component, the step size $\tau_t$, is determined by the ratio of the observed error $\ell_{\in}^t$ to the squared norm of the discrepancy between the current feature vector $\mathbf{x}_t$ and the mean feature vector $\bar{x}_t$ up to time $t$. The formula for the step size in PAMR is expressed as:

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
julia> results = OPSMetrics(result.b, rel_pr)

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

julia> results = OPSMetrics(result.b, rel_pr)

            Cumulative Return: 1.4875128237671749
                          MER: -0.41530107834650865
                          APY: 0.48986807082085115
Annualized Standard Deviation: 0.2365856617445457
      Annualized Sharpe Ratio: 1.9860378154623461
             Maximum Drawdown: 0.1399713874022588
                 Calmar Ratio: 3.4997729172537
```

In this case, the algorithm has a better performance in terms of the cumulative return, annualized sharpe ratio, and calmar ratio. However, the maximum drawdown is slightly higher than the PAMR algorithm. The same procedure can be applied to the PAMR-2 algorithm (see [`PAMR2`](@ref)).

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.