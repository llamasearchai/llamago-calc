# 🦙 LlamaCalc - Secure gRPC Calculator Service

A secure, production-ready calculator service built with Go and gRPC, featuring mutual TLS authentication, role-based access control, and comprehensive monitoring.

## Features

- ✨ Secure gRPC communication with mTLS
- 🔒 Role-based access control (RBAC)
- 📊 Prometheus metrics integration
- 🚀 High-performance Go implementation
- 🧪 Comprehensive error handling
- 🦙 Llama-themed!

## Quick Start

### Running the Demo

The easiest way to run the demo is to use the provided script:

```bash
cd LlamaCalc
./run_demo.sh
```

This script will:
1. Check if a server is already running
2. Start a new server if needed
3. Run client commands for all operations
4. Clean up the server if it started one

### Manual Usage

#### Running the Server

```bash
cd LlamaCalc
go run cmd/basic_server/main.go
```

#### Running the Client

```bash
cd LlamaCalc
go run cmd/basic_client/main.go -op add -a 5 -b 3
```

Supported operations:
- `add` - Addition
- `subtract` - Subtraction
- `multiply` - Multiplication
- `divide` - Division

### Simple Calculator (without gRPC)

For a simple command-line calculator without gRPC:

```bash
cd LlamaCalc
go run cmd/simple/main.go add 5 3
```

## Project Structure

- `cmd/basic_server` - Basic gRPC server implementation
- `cmd/basic_client` - Basic gRPC client implementation
- `cmd/simple` - Simple command-line calculator
- `cmd/server` - Full-featured gRPC server with authentication and metrics
- `cmd/client` - Full-featured gRPC client with authentication
- `pkg/calculator` - Calculator business logic
- `pkg/auth` - Authentication and authorization
- `pkg/monitoring` - Prometheus metrics collector
- `proto` - Protocol buffer definitions

## Security

- mTLS for service-to-service authentication
- RBAC with different access levels
- Input validation and error handling
- Rate limiting and monitoring

## Monitoring

Access Prometheus metrics at http://localhost:9090/metrics

## License

MIT License 