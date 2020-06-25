## SSL

### Generated Self Signed Certs
```bash
openssl req -new -x509 -nodes -out dev.crt -keyout dev.key
```

```elixir
config :prometheus_sidecar,
  https: [
    keyfile: "#{priv_dir}/dev.key",
    certfile: "#{priv_dir}/dev.crt"
  ]
```

All SSL configs
https://ninenines.eu/docs/en/ranch/1.7/manual/ranch_ssl/