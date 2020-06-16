defmodule PrometheusSidecar.MixProject do
  use Mix.Project

  def project do
    [
      app: :prometheus_sidecar,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PrometheusSidecar.Application, []},
      start_phases: [{:ranch, []}, {:plug_exporter, []}]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.3"},
      {:ranch, "~> 1.7"},
      {:prometheus_plugs, "~> 1.1"}
    ]
  end
end
