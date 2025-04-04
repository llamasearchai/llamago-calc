# 🦙 LlamaCalc - Enterprise gRPC Calculator Service

<div align="center">
  
![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![gRPC](https://img.shields.io/badge/gRPC-Ready-00b8d4?style=for-the-badge&logo=google&logoColor=white)
![Security](https://img.shields.io/badge/Security-Hardened-brightgreen?style=for-the-badge&logo=letsencrypt&logoColor=white)
![GitHub stars](https://img.shields.io/github/stars/yourusername/llamacalc?style=for-the-badge&logo=github)
![MIT License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)

</div>

<p align="center">
  <em>A high-performance, enterprise-grade, secure gRPC-based calculator service built with Go.</em>
</p>

<img src="docs/llamacalc_architecture.png" alt="LlamaCalc Architecture" width="100%">

## 🌟 Key Features

- **High-Performance Calculations**: Optimized for speed and efficiency
- **Enterprise-Grade Security**:
  - Mutual TLS (mTLS) authentication
  - JWT-based authentication as fallback
  - Role-Based Access Control (RBAC)
  - Input validation and sanitization
- **Observability First**:
  - Prometheus metrics integration
  - Structured logging with correlation IDs
  - Distributed tracing with OpenTelemetry
- **Resilience Built-in**:
  - Rate limiting protection
  - Comprehensive error handling
  - Timeouts and circuit breaking
- **Developer Experience**:
  - Clean, maintainable codebase
  - Exhaustive test coverage
  - Comprehensive documentation
  - Docker and docker-compose ready

## 🚀 Quick Start

### Running with Management Script

The easiest way to interact with LlamaCalc is via the management script:

```bash
# Start the server daemon
./manage.sh start

# Run a demo of all operations
./manage.sh demo

# Check server status
./manage.sh status

# Restart the server
./manage.sh restart

# Stop the server
./manage.sh stop
```

### Docker Support

```bash
# Build and run with Docker
docker-compose up -d

# Run a specific calculator operation
docker-compose exec client ./client -op add -a 5 -b 3
```

## 📊 Project Structure

```
LlamaCalc/
├── cmd/                  # Command-line applications
│   ├── basic_server/     # Simplified server implementation
│   ├── basic_client/     # Simplified client implementation  
│   ├── server/           # Production-grade server with all features
│   ├── client/           # Full-featured command-line client
│   └── simple/           # Simple command-line calculator (no gRPC)
├── pkg/                  # Library packages
│   ├── calculator/       # Core calculation logic
│   ├── auth/             # Authentication and authorization
│   ├── monitoring/       # Prometheus metrics collection
│   ├── logging/          # Structured logging
│   └── ratelimit/        # Rate limiting implementation
├── proto/                # Protocol buffer definitions
├── certs/                # TLS certificates for secure communication
├── test/                 # Integration and unit tests
│   ├── integration/      # Integration tests
│   └── unit/             # Unit tests
├── docs/                 # Documentation and design diagrams
└── scripts/              # Utility scripts
```

## 🔐 Security

LlamaCalc implements multiple layers of security:

1. **Network Security**: All communications are encrypted using TLS 1.3
2. **Authentication**:
   - Mutual TLS (mTLS) for service-to-service authentication
   - JWT tokens for user authentication
3. **Authorization**: Role-Based Access Control with three levels:
   - Admin: Full access to all operations
   - User: Access to Add, Subtract, and Multiply operations
   - Guest: Access to Add and Subtract operations only
4. **Input Validation**: All inputs are validated to prevent overflow, underflow, and other calculation errors

## 📈 Monitoring

LlamaCalc exports Prometheus metrics on port 9090, including:
- Request counts and rates
- Error rates by operation type
- Response time histograms
- Resource utilization metrics

## 🧪 Testing

LlamaCalc includes comprehensive tests:

```bash
# Run all tests
go test -v ./...

# Run unit tests only
go test -v ./test/unit/...

# Run integration tests
go test -v ./test/integration/...

# Check test coverage
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## 📋 API Documentation

| Operation | Description | Access Level |
|-----------|-------------|--------------|
| Add       | Add two numbers | Admin, User, Guest |
| Subtract  | Subtract second number from first | Admin, User, Guest |
| Multiply  | Multiply two numbers | Admin, User |
| Divide    | Divide first number by second | Admin only |

## 🔧 Implementation Details

- **Error Handling**: Comprehensive error handling with appropriate error codes
- **Validation**: Input validation to protect against invalid inputs
- **Performance**: Optimized for high throughput with minimal resource utilization
- **Code Quality**: Clean, well-documented code following Go best practices

## 📚 Additional Resources

- [Architecture Decision Records](docs/adr/)
- [API Documentation](docs/api.md)
- [Security Model](docs/security.md)
- [Performance Benchmarks](docs/performance.md)

## 👨‍💻 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
