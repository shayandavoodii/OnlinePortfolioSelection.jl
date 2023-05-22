# Performance evaluation

This package provides a set metrics to evaluate the performance of the algorithms. The metrics are prominent in the literature and are used to compare the performance of different algorithms. Currently, the following metrics are supported:

1. Cumulative Return (CR, Also known as $S_n$)

    This metric calculates the cumulative return of the algorithm during the investment period. The cumulative return is defined as:  

    ```math
    \begin{aligned}
    {S_n} = {S_0}\prod\limits_{t = 1}^T {\left\langle {{b_t},{x_t}} \right\rangle }
    \end{aligned}
    ```

    where $S_0$ is the initial capital, $b_t$ is the portfolio vector at time $t$ and $x_t$ is the relative price vector at time $t$. This metric can be calculated by using the [`sn`](@ref) function.

2. Annualized Return (APY)

    This metric calculates the annualized return of the algorithm during the investment period. The annualized return is defined as:

    ```math
    \begin{aligned}
    {APY} = \left( {{S_n}} \right)^{\frac{1}{y}} - 1
    \end{aligned}
    $
    ```

    where $y$ is the number of years in the investment period. This metric can be calculated by using the [`apy`](@ref) function.

3. Annualized Standard Deviation ($\sigma_p$)

    Another measurement used to examine the risk is the annual standard deviation of returns of the portfolio. The daily standard deviation is calculated to compute the annual standard deviation and then it is multiplied by $\sqrt{252}$ (it is assumed that there are 252 days of each year). However, users can change the number of days in a year by setting the `dpy` keyword argument. This metric can be calculated by using the [`ann_std`](@ref) function.

4. Annualized Sharpe Ratio (SR)

    The Sharpe ratio is a measure of risk-adjusted return. It is defined as:

    ```math
    \begin{aligned}
    SR = {{APY - {R_f}} \over {{\sigma _p}}}
    \end{aligned}
    ```

    where $R_f$ is the risk-free rate which is considered to be equal to the treasury bill rate at the time of investment. This metric can be calculated by using the [`ann_sharpe`](@ref) function.

5. Maximum Drawdown (MDD)

    The maximum drawdown is the maximum loss from a peak to a trough of a portfolio, before a new peak is attained. Calculation of MDD is based on the capital break value. Capital break can be considered as one of the most important criteria to evaluate the capital market which is equal to the upper bound of decline from the peak of portfolio cumulative function. Capital break is defined as:

    ```math
    \begin{aligned}
    DD\left( T \right) = \sup \left[ {0,{{\sup }_{i \in \left( {0,t} \right)}}{S_i} - {S_t}} \right]
    \end{aligned}
    ```

    where $S_t$ is the portfolio cumulative function at time $t$. The maximum capital break can be used for measuring the risk that can be defined as:

    ```math
    \begin{aligned}
    MDD\left( n \right) = {\sup _{t \in \left( {0,n} \right)}}\left[ {DD\left( t \right)} \right]
    \end{aligned}
    ```

    This metric can be calculated by using the [`mdd`](@ref) function.

6. Calmar Ratio (CR)

    The Calmar ratio is a measurement of risk-adjusted return based on maximum drawdown. It is defined as:  

    ```math
    \begin{aligned}
    CR = {{APY} \over {MDD}}
    \end{aligned}
    ```

    This metric can be calculated by using the [`calmar`](@ref) function.  

    It is worth mentioning that these metrics can be calculated as a whole rather than calculating them one by one. This can be done by using the [`OPSMetrics`](@ref) function. This function returns an object of type `OPSMetrics` which contains all the metrics mentioned above.