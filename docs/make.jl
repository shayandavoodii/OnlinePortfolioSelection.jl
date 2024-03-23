using OnlinePortfolioSelection
using Documenter
using DocumenterCitations
using Pkg

DocMeta.setdocmeta!(OnlinePortfolioSelection, :DocTestSetup, :(using OnlinePortfolioSelection); recursive=true)
bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))
PROJECT_TOML = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
VERSION_ = PROJECT_TOML["version"]
NAME = PROJECT_TOML["name"]
GITHUB = "https://github.com/shayandavoodii/OnlinePortfolioSelection.jl"

makedocs(;
    modules=[OnlinePortfolioSelection],
    authors="Shayan Davoodi <sh0davoodi@gmail.com>",
    sitename="OnlinePortfolioSelection.jl",
    checkdocs=:exports,
    plugins=[bib],
    format=Documenter.HTML(;
        canonical="https://shayandavoodii.github.io/OnlinePortfolioSelection.jl",
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=[
          "assets/citations.css",
          "assets/icon.ico"
        ],
        footer="[$NAME.jl]($GITHUB) v$VERSION_ docs powered by [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).",
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
        "Types" => "types.md",
        "References" => "refs.md",
    ],
)

deploydocs(;
    repo="github.com/shayandavoodii/OnlinePortfolioSelection.jl.git",
    devbranch="main",
)
