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
    |> add_connection_drainer(@ranch_ref)
    |> add_ranch(@ranch_ref)
    |> Supervisor.start_link(strategy: :one_for_one, name: PrometheusSidecar.Supervisor)
  end

  defp add_ranch(children, reference) do
    if Env.enable_server?() do
      case ranch_args(reference) do
        {ref, transport, trans_opts, protocol, proto_opts} ->
          [:ranch.child_spec(ref, transport, trans_opts, protocol, proto_opts) | children]

        _ ->
          children
      end
    else
      children
    end
  end

  defp add_connection_drainer(children, ref) do
    if Env.enable_server?() do
      [{RanchConnectionDrainer, ranch_ref: ref, shutdown: 30_000} | children]
    else
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
           socket_opts: [port: Env.port()] |> Keyword.merge(Env.http())
         }, :cowboy_clear, protocol_opts()}

      :https ->
        {ref, :ranch_ssl,
         %{
           max_connections: Env.max_connections(),
           num_acceptors: 100,
           socket_opts:
             [
               alpn_preferred_protocols: ["h2", "http/1.1"],
               next_protocols_advertised: ["h2", "http/1.1"],
               reuse_sessions: true,
               secure_renegotiate: true,
               port: Env.port()
             ]
             |> Keyword.merge(Env.https())
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
    unless is_nil(Enum.find(:ranch.info(), fn {ref, _} -> ref == @ranch_ref end)) do
      # :ranch_server.get_addr/1 will raise and ArgumentError if the ref does not exist
      case :ranch_server.get_addr(@ranch_ref) do
        {host, port} ->
          Logger.info(
            "[prometheus_sidecar] Started a ranch Server running on #{
              to_string(:inet_parse.ntoa(host))
            }:#{inspect(port)}"
          )

        error ->
          Logger.error("[prometheus_sidecar] Error getting ranch server info. " <> inspect(error))
      end
    end

    :ok
  rescue
    _ -> :ok
  end

  def start_phase(:plug_exporter, _, _) do
    PrometheusSidecar.PlugExporter.setup()
    :ok
  rescue
    _ -> :ok
  end

  def start_phase(_, _, _), do: :ok
end
