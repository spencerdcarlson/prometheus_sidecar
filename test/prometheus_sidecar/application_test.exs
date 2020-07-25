defmodule Boxer.ApplicationTest do
  use ExUnit.Case, async: false

  @sup PrometheusSidecar.Supervisor

  describe "PrometheusSidecar.Application" do
    test "Starts PrometheusSidecar.Endpoint.HTTP before RanchConnectionDrainer" do
      # Supervisors shutdown their children in the reverse order of how they were started.
      #
      # When shutting down the `RanchConnectionDrainer` it calls the `PrometheusSidecar.Endpoint.HTTP`
      # so the `PrometheusSidecar.Endpoint.HTTP` can not be shutdown before the `RanchConnectionDrainer`.
      # Consequently, the `PrometheusSidecar.Endpoint.HTTP` must be started before the `RanchConnectionDrainer`
      endpoint_rank =
        @sup
        |> Supervisor.which_children()
        |> child_index({:ranch_listener_sup, PrometheusSidecar.Endpoint.HTTP})

      ranch_connection_drainer_rank =
        @sup
        |> Supervisor.which_children()
        |> child_index(RanchConnectionDrainer)

      refute is_nil(endpoint_rank)
      refute is_nil(ranch_connection_drainer_rank)
      assert endpoint_rank > ranch_connection_drainer_rank
    end
  end

  defp child_index(children, id) do
    Enum.find_index(children, fn {cid, _child, _type, _modules} -> cid == id end)
  end
end
