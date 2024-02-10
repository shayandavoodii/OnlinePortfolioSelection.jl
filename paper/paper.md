# Summary

`OnlinePortfolioSelection` is a `Julia` package that implements a variety of prominent Online Portfolio Selection (OPS) algorithms to be used by researchers and developers of OPS algorithms. This package facilitates benchmarking for researchers who intend to compare their OPS algorithms with the statet-of-the-art OPS algorithms. Also, `OnlinePortfolioSelection` package provides a set of tools for researchers to evaluate the performance of their proposed algorithms according to vaious well-known performance metrics in the OPS literature. The package brings together a variety of OPS algorithms and performance metrics to a relatively new programming language, `Julia`, which is known for its high performance and ease of use. In addition to the performance merits of `Julia`, the algorithms within this package are implemented in a way that follows the pseudocode and the mathematical signature of the original papers, which makes it easier for researchers to understand and compare the algorithms. This paper presents the basic of the Application Programming Interface (API), example usage, and code snippets for the `OnlinePortfolioSelection` package.

# Introduction

The OPS algorithms update the portfolio after observing the new data, meaning that the whole algorithm takes in place by including the new data into the procedure. The main purpose of OPS algorithms is to select a portfolio vector $\mathbf{b}_t\in{\mathbb{R}^m}$ in each period $t$ that maximizes cumulative return of the portfolio over time, where $m$ is the number of stocks. The constructed portfolio in each period can be defined on the m-dimensional simplex as the weight of each asset is a positive value and sum of the weights in a portfolio should sum up to one:

$$
{{\Delta _m}}:=\left\{\mathbf{b}_t \in \mathbb{R}_ + ^m:\sum\limits_{i = 1}^m {{b_{i,t}} = 1}\right\}
$$

where $\mathbf{b}_t \in \mathbb{R}_ + ^m$ refers to the portfolio vector of the $t^{th}$ period with $m$ positive values, $b_{i,t}$ represents the proportion of wealth that should be invested in the $i^{th}$ stock in the $t^{th}$ period. The m-dimensional simplex divests shortselling capability from the algorithm and enforces it to invest the whole wealth in the portfolio selection.  
At the end of $t^{th}$ period, the cumulative wealth of the investment $S_t$ increases by a factor of $\mathbf{b}_t \times \mathbf{r}_t$, where $\mathbf{r}_t$ is the price relative vector of the stocks in the $t^{th}$ period and can be presented as ${\mathbf{r}_t} \triangleq \frac{{{\mathbf{p}_t}}}{{{\mathbf{p}_{t - 1}}}}$, where $\mathbf{p}_t=(p_{1,t}, p_{2,t}, \ldots, p_{m,t})\in\mathbb{R}^m_+$ is the vector of close prices of $m$ stocks in the $t^{th}$ period and the division "$\div$" is performed element-wise. The cumulative wealth of the investment at $t^{th}$ period can be defined as:

$$
{S_t} = {S_{t - 1}} \times \sum\limits_{i = 1}^m {{b_{i,t}}\times{r_{i,t}}}
$$

where it is usually assumed that the initial wealth is $S_0=1$, $r_{i,t}$ is the price relative of the $i^{th}$ stock in the $t^{th}$ period, and $b_{i,t}$ is the proportion of wealth to be invested in the $i^{th}$ stock in the $t^{th}$ period. The primary evaluation metric for OPS algorithms is the ultimate cumulative wealth of the investment, which is defined as:

$$
{S_n} = \prod\limits_{t = 1}^n {{\mathbf{b}_t} \times {\mathbf{r}_t}}
$$

where $n$ is the number of investment periods. The higher the ultimate cumulative wealth, the better the performance of the OPS algorithm. Thus, OPS algorithms aim to find the set of portfolio vectors ${{\mathbf{b}}^*} = \left\{ {{{\mathbf{b}}_1},{{\mathbf{b}}_2}, \ldots ,{{\mathbf{b}}_n}} \right\} \in \mathbb{R}_ + ^{m \times n}$ that maximizes the cumulative wealth of the investment:

$$
{{\hat S}_n} = \mathop {\max }\limits_{\left\{ {\mathbf{{b}_t} \in {\Delta _m}} \right\}_{t = 1}^n} \prod\limits_{t = 1}^n {{\mathbf{r}_t}{\mathbf{b}_t}}
$$

It is worth mentioning that in these algorithms it is assumed that the market is liquid and there are vendors and buyers for the stocks at any given period. Also, it is presumed that the algorithm does not affect the market condition.

# State of the field

