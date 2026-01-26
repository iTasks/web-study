.PHONY: help run run-prod test bench clean install fmt vet docker-build docker-run

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	go mod download
	go mod tidy

run: ## Run basic server
	go run main.go

run-prod: ## Run production server with all features
	go run production_server.go monitoring.go tracing.go

test: ## Run tests
	go test -v -cover

bench: ## Run benchmarks
	go test -bench=. -benchmem

fmt: ## Format code
	go fmt ./...

vet: ## Run go vet
	go vet ./...

clean: ## Clean build artifacts
	rm -f server
	go clean

build: ## Build server binary
	go build -o server production_server.go monitoring.go tracing.go

docker-build: ## Build Docker image
	docker build -t echo-server:latest .

docker-run: ## Run Docker container
	docker run -p 8080:8080 echo-server:latest

check: fmt vet test ## Run all checks (format, vet, test)

.DEFAULT_GOAL := help
