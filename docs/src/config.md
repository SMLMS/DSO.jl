# Config

The `config.jl` file defines the global configuration structure for the DSO API. This structure is designed to manage environmental paths and state across the application.

---

## **Struct: `Config`**

```@docs
Config
```


---

## **Usage**

Since the struct is defined as `mutable`, values can be updated after the initial configuration is created. This is particularly useful for setting the `stage_here` path dynamically during execution.

### **Initialization Examples**

**Default Initialization:**
```julia
# Creates a config where stage_here is nothing
my_config = Config()
```

**Keyword Initialization:**
```julia
using FilePathsBase

# Creates a config with a specific path
my_config = Config(stage_here=p"/absolute/path/to/stage")
```

---

## **Dependencies**
* **`FilePathsBase.jl`**: Used to handle system-agnostic path types (`AbstractPath`).
