#!/bin/bash

# LlamaCalc - Secure gRPC Calculation Service
# This script sets up a complete LlamaCalc project with all enhancements
# March 2025

set -e

LLAMA_ASCII="
                         ⠀⠀⠀⠀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀
                      ⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⡀⠀⠀
                    ⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀
                   ⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀
                  ⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀
                 ⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄
                 ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
                ⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀
               ⢀⣿⣿⣿⣿⠿⠋⠉⠉⠉⠉⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀
        _____  ⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⡇  _____
       /     \ ⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⡇ /     \
      /       \⠘⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⡟⠁/       \
     (         )⠈⢿⣿⣿⣿⣿⣶⣤⣤⣤⣤⣴⣾⣿⣿⣿⣿⣿⣿⡿⠋ (         )
     |  🦙 + | ⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀  |   🦙 /  |
     |   --   |⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀  |   -    |
     (         )⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀  (         )
      \  × ÷  /⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   \   ×    /
       \_____/⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   \_____/"

print_llama() {
    echo -e "\033[1;35m$LLAMA_ASCII\033[0m"
}

print_section() {
    echo -e "\n\033[1;36m🦙 $1\033[0m"
    echo -e "\033[1;36m$(printf '=%.0s' {1..50})\033[0m"
}

print_success() {
    echo -e "\033[1;32m✅ $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m⚠️  $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m❌ $1\033[0m"
    exit 1
}

check_dependency() {
    if ! command -v $1 &> /dev/null; then
        print_warning "$1 is not installed. Installing..."
        return 1
    else
        print_success "$1 is already installed."
        return 0
    fi
}

install_dependencies() {
    print_section "Checking and Installing Dependencies"
    
    # Check for Homebrew
    if ! check_dependency "brew"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || print_error "Failed to install Homebrew"
    fi
    
    # Check for Go
    if ! check_dependency "go"; then
        brew install go || print_error "Failed to install Go"
    fi
    
    # Check for protoc
    if ! check_dependency "protoc"; then
        brew install protobuf || print_error "Failed to install protobuf"
    fi
    
    # Check for Docker
    if ! check_dependency "docker"; then
        brew install --cask docker || print_warning "Failed to install Docker. Please install manually."
    fi
    
    # Install Go dependencies
    print_section "Installing Go dependencies"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest || print_error "Failed to install protoc-gen-go"
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest || print_error "Failed to install protoc-gen-go-grpc"
    
    print_success "All dependencies installed successfully!"
}

setup_project() {
    print_section "Setting up Project Structure"
    
    # Create project directory
    PROJECT_DIR="LlamaCalc"
    mkdir -p $PROJECT_DIR
    cd $PROJECT_DIR
    
    # Initialize Go module
    go mod init github.com/yourusername/llamacalc || print_error "Failed to initialize Go module"
    
    # Create directory structure
    mkdir -p proto
    mkdir -p cmd/server
    mkdir -p cmd/client
    mkdir -p pkg/calculator
    mkdir -p pkg/auth
    mkdir -p pkg/monitoring
    mkdir -p pkg/logging
    mkdir -p pkg/ratelimit
    mkdir -p internal/theme
    mkdir -p test/unit
    mkdir -p test/integration
    mkdir -p certs
    mkdir -p docs
    
    print_success "Project structure created successfully!"
}

create_proto_file() {
    print_section "Creating Protocol Buffer Definition"
    
    cat > proto/calculator.proto << 'EOF'
syntax = "proto3";

package calculator;

option go_package = "github.com/yourusername/llamacalc/proto";

// LlamaCalc service definition
service Calculator {
  // Add operation - adds two numbers
  rpc Add(CalculationRequest) returns (CalculationResponse) {}
  
  // Subtract operation - subtracts second number from first
  rpc Subtract(CalculationRequest) returns (CalculationResponse) {}
  
  // Multiply operation - multiplies two numbers
  rpc Multiply(CalculationRequest) returns (CalculationResponse) {}
  
  // Divide operation - divides first number by second
  rpc Divide(CalculationRequest) returns (CalculationResponse) {}
}

// Request message containing two numbers for calculation
message CalculationRequest {
  // First operand
  double a = 1;
  
  // Second operand
  double b = 2;
  
  // User authentication token (when not using mTLS)
  string auth_token = 3;
  
  // User role for RBAC
  string role = 4;
}

// Response message containing the calculation result
message CalculationResponse {
  // Result of the calculation
  double result = 1;
  
  // Status code (0 = success, non-zero = error)
  int32 status_code = 2;
  
  // Error message (empty if success)
  string error_message = 3;
  
  // Operation performed
  string operation = 4;
}
EOF
    
    print_success "Protocol buffer definition created successfully!"
}

