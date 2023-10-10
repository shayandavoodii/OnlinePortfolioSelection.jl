rel_pr = rand(3, 10)
n_assets, n_days = size(rel_pr)

@testset "CW-OGD.jl" begin
  @testset "With Default Arguments" begin
    model = cwogd(rel_pr, 0.2, 0.5)

    @test size(model.b) == size(rel_pr)

    @test model.b[:, 1] == ones(n_assets)/n_assets

    @test model.b[:, 1] == ones(n_assets)/n_assets

    @test sum(model.b, dims=1) .|> isapprox(1.) |> all

    @test model.n_assets == n_assets == size(model.b, 1)
  end

  @testset "With Custome Arguments" begin
    b1 = [
      1. 0. 1. 0. 0.
      0. 1. 0. 1. 0.
      0. 0. 0. 0. 1.
    ]
    model = cwogd(rel_pr, 0.2, 0.5, bj=b1)

    @test size(model.b) == size(rel_pr)

    @test model.b[:, 1] == ones(n_assets)/n_assets

    @test model.b[:, 1] == ones(n_assets)/n_assets

    @test sum(model.b, dims=1) .|> isapprox(1.) |> all

    @test model.n_assets == n_assets == size(model.b, 1)
  end

  @testset "With Invalid Arguments" begin
    @test_throws DomainError cwogd(rel_pr, -0.1, 0.5) #γ
    @test_throws DomainError cwogd(rel_pr, 1.1, 0.5) #γ
    @test_throws DomainError cwogd(rel_pr, 0.2, 0.) #H
    @test_throws DomainError cwogd(rel_pr, 0.2, -0.1) #H
    @test_throws ArgumentError cwogd(rel_pr, 0.2, 0.5, bj=ones(n_assets, 4)) #bj
    b2 = [
      1. 0. 1. 0. 0.
      0. 1. 0. 1. 0.
      .5 0. 0. 0. 1.
    ]
    @test_throws ArgumentError cwogd(rel_pr, 0.2, 0.5, bj=b2) #bj

    b3 = [
      .5 0. 0. 0. 0.
      0. 1. 0. 1. 0.
      0. 0. 0. 0. 1.
    ]

    @test_throws ArgumentError cwogd(rel_pr, 0.2, 0.5, bj=b3) #bj

    b4 = [
      1. 0. 1. 0. 0.
      0. 1. 0. 1. 0.
      0. 0. 0. 0. 1.
      .5 0. 0. 0. 0.
    ]

    @test_throws ArgumentError cwogd(rel_pr, 0.2, 0.5, bj=b4) #bj
  end
end
