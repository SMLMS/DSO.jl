using FilePathsBase
using YAML
using Dates

"""
   here(rel_path::Union{Nothing,AbstractString}=nothing)::AbstractString

Get project root as a path string.

# Arguments

- `rel_path::Union{Nothing,AbstractString}`: Relative path to be appended to the project root

# Output

Absolute path to `rel_path`

# Notes

If `rel_path` is provided, returns `joinpath(project_root, rel_path)`.

# Examples

```Julia
here("path/to/file")
```
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

# Arguments

- `rel_path::Union{Nothing,AbstractString}`: A relative path

# Output

Absolute path to the curent project stage.

# Notes

The current stage is stored in `CONFIG` and can be set calling either`set_stage` or `read_params`.
Throws an error if no stage has been set (use `set_stage` or `read_params` first).
If `rel_path` is provided, appends it to the stage root.

# Examples

```Julia
stage_here("path/to/file")
```
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
    set_stage(; stage::Union{String,AbstractString})::Nothing

Set the stage_here field in CONFIG.

# Arguments

- `stage::Union{String,AbstractString}`: Path to stage, relative to the project root

# Notes

`stage` is interpreted as a path relative to the project root.
If the referenced stage directory does not exist, an ArgumentError is thrown.

# Example
```Julia
set_stage("path/to/stage")
```
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


"""
    read_safe_yaml(params_file::AbstractString)::Dict

Reads params YAML.

# Arguments

-`params_file::AbstractString`: path to the parameter file

# Output

Parameters in dictionary format

# Examples

```Julia
params_dict = read_safe_yaml("path/to/params.yaml")
```
"""
function read_safe_yaml(params_file::AbstractString)::Dict
    return YAML.load_file(params_file)
end




"""
    read_params(stage_path::Union{AbstractString, Nothing}=nothing, return_dict::Bool=false)::Union{Dict, DsoParams, NULL}


Set stage and load parameters from params.yaml via dso-cli.

# Arguments

-`stage_path::Union{AbstractString, Nothing}`: path to stage
-`return_dict::Bool`: indicates if parameters should be returned as dict or as DsoParams object.

# Output

Dso parameters. Either in dict format or as DsoParams object.
The function will return null if DSO cli is not available.

# Examples
```Julia
params_dict = read_params("path/to/params.yaml", true)
params_obj = read_params("path/to/params.yaml", false)
same_params_obj = read_params("path/to/params.yaml")
```
"""
function read_params(stage_path::Union{AbstractString, Nothing}=nothing, return_dict::Bool=false)::Union{Dict, DsoParams, NULL}
    if !dso_cli_available()
        return null
    end

    current_stage_path = ""

    if !isnothing(stage_path)
        set_stage(stage_path)
        current_stage_path = string(CONFIG.stage_here)
    else
        if isnothing(CONFIG.stage_here)
            error("stage_path argument missing.")
        else
            @info "Reloading from already set stage_path: $(string(CONFIG.stage_here))"
            current_stage_path = string(CONFIG.stage_here)
        end
    end

    tmp_config_file = tempname()
    tmp_err_file = tempname()

    # Run external process
    # stdout and stderr redirection in Julia
    pipeline_cmd = pipeline(`$DSO_EXEC get-config $current_stage_path`, 
                            stdout=tmp_config_file, 
                            stderr=tmp_err_file)
        
    run_dso(pipeline_cmd)

    yaml_data = read_safe_yaml(tmp_config_file)
    
    # Clean up temp files
    rm(tmp_config_file, force=true)
    rm(tmp_err_file, force=true)

    return return_dict ? yaml_data : DsoParams(yaml_data)
end



"""
    compile_config(dir::Union{AbstractString, Nothing})::Bool

This function runs the dso compile-config command and updates the params.yaml with info from other params.in.yaml and params.yaml.

# Arguments

- `dir::Union{AbstractString, Nothing}`: directory (including subdirectories and relevant parent files) to compile. By default compiles the current working directory.

# Output

true: dso compile-config ran sucessfully
false: else 

# Examples

```Julia
compile_config()
compile_config("/path/to/dso/item")
```
"""
function compile_config(dir::Union{AbstractString, Nothing}=nothing)::BOOL
    if !dso_cli_available()
        return false
    end

    if isnothing(dir)
        path_to_stage = here()
    else
        path_to_stage = dir
    end

    if !isdir(path_to_stage)
        println("No dso item termed $path_to_stage ")
        return false
    end

    # Run external process
    # stdout and stderr redirection in Julia
    tmp_config_file = tempname()
    tmp_err_file = tempname()

    pipeline_cmd = pipeline(`$DSO_EXEC compile-config $path_to_stage `, 
                            stdout=tmp_config_file, 
                            stderr=tmp_err_file)
        
    run_dso(pipeline_cmd)

    # Clean up temp files
    rm(tmp_config_file, force=true)
    rm(tmp_err_file, force=true)

    return true
end


"""
    create(item; dir::Union{AbstractString, Nothing}=nothing, name::Union{String, Nothing}=nothing, description::Union{String, Nothing}=nothing)::Bool

