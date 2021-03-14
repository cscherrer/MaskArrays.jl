using MaskArrays
using Documenter

DocMeta.setdocmeta!(MaskArrays, :DocTestSetup, :(using MaskArrays); recursive=true)

makedocs(;
    modules=[MaskArrays],
    authors="Chad Scherrer <chad.scherrer@gmail.com> and contributors",
    repo="https://github.com/cscherrer/MaskArrays.jl/blob/{commit}{path}#{line}",
    sitename="MaskArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cscherrer.github.io/MaskArrays.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cscherrer/MaskArrays.jl",
)
