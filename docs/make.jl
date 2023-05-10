using OnlinePortfolioSelection
using Documenter

DocMeta.setdocmeta!(OnlinePortfolioSelection, :DocTestSetup, :(using OnlinePortfolioSelection); recursive=true)

makedocs(;
    modules=[OnlinePortfolioSelection],
    authors="Shayan Davoodi <sh0davoodi@gmail.com>",
    sitename="OnlinePortfolioSelection.jl",
    format=Documenter.HTML(;
        canonical="https://shayandavoodii.github.io/OnlinePortfolioSelection.jl",
        prettyurls = get(ENV, "CI", nothing) == "true",
        sidebar_sitename = false
    ),
    pages=Any[
        "Home" => "index.md",
        "Fetch Financial Data" =>"fetchdata.md",
        "OPS Strategies" => Any[
          "Benchmark" => "benchmark.md",
          "Follow the Loser" => "FL.md",
          "Follow the Winner" => "FW.md",
          "Pattern-Matching" => "PM.md",
        ],
        "Performance Evaluation" => "performance_eval.md",
        "Functions" => "funcs.md"
    ],
)

deploydocs(;
    repo="github.com/shayandavoodii/OnlinePortfolioSelection.jl.git",
    devbranch="main",
)
