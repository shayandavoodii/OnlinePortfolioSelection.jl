# Performance evaluation

## Introduction

This package offers a range of metrics to assess the performance of algorithms. These metrics are well-established in the literature and serve as benchmarks to compare different algorithm performances. Currently, the supported metrics are:

- Cumulative Return (CR, Also known as $S_n$)

This metric computes the portfolio's cumulative return of the algorithm throughout an investment period. The cumulative return is defined as:

```math
\begin{aligned}
{S_n} = {S_0}\prod\limits_{t = 1}^T {\left\langle {{b_t},{x_t}} \right\rangle }
\end{aligned}
```

where $S_0$ represents the initial capital, $b_t$ stands for the portfolio vector at time $t$, and $x_t$ denotes the relative price vector at time $t$. This metric can be evaluated using the [`sn`](@ref) function.

- Mean excess return (MER)

MER is utilized to gauge the average excess returns of an OPS method that surpasses the benchmark market strategy. MER is defined as:

```math
MER = {1 \over n}\sum\nolimits_{t = 1}^n {{R_t} - } {1 \over n}\sum\nolimits_{t = 1}^n {R_t^*}
```

where $R$ and ${R_t^*}$ represent the daily returns of a portfolio and the market strategy at the $t$th trading day, respectively. For a given OPS method, accounting for transaction costs, ${{R_t}}$ is calculated by ${R_t} = \left( {\mathbf{x}_t\mathbf{b}_t} \right) \times \left( {1 - {\nu  \over 2} \times \sum\nolimits_{i = 1}^d {\left| {{b_{t,i}} - {{\tilde b}_{t,i}}} \right|} } \right) - 1$. The market strategy initially allocates capital equally among all assets and remains unchanged. ${R_t^*}$ is defined as:
$R_t^* = \mathbf{x}_t \cdot \mathbf{b}^* - 1$ and ${\mathbf{b}^*} = {\left( {{1 \over d},{1 \over d}, \ldots ,{1 \over d}} \right)^ \top }$, where $d$ is the number of assets, and $n$ is the number of trading days. This metric can be calculated using the [`mer`](@ref) function. (see [[1](https://doi.org/10.1016/j.patcog.2023.109872)] for more details.)

- Annualized Return (APY)

This metric computes the annualized return of the algorithm throughout the investment period. The annualized return is defined as:

```math
\begin{aligned}
{APY} = \left( {{S_n}} \right)^{\frac{1}{y}} - 1
\end{aligned}
```

where $y$ represents the number of years in the investment period. This metric can be evaluated using the [`apy`](@ref) function.

- Annualized Standard Deviation ($\sigma_p$)

Another measurement employed to assess risk is the annual standard deviation of portfolio returns. The daily standard deviation is computed to derive the annual standard deviation, after which it is multiplied by $\sqrt{252}$ (assuming 252 days in a year). Users can adjust the number of days in a year by specifying the `dpy` keyword argument. This metric can be computed using the [`ann_std`](@ref) function.

- Annualized Sharpe Ratio (SR)

The Sharpe ratio serves as a measure of risk-adjusted return. It is defined as:

```math
\begin{aligned}
SR = {{APY - {R_f}} \over {{\sigma _p}}}
\end{aligned}
```

Here, $R_f$ denotes the risk-free rate, typically equivalent to the treasury bill rate at the investment period. This metric can be computed using the [`ann_sharpe`](@ref) function.

- Maximum Drawdown (MDD)

The maximum drawdown is the largest loss observed from a peak to a trough within a portfolio, before a subsequent peak is attained. The calculation of MDD relies on the capital break value. Capital break serves as a critical criterion for assessing the capital market and equals the maximum decline from the peak of the portfolio cumulative function. Capital break is defined as:

```math
\begin{aligned}
DD\left( T \right) = \sup \left[ {0,{{\sup }_{i \in \left( {0,t} \right)}}{S_i} - {S_t}} \right]
\end{aligned}
```

where $S_t$ denotes the portfolio cumulative function at time $t$. The maximum capital break, used to gauge risk, is defined as:

```math
\begin{aligned}
MDD\left( n \right) = {\sup _{t \in \left( {0,n} \right)}}\left[ {DD\left( t \right)} \right]
\end{aligned}
```

This metric can be calculated using the [`mdd`](@ref) function.

- Calmar Ratio (CR)

The Calmar ratio is a risk-adjusted return metric based on the maximum drawdown. It is defined as:

```math
\begin{aligned}
CR = {{APY} \over {MDD}}
\end{aligned}
```

This metric can be computed using the [`calmar`](@ref) function. Additionally, it's noteworthy that these metrics can be computed collectively rather than individually. This can be achieved using the [`OPSMetrics`](@ref) function. This function yields an object of type [`OPSMetrics`](@ref) containing all the aforementioned metrics.

## Examples

Here, we provide a simple example to demonstrate the usage of the metrics. First, I use the `OPSMetrics` function to compute the metrics all at once. Then, I show how to compute each metric individually.

# [`OPSMetrics`](@ref) function

Once can compute all the metrics using the [`OPSMetrics`](@ref) function at once. The function takes the following positional arguments:

- `weights`: A matrix of size $m \times t$ where $m$ is the number of assets and $t$ is the number of trading days. This matrix contains the portfolio weights at each trading day using the employed OPS algorithm.
- `rel_pr`: A matrix of size $m \times t$ where $m$ is the number of assets and $t$ is the number of trading days. This matrix contains the relative prices of the assets at each trading day. Note that most of the studies in the literature assume that the relative prices are calculated as $\frac{p_{t,i}}{p_{t-1,i}}$ where $p_{t,i}$ is the price of asset $i$ at time $t$. On the other hand, few studies assume that the relative prices are calculated as $\frac{c_{t,i}}{o_{t,i}}$ where $c_{t,i}$ and $o_{t,i}$ are the closing and opening prices of asset $i$ at time $t$, respectively. It is up to user to decide which relative prices to use, and pass the corresponding matrix to the function.

Furthermore, the function takes the following keyword arguments:

- `init_inv=1.`: The initial investment, which is set to `1.0` by default.
- `RF=0.02`: The risk-free rate, which is set to `0.02` by default.
- `dpy=252`: The number of days in a year, which is set to `252` days by default.
- `v=0.`: The transaction cost rate, which is set to `0.0` by default.

The function returns an object of type [`OPSMetrics`](@ref) containing all the metrics as fields. Now, let's choose few algorithms and assess their performance using the aforementioned function.

```julia
using OnlinePortfolioSelection, YFinance, Plots

# Fetch data
tickers = ["AAPL", "MSFT", "AMZN", "META", "GOOG"]

startdt, enddt = "2023-04-01", "2023-08-27";

querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

prices = stack(querry) |> permutedims;

rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

nassets, ndays = size(rel_pr);

# Run algorithms for 30 days
horizon = 30;

# Run models on the given data
loadm = load(prices, 0.5, 8, horizon, 0.1)[1];
uniformm = uniform(nassets, horizon);
cornkm = cornk(prices, horizon, 5, 5, 10, progress=true);
┣████████████████████████████████████████┫ 100.0% |30/30 

models = (loadm, uniformm, cornkm);

all_metrics = OPSMetrics.([loadm.b, uniformm.b, cornkm.b], Ref(rel_pr));

# Draw a bar plot to depict the values of each metric for each algorithm
bar(

)
```

```@raw html
<img src="assets/cumulative_budgets.png" width="100%">
```