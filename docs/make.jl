using OnlinePortfolioSelection
using Documenter
using DocumenterCitations

DocMeta.setdocmeta!(OnlinePortfolioSelection, :DocTestSetup, :(using OnlinePortfolioSelection); recursive=true)
bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))

makedocs(;
    modules=[OnlinePortfolioSelection],
    authors="Shayan Davoodi <sh0davoodi@gmail.com>",
    sitename="OnlinePortfolioSelection.jl",
    checkdocs=:exports,
    plugins=[bib],
    format=Documenter.HTML(;
        canonical="https://shayandavoodii.github.io/OnlinePortfolioSelection.jl",
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=String["assets/citations.css"],
    ),
    pages=Any[
        "Home" => "index.md",
        "Fetch Financial Data" =>"fetchdata.md",
        "Use In Python" => "python.md",
        "OPS Strategies" => Any[
          "Benchmark" => "benchmark.md",
          "Follow the Loser" => "FL.md",
          "Follow the Winner" => "FW.md",
          "Pattern-Matching" => "PM.md",
          "Meta-Learning" => "ML.md",
          "Combined Strategies" => "Combined.md",
        ],
        "Performance Evaluation" => "performance_eval.md",
        "Functions" => "funcs.md",
    ],
)

deploydocs(;
    repo="github.com/shayandavoodii/OnlinePortfolioSelection.jl.git",
    devbranch="main",
)
