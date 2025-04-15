package client

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"

	pb "llamacalc/pkg/proto"
)

// LlamaCalcClient is a client for the LlamaCalc gRPC service
type LlamaCalcClient struct {
	conn         *grpc.ClientConn
	client       pb.CalculatorClient
	healthClient pb.HealthServiceClient
	config       *ClientConfig
}

// ClientConfig contains configuration for the LlamaCalc client
type ClientConfig struct {
	// Connection settings
	ServerAddress string
	Timeout       time.Duration

	// Security settings
	TLSEnabled  bool
	MTLSEnabled bool
	CACertFile  string
	CertFile    string
	KeyFile     string
	Insecure    bool

	// Authentication settings
	JWTToken string

	// Connection parameters
	DialTimeout      time.Duration
	KeepAliveTime    time.Duration
	KeepAliveTimeout time.Duration
	MaxRetries       int
	RetryBackoff     time.Duration
	MaxRecvMsgSize   int
	MaxSendMsgSize   int
}

// DefaultClientConfig returns a default configuration for the LlamaCalc client
func DefaultClientConfig() *ClientConfig {
	return &ClientConfig{
		ServerAddress:    "localhost:50051",
		Timeout:          5 * time.Second,
		TLSEnabled:       false,
		MTLSEnabled:      false,
		Insecure:         true,
		DialTimeout:      5 * time.Second,
		KeepAliveTime:    10 * time.Second,
		KeepAliveTimeout: 3 * time.Second,
		MaxRetries:       3,
		RetryBackoff:     100 * time.Millisecond,
		MaxRecvMsgSize:   4 * 1024 * 1024, // 4 MiB
		MaxSendMsgSize:   4 * 1024 * 1024, // 4 MiB
	}
}

// NewLlamaCalcClient creates a new LlamaCalc client
func NewLlamaCalcClient(config *ClientConfig) (*LlamaCalcClient, error) {
	// Initialize client options
	var opts []grpc.DialOption

	// Configure message sizes
	opts = append(opts, grpc.WithDefaultCallOptions(
		grpc.MaxCallRecvMsgSize(config.MaxRecvMsgSize),
		grpc.MaxCallSendMsgSize(config.MaxSendMsgSize),
	))

	// Configure keepalive
	opts = append(opts, grpc.WithKeepaliveParams(keepalive.ClientParameters{
		Time:                config.KeepAliveTime,
		Timeout:             config.KeepAliveTimeout,
		PermitWithoutStream: true,
	}))

	// Configure security
	if config.TLSEnabled {
		var creds credentials.TransportCredentials
		var err error

		if config.MTLSEnabled {
			creds, err = loadMTLSCredentials(config.CACertFile, config.CertFile, config.KeyFile)
		} else {
			creds, err = loadTLSCredentials(config.CACertFile)
		}

		if err != nil {
			return nil, fmt.Errorf("failed to load TLS credentials: %v", err)
		}

		opts = append(opts, grpc.WithTransportCredentials(creds))
	} else if config.Insecure {
		opts = append(opts, grpc.WithTransportCredentials(insecure.NewCredentials()))
	}

	// TODO: Add authentication interceptors (JWT token, etc.)
	// This is a placeholder for now

	// Establish connection
	ctx, cancel := context.WithTimeout(context.Background(), config.DialTimeout)
	defer cancel()

	conn, err := grpc.DialContext(ctx, config.ServerAddress, opts...)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to LlamaCalc server: %v", err)
	}

	// Create client
	client := pb.NewCalculatorClient(conn)
	healthClient := pb.NewHealthServiceClient(conn)

	return &LlamaCalcClient{
		conn:         conn,
		client:       client,
		healthClient: healthClient,
		config:       config,
	}, nil
}

// Close closes the client connection
func (c *LlamaCalcClient) Close() error {
	return c.conn.Close()
}

