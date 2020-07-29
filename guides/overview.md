# Overview

A Simple web server (ranch) that allows your application to be scraped by prometheus

## Installation

To install Prometheus Sidecar, just add an entry to your mix.exs:

```elixir
def deps do
  [
    {:prometheus_sidecar, "~> 0.1"}
  ]
end
```

## Configuration
There are no required configurations. By default, Prometheus Sidecar will start a simple non-secure (http) web server on [http://localhost:5001](http://localhost:5001) with
the following endpoints:
* [/metrics](http://localhost:5001/metrics) 
* [/available](http://localhost:5001/available) 
* [/health](http://localhost:5001/health) 

### Advanced Configuration Options

| System Env                            | Elixir config     | Default | Description                        |
| ------------------------------------- |-------------------| --------| ---------------------------------- |
| `PROMETHEUS_SIDECAR_PORT`             | `:port`           | `5001`  | Change the default port.           |
| `PROMETHEUS_SIDECAR_ENABLE_SERVER`    | `:enable_server`  | `true`  | Do not start up the server.        |
| `PROMETHEUS_SIDECAR_MAX_CONNECTIONS`  | `:max_connections`| `16_384`| Max connections.                   |
|  N/A                                  | `:https`          | `[]`    | Enables HTTPS.                     |
For each option you can use either the System environment approach, or the elixir config approach:
```bash
PROMETHEUS_SIDECAR_PORT=5001
```
```elixir
config :prometheus_sidecar, port: 5001
```

See the `PrometheusSidecar.Env` module for more details.
 
### Prometheus Plugs Configuration 
Prometheus Sidecar internally uses [prometheus_plugs](https://hex.pm/packages/prometheus_plugs), which greatly
facilitates setting any [prometheus configurations](https://github.com/deadtrickster/prometheus.erl#configuration). 
See the [configuration documentation](https://hexdocs.pm/prometheus_plugs/Prometheus.PlugExporter.html#module-configuration)
for details.

Here is an example of how to change `/metrics` to `/stats` and require basic auth to access the endpoint
```elixir
config :prometheus, PrometheusSidecar.PlugExporter, 
  path: "/stats",
  format: :auto,
  registry: :default,
  auth: {:basic, "username", "password"}
``` 

_Note for the above changes to take effect, run `mix deps.clean prometheus_sidecar && mix deps.get`_

## HTTPS
See the [HTTPS Guide](./https.html)