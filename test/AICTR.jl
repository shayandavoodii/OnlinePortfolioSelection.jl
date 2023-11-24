prices = [
  37.8933      34.1189      35.5754      35.4962      36.1729      36.7871
  96.0233      92.4908      96.7924      96.9159      97.6186      99.0145
  52.2925      50.803       53.5355      53.4195      53.814       53.733
  76.9565      75.014       78.7695      81.4755      82.829       82.971
 135.68       131.74       137.95       138.05       142.53       144.23
  20.6747      20.024       21.1793      22.3307      22.3567      22.5687
304057.0     287000.0     292500.0     295400.0     294300.0     294560.0
  33.7935      31.7517      33.786       35.5747      34.689       35.3712
  85.3347      84.1219      87.2231      87.2838      87.1191      86.9719
 111.579      109.806      111.649      110.933      113.51       112.61
]

n_assets = size(prices, 1)
horizon = 2
w = 2
ϵ = 1000
models = [SMA(), EMA(0.5)]
bt = rand(n_assets)
bt = bt ./ sum(bt)

@testset "AICTR.jl" begin
  bt = rand(n_assets)
  bt = bt ./ sum(bt)
  σ = [0.1, 0.05]
  @testset "With valid arguments" begin
    model = aictr(prices, horizon, w, ϵ, σ, models)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, horizon)
    @test model.n_assets == n_assets
    model = aictr(prices, horizon, w, ϵ, [0.1, 0.05, 0.03], [SMA(), EMA(0.2), PP()])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, horizon)
    @test model.n_assets == n_assets
  end

  @testset "With custom arguments" begin
    model = aictr(prices, horizon, w, ϵ, σ, models, bt=bt)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, horizon)
    @test model.n_assets == n_assets
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError aictr(prices, 1, w, ϵ, σ, models)
    @test_throws ArgumentError aictr(prices, horizon, 0, ϵ, σ, models)
    @test_throws ArgumentError aictr(prices, horizon, w, 0, σ, models)
    @test_throws ArgumentError aictr(prices, horizon, w, ϵ, [0., 0.05], models)
    @test_throws ArgumentError aictr(prices, horizon, w, ϵ, [0.02, 1.01], models)
    @test_throws DimensionMismatch aictr(prices, horizon, w, ϵ, [0.02], models)
    @test_throws ArgumentError aictr(prices, horizon, w, ϵ, σ, models, bt=bt[1:end-1])
    bt[1] = -0.2
    @test_throws ArgumentError aictr(prices, horizon, w, ϵ, σ, models, bt=bt)
    bt = rand(-1:0.1:1, n_assets)
    bt = bt ./ sum(bt)
    @test_throws ArgumentError aictr(prices, horizon, w, ϵ, σ, models, bt=bt)
    @test_throws DomainError aictr(prices, horizon+1, w, ϵ, σ, models)
  end

  @testset "Individual functions" begin
    L = 3;
    n_assets = 4;
    X̂ₜ₊₁ = rand(n_assets, L)
    𝝓 = zeros(L)
    @test OnlinePortfolioSelection.cₜ₊₁func(𝝓, X̂ₜ₊₁, ϵ) == zeros(n_assets)
  end
end
