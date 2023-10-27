# Performance evaluation

This package provides a set metrics to evaluate the performance of the algorithms. The metrics are prominent in the literature and are used to compare the performance of different algorithms. Currently, the following metrics are supported:

1. Cumulative Return (CR, Also known as $S_n$)

This metric calculates the cumulative return of the algorithm during the investment period. The cumulative return is defined as:

```math
\begin{aligned}
{S_n} = {S_0}\prod\limits_{t = 1}^T {\left\langle {{b_t},{x_t}} \right\rangle }
\end{aligned}
```

where $S_0$ is the initial capital, $b_t$ is the portfolio vector at time $t$ and $x_t$ is the relative price vector at time $t$.   This metric can be calculated by using the [`sn`](@ref) function.

2. Mean excess return (MER)

MER is used to measure the average excess returns of an OPS method that outperforms the benchmark market strategy. MER is defined as:

```math
MER = {1 \over n}\sum\nolimits_{t = 1}^n {{R_t} - } {1 \over n}\sum\nolimits_{t = 1}^n {R_t^*}
```

where $R$ and ${R_t^*}$ are the daily returns of a portfolio and the market strategy at the 𝑡th trading day, respectively. For a given OPS method, considering the transaction costs, ${{R_t}}$ is calculated by ${R_t} = \left( {\mathbf{x}_t\mathbf{b}_t} \right) \times \left( {1 - {\nu  \over 2} \times \sum\nolimits_{i = 1}^d {\left| {{b_{t,i}} - {{\tilde b}_{t,i}}} \right|} } \right) - 1$. The market strategy allocates the capital equally to all the assets at the beginning and remains unchanged. ${R_t^*}$ is defined as:
$R_t^* = \mathbf{x}_t \cdot \mathbf{b}^* - 1$ and ${\mathbf{b}^*} = {\left( {{1 \over d},{1 \over d}, \ldots ,{1 \over d}} \right)^ \top }$, where $d$ is the number of assets, and $n$ is the number of trading days. This metric can be calculated by using the [`mer`](@ref) function. (see [[1](https://doi.org/10.1016/j.patcog.2023.109872)] for more details.)

3. Annualized Return (APY)

This metric calculates the annualized return of the algorithm during the investment period. The annualized return is defined as:

```math
\begin{aligned}
{APY} = \left( {{S_n}} \right)^{\frac{1}{y}} - 1
\end{aligned}
```

where $y$ is the number of years in the investment period. This metric can be calculated by using the [`apy`](@ref) function.

4. Annualized Standard Deviation ($\sigma_p$)

Another measurement used to examine the risk is the annual standard deviation of returns of the portfolio. The daily standard deviation is calculated to compute the annual standard deviation and then it is multiplied by $\sqrt{252}$ (it is assumed that there are 252 days of each year). However, users can change the number of days in a year by setting the `dpy` keyword argument. This metric can be calculated by using the [`ann_std`](@ref) function.

5. Annualized Sharpe Ratio (SR)

The Sharpe ratio is a measure of risk-adjusted return. It is defined as:

```math
\begin{aligned}
SR = {{APY - {R_f}} \over {{\sigma _p}}}
\end{aligned}
```

where $R_f$ is the risk-free rate which is considered to be equal to the treasury bill rate at the time of investment. This metric can be calculated by using the [`ann_sharpe`](@ref) function.

6. Maximum Drawdown (MDD)

The maximum drawdown is the maximum loss from a peak to a trough of a portfolio, before a new peak is attained. Calculation of MDDis based on the capital break value. Capital break can be considered as one of the most important criteria to evaluate the capitalmarket which is equal to the upper bound of decline from the peak of portfolio cumulative function. Capital break is defined as:

```math
\begin{aligned}
DD\left( T \right) = \sup \left[ {0,{{\sup }_{i \in \left( {0,t} \right)}}{S_i} - {S_t}} \right]
\end{aligned}
```

where $S_t$ is the portfolio cumulative function at time $t$. The maximum capital break can be used for measuring the risk thatcan be defined as:

```math
\begin{aligned}
MDD\left( n \right) = {\sup _{t \in \left( {0,n} \right)}}\left[ {DD\left( t \right)} \right]
\end{aligned}
```

This metric can be calculated by using the [`mdd`](@ref) function.

7. Calmar Ratio (CR)

The Calmar ratio is a measurement of risk-adjusted return based on maximum drawdown. It is defined as:  

```math
\begin{aligned}
CR = {{APY} \over {MDD}}
\end{aligned}
```

This metric can be calculated by using the [`calmar`](@ref) function.  
It is worth mentioning that these metrics can be calculated as a whole rather than calculating them one by one. This can be doneby using the [`OPSMetrics`](@ref) function. This function returns an object of type `OPSMetrics` which contains all the metricsmentioned above.