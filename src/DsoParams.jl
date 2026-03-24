"""
    DsoParams

Container class for dso parameters

# Fields

- `data::Dict`: content of dso params file in dict format

# Examples

```Julia
params = DsoParams(data::Dict{Symbol, Any})
````
"""
struct DsoParams
    data::Dict{Symbol, Any}
end



# Overload getter: Permits access via dot notation (obj.key)
"""
    getproperty(obj::DsoParams, sym::Symbol)::Any

Return the property of a specific symbol from data dict via dot notation.

# Arguments

- `obj::DsoParams`: Instance of DsoParams
- `sym::Symbol`: Key of requested property

# Output

Any data stored under the kprovided key in data Dict

# Examples

```Julia
params = DsoParams(data::Dict{Symbol, Any})
property_value = params.key
```
"""
function Base.getproperty(obj::DsoParams, sym::Symbol)::Any
    if sym === :data
        return getfield(obj, :data)
    else
        return getfield(obj, :data)[sym]
    end
end



# Overload setter: Permits assignment via doz notation (obj.key = value)
"""
    setproperty!(obj::DsoParams, sym::Symbol, val::Any)::Nothing

Set the property of a specific symbol from data dict via dot notation.

# Arguments

- `obj::DsoParams`: Instance of DsoParams
- `sym::Symbol`: Key of the entry in the object's data Dict to be set.
- `val:Any`: Value that should be stored under the key of the object's  data dict

# Exapmles

```Julia
params = DsoParams(data::Dict{Symbol, Any})
params.key = 1
```
"""
function Base.setproperty!(obj::DsoParams, sym::Symbol, val::Any)::Nothing
    if sym === :data
        error("Instance vaiable data must not be replaced!")
    else
        getfield(obj, :data)[sym] = val
    end
    return nothing
end



# Overload propertynames: Permits autocompletion in VScode
"""
    propertynames(obj::DsoParams, private::Bool=false)

Function that permits autocompletion in VScode
"""
function Base.propertynames(obj::DsoParams, private::Bool=false)
    return (fieldnames(DsoParams)..., keys(getfield(obj, :data))...)
end



"""
    get_keys(obj::DsoParams)::Vector{String}

colletct the keys of the instance variable data.

# Arguments

- `obj::DsoParams`: An instance of the DsoParams object.

# Output

Array of keys

```Julia
params = DsoParams(data::Dict{Symbol, Any})
key_collection = get_keys(params)
```
"""
get_keys(obj::DsoParams) = collect(keys(obj.data))

# Overload index based setters and getters
Base.getindex(obj::DsoParams, key) = obj.data[key]
Base.setindex!(obj::DsoParams, val, key) = (obj.data[key] = val)

# Overload helper functions
Base.length(obj::DsoParams) = length(obj.data)
Base.keys(obj::DsoParams) = keys(obj.data)
Base.values(obj::DsoParams) = values(obj.data)
Base.haskey(obj::DsoParams, key) = haskey(obj.data, key)

# Permit iterations
Base.iterate(obj::DsoParams) = iterate(obj.data)
Base.iterate(obj::DsoParams, state) = iterate(obj.data, state)

# Overload show for pretty printing
"""
    show(io::IO, ::MIME"text/plain", obj::DsoParams)::Nothing

Pretty printing of DsoParams class

# Arguments

- `obj::DsoParams`: Instance of DsoParams class

# Examples

```Julia
params = DsoParams(data::Dict{Symbol, Any})
show(params)
```
"""
function Base.show(io::IO, ::MIME"text/plain", obj::DsoParams)::Nothing
    println(io, "DsoParams object with $(length(obj)) entries:")
    for (k, v) in obj.data
        println(io, "  $k => $v")
    end
    return nothing
end

# Overload show for pretty return
"""
    show(io::IO, obj::DsoParams)::Nothing

Pretty printing of DsoParams class

# Arguments

- `obj::DsoParams`: Instance of DsoParams class

# Examples

```Julia
params = DsoParams(data::Dict{Symbol, Any})
show(params)
```
"""
function Base.show(io::IO, obj::DsoParams)::Nothing
    print(io, "DsoParams(", length(obj.data), " Keys)")
    return nothing
end
