# Adjusted close prices of 3 assets for 10 days
adj_close = [
1.01774   1.00422  1.01267   1.00338   0.978882  1.00591   1.00929  1.00507  0.982264  0.991551
0.994283  1.0      0.988085  0.995235  0.968543  0.987609  1.00763  1.0      1.00906   1.03146
1.00952   1.01587  1.0127    0.998415  0.969844  1.00317   1.00317  1.00794  1.01429   1.01905
]

@testset "RPRT Algorithm" begin
  @testset "With default arguments" begin
    m_rprt = rprt(adj_close, 3)

    @test isa(m_rprt, OPSAlgorithm)
    @test m_rprt.alg == "RPRT"
    @test sum(m_rprt.b, dims=1) .|> isapprox(1.) |> all
    @test m_rprt.n_assets == size(adj_close, 1)
  end

  @testset "With custom arguments" begin
    m_rprt = rprt(adj_close, 3, 4, 0.5, 30)

    @test isa(m_rprt, OPSAlgorithm)
    @test m_rprt.alg == "RPRT"
    @test sum(m_rprt.b, dims=1) .|> isapprox(1.) |> all
    @test m_rprt.n_assets == size(adj_close, 1)

    bₜ = @views adj_close[:, 1] / sum(adj_close[:, 1])
    m_rprt = rprt(adj_close, 3, 4, 0.5, 30, bₜ)

    @test isa(m_rprt, OPSAlgorithm)
    @test m_rprt.alg == "RPRT"
    @test sum(m_rprt.b, dims=1) .|> isapprox(1.) |> all
    @test m_rprt.n_assets == size(adj_close, 1)
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError rprt(adj_close, 0, 3) #Invalide `horizon`
    @test_throws ArgumentError rprt(adj_close, 3, 2) #Invalide `w`
    @test_throws ArgumentError rprt(adj_close, 3, 3, 0.) #Invalide `ϑ`
    @test_throws ArgumentError rprt(adj_close, 3, 3, 0.5, 0) #Invalide `𝜖`
    bₜ = [0.2, 0.2, 0.2, 0.4]
    @test_throws ArgumentError rprt(adj_close, 3, 3, 0.5, 20, bₜ) #Invalide `bₜ`
    bₜ = [0.2, 0.2, 0.1]
    @test_throws ArgumentError rprt(adj_close, 3, 3, 0.5, 20, bₜ) #Invalide `bₜ`
    @test_throws ArgumentError rprt(adj_close, 3, 10, 0.5, 20) #Domain
  end

  @testset "Individual functions" begin
    OnlinePortfolioSelection.λ̂ₜ₊₁func(zeros(5), rand(5), 3)
  end
end
