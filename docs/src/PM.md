# Pattern-matching algorithms

Pattern-matching algorithms are one of most popular algorithms in the context of online portfolio selection. The main idea behind these algorithms is to find a pattern in the past price data and use it to predict the future price. These strategies are in consensus with technical analysts perspective. Technical analysts believe that the historical patterns in the price data will repeat in the future. The following pattern-matching algorithms are implemented in this package so far:
1. Correlation-driven Nonparametric Learning
    1.1. CORN-U
    1.2. CORN-K
2. Dynamic RIsk CORrelation-driven Non-parametric

## Correlation-driven Nonparametric Learning
Correlation-driven Nonparametric Learning (CORN) is a pattern-matching algorithm proposed by [Borodin et al. (2010)](https://doi.org/10.1145/1961189.1961193). CORN utilizes the correlation as the similarity measure between time windows. Additionally, CORN defines several experts to construct portfolios. For each trading day, CORN combines the portfolios of the experts to construct the final portfolio. This is where CORN-K and CORN-U differ. CORN-K uses K best experts (based on their performance on historical data) to construct the final portfolio. On the other hand, CORN-U uses all the experts and uniformly combines their portfolios to construct the final portfolio.
See [`cornu`](@ref) and [`cornk`](@ref). 


## Dynamic RIsk CORrelation-driven Non-parametric
[Dynamic RIsk CORrelation-driven Non-parametric (DRICORN)](https://www.doi.org/10.1007/978-3-030-66151-9_12) follows the same idea as CORN-K. However, DRICORN considers the beta of portfolio as a measure of risk in the portfolio optimization. Furthermore, they consider the recent trend of market in order to take advantage of positive risks, and avoid negative risks.

See [`dricornk`](@ref).