Create a new project, folder or stage in a given directory.

# Arguments

- `item::String`: item to create (project, folder, stage)
- `dir::Union{AbstractString, Nothing}`: path to directory in which project shall be initialised
- `name::Union{String, Nothing}`: project name: e.g. single_cell_lung_atlas. Can't be empty
- `description::Union{String, Nothing}`: description short project description. Can't be empty

# Output

true: dso create ran sucessfully
false: else

# Examples

```Julia
create("project", name = "single_cell_lung_atlas", description = "This project is awesome!")
create("folder", name = "single_cell_lung_atlas", description = "This folder comprises awesome analyses!")
create("project", name = "single_cell_lung_atlas", description = "This stage solves all your problems!")
```
"""
function create(item::String ;dir::Union{AbstractString, Nothing}=nothing, name::Union{String, Nothing}=nothing, description::Union{String, Nothing}=nothing)::Bool
    if !dso_cli_available()
        return false
    end

    if isnothing(name)
        println("No name for potential dso item provided")
        return false
    end

    if isnothing(description)
        println("Description of potential dso item must not be empty")
        return false
    end

    if isnothing(dir)
        path_to_stage = here(name)
    else
        path_to_stage = dir
    end

    if !isdir(path_to_stage)
        println("No dso item termed $path_to_stage ")
        return false
    end

    # Run external process
    # stdout and stderr redirection in Julia
    tmp_config_file = tempname()
    tmp_err_file = tempname()

    if (item === "project")
        pipeline_cmd = pipeline(`$DSO_EXEC init $name --description $description`, 
            stdout=tmp_config_file, 
            stderr=tmp_err_file)
    elseif (item === "folder")
        pipeline_cmd = pipeline(`$DSO_EXEC create folder $name --description $description`, 
            stdout=tmp_config_file, 
            stderr=tmp_err_file)
    elseif (item === "stage")
        pipeline_cmd = pipeline(`$DSO_EXEC create stage $name --description $description`, 
            stdout=tmp_config_file, 
            stderr=tmp_err_file)
    else
        error("item must be project, folder or stage!")
    end
    
    current_directory = pwd()
    cd(path_to_stage)
    run_dso(pipeline_cmd)
    cd(current_directory)

    # Clean up temp files
    rm(tmp_config_file, force=true)
    rm(tmp_err_file, force=true)

    return true
end


"""
    repro(;stage_dir::Union{AbstractString, Nothing}=nothing, single_stage::Bool=false)::Bool

This function reproduces a stage specified by `stage_dir`.
If `single_stage` is set to `TRUE`,
it reproduces the stage without its dependencies.
Otherwise, it reproduces the current stage
along with all its dependency stages.
By default, the current stage will be reproduced.

# Arguments

- `stage_dir::Union{String, Nothing}`: The path to a stage. Defaults to the current stage (Nothing).
- `single_stage::Bool`: flag indicating whether to reproduce only the current stage (`true`) or the current stage with all dependencies (`false`). Defaults to `false`

# Output

true: dso repro ran sucessfully
false: else


# Examples

```Julia
repro()
repro(stage_dir = "/path/to/dso/stage")
repro(stage_dir = "/path/to/dso/stage", single_stage = true)
```
"""
function repro(;stage_dir::Union{String, Nothing}=nothing, single_stage::Bool=false)::Bool
    if !dso_cli_available()
        return false
    end

    if isnothing(stage_dir)
        path_to_stage = here("dvc.yaml")
    else
        path_to_stage = joinpath(dir, "dvc.yaml")
    end

    if !isfile(path_to_stage)
        println("Not dso stage termed $path_to_stage")
        return false
    end

    # Run external process
    # stdout and stderr redirection in Julia
    tmp_config_file = tempname()
    tmp_err_file = tempname()

    if (single_stage == false)
        @info "Reproducing the stage $path_to_stage with all its dependency stages."
        pipeline_cmd = pipeline(`$DSO_EXEC repro $path_to_stage`, 
                                stdout=tmp_config_file, 
                                stderr=tmp_err_file)
    else
        @info "Reproducing the stage $path_to_stage without dependencies."
        pipeline_cmd = pipeline(`$DSO_EXEC -s repro $path_to_stage`, 
                                stdout=tmp_config_file, 
                                stderr=tmp_err_file)
    end
        
    run_dso(pipeline_cmd)

    # Clean up temp files
    rm(tmp_config_file, force=true)
    rm(tmp_err_file, force=true)

    return true
end