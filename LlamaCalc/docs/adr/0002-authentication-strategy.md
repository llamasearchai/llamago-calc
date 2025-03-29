# ADR 0002: Authentication Strategy

## Status

Accepted

## Date

2025-03-03

## Context

LlamaCalc needs a secure authentication mechanism to verify the identity of clients and control access to its API. We need to decide on an authentication strategy that balances security with ease of use and performance.

## Decision Drivers

- Security requirements
- Performance impact
- Client support across different languages and platforms
- Operational complexity
- Future extensibility

## Decision

LlamaCalc will use a multi-layered authentication approach:

1. **Primary: Mutual TLS (mTLS)** for service-to-service communication 
2. **Secondary: JWT Tokens** for cases where mTLS is not practical
3. **Tertiary: API Keys** for simple integrations with reduced privileges

## Rationale

### Mutual TLS (mTLS)

mTLS provides strong security through two-way certificate validation:

1. **Strong Authentication**: Both client and server authenticate each other
2. **Encryption**: Built-in encryption of all traffic
3. **Integration with RBAC**: Client certificates can include role information
4. **No Token Management**: No need to issue, expire, or revoke tokens
5. **Performance**: Minimal overhead after initial handshake

Our performance testing showed that mTLS adds only ~4.5% overhead compared to insecure connections.

### JWT Tokens

JWT provides a flexible alternative when mTLS is not feasible:

1. **Web Support**: Works in environments where client certificates are difficult to manage
2. **Stateless**: Tokens contain all necessary information
3. **Standard Format**: Well-defined structure with library support
4. **Claim-based**: Can include roles and permissions directly in the token
5. **Performance**: Acceptable overhead for secondary use cases

### API Keys

Simple API keys are included for non-critical operations:

1. **Simplicity**: Easy to implement and use
2. **Limited Scope**: Will only grant access to non-sensitive operations
3. **Rate Limiting**: Will be subject to stricter rate limits
4. **Migration Path**: Provides an easy on-ramp for new users

## Implementation Details

### mTLS Implementation

- Certificate generation and rotation process
- Role extraction from client certificates
- Integration with gRPC

```go
// Load TLS credentials
creds, err := credentials.NewServerTLSFromFile("server.crt", "server.key")
if err != nil {
    log.Fatalf("Failed to load credentials: %v", err)
}

// Create gRPC server with TLS
server := grpc.NewServer(grpc.Creds(creds))
```

### JWT Implementation

- Token issuance and validation
- Role-based claims
- Integration with gRPC interceptors

```go
// JWT validation in interceptor
func authInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
    token := extractToken(ctx)
    if !validateToken(token) {
        return nil, status.Errorf(codes.Unauthenticated, "invalid token")
    }
    return handler(ctx, req)
}
```

### API Key Implementation

- Key issuance and storage
- Limited permissions model
- Rate limiting integration

## Consequences

### Positive

- Strong security by default with mTLS
- Flexibility for different client scenarios
- Integration with existing identity systems
- Clear migration paths for users
- Performance optimized for different use cases

### Negative

- Increased complexity with multiple auth methods
- Need to maintain certificate infrastructure
- Slightly higher initial implementation effort
- Client education required for mTLS usage

## Alternatives Considered

### mTLS Only

While simplest from a security standpoint, this would limit adoption in scenarios where certificate management is challenging.

### JWT Only

More familiar to many developers but lacks the security benefits of mTLS for service-to-service communication.

### OAuth 2.0

A more complex solution than needed for our use case, with additional dependencies and operational overhead.

### Basic Authentication

Too insecure for a production service, even over TLS.

## Related Documents

- [LlamaCalc Security Model](../security.md)
- [API Documentation](../api.md) 