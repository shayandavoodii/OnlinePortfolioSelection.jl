prices = [
  154.78    152.852  153.247   151.85   154.269  156.196   155.473   157.343   156.235  157.246  160.128  161.024   160.446  159.675
  68.3685   68.033   69.7105   69.667   70.216   70.9915   71.4865   71.9615   71.544   71.96    72.585   74.0195   74.22    74.2975
 209.78    208.67   212.6     213.06   215.22   218.3     218.06    221.91    219.06   221.15   221.77   222.14    221.44   221.32
]

h = 3
n_assets = size(prices, 1)

@testset "GWR.jl" begin
  @testset "With default arguments" begin
    model = gwr(prices, h)
    @test sum(model.b, dims=1) .|> isapprox(1.0, atol=1e-2) |> all
    @test model.n_assets == n_assets == size(model.b, 1)
    @test (model.b[:, 1] .== 1/n_assets) |> all

    model = gwr(prices, h, [1, 2, 3])
    @test sum(model.b, dims=1) .|> isapprox(1.0) |> all
    @test model.n_assets == n_assets == size(model.b, 1)
    @test (model.b[:, 1] .== 1/n_assets) |> all
  end

  @testset "With custom arguments" begin
    model = gwr(prices, h, 1, 20, 0.01)
    @test sum(model.b, dims=1) .|> isapprox(1.0, atol=1e-2) |> all
    @test model.n_assets == n_assets == size(model.b, 1)
    @test (model.b[:, 1] .== 1/n_assets) |> all

    model = gwr(prices, h, [2, 3, 3.2], 20, 0.01)
    @test sum(model.b, dims=1) .|> isapprox(1.0, atol=1e-2) |> all
    @test model.n_assets == n_assets == size(model.b, 1)
    @test (model.b[:, 1] .== 1/n_assets) |> all
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError gwr(prices, 0)
    @test_throws ArgumentError gwr(prices, h, 0.)
    @test_throws ArgumentError gwr(prices, h, 2.4, 0)
    @test_throws ArgumentError gwr(prices, h, 2.4, 20, 0.)
    @test_throws ArgumentError gwr(prices, h, 0.1, 20)
    @test_throws ArgumentError gwr(prices[:, 1:11], h)
    @test_throws ArgumentError gwr(prices, 0, [2, 3, 4])
    @test_throws ArgumentError gwr(prices, h, [0.1, 0.2, 0.3])
    @test_throws ArgumentError gwr(prices, h, [2, 3, 4], 0)
    @test_throws ArgumentError gwr(prices, h, [2, 3, 4], 20, 0.)
    @test_throws ArgumentError gwr(prices, h, [2, 3, 0])
    @test_throws ArgumentError gwr(prices, h, [2])
    @test_throws ArgumentError gwr(prices[:, 1:11], h, [3., 3.1, 3.2])
  end
end
