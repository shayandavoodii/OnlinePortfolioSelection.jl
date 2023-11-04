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
