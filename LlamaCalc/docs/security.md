# LlamaCalc Security Model

This document provides a detailed overview of the security mechanisms implemented in LlamaCalc to protect against various threats and vulnerabilities.

## Security Architecture

LlamaCalc implements a defense-in-depth approach with multiple layers of security:

```
┌──────────────────────────────────────────────────────────┐
│                      LlamaCalc Server                    │
│                                                          │
│  ┌─────────────┐   ┌────────────┐   ┌────────────────┐  │
│  │ TLS/mTLS    │ → │ Auth/RBAC  │ → │ Input          │  │
│  │ Encryption  │   │ Layer      │   │ Validation     │  │
│  └─────────────┘   └────────────┘   └────────────────┘  │
│          ↓               ↓                ↓              │
│  ┌─────────────┐   ┌────────────┐   ┌────────────────┐  │
│  │ Rate        │ → │ Logging &  │ → │ Business       │  │
│  │ Limiting    │   │ Monitoring │   │ Logic          │  │
│  └─────────────┘   └────────────┘   └────────────────┘  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Transport Security

### TLS/mTLS

LlamaCalc uses TLS 1.3 for all communications to ensure:

1. **Encryption**: All data transmitted between clients and the server is encrypted
2. **Integrity**: Detection of any tampering with the transmitted data
3. **Authentication**: Verification of the server's identity

For service-to-service communication, LlamaCalc implements mutual TLS (mTLS):

1. **Two-way Authentication**: Both the client and server authenticate each other
2. **Client Certificates**: Clients present certificates to identify themselves
3. **Certificate Rotation**: Support for regular certificate rotation

#### TLS Configuration

LlamaCalc enforces strong TLS settings:

```go
config := &tls.Config{
    MinVersion:               tls.VersionTLS13,
    CurvePreferences:         []tls.CurveID{tls.X25519, tls.CurveP384},
    PreferServerCipherSuites: true,
    CipherSuites: []uint16{
        tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
        tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
        tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,
        tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,
    },
}
```

## Authentication & Authorization

### Authentication Methods

LlamaCalc supports multiple authentication methods:

1. **mTLS Authentication**: Client certificates are used to authenticate clients
2. **JWT Tokens**: For clients that cannot use mTLS
3. **API Keys**: For simple integration scenarios (with reduced privileges)

### Role-Based Access Control (RBAC)

LlamaCalc implements RBAC with the following roles:

| Role  | Access Level | Operations Allowed |
|-------|--------------|-------------------|
| Admin | Full Access  | Add, Subtract, Multiply, Divide |
| User  | Standard     | Add, Subtract, Multiply |
| Guest | Limited      | Add, Subtract |

The RBAC enforcement happens at the interceptor level, before the request reaches the service implementation:

```go
// AuthInterceptor enforces RBAC
func (interceptor *AuthInterceptor) Unary() grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
        // Extract role from context
        role := extractRole(ctx)
        
        // Check access
        if !interceptor.isAccessible(info.FullMethod, role) {
            return nil, status.Errorf(codes.PermissionDenied, 
                "no permission to access this RPC")
        }
        
        // Continue with the RPC
        return handler(ctx, req)
    }
}
```

## Input Validation

LlamaCalc implements thorough input validation to prevent:

1. **Overflow/Underflow**: Checking if operations would result in values outside representable ranges
2. **Division by Zero**: Explicit checks before division operations
3. **Invalid Inputs**: Validation of all input values before processing

Example from the division operation:
```go
// Check for division by zero
if req.B == 0 {
    return &proto.CalculationResponse{
        Result:       0,
        StatusCode:   2,
        ErrorMessage: "division by zero",
        Operation:    string(OpDivide),
    }, nil
}
```

## Rate Limiting

LlamaCalc implements rate limiting to protect against DoS attacks:

1. **Per-Client Limits**: Based on client identity
2. **Global Limits**: To protect overall system resources
3. **Adaptive Limits**: Dynamically adjusted based on system load

Implementation uses the token bucket algorithm:
```go
// RateLimiter controls request rates
type RateLimiter struct {
    limit  rate.Limit
    burst  int
    limits map[string]*rate.Limiter
    mu     sync.Mutex
}

// Allow checks if a request should be allowed
func (r *RateLimiter) Allow(clientID string) bool {
    r.mu.Lock()
    defer r.mu.Unlock()
    
    limiter, exists := r.limits[clientID]
    if !exists {
        limiter = rate.NewLimiter(r.limit, r.burst)
        r.limits[clientID] = limiter
    }
    
    return limiter.Allow()
}
```

## Logging & Monitoring

LlamaCalc implements comprehensive logging and monitoring:

1. **Request Logging**: All requests are logged with appropriate detail
2. **Audit Logging**: Security-relevant events are recorded
3. **Prometheus Metrics**: Real-time monitoring of security events
4. **Alerting**: Automated alerts for suspicious activities

Security-relevant metrics include:
- Authentication failures
- Authorization failures
- Rate limit triggers
- Input validation failures

## Threat Modeling

LlamaCalc's security design addresses the following threats:

### STRIDE Threat Model

| Threat | Mitigation |
|--------|------------|
| **S**poofing | mTLS authentication, JWT validation |
| **T**ampering | TLS encryption, integrity checks |
| **R**epudiation | Comprehensive audit logging |
| **I**nformation Disclosure | TLS encryption, RBAC |
| **D**enial of Service | Rate limiting, input validation |
| **E**levation of Privilege | RBAC, input validation |

### API Security Checklist

- [x] Use TLS for all communications
- [x] Implement proper authentication
- [x] Implement proper authorization
- [x] Validate all inputs
- [x] Implement rate limiting
- [x] Log security-relevant events
- [x] Monitor for suspicious activities
- [x] Protect against overflow/underflow
- [x] Implement proper error handling

## Secure Deployment

Recommended deployment settings for LlamaCalc:

1. **Network Isolation**: Deploy behind a firewall or within a private network
2. **Regular Updates**: Keep all dependencies updated
3. **Certificate Management**: Implement proper certificate rotation
4. **Secrets Management**: Use a secure vault for storing secrets
5. **Monitoring**: Implement continuous monitoring for security events

## Security Contacts

For reporting security vulnerabilities in LlamaCalc, please contact:
- Email: security@example.com
- GPG Key: [Security Team GPG Key](https://example.com/gpg-key.asc) 