using Documenter
using DSO

makedocs(
    sitename = "DSO.jl Documentation",
    format = Documenter.HTML(),
    modules = [DSO],
    pages = [
        "Home" => "index.md",
        "Core API" => "api.md",
        "Data Structures" => ["config.md", "dsoParams.md"],
        "Developer" => "util.md"
    ]
)

deploydocs(
    repo = "github.com/SMLMS/DSO.jl.git",
    devbranch = "main"
)