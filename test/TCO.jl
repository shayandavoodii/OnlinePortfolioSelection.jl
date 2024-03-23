rel_pr = [
1.01774   1.00422  1.01267   1.00338   0.978882  1.00591   1.00929  1.00507  0.982264  0.991551
0.994283  1.0      0.988085  0.995235  0.968543  0.987609  1.00763  1.0      1.00906   1.03146
1.00952   1.01587  1.0127    0.998415  0.969844  1.00317   1.00317  1.00794  1.01429   1.01905
]

@testset "TCO.jl" begin
  @testset "With default arguments" begin
    model = tco(rel_pr, 2, 3, 0.01, 10, TCO1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == size(rel_pr, 1)
    @test (model.b[:, 1] .== 1/size(rel_pr, 1)) |> all

    model1 = tco(rel_pr, 2, 3, 0.01, 10, TCO2)
    @test sum(model1.b, dims=1) .|> isapprox(1.) |> all
    @test model1.n_assets == size(rel_pr, 1)
    @test (model1.b[:, 1] .== 1/size(rel_pr, 1)) |> all

    @test model.b != model1.b
  end

  @testset "With custom arguments" begin
    model = tco(rel_pr, 2, 3, 0.01, 10, TCO1, [0.7, 0.1, 0.2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == size(rel_pr, 1)
    @test (model.b[:, 1] == [0.7, 0.1, 0.2])

    model1 = tco(rel_pr, 2, 3, 0.01, 10, TCO2, [0.7, 0.1, 0.2])
    @test sum(model1.b, dims=1) .|> isapprox(1.) |> all
    @test model1.n_assets == size(rel_pr, 1)
    @test (model.b[:, 1] == [0.7, 0.1, 0.2])

    @test model.b != model1.b
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError tco(rel_pr, 4, 7, 0.04, 10, TCO1)
    @test_throws ArgumentError tco(rel_pr, 2, 0, 0.04, 10, TCO1)
    @test_throws ArgumentError tco(rel_pr, 1, 3, 0.04, 10, TCO1)
    @test_throws ArgumentError tco(rel_pr, 2, 3, 0., 10, TCO1)
    @test_throws ArgumentError tco(rel_pr, 2, 3, 0.04, 0, TCO1)
    @test_throws ArgumentError tco(rel_pr, 2, 3, 0.04, 10, TCO1, [0.7, 0.1, 0.1])
    @test_throws ArgumentError tco(rel_pr, 2, 3, 0.04, 10, TCO1, [0.7, 0.1, 0.05, 0.05])
  end

  @testset "Warns" begin
    @test_logs (:warn, "Tha passed transaction rate (0.06) is considered to be high. Due to the \
      nature of the algorithm, there might be no difference between the result of the algorithm, \
      whether it is `OTC1` or `OTC2`. The values lower than or equal to 0.05 are recommended."
    ) tco(rel_pr, 2, 3, 0.06, 10, TCO1)
  end
end
