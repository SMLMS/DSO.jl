using FilePathsBase

"""
    Config

Container for global DSO API configuration.

### Fields
- `stage_here` -- either `nothing` or an absolute path `PosixPath`` to the current stage.

### Examples
- `Config(
    stage_here::Union{PosixPath, Nothing}
)` -- default constructor

"""
@kwdef mutable struct Config
    stage_here::Union{FilePathsBase.PosixPath, Nothing} = nothing
end
