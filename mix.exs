defmodule PrometheusSidecar.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :prometheus_sidecar,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      description:
        "Simple web server (ranch) that allows your application to be scraped by prometheus",

      # Docs
      name: "Prometheus Sidecar",
      source_url: "https://github.com/spencerdcarlson/prometheus_sidecar",
      docs: docs()
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      files: ~w(CHANGELOG* config LICENSE* README* lib mix.exs priv .formatter.exs),
      links: %{
        "GitHub" => "https://github.com/spencerdcarlson/prometheus_sidecar"
      }
    ]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      main: "Overview",
      extras: ["guides/Overview.md", "guides/HTTPS.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:plug_cowboy, "~> 2.0"},
      {:ranch, "~> 1.7"},
      {:prometheus_plugs, "~> 1.1"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end
end
