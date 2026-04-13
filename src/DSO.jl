"""
    module DSO
 
DSO.jl is a Julia companion package for the DSO CLI, providing utilities for project and stage management, configuration handling,
and robust parameter loading from YAML files. It is designed to integrate seamlessly with DSO-based workflows,
offering ergonomic access to project roots, stage directories, and configuration parameters.
 
Main features:
- Project root and stage path resolution
- Flexible parameter loading and access via `DsoParams`
- Utility functions for path and environment management
- Integration with the DSO command-line interface
 
Intended for users who need to manage complex project structures and configurations in Julia, especially in conjunction with the DSO CLI.
"""
module DSO

    # Exports
    export Config 
    include("config.jl")

    export DsoParams, get_keys
    include("DsoParams.jl")

    export here, stage_here, set_stage, read_params, create, compile_config, repro, session_info
    include("api.jl")

    include("util.jl")

    # define constants
    const DSO_EXEC = "dso"
    const CONFIG = Config()

end

