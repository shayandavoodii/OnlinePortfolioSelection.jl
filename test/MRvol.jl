const Wₘᵢₙ = 3
const Wₘₐₓ = 6

@testset "MRvol.jl" begin
  @testset "With valid arguments" begin
    rel_pr = rand(3, 100)
    rel_vol = rand(3, 100)
    model = mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 0.2, 0.3)

    @test size(model.b) == (3, 50)

    @test model.b[:, 1] == ones(size(rel_pr, 1))/size(rel_pr, 1)

    @test sum(model.b, dims=1) .|> isapprox(1.) |> all

    @test model.n_assets == size(rel_pr, 1) == size(model.b, 1)

    model = mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 0., 0.3)

    @test size(model.b) == (3, 50)

    @test model.b[:, 1] == ones(size(rel_pr, 1))/size(rel_pr, 1)

    @test sum(model.b, dims=1) .|> isapprox(1.) |> all

    @test model.n_assets == size(rel_pr, 1) == size(model.b, 1)

    model = mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 1., 0.3)

    @test size(model.b) == (3, 50)

    @test model.b[:, 1] == ones(size(rel_pr, 1))/size(rel_pr, 1)

    @test sum(model.b, dims=1) .|> isapprox(1.) |> all

    @test model.n_assets == size(rel_pr, 1) == size(model.b, 1)

    model = mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 0.2, 5.)

    @test size(model.b) == (3, 50)

    @test model.b[:, 1] == ones(size(rel_pr, 1))/size(rel_pr, 1)

    @test sum(model.b, dims=1) .|> isapprox(1.) |> all

    @test model.n_assets == size(rel_pr, 1) == size(model.b, 1)
  end

  @testset "With invalid arguments" begin
    rel_pr = rand(3, 100)
    rel_vol = rand(3, 100)

    @test_throws DomainError mrvol(rel_pr, rel_vol, 0, Wₘᵢₙ, Wₘₐₓ, 0.2, 0.3) #horizon
    @test_throws DomainError mrvol(rel_pr, rel_vol, 95, Wₘᵢₙ, Wₘₐₓ, 0.2, 0.3) #horizon
    @test_throws DomainError mrvol(rel_pr, rel_vol, 50, 0, Wₘₐₓ, 0.2, 0.3) #Wₘᵢₙ
    @test_throws DomainError mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, 0, 0.2, 0.3) #Wₘₐₓ
    @test_throws DomainError mrvol(rel_pr, rel_vol, 50, 6, 3, 0.2, 0.3) #Wₘᵢₙ < Wₘₐₓ
    @test_throws DomainError mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 1.1, 0.3) #λ
    @test_throws DomainError mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, -0.1, 0.3) #λ
    @test_throws DomainError mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 0.2, 0.) #η

    rel_vol = rand(3, 99)
    @test_throws DimensionMismatch mrvol(rel_pr, rel_vol, 50, Wₘᵢₙ, Wₘₐₓ, 0.2, 0.3)
  end

  @testset "expertspool" begin
    rel_pr = [
      0.993 1.005 0.898 0.992 1.000 0.957
      0.983 0.958 1.006 1.015 1.010 1.001
      0.960 1.029 0.999 1.017 1.025 0.998
      1.000 0.986 1.034 0.998 0.854 1.006
      0.992 0.975 1.022 1.003 1.008 0.995
    ];
    rel_vol = [
      1.336 1.203 0.829 0.666 0.673 2.120
      3.952 1.661 0.805 1.222 1.445 0.912
      0.362 2.498 1.328 1.009 1.954 0.613
      0.900 1.335 0.583 0.753 1.440 1.064
      1.487 1.900 0.676 0.776 1.319 1.788
    ];

    pool = OnlinePortfolioSelection.expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)
    @test isapprox(pool, [
      0.0       0.0   0.0  0.166667
      0.333333  0.25  0.2  0.166667
      0.333333  0.25  0.2  0.166667
      0.0       0.25  0.4  0.333333
      0.333333  0.25  0.2  0.166667
    ], atol=1e-6)

    rel_pr = [
      1.000 0.993 0.995 0.998 1.000 1.002
      1.000 0.958 1.006 1.015 1.010 1.001
      1.000 1.029 0.999 1.017 1.025 0.998
      1.000 0.986 1.034 0.998 0.854 1.006
      1.000 0.975 1.022 1.003 1.008 0.995
    ]

    pool = OnlinePortfolioSelection.expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)

    @test isapprox(pool, [
      0.0  0.0       0.0   0.0
      0.0  0.0       0.0   0.0
      0.5  0.333333  0.25  0.2
      0.0  0.333333  0.5   0.4
      0.5  0.333333  0.25  0.4
    ], atol=1e-6)

    rel_pr = [
      1.000 1.000 1.000 1.000 1.000 1.000
      1.000 1.000 1.000 1.000 1.000 1.000
      1.000 1.000 1.000 1.000 1.000 1.000
      1.000 1.000 1.000 1.000 1.000 1.000
      1.000 1.000 1.000 1.000 1.000 1.000
    ]

    pool = OnlinePortfolioSelection.expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)

    @test pool ≈ [
      0.2  0.2  0.2  0.2
      0.2  0.2  0.2  0.2
      0.2  0.2  0.2  0.2
      0.2  0.2  0.2  0.2
      0.2  0.2  0.2  0.2
    ]

    rel_pr = [
      1.000 0.993 0.995 0.998 1.000
      1.000 0.958 1.006 1.015 1.010
      1.000 1.029 0.999 1.017 1.025
      1.000 0.986 1.034 0.998 0.854
      1.000 0.975 1.022 1.003 1.008
    ]

    @test_throws DimensionMismatch OnlinePortfolioSelection.expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)

    rel_pr = [
      1.000 0.993 0.995 0.998 1.000 1.002
      1.000 0.958 1.006 1.015 1.010 1.001
      1.000 1.029 0.999 1.017 1.025 0.998
      1.000 0.986 1.034 0.998 0.854 1.006
      1.000 0.975 1.022 1.003 1.008 0.995
    ]

    @test_throws DomainError OnlinePortfolioSelection.expertspool(rel_pr, rel_vol, Wₘᵢₙ, size(rel_pr, 2)+1)
  end
end
