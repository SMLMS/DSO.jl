# DsoParams.jl

The `DsoParams.jl` file defines a container class specifically designed to manage DSO parameters. It acts as a wrapper around a standard Julia dictionary, providing enhanced accessibility through dot notation and seamless integration with common Julia collections functions.

---

```@docs
DsoParams
```

---

## **Key Features**

### **1. Dot Notation Access**

The `DsoParams` object overloads `getproperty` and `setproperty!`, allowing you to interact with dictionary keys as if they were object fields.
* **Get**: `params.key` retrieves the value associated with `:key`.
* **Set**: `params.key = value` updates or creates the entry for `:key`.
* **Safety**: The underlying `data` field itself cannot be replaced via dot notation; attempting to do so will result in an error.

### **2. IDE Integration**

* **Autocompletion**: The `propertynames` function is overloaded to ensure that keys stored within the `data` dictionary appear in VS Code autocompletion suggestions

### **3. Collection & Iteration Support**

`DsoParams` behaves like a standard Julia collection by overloading several `Base` methods:
* **Indexing**: Access data using `params[:key]` or set it using `params[:key] = val`.
* **Iteration**: You can loop over the object (e.g., `for (k, v) in params`) just like a dictionary.
* **Utility Functions**: Supports `length()`, `keys()`, `values()`, and `haskey()`.

---

## **Functions**

```@docs
Base.propertynames
Base.getproperty
Base.setproperty!
get_keys
show
```

---

## **Usage Example**

```julia
# Initialize with a dictionary
data_dict = Dict(:alpha => 0.1, :beta => 20)
params = DsoParams(data_dict)

# Access via dot notation
println(params.alpha)  # 0.1

# Update a value
params.beta = 30

# Use as a collection
if haskey(params, :alpha)
    println("Length: ", length(params))
end
```