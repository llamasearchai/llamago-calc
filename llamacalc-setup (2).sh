print_success "Docker Compose file created successfully!"

create_readme() {
    print_section "Creating README.md"
    
    cat > README.md << 'EOF'
# 🦙 LlamaCalc - Secure gRPC Calculation Service

LlamaCalc is a cutting-edge, Llama-themed Golang gRPC service that provides simple calculation operations with a strong focus on API security. This project addresses modern concerns about API vulnerabilities by implementing robust security measures.

<p align="center">
  <img src="https://raw.githubusercontent.com/yourname/llamacalc/main/docs/llamacalc_logo.png" alt="LlamaCalc Logo" width="300"/>
</p>

## 🔑 Key Features

- **Secure gRPC Communication**: Implements mutual TLS (mTLS) for strong authentication and encryption
- **Role-Based Access Control (RBAC)**: Restricts access to operations based on user roles
- **Input Validation**: Prevents vulnerabilities like division by zero and integer overflow
- **Rate Limiting**: Protects against denial-of-service attacks
- **Comprehensive Logging**: Records all requests and responses for auditing
- **Monitoring**: Integration with Prometheus and Grafana for real-time metrics
- **Fun Llama Theme**: Because who doesn't love llamas? 🦙

## 🏗️ Architecture

LlamaCalc follows a client-server architecture using gRPC for communication:

```
┌─────────────┐     gRPC/mTLS     ┌──────────────┐
│ LlamaCalc   │<------------------>│ LlamaCalc    │
│ Client      │                    │ Server       │
└─────────────┘                    └──────────────┘
                                          │
                                          │ Prometheus
                                          ▼
                                   ┌──────────────┐
                                   │ Monitoring   │
                                   │ Dashboard    │
                                   └──────────────┘
```

### Security Architecture

- **Authentication**: mTLS for service-to-service authentication
- **Authorization**: RBAC based on client certificates and JWT tokens
- **Encryption**: TLS 1.3 for all communications
- **API Security**: Input validation, rate limiting, and comprehensive error handling#!/bin/bash

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
       \_____/⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   \_____/
"

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

generate_grpc_code() {
    print_section "Generating gRPC Code from Proto Definition"
    
    # Make sure GOPATH/bin is in PATH
    export PATH="$PATH:$(go env GOPATH)/bin"
    
    # Generate Go code from proto file
    protoc --go_out=. --go_opt=paths=source_relative \
        --go-grpc_out=. --go-grpc_opt=paths=source_relative \
        proto/calculator.proto || print_error "Failed to generate gRPC code"
    
    print_success "gRPC code generated successfully!"
}

create_calculator_package() {
    print_section "Creating Calculator Package"
    
    cat > pkg/calculator/calculator.go << 'EOF'
// Package calculator provides the core calculation functionality for LlamaCalc
package calculator

import (
	"context"
	"errors"
	"fmt"
	"math"
	"time"

	"github.com/yourusername/llamacalc/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Operation type
type Operation string

// Operation constants
const (
	OpAdd      Operation = "ADD"
	OpSubtract Operation = "SUBTRACT"
	OpMultiply Operation = "MULTIPLY"
	OpDivide   Operation = "DIVIDE"
)

// Service implements the Calculator gRPC service
type Service struct {
	proto.UnimplementedCalculatorServer
}

// NewService creates a new calculator service
func NewService() *Service {
	return &Service{}
}

// Add implements the Add RPC method
func (s *Service) Add(ctx context.Context, req *proto.CalculationRequest) (*proto.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for potential overflow
	if (req.A > 0 && req.B > math.MaxFloat64-req.A) || (req.A < 0 && req.B < -math.MaxFloat64-req.A) {
		return &proto.CalculationResponse{
			Result:       0,
			StatusCode:   1,
			ErrorMessage: "overflow detected in addition operation",
			Operation:    string(OpAdd),
		}, nil
	}

	result := req.A + req.B

	return &proto.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpAdd),
	}, nil
}

// Subtract implements the Subtract RPC method
func (s *Service) Subtract(ctx context.Context, req *proto.CalculationRequest) (*proto.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for potential overflow
	if (req.A > 0 && req.B < req.A-math.MaxFloat64) || (req.A < 0 && req.B > req.A+math.MaxFloat64) {
		return &proto.CalculationResponse{
			Result:       0,
			StatusCode:   1,
			ErrorMessage: "overflow detected in subtraction operation",
			Operation:    string(OpSubtract),
		}, nil
	}

	result := req.A - req.B

	return &proto.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpSubtract),
	}, nil
}

