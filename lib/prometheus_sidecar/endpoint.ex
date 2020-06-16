defmodule PrometheusSidecar.Endpoint do
  @moduledoc false

  use Plug.Router
  # Makes "/metrics" endpoint available.
  # This plug must come before :match and :dispatch otherwise it will attempt to handle all endpoints
  # See https://hexdocs.pm/prometheus_plugs/Prometheus.PlugExporter.html#content on how to configure
  # a custom endpoint or basic auth
  plug(PrometheusSidecar.PlugExporter)

  # These make the below routes available
  plug(:match)
  plug(:dispatch)

  get "/available" do
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, "{}")
  end

  get "/health" do
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, "{}")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
