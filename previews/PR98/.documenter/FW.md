
# Follow the Winner (FW) {#Follow-the-Winner-FW}

The Follow the Winner (FW) strategies operate on the principle that assets that have shown superior performance in the past are likely to continue excelling in the future. In this package, the following FW strategies have been implemented:
1. [Exponential Gradient (EG)](/FW#Exponential-Gradient-(EG))
  
2. [Price Peak Tracking (PPT)](/FW#Price-Peak-Tracking-(PPT))
  
3. [Adaptive Input and Composite Trend Representation (AICTR)](/FW#Adaptive-Input-and-Composite-Trend-Representation-(AICTR))
  
4. [Exponential Gradient with Momentum (EGM)](/FW#Exponential-Gradient-with-Momentum-(EGM))
  
5. [Short-term Sparse Portfolio Optimization (SSPO)](/FW#Short-term-Sparse-Portfolio-Optimization-(SSPO))
  

## Exponential Gradient (EG) {#Exponential-Gradient-EG}

Exponential Gradient (EG) is a FW strategy introduced by [Helmbold _et al._ [16]](/refs#10.1111/1467-9965.00058). The authors assert that EG can nearly attain the same wealth as the best constant rebalanced portfolio (BCRP), discerned retrospectively from the actual market outcomes. This algorithm is notably straightforward to implement.

See [`eg`](/funcs#OnlinePortfolioSelection.eg-Tuple{AbstractMatrix}).

### Run EG {#Run-EG}

Let&#39;s run the algorithm on the real market data. The data is collected as noted in the &quot;[Fetch-Data](/fetchdata#Fetch-Data)&quot; section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

# Let's run the algorithm on the last 5 days of the data.
julia> m_eg = eg(rel_price[:, end-4:end], eta=0.02);

juila> m_eg.b
5×5 Matrix{Float64}:
 0.2  0.199997  0.199998  0.200013  0.200025
 0.2  0.199926  0.199974  0.199997  0.20001
 0.2  0.20005   0.20004   0.200024  0.200076
 0.2  0.200011  0.19995   0.199862  0.1998
 0.2  0.200016  0.200039  0.200105  0.200089
```


One can calculate the cumulative wealth during the investment period by using the [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function:

```julia
julia> sn(m_eg.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822592665679
 0.985479797067587
 0.9871244111946488
 0.9773536585545797
 0.9716460557458115
```


The outcome suggests that if we had invested during the given period, we would have incurred a loss of approximately more than 2.8% of our wealth. It&#39;s important to note that [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) automatically considers the last 5 relative prices in this case. Let&#39;s proceed to investigate the algorithm&#39;s performance using key metrics.

```julia
julia> results = opsmetrics(m_eg.b, rel_price)

            Cumulative Wealth: 0.9716460557458115
        Mean Excessive Return: 0.022895930308319247
  Annualized Percentage Yield: -0.7653568719687657
Annualized Standard Deviation: 0.08718280263716766
      Annualized Sharpe Ratio: -9.008162713433503
             Maximum Drawdown: 0.028353944254188468
                 Calmar Ratio: -26.992959607575816

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.028353944254188468
```


It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat). See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Price Peak Tracking (PPT) {#Price-Peak-Tracking-PPT}

The PPT algorithm [[17](/refs#7942104)] is a novel linear learning system for online portfolio selection, based on the idea of tracking control. The algorithm uses a transform function that aggressively tracks the increasing power of different assets, and allocates more investment to the better performing ones. The PPT objective can be solved by a fast backpropagation algorithm, which is suitable for large-scale and time-limited applications, such as high-frequency trading. The algorithm has been shown to outperform other state-of-the-art systems in computational time, cumulative wealth, and risk-adjusted metrics (See [`ppt`](/funcs#OnlinePortfolioSelection.ppt)).

Let&#39;s run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2020-01-01")["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> model = ppt(prices, 10, 100, 100);

julia> model.b
4×100 Matrix{Float64}:
 0.25  1.0  0.999912    0.999861    …  0.0         0.0       
 0.25  0.0  2.92288e-5  4.63411e-5     1.00237e-8  9.72784e-9
 0.25  0.0  2.92288e-5  4.63411e-5     1.0         1.0
 0.25  0.0  2.92288e-5  4.63411e-5     0.0         0.0
```


One can calculate the cumulative wealth during the investment period by using the [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
101-element Vector{Float64}:
 1.0
 0.9888797685444782
 0.9863705003355839
 ⋮
 1.250897464327529
 1.2363240910685966
 1.2371383272398555
```


The outcome suggests that if we had invested during the given period, we would have gained ~23% of our wealth. It&#39;s important to note that [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) automatically considers the last 5 relative prices in this case. Let&#39;s proceed to investigate the algorithm&#39;s performance using key metrics.

```julia
julia> results = opsmetrics(model.b, rel_price)

            Cumulative Wealth: 1.2371383272398555
        Mean Excessive Return: -0.15974968844419762
  Annualized Percentage Yield: 0.709598073342651
Annualized Standard Deviation: 0.1837958159802144
      Annualized Sharpe Ratio: 3.751979171369636
             Maximum Drawdown: 0.04210405543971303
                 Calmar Ratio: 16.853437654211092

julia> results.MER
-0.15974968844419762
```


It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat). See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Adaptive Input and Composite Trend Representation (AICTR) {#Adaptive-Input-and-Composite-Trend-Representation-AICTR}

Adaptive Input and Composite Trend Representation (AICTR)[[18](/refs#8356708)] is an extension of the [Price Peak Tracking (PPT)](/FW#Price-Peak-Tracking-(PPT)) algorithm. This algorithm adopt multiple trend representations to capture the asset price trends, which enhances price prediction performance. for each investment period, the algorithm selects the best trend representation according to the recent investing performance of different price predictions. See [`aictr`](/funcs#OnlinePortfolioSelection.aictr-Tuple{AbstractMatrix,%20Integer,%20Integer,%20Integer,%20AbstractVector,%20AbstractVector{<:OnlinePortfolioSelection.TrendRep}}).

Let&#39;s run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG", "AMZN", "META", "TSLA", "BRK-A", "NVDA", "JPM", "JNJ"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-12-31")["adjclose"] for ticker ∈ tickers];

julia> prices = stack(querry) |> permutedims;

julia> horizon = 5;

julia> w = 3;

julia> ϵ = 500;

julia> σ = [0.5, 0.5];

julia> models = [SMA(), EMA(0.5)];

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


One can calculate the cumulative wealth during the investment period by using the [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
6-element Vector{Float64}:
 1.0
 1.004712570810936
 1.000779650243031
 1.0138065607851992
 1.0132505575298283
 0.9937871965996727
```


The outcome suggests that if we had invested during the given period, we would have incurred a loss of approximately 1% of our wealth. It&#39;s important to note that [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) automatically considers the last 5 relative prices in this case. Other metrics can be found in the [Performance evaluation](/performance_eval#Performance-evaluation) section.

## Exponential Gradient with Momentum (EGM) {#Exponential-Gradient-with-Momentum-EGM}

[Li _et al._ [19]](/refs#LI2022115889) proposed a novel online portfolio selection algorithm, named Exponential Gradient with Momentum (EGM), which is an extension of the Exponential Gradient (EG) algorithm. The EGM algorithm integrates the EG algorithm with the momentum technique, which can effectively use the historical information to improve the performance of the EG algorithm. Through the study, three variants of the EGM algorithm are proposed, namely, EGE, EGR, and EGA, which each use a different formula to update the weights of the portfolio. The EGE algorithm adopts the Exponential Moving Average (EMA) method to update the weights of the portfolio. EGR algorithm employs the RMSProp method to update the weights of the portfolio, and EGA algorithm uses a combination of EGE and EGR to update the weights of the portfolio. **It is worth mentioning that all three variants of the EGM algorithm are implemented in this package.** See [`egm`](/funcs#OnlinePortfolioSelection.egm).

Let&#39;s run the algorithm on the real market data.

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

julia> model = egm(rel_pr, variant)

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.33294   0.332704  0.332576  0.332576  0.332634  0.332711
 0.333333  0.333493  0.333564  0.333619  0.333614  0.333647  0.33363
 0.333333  0.333567  0.333732  0.333805  0.33381   0.333719  0.333659

julia> # EGR variant
julia> variant = EGR(0.)

julia> model = egm(rel_pr, variant)

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.348653  0.350187  0.350575  0.348072  0.345816  0.344006
 0.333333  0.327     0.327299  0.326573  0.327852  0.326546  0.327824
 0.333333  0.324347  0.322514  0.322853  0.324077  0.327638  0.328169

julia> # EGA variant
julia> variant = EGA(0.5, 0.)

julia> model = egm(rel_pr, variant)

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.349056  0.350429  0.350706  0.348071  0.345757  0.343929
 0.333333  0.326833  0.327223  0.326516  0.327857  0.326514  0.327842
 0.333333  0.324111  0.322348  0.322779  0.324072  0.327729  0.328229
```


One can calculate the cumulative wealth during the investment period by using the [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function. For example, this metric can be calculated for the EGE variant as follows:

```julia
julia> sn(model.b, rel_pr)
8-element Vector{Float64}:
 1.0
 0.945040143852776
 0.990085264306328
 0.9890572598499234
 1.0001585616811146
 1.0100760127054376
 1.0076262117924928
 0.9976113744470753
```


The outcome suggests that if we had invested during the given period, we would have incurred a loss of approximately 1% of our wealth. It&#39;s important to note that [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) automatically considers the last 7 relative prices in this case. Other metrics can be found in the [Performance evaluation](/performance_eval#Performance-evaluation) section.

## Short-term Sparse Portfolio Optimization (SSPO) {#Short-term-Sparse-Portfolio-Optimization-SSPO}

Short-term Sparse Portfolio Optimization (SSPO)[[20](/refs#JMLR:v19:17-558)] is a unique online portfolio selection method designed to construct sparse portfolios for short-term investments. It adapts the portfolio based on the evolving growth potential of various assets over time. The algorithm is based on the idea of the Follow the Winner (FW) framework and utilizes the inherent sparse nature of the portfolio by concurrently applying an $\ell$1-regularization term and a self-financing constraint. See [`sspo`](/funcs#OnlinePortfolioSelection.sspo).

Let&#39;s run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"]

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers]

julia> prices = stack(querry, dims=1)

julia> h = 5

julia> w = 5

julia> model = sspo(prices, h, w);

julia> model.b
4×5 Matrix{Float64}:
 0.25  9.92018e-9  1.0         1.0  1.0
 0.25  0.0         0.0         0.0  0.0
 0.25  0.0         0.0         0.0  0.0
 0.25  1.0         9.94367e-9  0.0  0.0
```


You can analyse the algorithm&#39;s performance using several metrics that have been provided in this package. Check out the [Performance evaluation](/performance_eval#Performance-evaluation) section for more details.

## References {#References}
1. D. P. Helmbold, R. E. Schapire, Y. Singer and M. K. Warmuth. _On-Line Portfolio Selection Using Multiplicative Updates_. [Mathematical Finance **8**, 325–347](https://doi.org/10.1111/1467-9965.00058) (1998).
  
2. Z.-R. Lai, D.-Q. Dai, C.-X. Ren and K.-K. Huang. _A Peak Price Tracking-Based Learning System for Portfolio Selection_. [IEEE Transactions on Neural Networks and Learning Systems **29**, 2823–2832](https://doi.org/10.1109/TNNLS.2017.2705658) (2018).
  
3. Z.-R. Lai, D.-Q. Dai, C.-X. Ren and K.-K. Huang. _Radial Basis Functions With Adaptive Input and Composite Trend Representation for Portfolio Selection_. [IEEE Transactions on Neural Networks and Learning Systems **29**, 6214–6226](https://doi.org/10.1109/TNNLS.2018.2827952) (2018).
  
4. Y. Li, X. Zheng, C. Chen, J. Wang and S. Xu. _Exponential Gradient with Momentum for Online Portfolio Selection_. [Expert Systems with Applications **187**, 115889](https://doi.org/10.1016/j.eswa.2021.115889) (2022).
  
5. Z.-R. Lai, P.-Y. Yang, L. Fang and X. Wu. [_Short-term Sparse Portfolio Optimization Based on Alternating Direction Method of Multipliers_](http://jmlr.org/papers/v19/17-558.html). Journal of Machine Learning Research **19**, 1–28 (2018).
  