Algorithm trading researchers were used to rely on analyse the market conditions and perform calculations by hand. Nowadays, with the advent of infrustructure, the amount of data and the speed of the data flow has increased dramatically. Therefore, market practitioners would lose good investment opportunities if they opt to manual computations. Thus, the need for algorithms that can process the data and perform computations in a short amount of time is felt. OPS algorithms are trading algorithms that are meant to process the data and make decisions in a time-efficient manner. The proposed approaches in the literature generaly involve Machine Learning (ML) concepts or directly employ ML algorithms as a part of the model in the decision-making and/or data processing procedure. Hence, developing open-sourced softwares that can provide these algorithms is justifiable as they can be used by researchers to compare their novel algorithms against the traditional algorithms and also for better grasping the idea behind the state-of-the-art algorithms. Accordingly, there are several tools in various languages that present OPS algorithms. Some of them provide a single algorithm, and some of them provide a variety of algorithms. `SSPO` provides the Matlab implementation of the 'sspo' algorithm by the authors of the related paper. `OLPS` is a Matlab toolbox that provides the implementation for a set of traditional OPS algorithms. Although the toolbox is open-sourced, its required software, Matlab, is not freely accessable. Furthermore, the aforementioned toolbox does not provide the implementation of the novel OPS algorithms. `universal-portfolios` is a Python package that only provides the traditional OPS algorithms and is poorly documented. `olpsR` presents a limited set of state-of-the-art OPS algorithms in R language .

# Statement of need

While the tools mentioned above lacking some features such as the novel OPS algorithms in the literature, being free to use, and well-documented, `OnlinePortfolioSelection` package is designed to fill these gaps by providing a vast variety of OPS algorithms including the most novel algorithms published in the literature with detailed documentation and examples, that are free to use. The package is implemented in `Julia` programming language, which is known for its high performance and readable syntax.  
The package presents methods for the following OPS algorithms:

| Row № | Algorithm | Year |   FL  |   FW  |   PM  |   Meta-Learning |   Combinatorics |   Market |
|:-----:| --------- | ---- | :---: | :---: | :---: | :-------------: | :-------------: | :------: |
| 1     | 1/N       | -    |       |       |       |                 |                 |   ×      |
| 2     | CRP       | 1991 |       |       |       |                 |                 |   ×      |
| 3     | UP        | 1991 |       |       |       |                 |                 |   ×      |
| 4     | EG        | 1998 |       |   ×   |       |                 |                 |          |
| 5     | Anticor   | 2003 |   ×   |       |       |                 |                 |          |
| 6     | Bk        | 2006 |       |       |   ×   |                 |                 |          |
| 7     | ONS       | 2006 |       |       |       |                 |                 |   ×      |
| 8     | BS        | 2007 |       |       |       |                 |                 |   ×      |
| 9     | CORN      | 2011 |       |       |   ×   |                 |                 |          |
| 10    | PAMR      | 2012 |   ×   |       |       |                 |                 |          |
| 11    | OLMAR     | 2012 |   ×   |       |       |                 |                 |          |
| 12    | CWMR      | 2013 |   ×   |       |       |                 |                 |          |
| 13    | RMR       | 2016 |   ×   |       |       |                 |                 |          |
| 14    | PPT       | 2018 |       |   ×   |       |                 |                 |          |
| 15    | AICTR     | 2018 |       |   ×   |       |                 |                 |          |
| 16    | SSPO      | 2018 |       |   ×   |       |                 |                 |          |
| 17    | LOAD      | 2019 |       |       |       |                 |   ×             |          |
| 18    | GWR       | 2019 |   ×   |       |       |                 |                 |          |
| 19    | DRICORN-K | 2020 |       |       |   ×   |                 |                 |          |
| 20    | ClusLog   | 2020 |       |       |   ×   |                 |                 |          |
| 21    | RPRT      | 2020 |   ×   |       |       |                 |                 |          |
| 22    | CAEG      | 2020 |       |       |       |   ×             |                 |          |
| 23    | CW-OGD    | 2021 |       |       |       |   ×             |                 |          |
| 24    | EGM       | 2021 |       |   ×   |       |                 |                 |          |
| 25    | TPPT      | 2021 |       |       |       |                 |   ×             |          |
| 26    | MRvol     | 2023 |       |       |       |                 |   ×             |          |
| 27    | OLDEM     | 2023 |       |       |   ×   |                 |                 |          |
| 28    | DMR       | 2023 |   ×   |       |       |                 |                 |          |

Additionally, the package provides a set of metrics that have been used in the literature for evaluating the performance of the algorithms. The metrics can easily get employed by researchers to evaluate the performance of their novel algorithms. The provided metrics are as follows:

| Row № | Metric                                    | Abbreviation                        |
|:-----:|:----------------------------------------- |:-----------------------------------:|
| 1     | [Cumulative Wealth]()                     | CW (Also known as $S_n$)            |
| 2     | [Mean Excess Return]()                    | MER                                 |
| 3     | [Information Ratio]()                     | IR                                  |
| 4     | [Annualized Percentage Yield]()           | APY                                 |
| 5     | [Annualized Standard Deviation]()         | $\sigma_p$                          |
| 6     | [Annualized Sharpe Ratio]()               | SR                                  |
| 7     | [Maximum Drawdown]()                      | MDD                                 |
| 8     | [Calmar Ratio]()                          | CR                                  |
| 9     | [Average Turnover]()                      | AT                                  |

