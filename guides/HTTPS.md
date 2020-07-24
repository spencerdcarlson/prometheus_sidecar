## Enable HTTPS

### Generate Self Signed Certs
```bash
openssl req -new -x509 -nodes -out dev.crt -keyout dev.key
```

```elixir
config :prometheus_sidecar,
  https: [
    keyfile: "/dev.key",
    certfile: "/dev.crt"
  ]
```

Or you can point to the [dev.key](../priv/dev.key) and [dev.key](../priv/dev.crt) file that ship with Prometheus Sidecar
```elixir
 config :prometheus_sidecar,
  https: [
    keyfile: "deps/prometheus_sidecar/priv/dev.key",
    certfile: "deps/prometheus_sidecar/priv/dev.crt"
  ]
```
_Note: that these certs are self signed certs for demo purposes only._

Anything passed into the `:https` option will be merged into [ranch's](https://ninenines.eu/docs/en/ranch/1.6/manual/ranch/) `socket_opts`

See all SSL [ranch configurations](https://ninenines.eu/docs/en/ranch/1.7/manual/ranch_ssl/) 