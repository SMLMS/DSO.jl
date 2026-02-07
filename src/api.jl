using FilePathsBase
using YAML
using Dates

"""
   here(rel_path::Union{Nothing,AbstractString}=nothing)::AbstractString

Get project root as a path string.

### Input

- `rel_path` -- Relative path to be appended to the project root

### Output

Absolute path to `rel_path`

### Notes

If `rel_path` is provided, returns `joinpath(project_root, rel_path)`.
"""
function here(rel_path::Union{Nothing,AbstractString}=nothing)::AbstractString
    proj_root = get_project_root(pwd())
    if rel_path === nothing
        return proj_root
    else
        return joinpath(proj_root, rel_path)
    end
end




"""
    stage_here(rel_path::Union{Nothing,AbstractString}=nothing)::AbstractString

Get the absolute path to the current stage.

### Input

- `rel_path` -- A relative path

### Output

Absulute path to the curent project stage.

### Notes

The current stage is stored in `CONFIG` and can be set calling either`set_stage` or `read_params`.
Throws an error if no stage has been set (use `set_stage` or `read_params` first).
If `rel_path` is provided, appends it to the stage root.
"""
function stage_here(rel_path::Union{Nothing,AbstractString}=nothing)::AbstractString
    if CONFIG.stage_here === nothing
        throw(ErrorException("No stage has been set. Run `read_params` or `set_stage` first!"))
    end

    if rel_path === nothing
        return string(CONFIG.stage_here)
    else
        return joinpath(string(CONFIG.stage_here), rel_path)
    end
end




"""
    set_stage(; stage::Union{String,AbstractString})::nothing

Set the stage_here field in CONFIG.

### Input

- `stage` -- Path to stage, relative to the project root

### Notes

`stage` is interpreted as a path relative to the project root.
If the referenced stage directory does not exist, an ArgumentError is thrown.
"""
function set_stage(stage::Union{String,AbstractString})::Nothing
    proj_root = get_project_root(pwd())
    stage_path = joinpath(proj_root, String(stage))

    if !isdir(stage_path)
        msg = """
        The stage `$(stage)` could not be found.

        Current working directory: `$(pwd())`
        Inferred project root: `$(proj_root)`
        """
        throw(ArgumentError(strip(msg)))
    end

    CONFIG.stage_here = FilePathsBase.PosixPath(stage_path)
    @info "stage_here() starts at $(CONFIG.stage_here)"

    return nothing
end



# Mocking dsoParams - in Julia, this could be a struct or a specific wrapper
struct DsoParams
    data::Dict
end




"""
    read_safe_yaml(params_file::String)

Reads YAML.
Julia's YAML.jl is more robust than R's default. Similar to Python's.
"""
function read_safe_yaml(params_file::String)
    return YAML.load_file(params_file)
end

"""
    read_params(stage_path=nothing, return_list=false)

Set stage and load parameters from params.yaml via dso-cli.
"""
function read_params(stage_path::Union{String, Nothing}=nothing, return_list::Bool=false)
    
    current_stage_path = ""

    if !isnothing(stage_path)
        current_stage_path = set_stage(stage_path)
    else
        if isnothing(config_env["stage_dir"])
            error("stage_path argument missing.")
        else
            @info "Reloading from already set stage_path: $(config_env["stage_dir"])"
            current_stage_path = config_env["stage_dir"]
        end
    end

    tmp_config_file = tempname()
    tmp_err_file = tempname()

    try
        # Run external process
        # stdout and stderr redirection in Julia
        pipeline_cmd = pipeline(`$DSO_EXEC get-config $current_stage_path`, 
                                stdout=tmp_config_file, 
                                stderr=tmp_err_file)
        
        run(pipeline_cmd)

    catch e
        stderror_content = isfile(tmp_err_file) ? read(tmp_err_file, String) : ""
        error("An error occurred when executing dso get-config: \n$stderror_content\n$(sprint(showerror, e))")
    end

    yaml_data = read_safe_yaml(tmp_config_file)
    
    # Clean up temp files
    rm(tmp_config_file, force=true)
    rm(tmp_err_file, force=true)

    return return_list ? yaml_data : DsoParams(yaml_data)
end
