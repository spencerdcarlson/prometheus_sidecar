defmodule PrometheusSidecar.MixProject do
  use Mix.Project

  def project do
    [
      app: :prometheus_sidecar,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:prometheus_plugs, "~> 1.1"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
