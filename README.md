# Jexon

Jexon is an Elixir library designed to provide a seamless bridge between Elixir data structures and JSON, while preserving the unique Elixir types that are not directly supported in JSON. 

## Key Features

- Convert Elixir structs and maps to JSON, and vice versa, without losing data fidelity.
- Retains unique Elixir types during the conversion process.

## API

Jexon provides a simple API with three main functions:

### `to_map`

This function converts Elixir structs or maps into a map that can be serialized into JSON. This map maintains Elixir-specific types that are not directly translatable into JSON.

```elixir
# simple maps
Jexon.to_map(%{foo: 1, baz: 2, bar: 3})
%{"bar" => 3, "baz" => 2, "foo" => 1}

# with key info
Jexon.to_map(%{foo: 1, baz: 2, bar: 3}, keep_key_identity: true)
%{"__atom__:bar" => 3, "__atom__:baz" => 2, "__atom__:foo" => 1}

# structs
defmodule Foo do
    defstruct ~w(foo baz bar)a
end

data = %Foo{foo: 1, baz: 2, bar: 3}

Jexon.to_json(data)
{:ok,
 "{\"__atom__:__struct__\":[\"__atom__\",\"Elixir.Foo\"],\"__atom__:bar\":3,\"__atom__:baz\":2,\"__atom__:foo\":1}"}

json = ~S/
    {
        "__atom__:__struct__": ["__atom__", "Elixir.Foo"],
        "__atom__:foo": 1,
        "__atom__:baz": 2,
        "__atom__:bar": 3
    }
/

Jexon.from_json(json)
{:ok, %Foo{bar: 3, baz: 2, foo: 1}}
```

### `to_json`

This function converts Elixir structs or maps into a JSON string. This JSON string includes Elixir-specific types that are not directly translatable into JSON.

```elixir
dt = DateTime.utc_now()

Jexon.to_json(dt)

{:ok,
 "{\"__atom__:__struct__\":[\"__atom__\",\"Elixir.DateTime\"],\"__atom__:calendar\":[\"__atom__\",\"Elixir.Calendar.ISO\"],\"__atom__:day\":8,\"__atom__:hour\":8,\"__atom__:microsecond\":[\"__tuple__\",814264,6],\"__atom__:minute\":29,\"__atom__:month\":8,\"__atom__:second\":45,\"__atom__:std_offset\":0,\"__atom__:time_zone\":\"Etc/UTC\",\"__atom__:utc_offset\":0,\"__atom__:year\":2023,\"__atom__:zone_abbr\":\"UTC\"}"}
```

### `from_json`

This function converts a JSON string, possibly including Elixir-specific types, back into an Elixir struct or map.

```elixir
json = ~S/
    {
        \"__atom__:__struct__\":[\"__atom__\",\"Elixir.Time\"],\"__atom__:calendar\":[\"__atom__\",\"Elixir.Calendar.ISO\"],
        \"__atom__:hour\":12,
        \"__atom__:microsecond\":[\"__tuple__\",0,0],\"__atom__:minute\":0,
        \"__atom__:second\":0
    }
/

Jexon.from_json(json)

{:ok, ~T[12:00:00]}
```


>With Jexon, you can work more effectively with JSON data in Elixir without worrying about data loss or type incompatibility issues