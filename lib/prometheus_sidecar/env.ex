defmodule PrometheusSidecar.Env do
  @moduledoc """
  Get Environment variables
  """

  @app :prometheus_sidecar
  @defaults [
    port: 5001,
    max_connections: 16_384
  ]

  def library_version do
    @app
    |> Application.spec()
    |> Keyword.get(:vsn)
    |> to_string()
  end

  def port do
    "PROMETHEUS_SIDECAR_PORT"
    |> env(:port)
    |> to_number(@defaults[:port])
  end

  def scheme do
    case Application.get_env(@app, :https, nil) do
      nil -> :http
      _ -> :https
    end
  end

  def max_connections do
    "PROMETHEUS_SIDECAR_MAX_CONNECTIONS"
    |> env(:max_connections)
    |> to_number(@defaults[:max_connections])
  end

  def http, do: Application.get_env(@app, :http, [])
  def https, do: Application.get_env(@app, :https, [])

  defp env(string, key, default \\ nil) do
    (System.get_env(string) ||
       Application.get_env(@app, key, Keyword.get(@defaults, key, default)))
    |> parse()
  end

  defp parse(string) when is_bitstring(string) do
    if string =~ ";" do
      string
      |> String.split(";")
      |> Enum.map(&String.trim/1)
    else
      string
    end
  end

  defp parse(list) when is_list(list), do: Enum.map(list, &parse/1)
  defp parse(atom) when is_atom(atom), do: atom
  defp parse(number) when is_number(number), do: number
  defp parse(nil), do: nil
  defp parse({key, value}), do: {key, value}
  defp parse(_), do: nil

  defp to_number(value, _) when is_number(value), do: value

  defp to_number(value, default) when is_bitstring(value) do
    String.to_integer(value)
  rescue
    _ -> default
  end

  defp to_number(_, default), do: default

  #  defp to_atom(atom) when is_atom(atom), do: atom
  #  defp to_atom(string) when is_bitstring(string), do: String.to_atom(string)
  #  defp to_atom(_), do: :error
end
