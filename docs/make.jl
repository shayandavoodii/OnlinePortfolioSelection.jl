using OPS
using Documenter

DocMeta.setdocmeta!(OPS, :DocTestSetup, :(using OPS); recursive=true)

makedocs(;
    modules=[OPS],
    authors="Shayan Davoodi <sh0davoodi@gmail.com>",
    sitename="OPS.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://shayandavoodii.github.io/OPS.jl",
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    pages=[
        "Home" => "index.md",
        "OPS Strategies" => [
          "Benchmark" => "benchmark.md",
          "Follow the Loser" => "FL.md",
          "Follow the Winner" => "FW.md",
          "Pattern-matching" => "PM.md",
        ],
        "Functions" => "funcs.md"
    ],
)

deploydocs(;
    repo="github.com/shayandavoodii/OPS.jl.git",
    devbranch="master",
)
