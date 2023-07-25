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
iex> Jexon.to_map(%DateTime{year: 2000, month: 12, day: 31, zone_abbr: "UTC", hour: 23, minute: 59, second: 59})
```

### `to_json`

This function converts Elixir structs or maps into a JSON string. This JSON string includes Elixir-specific types that are not directly translatable into JSON.

```elixir
iex> Jexon.to_json(%DateTime{year: 2000, month: 12, day: 31, zone_abbr: "UTC", hour: 23, minute: 59, second: 59})
```

### `from_json`

This function converts a JSON string, possibly including Elixir-specific types, back into an Elixir struct or map.

```elixir
iex> Jexon.from_json("{\"year\":2000,\"month\":12,\"day\":31,\"hour\":23,\"minute\":59,\"second\":59,\"__struct__\":\"Elixir.DateTime\",\"zone_abbr\":\"UTC\"}")
```


>With Jexon, you can work more effectively with JSON data in Elixir without worrying about data loss or type incompatibility issues