The full set of other tools and utility functions are listed and documented in the source code as well as in the online documentation.

# Installation and basic usage

`OnlinePortfolioSelection` package can be installed using the Julia package manager by entering the following commands in the Julia REPL:

```julia
julia> using Pkg
julia> Pkg.add("OnlinePortfolioSelection")
```

After the installation, the package can be imported and used as follows:

```julia
julia> using OnlinePortfolioSelection
```

Suppose the 'CORN-U' algorithm is to be employed for the portfolio selection over the adjusted close prices of the 'MSFT', 'AAPL', 'META', and 'GOOGL' stocks from 1st January, 2024 to 6th January, 2024. The required data can be obtained from the Yahoo Finance using the `YFinance` package in Julia:

```julia
julia> using YFinance
julia> tickers = ["MSFT", "AAPL", "META", "GOOGL"]
julia> start_date = "2024-01-01"
julia> end_date = "2024-01-12"
julia> querry = [get_prices(ticker, startdt=start_date, enddt=end_date)["adjclose"] for ticker in tickers]
julia> prices = stack(querry) |> permutedims
4×6 Matrix{Float64}:
 370.87   370.6    367.94   367.75   374.69   375.79
 185.403  184.015  181.678  180.949  185.324  184.904
 346.29   344.47   347.12   351.95   358.66   357.43
 138.17   138.92   136.39   135.73   138.84   140.95
```

The matrix above contains the adjusted close prices of the stocks where the rows represent the stocks and the columns represent the days. The 'CORN-U' algorithm can be employed as follows:

```julia
julia> using OnlinePortfolioSelection
julia> horizon = 4
julia> window_size = 2
julia> model = cornu(prices, horizon, window_size)
OPSAlgorithm{Float64}(4, [0.12513423100917873 0.1252014698797476 0.12364583463206219 0.0; 0.12513423100917873 0.6243955903607573 0.12364583463206219 0.0; 0.6245973069724639 0.1252014698797476 0.6290624961038135 0.5052279142063506; 0.12513423100917873 0.1252014698797476 0.12364583463206219 0.4947720857936494], "CORN-U")
```

For the sake of coherence, all of the algorithms in the package return the same type of object, which is named `OPSAlgorithm`. The returned object has three different fields, number of assets, portfolio matrix, and the name of the algorithm. The portfolio matrix is the matrix of the portfolio vectors where the rows represent the stocks and the columns represent the investment days. The fields can be accessed as follows:

```julia
julia> model.n_assets
4

julia> model.b
4×4 Matrix{Float64}:
 0.125134  0.125201  0.123646  0.0
 0.125134  0.624396  0.123646  0.0
 0.624597  0.125201  0.629062  0.505228
 0.125134  0.125201  0.123646  0.494772

julia> model.alg
"Anticor"
```

In terms of evaluating the performance of the algorithm regarding all of the available metrics in the package, the `opsmetrics` function can be employed as follows:

```julia
julia> # In order to calculate the 'Information Ratio (IR)' of the algorithm, the market prices are required.
julia> # Since the selected stocks are from the 'S&P 500' index
julia> # the adjusted close prices of the 'S&P 500' index can be obtained from the Yahoo Finance as follows:
julia> market_prices = get_prices("^GSPC", startdt=start_date, enddt=end_date)["adjclose"]
8-element Vector{Float64}:
 4742.830078125
 4704.81005859375
 4688.68017578125
 4697.240234375
 4763.5400390625
 4756.5
 4783.4501953125
 4780.240234375

julia> relative_prices = prices[:, 2:end] ./ prices[:, 1:end-1]
julia> metrics = opsmetrics(model.b, relative_prices, market_prices)

            Cumulative Wealth: 1.0463984165558158
        Mean Excessive Return: -0.029945871482074782
            Information Ratio: -654.9268365917005
  Annualized Percentage Yield: 16.414686027992634
Annualized Standard Deviation: 0.23146105808197664
      Annualized Sharpe Ratio: 70.83129302116178
             Maximum Drawdown: 0.0017864622612592136
                 Calmar Ratio: 9188.37547479033
             Average Turnover: 0.45886426227669413
```

The `opsmetrics` function returns an object of type `OPSMetrics` that contains the calculated metrics. The fields of the object can be accessed as follows:

```julia
julia> metrics.Sn
5-element Vector{Float64}:
 1.0
 1.0201618571657012
 1.0205981337390326
 1.0482711133393647
 1.0463984165558158

 julia> # The result above is the cumulative wealth of the investment over the investment days.

julia> metrics.MER
-0.029945871482074782

julia> metrics.IR
-654.9268365917005

julia> metrics.APY
16.414686027992634

julia> metrics.Ann_Std
0.23146105808197664

julia> metrics.Ann_Sharpe
70.83129302116178

julia> metrics.MDD
0.0017864622612592136

julia> metrics.Calmar
9188.37547479033

julia> metrics.AT
0.45886426227669413
```

For any method, `?methodname` shows the documentation as in the same way in other Julia packages.

# References