// Multiply implements the Multiply RPC method
func (s *Service) Multiply(ctx context.Context, req *proto.CalculationRequest) (*proto.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for potential overflow
	absA, absB := math.Abs(req.A), math.Abs(req.B)
	if absA > 1 && absB > math.MaxFloat64/absA {
		return &proto.CalculationResponse{
			Result:       0,
			StatusCode:   1,
			ErrorMessage: "overflow detected in multiplication operation",
			Operation:    string(OpMultiply),
		}, nil
	}

	result := req.A * req.B

	return &proto.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpMultiply),
	}, nil
}

// Divide implements the Divide RPC method
func (s *Service) Divide(ctx context.Context, req *proto.CalculationRequest) (*proto.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for division by zero
	if req.B == 0 {
		return &proto.CalculationResponse{
			Result:       0,
			StatusCode:   2,
			ErrorMessage: "division by zero",
			Operation:    string(OpDivide),
		}, nil
	}

	result := req.A / req.B

	// Check for infinity or NaN
	if math.IsInf(result, 0) || math.IsNaN(result) {
		return &proto.CalculationResponse{
			Result:       0,
			StatusCode:   3,
			ErrorMessage: fmt.Sprintf("invalid result: %v", result),
			Operation:    string(OpDivide),
		}, nil
	}

	return &proto.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpDivide),
	}, nil
}

// Validate validates the request parameters for any calculation operation
func Validate(req *proto.CalculationRequest) error {
	// Check for NaN or infinity
	if math.IsNaN(req.A) || math.IsInf(req.A, 0) {
		return errors.New("first operand is NaN or infinity")
	}
	if math.IsNaN(req.B) || math.IsInf(req.B, 0) {
		return errors.New("second operand is NaN or infinity")
	}
	return nil
}
EOF
    
    print_success "Calculator package created successfully!"
}

create_auth_package() {
    print_section "Creating Authentication Package"
    
    cat > pkg/auth/auth.go << 'EOF'
// Package auth provides authentication and authorization functionality for LlamaCalc
package auth

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"io/ioutil"

	"github.com/yourusername/llamacalc/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
)

// Role represents a user role for RBAC
type Role string

// Role constants
const (
	RoleAdmin  Role = "ADMIN"
	RoleUser   Role = "USER"
	RoleGuest  Role = "GUEST"
	RoleDenied Role = "DENIED"
)

// Operation represents a calculator operation
type Operation string

// Operation constants
const (
	OpAdd      Operation = "ADD"
	OpSubtract Operation = "SUBTRACT"
	OpMultiply Operation = "MULTIPLY"
	OpDivide   Operation = "DIVIDE"
)

// AuthInterceptor is a server interceptor for authentication and authorization
type AuthInterceptor struct {
	jwtManager      *JWTManager
	accessibleRoles map[string][]string
}

// NewAuthInterceptor creates a new auth interceptor
func NewAuthInterceptor(jwtManager *JWTManager) *AuthInterceptor {
	accessibleRoles := map[string][]string{
		"/calculator.Calculator/Add":      {string(RoleAdmin), string(RoleUser), string(RoleGuest)},
		"/calculator.Calculator/Subtract": {string(RoleAdmin), string(RoleUser), string(RoleGuest)},
		"/calculator.Calculator/Multiply": {string(RoleAdmin), string(RoleUser)},
		"/calculator.Calculator/Divide":   {string(RoleAdmin)},
	}

	return &AuthInterceptor{
		jwtManager:      jwtManager,
		accessibleRoles: accessibleRoles,
	}
}

// Unary returns a server interceptor function to authenticate and authorize unary RPC
func (interceptor *AuthInterceptor) Unary() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		// Check if the method requires authentication
		if !interceptor.isAccessible(info.FullMethod, RoleGuest) {
			return nil, status.Errorf(codes.PermissionDenied, "no permission to access this RPC")
		}

		// Get client role from context (mTLS) or JWT token
		role, err := interceptor.authorize(ctx, info.FullMethod)
		if err != nil {
			return nil, err
		}

		// Check if the role has access to the method
		if !interceptor.isAccessible(info.FullMethod, role) {
			return nil, status.Errorf(codes.PermissionDenied, "no permission to access this RPC")
		}

		// Continue execution of the RPC
		return handler(ctx, req)
	}
}

