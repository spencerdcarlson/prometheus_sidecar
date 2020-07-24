# PrometheusSidecar

Simple web server (ranch) that allows your application to be scraped by prometheus

## Installation

To install Prometheus Sidecar, just add an entry to your mix.exs:

```elixir
def deps do
  [
    {:prometheus_sidecar, "~> 0.1.0"}
  ]
end
```

## Configuration
By default, Prometheus Sidecar will start a simple non-secure (http) web server on [http://localhost:5001](http://localhost:5001) with
the following endpoints:
* [/metrics](http://localhost:5001/metrics) 
* [/available](http://localhost:5001/available) 
* [/health](http://localhost:5001/health) 

For advanced configuration you have the following options:

| System Env                            | Elixir config     | Default | Description                        |
| ------------------------------------- |-------------------| --------| ---------------------------------- |
| `PROMETHEUS_SIDECAR_PORT`             | `:port`           | `5001`  | Change the default port            |
| `PROMETHEUS_SIDECAR_ENABLE_SERVER`    | `:enable_server`  | `true`  | Do not start up the server. Similar to a `runtime: false` configuration, but allows for different values per environment. |
| `PROMETHEUS_SIDECAR_MAX_CONNECTIONS`  | `:max_connections`| `16_384`| Max connections. Same as [Plug.Cowboy's](https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html) `:transport_options` value |
|  N/A                                  | `:https`          | `[]`    | Enables HTTPS and expects cert files. |
For each option you can use either the System environment approach, or the elixir config approach:
```bash
PROMETHEUS_SIDECAR_PORT=5001
```
```elixir
config :prometheus_sidecar, port: 5001
```

## HTTPS
See the [HTTPS Guide](./guides/https.md)


