"""
   DSO.jl

A Julia companion for DSO.
"""
module DSO

    # Exports
    export Config 
    include("config.jl")

    #export read_params
    #include("read_params.jl")

    export here, stage_here, set_stage, read_params, DsoParams
    include("api.jl")

    export is_relative_to, find_in_parent, get_project_root
    include("util.jl")

    # define constants
    const DSO_EXEC = "dso"
    const CONFIG = Config()

end