// authorize checks whether the client is authorized to call the method
func (interceptor *AuthInterceptor) authorize(ctx context.Context, method string) (Role, error) {
	// First try to get role from client certificate
	role, err := getRoleFromCert(ctx)
	if err == nil {
		return role, nil
	}

	// If cert-based auth fails, try JWT auth
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return RoleDenied, status.Errorf(codes.Unauthenticated, "metadata is not provided")
	}

	values := md["authorization"]
	if len(values) == 0 {
		return RoleDenied, status.Errorf(codes.Unauthenticated, "authorization token is not provided")
	}

	accessToken := values[0]
	claims, err := interceptor.jwtManager.Verify(accessToken)
	if err != nil {
		return RoleDenied, status.Errorf(codes.Unauthenticated, "access token is invalid: %v", err)
	}

	return Role(claims.Role), nil
}

// isAccessible checks if the role has access to the method
func (interceptor *AuthInterceptor) isAccessible(method string, role Role) bool {
	if len(interceptor.accessibleRoles[method]) == 0 {
		return true // Method is publicly accessible
	}

	for _, r := range interceptor.accessibleRoles[method] {
		if r == string(role) {
			return true
		}
	}

	return false
}

// getRoleFromCert extracts the role from the client certificate
func getRoleFromCert(ctx context.Context) (Role, error) {
	p, ok := peer.FromContext(ctx)
	if !ok {
		return RoleDenied, errors.New("no peer found")
	}

	mtls, ok := p.AuthInfo.(credentials.TLSInfo)
	if !ok {
		return RoleDenied, errors.New("not a TLS connection")
	}

	if len(mtls.State.VerifiedChains) == 0 || len(mtls.State.VerifiedChains[0]) == 0 {
		return RoleDenied, errors.New("no verified client certificate")
	}

	// Extract OU field from client certificate as role
	// In a real-world application, this would be more sophisticated
	clientCert := mtls.State.VerifiedChains[0][0]
	
	// Default to user role
	role := RoleUser
	
	for _, ou := range clientCert.Subject.OrganizationalUnit {
		switch ou {
		case "Admin":
			role = RoleAdmin
		case "Guest":
			role = RoleGuest
		}
	}

	return role, nil
}

// LoadTLSCredentials loads TLS credentials for mTLS
func LoadTLSCredentials(serverCertFile, serverKeyFile, caCertFile string) (credentials.TransportCredentials, error) {
	// Load certificate of the CA who signed client's certificate
	pemClientCA, err := ioutil.ReadFile(caCertFile)
	if err != nil {
		return nil, err
	}

	certPool := x509.NewCertPool()
	if !certPool.AppendCertsFromPEM(pemClientCA) {
		return nil, errors.New("failed to add client CA's certificate")
	}

	// Load server's certificate and private key
	serverCert, err := tls.LoadX509KeyPair(serverCertFile, serverKeyFile)
	if err != nil {
		return nil, err
	}

	// Create the credentials and return it
	config := &tls.Config{
		Certificates: []tls.Certificate{serverCert},
		ClientAuth:   tls.RequireAndVerifyClientCert,
		ClientCAs:    certPool,
		MinVersion:   tls.VersionTLS13,
	}

	return credentials.NewTLS(config), nil
}

// LoadClientTLSCredentials loads TLS credentials for mTLS client
func LoadClientTLSCredentials(clientCertFile, clientKeyFile, caCertFile string) (credentials.TransportCredentials, error) {
	// Load certificate of the CA who signed server's certificate
	pemServerCA, err := ioutil.ReadFile(caCertFile)
	if err != nil {
		return nil, err
	}

	certPool := x509.NewCertPool()
	if !certPool.AppendCertsFromPEM(pemServerCA) {
		return nil, errors.New("failed to add server CA's certificate")
	}

	// Load client's certificate and private key
	clientCert, err := tls.LoadX509KeyPair(clientCertFile, clientKeyFile)
	if err != nil {
		return nil, err
	}

	// Create the credentials and return it
	config := &tls.Config{
		Certificates: []tls.Certificate{clientCert},
		RootCAs:      certPool,
		MinVersion:   tls.VersionTLS13,
	}

	return credentials.NewTLS(config), nil
}
EOF

    cat > pkg/auth/jwt.go << 'EOF'
package auth

import (
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
)

// JWTManager is a JSON web token manager
type JWTManager struct {
	secretKey     string
	tokenDuration time.Duration
}

// UserClaims contains user claims data
type UserClaims struct {
	jwt.StandardClaims
	Username string `json:"username"`
	Role     string `json:"role"`
}

// NewJWTManager returns a new JWT manager
func NewJWTManager(secretKey string, tokenDuration time.Duration) *JWTManager {
	return &JWTManager{secretKey, tokenDuration}
}

