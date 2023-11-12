adj1 = [
  1.315 1.326 1.358 1.39461 1.424 1.4015 1.52531
  1.215 1.111 1.215 1.35614 1.454 1.2158 1.32561
]
adj2 = rand(3, 20);
n_assets_adj1 = size(adj1, 1)
n_assets_adj2 = size(adj2, 1)
horizon = 3

@testset "OLMAR.jl" begin
  @testset "All good" begin
    model = olmar(adj1, horizon, 3, 2)

    @test all(sum(model.b, dims=1) .≈ 1.0)

    @test size(model.b) == (n_assets_adj1, horizon)

    model = olmar(adj2, horizon, 3, 2)

    @test all(sum(model.b, dims=1) .≈ 1.0)

    @test size(model.b) == (n_assets_adj2, horizon)
  end

  @testset "Errors" begin
    @test_throws ArgumentError olmar(adj1, horizon, 3, 1)
    @test_throws ArgumentError olmar(adj1, horizon, 2, 2)
    @test_throws ArgumentError olmar(adj1, 6, 3, 2)
  end
end
