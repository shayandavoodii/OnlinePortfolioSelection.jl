# Adjusted close prices of 3 assets for 10 days
adj_close = [
1.01774   1.00422  1.01267   1.00338   0.978882  1.00591   1.00929  1.00507  0.982264  0.991551
0.994283  1.0      0.988085  0.995235  0.968543  0.987609  1.00763  1.0      1.00906   1.03146
1.00952   1.01587  1.0127    0.998415  0.969844  1.00317   1.00317  1.00794  1.01429   1.01905
]


@testset "UP.jl" begin
  @testset "with default arguments" begin
    up = UP(adj_close)

    @test isa(up, OPSAlgorithm)

    @test up.alg == "UP"

    @test sum(up.b, dims=1) .|> isapprox(1.0) |> all

    @test up.n_assets == size(adj_close, 1)
  end

  @testset "with custom arguments" begin
    up = UP(adj_close, init_budg=1e2, eval_points=10^5, leverage=1.5)

    @test isa(up, OPSAlgorithm)

    @test up.alg == "UP"

    @test sum(up.b, dims=1) .|> isapprox(1.0) |> all

    @test up.n_assets == size(adj_close, 1)
  end
end
