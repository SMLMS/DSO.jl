using FilePathsBase

"""
    Config

Container for global DSO API configuration.

# Fields

- `stage_here` -- either `nothing` or an absolute path `AbstractPath` to the current stage.

# Examples

```Julia
Config(stage_here::Union{AbstractPath, Nothing})
```
"""
@kwdef mutable struct Config
    stage_here::Union{FilePathsBase.AbstractPath, Nothing} = nothing
end