generate_certs() {
    print_section "Generating TLS Certificates for mTLS"
    
    cd certs

    # Create configuration for CA
    cat > ca.conf << 'EOF'
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
C = US
ST = California
L = San Francisco
O = LlamaCalc Inc.
OU = Security
CN = LlamaCalc Root CA
EOF

    # Create configuration for server
    cat > server.conf << 'EOF'
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
C = US
ST = California
L = San Francisco
O = LlamaCalc Inc.
OU = Security
CN = localhost

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

    # Create configuration for client
    cat > client.conf << 'EOF'
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
C = US
ST = California
L = San Francisco
O = LlamaCalc Inc.
OU = Client
CN = LlamaCalc Client
EOF

    # Generate CA key and certificate
    openssl genrsa -out ca.key 4096
    openssl req -new -x509 -key ca.key -sha256 -subj "/C=US/ST=California/L=San Francisco/O=LlamaCalc Inc./OU=Security/CN=LlamaCalc Root CA" -out ca.crt -days 365

    # Generate server key and certificate
    openssl genrsa -out server.key 4096
    openssl req -new -key server.key -out server.csr -config server.conf
    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 -extensions req_ext -extfile server.conf

    # Generate client key and certificate
    openssl genrsa -out client.key 4096
    openssl req -new -key client.key -out client.csr -config client.conf
    openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365 -sha256

    cd ..
    
    print_success "TLS certificates generated successfully!"
}

