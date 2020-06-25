defmodule PrometheusSidecar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias PrometheusSidecar.Env
  @ranch_ref PrometheusSidecar.Endpoint.HTTP
  require Logger

  def start(_type, _args) do
    []
    |> add_ranch(@ranch_ref)
    |> Supervisor.start_link(strategy: :one_for_one, name: PrometheusSidecar.Supervisor)
  end

  defp add_ranch(children, reference) do
    case ranch_args(reference) do
      {ref, transport, trans_opts, protocol, proto_opts} ->
        [:ranch.child_spec(ref, transport, trans_opts, protocol, proto_opts) | children]

      _ ->
        children
    end
  end

  defp ranch_args(ref) do
    # builds the arguments for :ranch.child_spec/5
    # These settings were copied from plug_cowboy
    # See:
    #  https://github.com/elixir-plug/plug_cowboy/blob/2fb3285ea8f0e5302a5ab2b62abf9bab797c9b98/lib/plug/cowboy.ex#L173
    case Env.scheme() do
      :http ->
        {ref, :ranch_tcp,
         %{
           max_connections: Env.max_connections(),
           num_acceptors: 100,
           socket_opts: [port: Env.port()]
         }, :cowboy_clear, protocol_opts()}

      :https ->
        {ref, :ranch_ssl,
         %{
           max_connections: Env.max_connections(),
           num_acceptors: 100,
           socket_opts: [
             port: Env.port(),
             next_protocols_advertised: ["h2", "http/1.1"],
             alpn_preferred_protocols: ["h2", "http/1.1"]
           ]
         }, :cowboy_tls, protocol_opts()}
    end
  end

  defp protocol_opts do
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
