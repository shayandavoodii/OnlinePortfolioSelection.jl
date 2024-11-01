using Lasso

prices = [
  154.78    152.852  153.247   151.85   154.269  156.196   155.473   157.343   156.235  157.246  160.128  161.024   160.446  159.675
  68.3685   68.033   69.7105   69.667   70.216   70.9915   71.4865   71.9615   71.544   71.96    72.585   74.0195   74.22    74.2975
 209.78    208.67   212.6     213.06   215.22   218.3     218.06    221.91    219.06   221.15   221.77   222.14    221.44   221.32
]

n_assets = size(prices, 1)
h, w, q, eta, v, phat_t, bhat_t = 4, 5, 6, 1000, 0.5, rand(n_assets), nothing

@testset "GWR.jl" begin
  @testset "With default arguments" begin
    model = ktpt(prices, h, w, q, eta, v, phat_t, bhat_t)

    @test sum(model.b, dims=1) .|> isapprox(1.0) |> all
    @test model.n_assets == n_assets == size(model.b, 1)
    @test (model.b[:, 1] .== 1/n_assets) |> all
  end

  @testset "With custom arguments" begin
    b̂ₜ = [0.2, 0.5, 0.3]
    model = ktpt(prices, h, w, q, eta, v, phat_t, b̂ₜ)

    @test sum(model.b, dims=1) .|> isapprox(1.0) |> all
    @test model.n_assets == n_assets == size(model.b, 1)
    @test model.b[:, 1] == b̂ₜ
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError ktpt(prices, 0, w, q, eta, v, phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices, h, 0, q, eta, v, phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices, h, w, 0, eta, v, phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices, h, w, q, 0, v, phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices, h, w, q, eta, -1., phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices, h, w, q, eta, 2., phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices, h, w, q, eta, v, phat_t, [0.5, 0.5])
    @test_throws ArgumentError ktpt(prices, h, w, q, eta, v, [0.5, 0.2], bhat_t)
    @test_throws ArgumentError ktpt(prices, 5, w, q, eta, v, phat_t, bhat_t)
    @test_throws ArgumentError ktpt(prices[:, 1:end-1], h, w, q, eta, v, phat_t, bhat_t)

  end
end
