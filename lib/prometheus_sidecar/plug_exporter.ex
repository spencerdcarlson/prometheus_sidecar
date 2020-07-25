defmodule PrometheusSidecar.PlugExporter do
  @moduledoc """
  Plug to implement prometheus scraping requests.
  See [prometheus-plugs#exporting](https://github.com/deadtrickster/prometheus-plugs#exporting)
  """
  use Prometheus.PlugExporter
end
