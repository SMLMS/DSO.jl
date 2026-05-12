using Documenter
using DataScienceOperations

makedocs(
    sitename = "DataScienceOperations.jl Documentation",
    format = Documenter.HTML(),
    modules = [DataScienceOperations],
    pages = [
        "Home" => "index.md",
        "Core API" => "api.md",
        "Data Structures" => ["config.md", "dsoParams.md"],
        "Developer" => "util.md"
    ]
)

deploydocs(
    repo = "github.com/SMLMS/DataScienceOperations.jl.git",
    devbranch = "develop"
)