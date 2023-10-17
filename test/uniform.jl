rel_pr = rand(0.8:0.01:1.2, 15, 50)
rel_pr2 = rand(0.8:0.01:1.2, 1, 1)
rel_pr3 = rand(0.8:0.01:1.2, 1, 5)
rel_pr4 = rand(0.8:0.01:1.2, 15, 1)


@testset "uniform.jl" begin
  @testset "uniform" begin
    model = uniform(rel_pr)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)

    model = uniform(rel_pr2)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr2)

    model = uniform(rel_pr3)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr3)

    model = uniform(rel_pr4)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr4)
  end
end
