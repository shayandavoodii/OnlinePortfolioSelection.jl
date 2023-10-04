# Adjusted close prices of 3 assets for 10 days
adj_close = [
1.01774   1.00422  1.01267   1.00338   0.978882  1.00591   1.00929  1.00507  0.982264  0.991551
0.994283  1.0      0.988085  0.995235  0.968543  0.987609  1.00763  1.0      1.00906   1.03146
1.00952   1.01587  1.0127    0.998415  0.969844  1.00317   1.00317  1.00794  1.01429   1.01905
]

@testset "LOAD.jl" begin
  @testset "with valid arguments" begin
    m_load, s = load(adj_close, 0.1, 3, 3, 0.5)

    @test sum(m_load.b, dims=1) .|> isapprox(1.0) |> all

    @test m_load.n_assets == size(adj_close, 1) == size(m_load.b, 1)
  end

  @testset "with high η" begin
    m_load, s = load(adj_close, 5., 3, 3, 0.5)

    @test sum(m_load.b, dims=1) .|> isapprox(1.0) |> all

    @test m_load.n_assets == size(adj_close, 1) == size(m_load.b, 1)
  end
  @testset "with invalid arguments" begin
    @test_throws DomainError load(adj_close, -0.1, 3, 3, 0.8)
    @test_throws DomainError load(adj_close, 0.1, 0, 3, 0.8)
    @test_throws DomainError load(adj_close, 0.1, 3, 0, 0.8)
    @test_throws DomainError load(adj_close, 0.1, 3, 3, 0.)
    @test_throws DomainError load(adj_close, 0.1, 8, 3, 0.8)
    @test_throws DomainError load(adj_close, 0.1, 3, 8, 0.8)
    @test_throws DomainError load(adj_close, 0.1, 3, 3, 1.1)
  end
end
