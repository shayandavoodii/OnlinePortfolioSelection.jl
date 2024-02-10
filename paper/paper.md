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

| Algorithm | Year |   FL  |   FW  |   PM  |   Meta-Learning |   Combinatorics |   Market |
| --------- | ---- | :---: | :---: | :---: | :-------------: | :-------------: | :------: |
| 1/N       | -    |       |       |       |                 |                 |   ×      |
| CRP       | 1991 |       |       |       |                 |                 |   ×      |
| UP        | 1991 |       |       |       |                 |                 |   ×      |
| EG        | 1998 |       |   ×   |       |                 |                 |          |
| Anticor   | 2003 |   ×   |       |       |                 |                 |          |
| Bk        | 2006 |       |       |   ×   |                 |                 |          |
| ONS       | 2006 |       |       |       |                 |                 |   ×      |
| BS        | 2007 |       |       |       |                 |                 |   ×      |
| CORN      | 2011 |       |       |   ×   |                 |                 |          |
| PAMR      | 2012 |   ×   |       |       |                 |                 |          |
| OLMAR     | 2012 |   ×   |       |       |                 |                 |          |
| CWMR      | 2013 |   ×   |       |       |                 |                 |          |
| RMR       | 2016 |   ×   |       |       |                 |                 |          |
| PPT       | 2018 |       |   ×   |       |                 |                 |          |
| AICTR     | 2018 |       |   ×   |       |                 |                 |          |
| SSPO      | 2018 |       |   ×   |       |                 |                 |          |
| LOAD      | 2019 |       |       |       |                 |   ×             |          |
| GWR       | 2019 |   ×   |       |       |                 |                 |          |
| DRICORN-K | 2020 |       |       |   ×   |                 |                 |          |
| ClusLog   | 2020 |       |       |   ×   |                 |                 |          |
| RPRT      | 2020 |   ×   |       |       |                 |                 |          |
| CAEG      | 2020 |       |       |       |   ×             |                 |          |
| CW-OGD    | 2021 |       |       |       |   ×             |                 |          |
| EGM       | 2021 |       |   ×   |       |                 |                 |          |
| TPPT      | 2021 |       |       |       |                 |   ×             |          |
| MRvol     | 2023 |       |       |       |                 |   ×             |          |
| OLDEM     | 2023 |       |       |   ×   |                 |                 |          |
| DMR       | 2023 |   ×   |       |       |                 |                 |          |

Additionally, the package provides a set of methods for evaluating the performance of the algorithms according to the following metrics:

