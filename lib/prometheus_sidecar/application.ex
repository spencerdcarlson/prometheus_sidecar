defmodule PrometheusSidecar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @ranch_ref PrometheusSidecar.Endpoint.HTTP
  require Logger

  def start(_type, _args) do
    children = [
      :ranch.child_spec(@ranch_ref, :ranch_tcp, transport_opts(), :cowboy_clear, proto_opts())
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PrometheusSidecar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp transport_opts do
    %{max_connections: 16384, num_acceptors: 100, socket_opts: [port: 5001]}
  end

  defp proto_opts do
    %{
      env: %{
        dispatch: [
          {:_, [], [{:_, [], Plug.Cowboy.Handler, {PrometheusSidecar.Endpoint, {:ok, []}}}]}
        ]
      },
      stream_handlers: [Plug.Cowboy.Stream]
    }
  end

  def start_phase(:ranch, _, _) do
    case :ranch_server.get_addr(@ranch_ref) do
      {host, port} ->
        Logger.info(
          "Ranch Server is running on #{to_string(:inet_parse.ntoa(host))}:#{inspect(port)}"
        )

      error ->
        Logger.error("Error getting ranch server info. " <> inspect(error))
    end

    :ok
  end

  def start_phase(:plug_exporter, _, _) do
    PrometheusSidecar.PlugExporter.setup()
    :ok
  end

  def start_phase(_, _, _), do: :ok
end
