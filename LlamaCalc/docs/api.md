# LlamaCalc API Documentation

This document describes the gRPC API provided by LlamaCalc, including request/response formats, error codes, and examples.

## Protocol Buffers Definition

LlamaCalc uses Protocol Buffers for defining the API contract. The full definition can be found in `proto/calculator.proto`.

```protobuf
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
```

## API Reference

### Add

Adds two numbers together.

**Request:**
```json
{
  "a": 5.0,
  "b": 3.0,
  "auth_token": "optional-jwt-token",
  "role": "optional-role-override"
}
```

**Response (Success):**
```json
{
  "result": 8.0,
  "status_code": 0,
  "error_message": "",
  "operation": "ADD"
}
```

**Access Control:** 
- Available to: Admin, User, Guest roles

**Error Codes:**
- `1`: Overflow detected
- `-1`: Authentication error

### Subtract

Subtracts the second number from the first.

**Request:**
```json
{
  "a": 10.0,
  "b": 4.0,
  "auth_token": "optional-jwt-token",
  "role": "optional-role-override"
}
```

**Response (Success):**
```json
{
  "result": 6.0,
  "status_code": 0,
  "error_message": "",
  "operation": "SUBTRACT"
}
```

**Access Control:** 
- Available to: Admin, User, Guest roles

**Error Codes:**
- `1`: Overflow detected
- `-1`: Authentication error

### Multiply

Multiplies two numbers together.

**Request:**
```json
{
  "a": 7.0,
  "b": 6.0,
  "auth_token": "optional-jwt-token",
  "role": "optional-role-override"
}
```

**Response (Success):**
```json
{
  "result": 42.0,
  "status_code": 0,
  "error_message": "",
  "operation": "MULTIPLY"
}
```

**Access Control:** 
- Available to: Admin, User roles
- Restricted from: Guest roles

**Error Codes:**
- `1`: Overflow detected
- `-1`: Authentication error
- `-2`: Authorization error

### Divide

Divides the first number by the second.

**Request:**
```json
{
  "a": 20.0,
  "b": 5.0,
  "auth_token": "optional-jwt-token",
  "role": "optional-role-override"
}
```

**Response (Success):**
```json
{
  "result": 4.0,
  "status_code": 0,
  "error_message": "",
  "operation": "DIVIDE"
}
```

**Response (Error - Division by Zero):**
```json
{
  "result": 0.0,
  "status_code": 2,
  "error_message": "division by zero",
  "operation": "DIVIDE"
}
```

**Access Control:** 
- Available to: Admin roles only
- Restricted from: User and Guest roles

**Error Codes:**
- `1`: Overflow detected
- `2`: Division by zero
- `3`: Invalid result (Infinity or NaN)
- `-1`: Authentication error
- `-2`: Authorization error

## Status Codes

LlamaCalc uses the following status codes in responses:

| Status Code | Description |
|-------------|-------------|
| 0 | Success - no error |
| 1 | Overflow error - calculation would result in overflow |
| 2 | Division by zero error |
| 3 | Invalid result (Infinity or NaN) |
| -1 | Authentication error - invalid or missing credentials |
| -2 | Authorization error - insufficient permissions for operation |
| -3 | Rate limit exceeded |
| -4 | Input validation error |
| -5 | System error |

## Authentication

LlamaCalc supports two authentication methods:

1. **Mutual TLS (mTLS)**: The preferred method for service-to-service communication. Client certificates are used to authenticate and authorize the client.

2. **JWT Tokens**: For cases where mTLS is not available, JWT tokens can be provided in the `auth_token` field. The token should be obtained through a separate authentication flow.

## Client Examples

### Go Client Example
```go
package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/yourusername/llamacalc/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

func main() {
	// Set up TLS credentials
	creds, err := credentials.NewClientTLSFromFile("ca.crt", "")
	if err != nil {
		log.Fatalf("Failed to load credentials: %v", err)
	}

	// Connect to server
	conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(creds))
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	// Create client
	client := proto.NewCalculatorClient(conn)

	// Prepare request
	req := &proto.CalculationRequest{
		A: 10,
		B: 5,
	}

	// Set timeout
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	// Call Add operation
	resp, err := client.Add(ctx, req)
	if err != nil {
		log.Fatalf("Call failed: %v", err)
	}

	fmt.Printf("Result: %v\n", resp.Result)
}
```

### Python Client Example
```python
import grpc
import calculator_pb2
import calculator_pb2_grpc

def run():
    # Create a secure channel
    with open('ca.crt', 'rb') as f:
        creds = grpc.ssl_channel_credentials(f.read())
    
    with grpc.secure_channel('localhost:50051', creds) as channel:
        # Create a stub (client)
        stub = calculator_pb2_grpc.CalculatorStub(channel)
        
        # Create a request
        request = calculator_pb2.CalculationRequest(a=10.0, b=5.0)
        
        # Make the call
        response = stub.Add(request)
        
        print(f"Result: {response.result}")

if __name__ == '__main__':
    run()
```

## Error Handling

Clients should always check the `status_code` field in the response. A non-zero value indicates an error occurred, and the `error_message` field will contain a description of the error. 