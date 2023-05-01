# Fetch Data
For fetching the data, one can use the [`YFinance.jl`](https://github.com/eohne/YFinance.jl) package:

```julia
julia> using YFinance, DataFrames

julia> tickers = ["MMM", "CSCO", "IBM", "INTC", "XOM"];

julia> startdt, enddt = "2023-04-01", "2023-04-27";

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = reduce(hcat, querry);

# Let's make a DataFrame out of it for better visualization of the data
julia> df = DataFrame(prices, tickers);

julia> first(df, 3)
3×5 DataFrame
 Row │ MMM      CSCO     IBM      INTC     XOM     
     │ Float64  Float64  Float64  Float64  Float64 
─────┼─────────────────────────────────────────────
   1 │  104.57    51.92   132.06    32.89   116.13 
   2 │  102.25    51.82   131.6     33.1    115.02 
   3 │  102.29    51.82   132.14    32.83   116.99 
```

The given data in each example throughout this documentation has been collected using the above code. 
