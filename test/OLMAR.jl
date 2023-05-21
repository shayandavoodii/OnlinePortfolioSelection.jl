adj1 = [
  1.315 1.326 1.358 1.39461 1.424 1.4015 1.52531
  1.215 1.111 1.215 1.35614 1.454 1.2158 1.32561
]
adj2 = rand(3, 20);

@testset "OLMAR.jl" begin
  @testset "All good" begin
    model = olmar(adj1, 2, 3)

    @test all(sum(model.b, dims=1) .≈ 1.0)

    @test size(model.b) == size(adj1)

    model = olmar(adj2, 2, 3)

    @test all(sum(model.b, dims=1) .≈ 1.0)

    @test size(model.b) == size(adj2)
  end

  @testset "Errors" begin
    @test_throws ArgumentError olmar(adj1, 1, 3)
    @test_throws ArgumentError olmar(adj1, 2, 2)
  end
end
