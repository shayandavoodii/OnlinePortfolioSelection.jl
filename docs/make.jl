using OPS
using Documenter

DocMeta.setdocmeta!(OPS, :DocTestSetup, :(using OPS); recursive=true)

makedocs(;
    modules=[OPS],
    authors="Shayan Davoodi",
    repo="https://github.com/shayandavoodii/OPS.jl/blob/{commit}{path}#{line}",
    sitename="OPS.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://shayandavoodii.github.io/OPS.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/shayandavoodii/OPS.jl",
    devbranch="master",
)
