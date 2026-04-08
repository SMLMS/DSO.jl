# DSO.jl

[![Build Status](https://github.com/SMLMS/DSO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/SMLMS/DSO.jl/actions/workflows/CI.yml?query=branch%3Amaster)

![Logo](assets/dso_jl.png)

A Julia companion package for the DSO CLI, providing project and stage management, YAML parameter loading, and configuration utilities.

```@docs
DSO.DSO
```

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

## Project Structure

- `src/`: Main source files
- `docs/`: Documentation
- `test/`: Tests


## Requirements

- Julia ≥ 1.10.10
- Dependencies: Dates, FilePathsBase, YAML

## Further reading

[Data Science Operations](https://github.com/Boehringer-Ingelheim/dso)

## License

See [LICENSE](LICENSE).