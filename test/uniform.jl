@testset "uniform.jl" begin
  @testset "With valid arguments" begin
    model = uniform(3, 5)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (3, 5)

    model = uniform(5, 1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (5, 1)

    model = uniform(1, 5)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (1, 5)

    model = uniform(1, 1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (1, 1)
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError uniform(0, 3)
    @test_throws ArgumentError uniform(2, 0)
  end
end