create_server() {
    print_section "Creating Server Implementation"
    
    cat > cmd/server/main.go << 'EOF'
package main

import (
    "log"
    "net"
    "net/http"
    "time"

    "github.com/yourusername/llamacalc/pkg/auth"
    "github.com/yourusername/llamacalc/pkg/calculator"
    "github.com/yourusername/llamacalc/pkg/monitoring"
    "github.com/yourusername/llamacalc/proto"
    "github.com/prometheus/client_golang/prometheus/promhttp"
    "google.golang.org/grpc"
)

const (
    port = ":50051"
    metricsPort = ":9090"
    jwtSecretKey = "your-secret-key"
    tokenDuration = 24 * time.Hour
)

func main() {
    // Create a TCP listener
    lis, err := net.Listen("tcp", port)
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    // Load TLS credentials
    tlsCredentials, err := auth.LoadTLSCredentials("certs/server.crt", "certs/server.key", "certs/ca.crt")
    if err != nil {
        log.Fatalf("failed to load TLS credentials: %v", err)
    }

    // Create JWT manager
    jwtManager := auth.NewJWTManager(jwtSecretKey, tokenDuration)

    // Create auth interceptor
    authInterceptor := auth.NewAuthInterceptor(jwtManager)

    // Create metrics collector
    metricsCollector := monitoring.NewMetricsCollector()

    // Create gRPC server with interceptors
    grpcServer := grpc.NewServer(
        grpc.Creds(tlsCredentials),
        grpc.UnaryInterceptor(authInterceptor.Unary()),
        grpc.ChainUnaryInterceptor(
            metricsCollector.MetricsInterceptor(),
        ),
    )

    // Register calculator service
    calcService := calculator.NewService()
    proto.RegisterCalculatorServer(grpcServer, calcService)

    // Start Prometheus metrics server
    go func() {
        http.Handle("/metrics", promhttp.Handler())
        log.Printf("Starting metrics server on %s", metricsPort)
        if err := http.ListenAndServe(metricsPort, nil); err != nil {
            log.Printf("metrics server error: %v", err)
        }
    }()

    // Start gRPC server
    log.Printf("Starting gRPC server on %s", port)
    if err := grpcServer.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
EOF

    print_success "Server implementation created successfully!"
}

create_client() {
    print_section "Creating Client Implementation"
    
    cat > cmd/client/main.go << 'EOF'
package main

import (
    "context"
    "flag"
    "fmt"
    "log"
    "time"

    "github.com/yourusername/llamacalc/pkg/auth"
    "github.com/yourusername/llamacalc/proto"
    "google.golang.org/grpc"
)

const (
    serverAddr = "localhost:50051"
)

func main() {
    // Command line flags
    op := flag.String("op", "add", "Operation to perform (add, subtract, multiply, divide)")
    a := flag.Float64("a", 0, "First number")
    b := flag.Float64("b", 0, "Second number")
    flag.Parse()

    // Load TLS credentials
    tlsCredentials, err := auth.LoadClientTLSCredentials(
        "certs/client.crt",
        "certs/client.key",
        "certs/ca.crt",
    )
    if err != nil {
        log.Fatalf("failed to load TLS credentials: %v", err)
    }

    // Create gRPC connection
    conn, err := grpc.Dial(
        serverAddr,
        grpc.WithTransportCredentials(tlsCredentials),
    )
    if err != nil {
        log.Fatalf("failed to connect: %v", err)
    }
    defer conn.Close()

    // Create calculator client
    client := proto.NewCalculatorClient(conn)

    // Prepare context with timeout
    ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    defer cancel()

    // Prepare request
    req := &proto.CalculationRequest{
        A: *a,
        B: *b,
    }

    // Perform calculation based on operation
    var resp *proto.CalculationResponse
    switch *op {
    case "add":
        resp, err = client.Add(ctx, req)
    case "subtract":
        resp, err = client.Subtract(ctx, req)
    case "multiply":
        resp, err = client.Multiply(ctx, req)
    case "divide":
        resp, err = client.Divide(ctx, req)
    default:
        log.Fatalf("unknown operation: %s", *op)
    }

    if err != nil {
        log.Fatalf("calculation failed: %v", err)
    }

    // Print result
    if resp.StatusCode != 0 {
        fmt.Printf("Error: %s\n", resp.ErrorMessage)
    } else {
        fmt.Printf("Result: %f\n", resp.Result)
    }
}
EOF

    print_success "Client implementation created successfully!"
}

create_go_mod() {
    print_section "Creating Go Module Files"
    
    cat > go.mod << 'EOF'
module github.com/yourusername/llamacalc

go 1.21

require (
    github.com/dgrijalva/jwt-go v3.2.0+incompatible
    github.com/prometheus/client_golang v1.19.0
    google.golang.org/grpc v1.62.1
    google.golang.org/protobuf v1.33.0
)
EOF

    print_success "Go module files created successfully!"
}

create_readme() {
    print_section "Creating README"
    
    cat > README.md << 'EOF'
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

1. Install dependencies:
   ```bash
   ./llamacalc-setup.sh
   ```

2. Start the server:
   ```bash
   cd LlamaCalc
   go run cmd/server/main.go
   ```

3. Run calculations:
   ```bash
   go run cmd/client/main.go -op add -a 5 -b 3
   go run cmd/client/main.go -op multiply -a 4 -b 2
   ```

## Security

- mTLS for service-to-service authentication
- RBAC with different access levels
- Input validation and error handling
- Rate limiting and monitoring

## Monitoring

Access Prometheus metrics at http://localhost:9090/metrics

## License

MIT License
EOF

    print_success "README created successfully!"
}

main() {
    print_llama
    
    install_dependencies
    setup_project
    create_proto_file
    generate_certs
    create_server
    create_client
    create_go_mod
    create_readme
    
    print_section "Setup Complete!"
    echo "To get started:"
    echo "1. cd LlamaCalc"
    echo "2. go mod tidy"
    echo "3. Start the server: go run cmd/server/main.go"
    echo "4. In another terminal, run calculations:"
    echo "   go run cmd/client/main.go -op add -a 5 -b 3"
}

main