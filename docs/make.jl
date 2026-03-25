using Documenter
using DSO

makedocs(
    sitename = "DSO API Documentation",
    format = Documenter.HTML(),
    modules = [DSO],
    pages = [
        "Home" => "index.md",
        "Core API" => "api.md",
        "Data Structures" => "dsoParams.md",
        "Configuration" => "config.md"
    ]
)

deploydocs(
    repo = "github.com/SMLMS/DSO.jl.git",
)