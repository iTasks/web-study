# Wallet Kafka-Stream Consumers App (Legacy)

[← Back to src](../../../readme.md) | [Main README](../../../../README.md)

## Dependencies
1. [Golang](https://golang.org/)
2. [Echo](https://echo.labstack.com/guide/installation/)
3. [Kafka — Goka](https://github.com/lovoo/goka) + [Sarama](https://github.com/Shopify/sarama)
4. [PostgreSQL — go-pg](https://github.com/go-pg/pg) + [embedded-postgres](https://github.com/fergusstrange/embedded-postgres)
5. [Impala — go-impala](https://github.com/bippio/go-impala) + [impyla](https://github.com/cloudera/impyla)
6. [Kudu](https://kudu.apache.org/docs/developing.html)
7. [Protobuf](https://developers.google.com/protocol-buffers/docs/gotutorial)
8. [Swagger — swag](https://github.com/swaggo/swag)

## Services
1. `core-bridge`
2. `core-stream`
3. `analytics` — python
4. `reporting` — python

## Local Run
1. Generate proto.go: `protoc --proto_path=. --go_out=:. --grpc-go_out=:. proto/wallet.proto`
   Generate proto.py: `python -m grpc_tools.protoc -Iproto --python_out=proto --grpc_python_out=proto/ proto/wallet_bridge.proto`
2. Move to directory: `cd $GOPATH/$service-dir`
3. Run go file: `go run $service-file.go`

## Docker Run
- [Golang Docker Image](https://hub.docker.com/_/golang)

1. Move to directory: `cd $GOPATH/$service-dir`
2. Docker build: `docker build -t $app-service-name`
3. Docker run: `docker run -it --rm --name $app-running-service $app-service-name`

## Structure
```
commchat --> wallet-bridge --> upay-api -->
                             |--> kafka-stream --> wallet-db (audit-tail, account-info, journal, ledger)
                                              |--> analytic-db (statistics, history, audit-tail-summary, reporting)
                                              |--> tcash-app (blockchain, audit-tail)
```

### Sequence
![High level calling sequence](uml/third-party-integration-sequence.png)
