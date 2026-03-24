# api.jl Documentation

The `api.jl` file serves as the primary interface for the DSO API. It provides functions for path management, parameter handling, and interaction with the DSO CLI for project lifecycle tasks like stage creation and reproduction.

---

## **Path Management**

These functions help navigate the project structure and manage the active stage

```@docs
here
stage_here
set_stage
```

---

## **Parameter Handling**

Use these functions to load and parse configuration parameters for your DSO project.

```@docs
read_params
read_safe_yaml
```

---

## **DSO CLI Operations**

These functions wrap common DSO CLI commands to manage the project lifecycle, including creating items and reproducing stages

```@docs
compile_config
create
repro
```

---

## **Error Handling & Dependencies**
All CLI-dependent functions (`read_params`, `compile_config`, `create`, `repro`) perform a check via `dso_cli_available()` before execution. If an external process fails, these functions capture the `stderr` content and throw a descriptive Julia error.
