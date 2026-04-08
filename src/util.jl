

"""
    is_relative_to(; path::AbstractString, barrier::AbstractString)::Bool

Check whether `path` is inside `barrier` (i.e. `barrier` is a prefix of `path`)

# Arguments

- `path::AbstractString`: current directory
- `barrier::AbstractString`: barrier definition

# Output

bool that describes if `path` is inside `barrier`
"""
function is_relative_to(; path::AbstractString, barrier::AbstractString)::Bool
    p_parts = splitpath(abspath(path))
    b_parts = splitpath(abspath(barrier))
    test_result = (length(b_parts) <= length(p_parts) && b_parts == p_parts[1:length(b_parts)])
    return test_result
end

"""
    find_in_parent(; start_directory::AbstractString, file_or_folder::AbstractString, recurse_barrier::Union{Nothing,AbstractString}=nothing)::Union{Nothing,AbstractString}

Recursively walk up to the folder directory from `start_directory` until we either find `file_or_folder` or reach the root.

# Arguments

- `start_directory:AbstractString`: The directory to start the search from.
- `file_or_folder::AbstractString`: File or folder that defines the project root.
- `recurse_barrier::Union{Nothing,AbstractString}`: Define barrier that will not be exceeded.

# Output

The project root or nothing.

# Notes

Walks up from `start_directory` looking for `file_or_folder`. Returns the absolute path
to the discovered `file_or_folder` (as a String), or `nothing` if not found.
If `recurse_barrier` is provided we will not walk above that directory.
"""
function find_in_parent(; start_directory::AbstractString, file_or_folder::AbstractString, recurse_barrier::Union{Nothing,AbstractString}=nothing)::Union{Nothing,AbstractString}
    current_directory = abspath(start_directory)

    while true
        # Root detection: dirname(current_directory ) == current_directory  on root (works cross-platform)
        if dirname(current_directory) == current_directory 
            return nothing
        end

        if recurse_barrier !== nothing
            # if current_directory is not inside the barrier, stop
            if !is_relative_to(path=current_directory, barrier=recurse_barrier)
                return nothing
            end
        end

        # If user passed a file path, move to its parent (mimic Python behavior)
        if isfile(current_directory)
            current_directory = dirname(current_directory)
            continue
        end

        candidate = joinpath(current_directory, file_or_folder)
        if isfile(candidate) || isdir(candidate)
            return candidate
        end

        current_directory = dirname(current_directory)
    end
end


"""
    get_project_root(start_directory::AbstractString)::AbstractString

Find the project root by locating the nearest parent `.git` entry and returning its parent.

# Arguments

- `start_directory::AbstractString`: The directory to start the search from.

# Output

The project root.

# Notes

Throws an error if `.git` cannot be found (mimics Python FileNotFoundError behaviour).
"""
function get_project_root(start_directory::AbstractString)::AbstractString
    proj_root = find_in_parent(
        start_directory=start_directory,
        file_or_folder=".git"
    )
    if proj_root === nothing
        error("Not within a dso project (No .git directory found)")
    else
        return dirname(proj_root)
    end
end

"""
    dso_cli_available()::Bool

Checks the DSO CLI is available in the System PATH.

# Output

A bool that states if DSO CLI is available or not.
"""
function dso_cli_available()::Bool
    if Sys.which("$DSO_EXEC") === nothing
        println("DSO CLI not found in PATH. Please install the DSO CLI and assure it is available in system PATH. See https://boehringer-ingelheim.github.io/dso/cli_installation.html for more information.")
        return false
    end
    return true
end


"""
    run_dso_cli(command::Base.ProcessChain)::Nothing

Helper function that executes the dso command

# Arguments

- `command::Base.ProcessCain`: Process to be executed

# Output

nothing
"""
function run_dso_cli(command::Base.CmdRedirect, tmp_err_file::AbstractString)::Nothing
    try
        run(command)
    catch e
        stderror_content = isfile(tmp_err_file) ? read(tmp_err_file, String) : ""
        error("An error occurred when executing dso: \n$stderror_content\n$(sprint(showerror, e))")
    end
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
    return YAML.load_file(params_file; dicttype=Dict{Symbol, Any})
end
