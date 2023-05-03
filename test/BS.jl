# Adjusted close prices of 3 assets for 10 days
adj_close = [
1.01774   1.00422  1.01267   1.00338   0.978882  1.00591   1.00929  1.00507  0.982264  0.991551
0.994283  1.0      0.988085  0.995235  0.968543  0.987609  1.00763  1.0      1.00906   1.03146
1.00952   1.01587  1.0127    0.998415  0.969844  1.00317   1.00317  1.00794  1.01429   1.01905
]

@testset "BS" begin
  @testset "with default arguments" begin
    res = bs(adj_close)

    @test res.b[:, 1] == ones(Float64, size(adj_close, 1))/size(adj_close, 1)

    # Test if just one asset is selected for each period except the first period
    @test sum(res.b[:, 2:end], dims=1) .|> isequal(1.) |> all

    @test size(res.b) == size(adj_close)
  end

  @testset "with last_n=2" begin
    res = bs(adj_close, last_n=2)

    @test res.b[:, 1] == ones(Float64, size(adj_close, 1))/size(adj_close, 1)

    # Test if just one asset is selected for each period except the first period
    @test sum(res.b[:, 2:end], dims=1) .|> isequal(1.) |> all

    @test size(res.b) == size(adj_close)
  end
end
