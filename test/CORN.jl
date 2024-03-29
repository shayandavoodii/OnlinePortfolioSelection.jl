# Test data for CORN.jl. Assumption: 3 assets and 30 periods.
adj_close = rand(3, 30) .* [4., 3., 2.] .+ [1., 5., 4.];

@testset "CORN" begin

  @testset "CORN-U" begin

    @testset "invalid ρ" begin
      @test_throws ArgumentError cornu(
        adj_close,
        3,
        3,
        rho=1.
      )

      @test_throws ArgumentError cornu(
        adj_close,
        3,
        3,
        rho=-0.5
      )
    end

    @testset "valid ρ" begin
      res = cornu(
        adj_close,
        3,
        3,
        rho=0.5
      );

      @test res.alg == "CORN-U"

      @test sum(res.b, dims=1) .|> isapprox(1.) |> all
    end

    @testset "invalid horizon" begin
      @test_throws ArgumentError cornu(
        adj_close,
        30,
        3,
        rho=0.1
      )
    end
  end

  @testset "CORN-K" begin
    @testset "invalid p" begin
      @test_throws ArgumentError cornk(
        adj_close,
        3,
        3,
        4,
        1
      )
    end

    @testset "valid p" begin
      res = cornk(
        adj_close,
        2,
        3,
        4,
        2
      );

      @test res.alg == "CORN-K"

      @test sum(res.b, dims=1) .|> isapprox(1.) |> all
    end

    @testset "invalid horizon" begin
      @test_throws ArgumentError cornk(
        adj_close,
        30,
        3,
        3,
        2
      )
    end
  end
end
