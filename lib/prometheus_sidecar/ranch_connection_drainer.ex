defmodule RanchConnectionDrainer do
  @moduledoc """
  Drains connections before shutting down.
  See the [ranch_connection_drainer](https://hex.pm/packages/ranch_connection_drainer)
  """

  use GenServer
  require Logger

  @spec child_spec(options :: keyword()) :: Supervisor.child_spec()
  def child_spec(options) when is_list(options) do
    id = Keyword.get(options, :id, __MODULE__)
    ranch_ref = Keyword.fetch!(options, :ranch_ref)
    shutdown = Keyword.fetch!(options, :shutdown)

    %{
      id: id,
      start: {__MODULE__, :start_link, [ranch_ref]},
      shutdown: shutdown
    }
  end

  @doc false
  def start_link(ranch_ref) do
    GenServer.start_link(__MODULE__, ranch_ref, name: :"#{ranch_ref}.Drainer")
  end

  @doc false
  def init(ranch_ref) do
    Process.flag(:trap_exit, true)
    {:ok, ranch_ref}
  end

  def terminate(_reason, ranch_ref) do
    Logger.info("Suspending listener #{inspect(ranch_ref)}")
    :ok = :ranch.suspend_listener(ranch_ref)
    Logger.info("Waiting for connections to drain for listener #{inspect(ranch_ref)}...")
    :ok = :ranch.wait_for_connections(ranch_ref, :==, 0)
    Logger.info("Connections successfully drained for listener #{inspect(ranch_ref)}")
  end
end
