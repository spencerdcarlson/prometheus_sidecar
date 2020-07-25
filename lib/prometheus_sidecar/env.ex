defmodule PrometheusSidecar.Env do
  @moduledoc """
  Helper module to get environment variables from the host application.

  Most options can be set using either a System environment variable or an elixir configuration.
  """

  @app :prometheus_sidecar
  @defaults [
    port: 5001,
    max_connections: 16_384,
    enable_server: true
  ]

  @doc """
  Get the current library version.
  """
  @spec library_version() :: String.t()
  def library_version do
    @app
    |> Application.spec()
    |> Keyword.get(:vsn)
    |> to_string()
  end

  @doc """
  Enable the ranch web server.

  This option is helpful when you do not want to report metrics in the `:dev` or `:test` environment

  default value: `true`

  Set using System env or elixir config:

  `PROMETHEUS_SIDECAR_ENABLE_SERVER=false`

  `config :prometheus_sidecar, enable_server: false`
  """
  @spec enable_server?() :: boolean()
  def enable_server? do
    "PROMETHEUS_SIDECAR_ENABLE_SERVER"
    |> env(:enable_server)
    |> to_boolean()
  end

  @doc """
  Sets the port for the ranch web server.

  default value: `5001`

  Set using System env or elixir config:

  `PROMETHEUS_SIDECAR_PORT=6001`

  `config :prometheus_sidecar, port: 6001`
  """
  @spec port() :: integer()
  def port do
    "PROMETHEUS_SIDECAR_PORT"
    |> env(:port)
    |> to_number(@defaults[:port])
  end

  @doc """
  Get the desired schema for the ranch web server.

  default value: `:http`

  This will always return `:http` unless there is a value for the `:https` option.

  This option can only be set using an elixir config:

  `config :prometheus_sidecar, https: [keyfile: "/dev.key", certfile: "/dev.crt"]`
  """
  @spec scheme() :: atom()
  def scheme do
    case Application.get_env(@app, :https, nil) do
      nil -> :http
      _ -> :https
    end
  end

  @doc """
  Sets max number of connections allowed on the ranch server.

  default value: `16_384`

  Set using System env or elixir config:

  `PROMETHEUS_SIDECAR_MAX_CONNECTIONS=1000`

  `config :prometheus_sidecar, max_connections: 1000`
  """
  @spec max_connections() :: integer()
  def max_connections do
    "PROMETHEUS_SIDECAR_MAX_CONNECTIONS"
    |> env(:max_connections)
    |> to_number(@defaults[:max_connections])
  end

  @doc """
  Extra socket options that are merged into the ranch http configuration.

  See:
  * ranch's [TransportOpts](http://ninenines.eu/docs/en/ranch/1.6/manual/ranch.child_spec#_arguments) for `ranch:child_spec(3)`
  * ranch's [socket_opts](https://ninenines.eu/docs/en/ranch/1.6/manual/ranch#_opts)
  * [ranch_tcp](https://ninenines.eu/docs/en/ranch/1.7/manual/ranch_tcp#_opt) transport module options
  """
  @spec http() :: keyword()
  def http, do: Application.get_env(@app, :http, [])

  @doc """
  Extra socket options that are merged into the ranch https configuration.

  See:
  * ranch's [TransportOpts](http://ninenines.eu/docs/en/ranch/1.6/manual/ranch.child_spec#_arguments) for `ranch:child_spec(3)`
  * ranch's [socket_opts](https://ninenines.eu/docs/en/ranch/1.6/manual/ranch#_opts)
  * [:ranch_ssl](https://ninenines.eu/docs/en/ranch/1.7/manual/ranch_ssl#_ssl_opt) transport module options
  """
  @spec https() :: keyword()
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

  defp to_boolean(boolean) when is_boolean(boolean), do: boolean
  defp to_boolean("true"), do: true
  defp to_boolean(_), do: false
end
