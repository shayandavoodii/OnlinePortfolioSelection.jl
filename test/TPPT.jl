prices = [
  73.1526   72.4415   73.0187   72.6753   73.8444   75.4129   75.5834
  154.78    152.852   153.247   151.85    154.269   156.196   155.473
   68.3685   68.033    69.7105   69.667    70.216    70.9915   71.4865
]

horizon = 3
w = 3

@testset "TPPT.jl" begin
  @testset "With default arguments" begin
    model = tppt(prices, horizon, w)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == size(prices, 1)
    @test (model.b[:, 1] .== 1/size(prices, 1)) |> all
  end

  @testset "With custom arguments" begin
    ϵ = 50
    α = 0.7
    model = tppt(prices, horizon, w, ϵ, α)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == size(prices, 1)
    @test (model.b[:, 1] .== 1/size(prices, 1)) |> all
  end

  @testset "With invalid arguments" begin
    @test_throws DomainError tppt(prices, 0, w)
    @test_throws DomainError tppt(prices, horizon, 0)
    @test_throws DomainError tppt(prices, horizon, w, 0)
    @test_throws DomainError tppt(prices, horizon, w, 100, 0.)
    @test_throws DomainError tppt(prices[:, 1:horizon+w-1-1], horizon, w)
  end
end