// Generate generates and signs a new token for a user
func (manager *JWTManager) Generate(username string, role string) (string, error) {
	claims := UserClaims{
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(manager.tokenDuration).Unix(),
		},
		Username: username,
		Role:     role,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(manager.secretKey))
}

// Verify verifies the access token string and returns a user claim if the token is valid
func (manager *JWTManager) Verify(accessToken string) (*UserClaims, error) {
	token, err := jwt.ParseWithClaims(
		accessToken,
		&UserClaims{},
		func(token *jwt.Token) (interface{}, error) {
			_, ok := token.Method.(*jwt.SigningMethodHMAC)
			if !ok {
				return nil, fmt.Errorf("unexpected token signing method")
			}

			return []byte(manager.secretKey), nil
		},
	)

	if err != nil {
		return nil, fmt.Errorf("invalid token: %w", err)
	}

	claims, ok := token.Claims.(*UserClaims)
	if !ok {
		return nil, fmt.Errorf("invalid token claims")
	}

	return claims, nil
}
EOF
    
    print_success "Authentication package created successfully!"
}

create_monitoring_package() {
    print_section "Creating Monitoring Package"
    
    cat > pkg/monitoring/monitoring.go << 'EOF'
// Package monitoring provides Prometheus-based monitoring for LlamaCalc
package monitoring

import (
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

// MetricsCollector collects metrics for the Calculator service
type MetricsCollector struct {
	requestCounter     *prometheus.CounterVec
	errorCounter       *prometheus.CounterVec
	responseTimeMetric *prometheus.HistogramVec
}

// NewMetricsCollector creates a new metrics collector
func NewMetricsCollector() *MetricsCollector {
	const namespace = "llamacalc"
	const subsystem = "grpc"

	requestCounter := promauto.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: namespace,
			Subsystem: subsystem,
			Name:      "requests_total",
			Help:      "Total number of gRPC requests",
		},
		[]string{"method", "operation"},
	)

	errorCounter := promauto.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: namespace,
			Subsystem: subsystem,
			Name:      "errors_total",
			Help:      "Total number of gRPC errors",
		},
		[]string{"method", "operation", "error_code"},
	)

	responseTimeMetric := promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Namespace: namespace,
			Subsystem: subsystem,
			Name:      "response_time_seconds",
			Help:      "Response time of gRPC requests in seconds",
			Buckets:   prometheus.DefBuckets,
		},
		[]string{"method", "operation"},
	)

	return &MetricsCollector{
		requestCounter:     requestCounter,
		errorCounter:       errorCounter,
		responseTimeMetric: responseTimeMetric,
	}
}

// RecordRequest records a request metric
func (c *MetricsCollector) RecordRequest(method, operation string) {
	c.requestCounter.WithLabelValues(method, operation).Inc()
}

// RecordError records an error metric
func (c *MetricsCollector) RecordError(method, operation string, errorCode int32) {
	c.errorCounter.WithLabelValues(method, operation, string(rune(errorCode))).Inc()
}

// RecordResponseTime records the response time for a request
func (c *MetricsCollector) RecordResponseTime(method, operation string, duration time.Duration) {
	c.responseTimeMetric.WithLabelValues(method, operation).Observe(duration.Seconds())
}

// MetricsInterceptor creates a gRPC interceptor for collecting metrics
func (c *MetricsCollector) MetricsInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		method := info.FullMethod
		
		// Extract operation from request if it's a CalculationRequest
		operation := "UNKNOWN"
		if calcReq, ok := req.(*proto.CalculationRequest); ok {
			// Infer operation from method name
			switch {
			case strings.Contains(method, "Add"):
				operation = "ADD"
			case strings.Contains(method, "Subtract"):
				operation = "SUBTRACT"
			case strings.Contains(method, "Multiply"):
				operation = "MULTIPLY"
			case strings.Contains(method, "Divide"):
				operation = "DIVIDE"
			}
		}
		
		c.RecordRequest(method, operation)
		startTime := time.Now()
		
		// Call the RPC method
		resp, err := handler(ctx, req)
		
		// Record response time
		duration := time.Since(startTime)
		c.RecordResponseTime(method, operation, duration)
		
		// Record error if any
		if err != nil {
			st, ok := status.FromError(err)
			if ok {
				c.RecordError(method, operation, int32(st.Code()))
			} else {
				c.RecordError(method, operation, -1) // Unknown error
			}
		} else if calcResp, ok := resp.(*proto.CalculationResponse); ok && calcResp.StatusCode != 0 {
			c.RecordError(method, operation, calcResp.StatusCode)
		}
		
		return resp, err
	}
}
EOF