// Add performs addition
func (c *LlamaCalcClient) Add(ctx context.Context, a, b float64) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, c.config.Timeout)
	defer cancel()

	resp, err := c.client.Add(ctx, &pb.CalculationRequest{
		A: a,
		B: b,
	})
	if err != nil {
		return 0, fmt.Errorf("error calling Add: %v", err)
	}

	if resp.StatusCode != 200 {
		return 0, fmt.Errorf("error code %d: %s", resp.StatusCode, resp.ErrorMessage)
	}

	return resp.Result, nil
}

// Subtract performs subtraction
func (c *LlamaCalcClient) Subtract(ctx context.Context, a, b float64) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, c.config.Timeout)
	defer cancel()

	resp, err := c.client.Subtract(ctx, &pb.CalculationRequest{
		A: a,
		B: b,
	})
	if err != nil {
		return 0, fmt.Errorf("error calling Subtract: %v", err)
	}

	if resp.StatusCode != 200 {
		return 0, fmt.Errorf("error code %d: %s", resp.StatusCode, resp.ErrorMessage)
	}

	return resp.Result, nil
}

// Multiply performs multiplication
func (c *LlamaCalcClient) Multiply(ctx context.Context, a, b float64) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, c.config.Timeout)
	defer cancel()

	resp, err := c.client.Multiply(ctx, &pb.CalculationRequest{
		A: a,
		B: b,
	})
	if err != nil {
		return 0, fmt.Errorf("error calling Multiply: %v", err)
	}

	if resp.StatusCode != 200 {
		return 0, fmt.Errorf("error code %d: %s", resp.StatusCode, resp.ErrorMessage)
	}

	return resp.Result, nil
}

// Divide performs division
func (c *LlamaCalcClient) Divide(ctx context.Context, a, b float64) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, c.config.Timeout)
	defer cancel()

	resp, err := c.client.Divide(ctx, &pb.CalculationRequest{
		A: a,
		B: b,
	})
	if err != nil {
		return 0, fmt.Errorf("error calling Divide: %v", err)
	}

	if resp.StatusCode != 200 {
		return 0, fmt.Errorf("error code %d: %s", resp.StatusCode, resp.ErrorMessage)
	}

	return resp.Result, nil
}

// CheckHealth checks the health of the server
func (c *LlamaCalcClient) CheckHealth(ctx context.Context) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, c.config.Timeout)
	defer cancel()

	resp, err := c.healthClient.Health(ctx, &pb.HealthCheckRequest{})
	if err != nil {
		return "", fmt.Errorf("error checking health: %v", err)
	}

	status := "UNKNOWN"
	switch resp.Status {
	case pb.HealthCheckResponse_SERVING:
		status = "SERVING"
	case pb.HealthCheckResponse_NOT_SERVING:
		status = "NOT_SERVING"
	case pb.HealthCheckResponse_SERVICE_UNKNOWN:
		status = "SERVICE_UNKNOWN"
	}

	return status, nil
}

// Helper function to load TLS credentials
func loadTLSCredentials(caFile string) (credentials.TransportCredentials, error) {
	// Load CA cert
	caCert, err := ioutil.ReadFile(caFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read CA cert: %v", err)
	}

	// Create cert pool and add CA
	certPool := x509.NewCertPool()
	if !certPool.AppendCertsFromPEM(caCert) {
		return nil, fmt.Errorf("failed to add CA cert to pool")
	}

	// Create credentials
	config := &tls.Config{
		RootCAs:    certPool,
		MinVersion: tls.VersionTLS13,
	}

	return credentials.NewTLS(config), nil
}

// Helper function to load mTLS credentials
func loadMTLSCredentials(caFile, certFile, keyFile string) (credentials.TransportCredentials, error) {
	// Load CA cert
	caCert, err := ioutil.ReadFile(caFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read CA cert: %v", err)
	}

	// Create cert pool and add CA
	certPool := x509.NewCertPool()
	if !certPool.AppendCertsFromPEM(caCert) {
		return nil, fmt.Errorf("failed to add CA cert to pool")
	}

	// Load client key pair
	clientCert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to load client key pair: %v", err)
	}

	// Create credentials
	config := &tls.Config{
		RootCAs:      certPool,
		Certificates: []tls.Certificate{clientCert},
		MinVersion:   tls.VersionTLS13,
	}

	return credentials.NewTLS(config), nil
}
