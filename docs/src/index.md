# DSO.jl

A Julia companion package for the DSO CLI, providing project and stage management, YAML parameter loading, and configuration utilities.

## Installation

```julia
using Pkg
Pkg.add("DSO")
```

## Usage

```julia
using DSO
```

### Flags & Options

- `here([rel_path])`: Returns the project root or a subpath.
- `stage_here([rel_path])`: Returns the absolute path to the current stage or a subpath.
- `set_stage(stage)`: Sets the current stage directory.
- `read_params([stage_path]; return_list=false)`: Loads parameters from YAML for a stage.
- `read_safe_yaml(params_file)`: Reads a YAML file robustly.

#### Example

```julia
# Get project root
root = here()

# Set stage
set_stage("analysis")

# Get stage path
stage_path = stage_here()

# Load parameters
params = read_params("analysis")
```

## Command-Line Flags (DSO CLI)

If you use the DSO CLI, typical flags include:
- `--stage <stage_name>`: Specify the stage directory.
- `--config <config_file>`: Specify a custom config file.
- `--help`: Show help message.

## Project Structure

- `src/`: Main source files
- `docs/`: Documentation
- `test/`: Tests

## Requirements

- Julia ≥ 1.10.10
- Dependencies: Dates, FilePathsBase, YAML

## License

See [LICENSE](LICENSE).