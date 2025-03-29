.PHONY: all build test clean docker-build docker-run lint proto proto-install tidy format bench coverage help

# Variables
GO := go
GOFLAGS := -ldflags="-w -s -X 'main.Version=$(shell git describe --tags --always)' -X 'main.BuildTime=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')'"
GOBUILD := $(GO) build $(GOFLAGS)
GOTEST := $(GO) test
GOCLEAN := $(GO) clean
BINARY_NAME := llamacalc
DOCKER_IMAGE := llamacalc:latest
COVERAGE_PROFILE := coverage.out

# Protobuf variables
PROTO_FILES := $(wildcard proto/*.proto)
PROTO_GO_FILES := $(patsubst proto/%.proto,pkg/proto/%.pb.go,$(PROTO_FILES))
PROTO_GRPC_FILES := $(patsubst proto/%.proto,pkg/proto/%_grpc.pb.go,$(PROTO_FILES))

# Default target
all: tidy format lint test build

# Build the binary
build:
	@echo "Building $(BINARY_NAME)..."
	$(GOBUILD) -o $(BINARY_NAME) ./cmd/server

# Run the tests
test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

# Clean build files
clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(COVERAGE_PROFILE)

# Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .

# Run Docker container
docker-run:
	@echo "Running Docker container..."
	docker run -p 50051:50051 $(DOCKER_IMAGE)

# Start Docker Compose environment
docker-compose-up:
	@echo "Starting Docker Compose environment..."
	docker-compose up -d

# Stop Docker Compose environment
docker-compose-down:
	@echo "Stopping Docker Compose environment..."
	docker-compose down

# Run linters
lint:
	@echo "Running linters..."
	golangci-lint run ./...

# Generate protobuf files
proto: proto-install $(PROTO_GO_FILES) $(PROTO_GRPC_FILES)

# Install protobuf tools
proto-install:
	@echo "Installing protobuf tools..."
	@if ! command -v protoc > /dev/null; then \
		echo "protoc not found. Please install it."; \
		exit 1; \
	fi
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generate protobuf Go files
pkg/proto/%.pb.go pkg/proto/%_grpc.pb.go: proto/%.proto
	@echo "Generating protobuf files from $<..."
	mkdir -p pkg/proto
	protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative $<

# Tidy go modules
tidy:
	@echo "Tidying Go modules..."
	$(GO) mod tidy

# Format code
format:
	@echo "Formatting code..."
	$(GO) fmt ./...

# Run benchmarks
bench:
	@echo "Running benchmarks..."
	$(GOTEST) -bench=. -benchmem ./...

# Generate test coverage
coverage:
	@echo "Generating test coverage..."
	$(GOTEST) -coverprofile=$(COVERAGE_PROFILE) ./...
	$(GO) tool cover -html=$(COVERAGE_PROFILE)

# Generate certificates for development
gen-certs:
	@echo "Generating certificates..."
	mkdir -p certs
	openssl req -x509 -newkey rsa:4096 -keyout certs/server.key -out certs/server.crt -days 365 -nodes -subj "/CN=localhost"

# Help
help:
	@echo "Available targets:"
	@echo "  all           : Format, lint, test, and build"
	@echo "  build         : Build the binary"
	@echo "  test          : Run tests"
	@echo "  clean         : Clean build files"
	@echo "  docker-build  : Build Docker image"
	@echo "  docker-run    : Run Docker container"
	@echo "  docker-compose-up   : Start Docker Compose environment"
	@echo "  docker-compose-down : Stop Docker Compose environment"
	@echo "  lint          : Run linters"
	@echo "  proto         : Generate protobuf files"
	@echo "  proto-install : Install protobuf tools"
	@echo "  tidy          : Tidy Go modules"
	@echo "  format        : Format code"
	@echo "  bench         : Run benchmarks"
	@echo "  coverage      : Generate test coverage"
	@echo "  gen-certs     : Generate certificates for development"
	@echo "  help          : Show this help message" 