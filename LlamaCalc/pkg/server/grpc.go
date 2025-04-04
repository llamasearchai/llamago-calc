package server

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"net"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"

	"llamacalc/pkg/calc"
	pb "llamacalc/pkg/proto"
)

// GRPCServer represents the LlamaCalc gRPC server
type GRPCServer struct {
	pb.UnimplementedCalculatorServer
	pb.UnimplementedHealthServiceServer

	calculator   *calc.Calculator
	server       *grpc.Server
	config       *Config
	port         int
	tlsEnabled   bool
	certFile     string
	keyFile      string
	caFile       string
	interceptors []grpc.UnaryServerInterceptor
}

// Config contains the configuration for the GRPCServer
type Config struct {
	Port                 int
	TLSEnabled           bool
	MTLSEnabled          bool
	CertFile             string
	KeyFile              string
	CAFile               string
	MaxRecvMsgSize       int
	MaxSendMsgSize       int
	MaxConcurrentStreams uint32
	ConnectionTimeout    time.Duration
	Keepalive            keepalive.ServerParameters
	MetricsEnabled       bool
	TracingEnabled       bool
	LoggingEnabled       bool
	RateLimitEnabled     bool
	AuthEnabled          bool
	RBACEnabled          bool
	MaxPrecision         int
	MaxDecimalPlaces     int
	OverflowCheckEnabled bool
}

// NewGRPCServer creates a new gRPC server
func NewGRPCServer(config *Config) (*GRPCServer, error) {
	// Create calculator service
	calculator := calc.NewCalculator(
		config.MaxPrecision,
		config.MaxDecimalPlaces,
		config.OverflowCheckEnabled,
	)

	// Initialize server options
	var opts []grpc.ServerOption

	// Configure message sizes
	opts = append(opts, grpc.MaxRecvMsgSize(config.MaxRecvMsgSize))
	opts = append(opts, grpc.MaxSendMsgSize(config.MaxSendMsgSize))

	// Configure stream limits
	opts = append(opts, grpc.MaxConcurrentStreams(config.MaxConcurrentStreams))

	// Configure keepalive
	opts = append(opts, grpc.KeepaliveParams(config.Keepalive))

	// Setup TLS if enabled
	if config.TLSEnabled {
		var creds credentials.TransportCredentials
		var err error

		if config.MTLSEnabled {
			creds, err = loadMTLSCredentials(config.CertFile, config.KeyFile, config.CAFile)
		} else {
			creds, err = loadTLSCredentials(config.CertFile, config.KeyFile)
		}

		if err != nil {
			return nil, fmt.Errorf("failed to load TLS credentials: %v", err)
		}

		opts = append(opts, grpc.Creds(creds))
	}

	// Create gRPC server
	server := grpc.NewServer(opts...)

	// Create server
	s := &GRPCServer{
		calculator: calculator,
		server:     server,
		config:     config,
		port:       config.Port,
		tlsEnabled: config.TLSEnabled,
		certFile:   config.CertFile,
		keyFile:    config.KeyFile,
		caFile:     config.CAFile,
	}

	// Register services
	pb.RegisterCalculatorServer(server, s)
	pb.RegisterHealthServiceServer(server, s)

	// Enable reflection if not in production
	// This helps with debugging tools like grpcurl
	reflection.Register(server)

	return s, nil
}

// Start starts the gRPC server
func (s *GRPCServer) Start() error {
	// Listen on TCP port
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", s.port))
	if err != nil {
		return fmt.Errorf("failed to listen on port %d: %v", s.port, err)
	}

	// Start server in a goroutine
	go func() {
		fmt.Printf("Starting LlamaCalc gRPC server on port %d...\n", s.port)
		if err := s.server.Serve(lis); err != nil {
			fmt.Printf("Failed to serve: %v\n", err)
		}
	}()

	return nil
}

// Stop stops the gRPC server
func (s *GRPCServer) Stop() {
	fmt.Println("Stopping LlamaCalc gRPC server...")
	s.server.GracefulStop()
	fmt.Println("LlamaCalc gRPC server stopped")
}

