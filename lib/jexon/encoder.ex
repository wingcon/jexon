defmodule Jexon.Encoder do
  @moduledoc """
  Responsible for encoding to JSON
  """

  @type json :: String.t()

  @spec encode(data :: any()) :: {:ok, json()} | {:error, Jason.EncodeError.t()}
  def encode(data) do
    data
    |> prepare_non_natives()
    |> Jason.encode()
  end

  defp prepare_non_natives(data) when is_struct(data) do
    struct = data.__struct__
    data
    |> Map.from_struct()
    |> Map.merge(%{"__atom__:__struct__" => struct})
    |> prepare_non_natives()
  end
  defp prepare_non_natives(data) when is_map(data) do
    Enum.map(data, fn
      {key, value} -> {prepare_key(key), prepare_non_natives(value)}
    end)
    |> Map.new
  end

  defp prepare_non_natives(data) when is_list(data) do
    Enum.map(data, & prepare_non_natives/1)
  end
  defp prepare_non_natives(data) when is_tuple(data) do
    prepared_data =
      data
      |> Tuple.to_list()
      |> prepare_non_natives()

    ~w(__tuple__) ++ prepared_data
  end
  defp prepare_non_natives(data) when is_atom(data) do
      ~w(__atom__) ++ [to_string(data)]
  end
  defp prepare_non_natives(data) do
    data
  end

  defp prepare_key(key) when is_atom(key) do
    "__atom__:#{key}"
  end

  defp prepare_key(key) when is_list(key) do
    "__list__:" <> (
      key
      |> Enum.map(& prepare_key/1)
      |> Enum.join(",")
    )
  end

  defp prepare_key(key) when is_tuple(key) do
    "__tuple__:" <> (
      key
      |> Tuple.to_list
      |> Enum.map(& prepare_key/1)
      |> Enum.join(",")
    )
  end

  defp prepare_key(key) when is_map(key) do
    raise "Maps as keys are not supported"
  end

  defp prepare_key(key) when is_struct(key) do
    raise "Structs as keys are not supported"
  end

  defp prepare_key(key) do
    key
  end
end
# {
#   \"__atom__:__struct__\":[\"__atom__\",\"Elixir.DateTime\"],
#   \"__atom__:calendar\":[\"__atom__\",\"Elixir.Calendar.ISO\"],
#   \"__atom__:day\":9,
#   \"__atom__:hour\":8,
#   \"__atom__:microsecond\":[\"__tuple__\",44490,6],
#   \"__atom__:minute\":24,
#   \"__atom__:month\":8,
#   \"__atom__:second\":14,
#   \"__atom__:std_offset\":0,
#   \"__atom__:time_zone\":\"Etc/UTC\",
#   \"__atom__:utc_offset\":0,
#   \"__atom__:year\":2023,
#   \"__atom__:zone_abbr\":\"UTC\"
# }
