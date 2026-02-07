
# Global state to mimic R's config_env
const config_env = Dict{String, Any}("stage_dir" => nothing)

"""
    set_stage(stage_path::String)

Sets the stage directory and updates the global config_env.
"""
function set_stage(stage_path::String)
    # Julia's equivalent to here::here() is often handled by project-relative paths
    # or using the package 'ProjectRelativeFiles'
    
    # Check for dvc.yaml existence as in the R code
    if !isfile(joinpath(stage_path, "dvc.yaml"))
        @warn "dvc.yaml not found in $stage_path"
    end

    stage_dir = abspath(stage_path)
    println("stage_here() starts at $stage_dir")
    
    config_env["stage_dir"] = stage_dir
    return stage_dir
end

"""
    stage_here(args...)

Returns the absolute path to the current stage, optionally appending sub-paths.
"""
function stage_here(args...)
    isnothing(config_env["stage_dir"]) && error("Stage directory not set. Call set_stage first.")
    return joinpath(config_env["stage_dir"], args...)
end
