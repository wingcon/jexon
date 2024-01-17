defmodule Jexon.Decoder do
  @moduledoc """
  Responsible for decoding from JSON
  """

  @type json :: String.t()

  @spec decode(json :: json()) :: {:ok, any()} | {:error, Jason.DecodeError.t()}
  def decode(json) do
    case Jason.decode(json) do
      {:error, _} = err -> err
      {:ok, data} -> {:ok, resolve_data(data)}
    end
  end

  defp resolve_data(["__atom___", var]) do
    String.to_atom(var)
  end

  defp resolve_data(["__tuple___"| values]) do
    values
    |> Enum.map(& resolve_data/1)
    |> List.to_tuple()
  end

  defp resolve_data(data) do
    data
  end

  defp resolve_key("__atom__:" <> rest) do
    String.to_atom(rest)
  end

  defp resolve_key("__tuple__:" <> rest) do
    String.to_atom(rest)
  end
end
