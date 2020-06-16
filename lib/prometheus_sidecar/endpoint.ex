defmodule PrometheusSidecar.Endpoint do
  @moduledoc false

  use Plug.Router
  # Makes "/metrics" endpoint available.
  # This plug must come before :match and :dispatch otherwise it will attempt to handle all endpoints
  plug(PrometheusSidecar.PlugExporter)
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
