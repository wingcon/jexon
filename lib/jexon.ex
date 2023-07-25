defmodule Jexon do
  @moduledoc """
  Library to parse JSON and convert structs into maps or json without deriving any encoder.
  """

  @doc """
  Returns a string map of the struct or atom map

  ## Options
  - `with_struct_info`, `boolean`, default: `true`
    - includes `__struct__` key

  ## Example Usage

      iex> {:ok, datetime} = DateTime.new(~D[2018-07-28], ~T[12:30:00])
      iex> Jexon.to_map(datetime)
      %{
        "calendar" => Calendar.ISO,
        "day" => 28,
        "hour" => 12,
        "microsecond" => {0, 0},
        "minute" => 30,
        "month" => 7,
        "second" => 0,
        "std_offset" => 0,
        "time_zone" => "Etc/UTC",
        "utc_offset" => 0,
        "year" => 2018,
        "zone_abbr" => "UTC",
        "__struct__" => DateTime
      }
  """
  @spec to_map(data :: struct() | map(), opts :: keyword()) :: map()
  def to_map(data, opts \\ [])

  def to_map(data, opts) do
    with_struct_info = Keyword.get(opts, :with_struct_info, true)

    data
    |> Map.to_list()
    |> Enum.map(&stringify_keys/1)
    |> Enum.reject(fn {key, _} -> key == "__struct__" and not with_struct_info end)
    |> Enum.map(fn
      {key, value} when is_map(value) or is_struct(value) -> {key, to_map(value, opts)}
      key_val_pair -> key_val_pair
    end)
    |> Map.new()
  end

  @doc """
  Returns JSON of any given datatype

  ## Options
  - `with_struct_info`, `boolean`, default: `true`
    - includes `__struct__` key
  - `with_type_info`, `boolean`, default: `true`
    - convert all non-existing types into lists starting with the elixir type as `__<type>__`
      - e.g. `{1,2,3}` = `["__tuple__", 1, 2, 3]`

  ## Example Usage

      iex> data = %{foo: 1, baz: {2}, bar: :lol}
      iex> Jexon.to_json(data, with_type_info: true)
      {:ok, ~s/{\"bar\":[\"__atom__\",\"lol\"],\"baz\":[\"__tuple__\",2],\"foo\":1}/}
  """
  @spec to_json(data :: any(), opts :: keyword()) ::
          {:ok, json :: String.t()} | {:error, Jason.EncodeError.t() | Exception.t()}
  def to_json(data, opts \\ [])
  def to_json(data, opts) do
    with_type_info = Keyword.get(opts, :with_type_info, true)
    data =
      if with_type_info do
        prepare_value_for_json_encoding(data, opts)
      else
        data
      end

    Jason.encode(data)
  end

  @doc """
  Returns (casted) value on given JSON

  ## Options
  - `raw`, `boolean`, default: `false`
    - perform no type casting and keep keys as strings
  """
  @spec from_json(json :: String.t(), opts :: keyword()) ::
          {:ok, any()} | {:error, Jason.DecodeError.t()}
  def from_json(json, opts \\ [])

  def from_json(json, opts) do
    raw = Keyword.get(opts, :raw, false)

    case Jason.decode(json, keys: :atoms) do
      {:error, _} = err ->
        err

      {:ok, data} ->
        if raw do
          {:ok, data}
        else
          {:ok, cast_type_back(data)}
        end
    end
  end

  defp prepare_value_for_json_encoding(value, opts) when is_map(value) do
    value
    |> to_map(opts)
    |> Enum.map(fn
      {key, val} -> {key, prepare_value_for_json_encoding(val, opts)} end)
    |> Map.new()
  end

  defp prepare_value_for_json_encoding(value, opts) when is_list(value) do
    value
    |> Enum.map(&prepare_value_for_json_encoding(&1, opts))
  end

  defp prepare_value_for_json_encoding(value, opts) when is_tuple(value) do
    ~w(__tuple__) ++ (Tuple.to_list(value) |> Enum.map(&prepare_value_for_json_encoding(&1, opts)))
  end

  defp prepare_value_for_json_encoding(value, _) when is_nil(value) do
    nil
  end

  defp prepare_value_for_json_encoding(value, _) when is_boolean(value) do
    value
  end

  defp prepare_value_for_json_encoding(value, _) when is_atom(value) do
    ~w(__atom__) ++ [to_string(value)]
  end

  defp prepare_value_for_json_encoding(value, _) do
    value
  end

  defp stringify_keys({key, val}), do: {to_string(key), val}

  defp cast_type_back(["__tuple__" | rest]) do
    rest
    |> Enum.map(&cast_type_back/1)
    |> List.to_tuple()
  end

  defp cast_type_back(["__atom__" | [x]]) do
    String.to_atom(x)
  end

  defp cast_type_back(value) when is_map(value) do
    value
    |> Enum.map(fn {key, val} -> {key, cast_type_back(val)} end)
    |> Map.new()
    |> cast_struct()
  end

  defp cast_type_back(value) when is_list(value) do
    Enum.map(value, &cast_type_back/1)
  end

  defp cast_type_back(value) do
    value
  end

  defp cast_struct(%{__struct__: _} = data) do
    keys =
      data
      |> Map.keys()
      |> Enum.reject(&(&1 in ~w(__struct__)a))

    struct(data.__struct__, Map.take(data, keys))
  end

  defp cast_struct(map) do
    map
  end
end