// Health check implementation
func (s *GRPCServer) Check(ctx context.Context, req *grpc_health_v1.HealthCheckRequest) (*grpc_health_v1.HealthCheckResponse, error) {
	// TODO: Implement real health checking logic
	return &grpc_health_v1.HealthCheckResponse{
		Status: grpc_health_v1.HealthCheckResponse_SERVING,
	}, nil
}

func (s *GRPCServer) Watch(req *grpc_health_v1.HealthCheckRequest, stream grpc_health_v1.Health_WatchServer) error {
	// TODO: Implement real health watching logic
	return stream.Send(&grpc_health_v1.HealthCheckResponse{
		Status: grpc_health_v1.HealthCheckResponse_SERVING,
	})
}

// Add implements the Add RPC
func (s *GRPCServer) Add(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := s.calculator.Add(ctx, req.A, req.B)

	// Convert to gRPC response
	response := &pb.CalculationResponse{
		Result:     result.Value,
		StatusCode: 200,
		Operation:  result.Operation,
		DurationNs: result.Duration.Nanoseconds(),
	}

	if result.Error != nil {
		response.StatusCode = 400
		response.ErrorMessage = result.Error.Error()
	}

	return response, nil
}

// Subtract implements the Subtract RPC
func (s *GRPCServer) Subtract(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := s.calculator.Subtract(ctx, req.A, req.B)

	// Convert to gRPC response
	response := &pb.CalculationResponse{
		Result:     result.Value,
		StatusCode: 200,
		Operation:  result.Operation,
		DurationNs: result.Duration.Nanoseconds(),
	}

	if result.Error != nil {
		response.StatusCode = 400
		response.ErrorMessage = result.Error.Error()
	}

	return response, nil
}

// Multiply implements the Multiply RPC
func (s *GRPCServer) Multiply(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := s.calculator.Multiply(ctx, req.A, req.B)

	// Convert to gRPC response
	response := &pb.CalculationResponse{
		Result:     result.Value,
		StatusCode: 200,
		Operation:  result.Operation,
		DurationNs: result.Duration.Nanoseconds(),
	}

	if result.Error != nil {
		response.StatusCode = 400
		response.ErrorMessage = result.Error.Error()
	}

	return response, nil
}

// Divide implements the Divide RPC
func (s *GRPCServer) Divide(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := s.calculator.Divide(ctx, req.A, req.B)

	// Convert to gRPC response
	response := &pb.CalculationResponse{
		Result:     result.Value,
		StatusCode: 200,
		Operation:  result.Operation,
		DurationNs: result.Duration.Nanoseconds(),
	}

	if result.Error != nil {
		response.StatusCode = 400
		response.ErrorMessage = result.Error.Error()
	}

	return response, nil
}

// Health implements the Health RPC for the HealthService
func (s *GRPCServer) Health(ctx context.Context, req *pb.HealthCheckRequest) (*pb.HealthCheckResponse, error) {
	// TODO: Implement real health checking logic
	return &pb.HealthCheckResponse{
		Status: pb.HealthCheckResponse_SERVING,
	}, nil
}

// Helper function to load TLS credentials
func loadTLSCredentials(certFile, keyFile string) (credentials.TransportCredentials, error) {
	// Load server key pair
	serverCert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to load key pair: %v", err)
	}

	// Create credentials
	config := &tls.Config{
		Certificates: []tls.Certificate{serverCert},
		ClientAuth:   tls.NoClientCert,
		MinVersion:   tls.VersionTLS13,
	}

	return credentials.NewTLS(config), nil
}

// Helper function to load mTLS credentials
func loadMTLSCredentials(certFile, keyFile, caFile string) (credentials.TransportCredentials, error) {
	// Load CA cert
	caPEM, err := ioutil.ReadFile(caFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read CA cert: %v", err)
	}

	// Create cert pool and add CA
	certPool := x509.NewCertPool()
	if !certPool.AppendCertsFromPEM(caPEM) {
		return nil, fmt.Errorf("failed to add CA cert to pool")
	}

	// Load server key pair
	serverCert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to load key pair: %v", err)
	}

	// Create credentials
	config := &tls.Config{
		Certificates: []tls.Certificate{serverCert},
		ClientAuth:   tls.RequireAndVerifyClientCert,
		ClientCAs:    certPool,
		MinVersion:   tls.VersionTLS13,
	}

	return credentials.NewTLS(config), nil
}
