# DSO.jl

[![Build Status](https://github.com/SMLMS/DSO.jl/actions/workflows/documentation.yml/badge.svg)](https://github.com/SMLMS/DSO.jl/actions/workflows/documentation.yml)

[![Build Status](https://github.com/SMLMS/DSO.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/SMLMS/DSO.jl/actions/workflows/CI.yml)

![Logo](assets/dso_jl.png)

A Julia companion package for the [DSO CLI](https://github.com/Boehringer-Ingelheim/dso), providing project and stage management, YAML parameter loading, and configuration utilities.

```@docs
DSO.DSO
```

## Installation

```julia
using Pkg
Pkg.add("DSO")
```

## 🛠️ Usage

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

## 🧪 Testing

Run

```julia
pkg> test
```

to verify the installation. 

## 🐙 Further reading

More information about the DSO project as well as an R-companion can be found here:

* [Data Science Operations](https://github.com/Boehringer-Ingelheim/dso)
* [DSO R companion](https://github.com/Boehringer-Ingelheim/dso-r)

## 📚 Documentation

Check out the [Docs](https://SMLMS.github.io/DSO.jl/dev/) for the full API reference.

## ⚖️ License

MIT © Sebastian Malkusch