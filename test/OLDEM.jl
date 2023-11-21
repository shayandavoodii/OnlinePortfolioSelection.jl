rel_pr = [
 0.987548  1.00258  0.990882  1.01593  1.01249   0.995373  1.01202  0.992957
 1.02963   1.01925  1.0388    1.0492   0.978055  0.993373  1.09769  1.02488
 0.990278  1.00797  0.995297  1.01609  1.02124   1.00226   1.02136  0.986497
 0.994709  1.01883  1.00216   1.01014  1.01431   0.998901  1.01766  0.987157
 0.991389  1.00095  0.995969  1.01535  1.00316   0.995971  1.00249  1.00249
]
n_assets = size(rel_pr, 1)
σ = 0.025;
w = 2;
h = 4;
L = 4;
s = 3;

@testset "OLDEM.jl" begin
  @testset "With default arguments" begin
    model = oldem(rel_pr, h, w, L, s, σ, 0.002, 0.25)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, h)
    @test model.n_assets == n_assets
  end

  @testset "With custom arguments" begin
    b̂ = [0.1, 0.1, 0.5, 0.2, 0.1]
    model = oldem(rel_pr, h, w, L, s, σ, 0.002, 0.25, bt=b̂)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, h)
    @test model.n_assets == n_assets

    model = oldem(rel_pr, h, w, L, s, σ, 0.002, 0.25, bt=b̂, progress=true)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, h)
    @test model.n_assets == n_assets
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError oldem(rel_pr, h, w, L, s, σ, 0.002, 0.25, bt=[0.1, 0.1, 0.5, 0.2, 0.8])
    @test_throws ArgumentError oldem(rel_pr, -1, w, L, s, σ, 0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, -1, L, s, σ, 0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, -1, s, σ, 0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, L, -1, σ, 0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, L, s, -1., 0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, L, s, σ, -0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, L, s, σ, 0.002, -0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, L, 4, σ, 0.002, 0.25)
    @test_throws ArgumentError oldem(rel_pr, h, w, L, s, σ, 0.002, 0.25, bt=[0.5, 0., -0.5, 0.2, 0.8])
    @test_throws DomainError oldem(rel_pr, h, w, 10, s, σ, 0.002, 0.25)
    @test_throws DomainError oldem(rel_pr, h, w+2, L, s, σ, 0.002, 0.25)
    @test_throws DomainError oldem(rel_pr, h+1, w, L, s, σ, 0.002, 0.25)
  end
end
