// Package auth provides authentication and authorization functionality for LlamaCalc
package auth

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"io/ioutil"

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
