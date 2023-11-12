adj1 = [
  1.315 1.326 1.358 1.39461 1.424 1.4015 1.52531
  1.215 1.111 1.215 1.35614 1.454 1.2158 1.32561
]

adj2 = [
  1.315 1.326 1.358 1.39461 1.424 1.4015 1.52531 1.375 1.396 1.378 1.39161 1.454 1.4315 1.57531
  1.215 1.111 1.215 1.35614 1.454 1.2158 1.32561 1.295 1.121 1.255 1.34614 1.404 1.1158 1.30561
];

n_assets_adj1 = size(adj1, 1)
n_assets_adj2 = size(adj2, 1)
horizon = 3

@testset "OLMAR.jl" begin
  @testset "With valid arguments" begin
    @testset "OLMAR" begin
      model = olmar(adj1, horizon, 3, 2)
      @test all(sum(model.b, dims=1) .≈ 1.0)
      @test size(model.b) == (n_assets_adj1, horizon)
      @test model.n_assets == n_assets_adj1

      model = olmar(adj2, horizon, 3, 2)
      @test all(sum(model.b, dims=1) .≈ 1.0)
      @test size(model.b) == (n_assets_adj2, horizon)
      @test model.n_assets == n_assets_adj2
    end

    @testset "BAH(OLMAR)" begin
      model = olmar(adj2, horizon, [3, 5, 4], 2)
      @test all(sum(model.b, dims=1) .≈ 1.0)
      @test size(model.b) == (n_assets_adj2, horizon)
      @test model.n_assets == n_assets_adj2
    end
  end
  @testset "With invalide arguments" begin
    @test_throws ArgumentError olmar(adj1, horizon, 3, 1)
    @test_throws ArgumentError olmar(adj1, horizon, 2, 2)
    @test_throws ArgumentError olmar(adj1, 6, 3, 2)
    @test_throws ArgumentError olmar(adj2, 3, [3], 2)
    @test_throws ArgumentError olmar(adj2, 3, [3, 2], 2)
    @test_throws ArgumentError olmar(adj2, 3, [3, 13], 2)
    @test_throws ArgumentError olmar(adj2, 3, [3, 8, 3], 2)
  end
end
