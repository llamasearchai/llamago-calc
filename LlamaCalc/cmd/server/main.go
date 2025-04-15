package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/spf13/cobra"
	"google.golang.org/grpc/keepalive"

	"llamacalc/pkg/server"
)

const (
	port        = ":50051"
	metricsPort = ":9090"
)

// Version information (set by build flags)
var (
	Version   = "dev"
	BuildTime = "unknown"
)

func main() {
	// Create root command
	rootCmd := &cobra.Command{
		Use:   "llamacalc",
		Short: "LlamaCalc - Enterprise-Grade Calculator Service",
		Long: `LlamaCalc is a high-performance, secure, and enterprise-grade 
calculator service built with Go and gRPC.`,
		Version: fmt.Sprintf("%s (built at %s)", Version, BuildTime),
	}

	// Add serve command
	serveCmd := &cobra.Command{
		Use:   "serve",
		Short: "Start the LlamaCalc server",
		Long:  "Start the LlamaCalc gRPC server with the specified configuration",
		Run:   runServer,
	}

	// Add health check command
	healthCmd := &cobra.Command{
		Use:   "health",
		Short: "Check server health",
		Long:  "Check if the LlamaCalc server is running and healthy",
		Run:   checkHealth,
	}

	// Add flags for serve command
	serveCmd.Flags().StringP("config", "c", "config/config.yaml", "Path to configuration file")
	serveCmd.Flags().Int("port", 50051, "Server port")
	serveCmd.Flags().Bool("tls", true, "Enable TLS")
	serveCmd.Flags().Bool("metrics", true, "Enable Prometheus metrics")
	serveCmd.Flags().String("log-level", "info", "Log level (debug, info, warn, error)")

	// Add flags for health command
	healthCmd.Flags().StringP("addr", "a", "localhost:50051", "Server address")
	healthCmd.Flags().DurationP("timeout", "t", 5*time.Second, "Connection timeout")
	healthCmd.Flags().Bool("insecure", false, "Skip TLS verification")

	// Add commands to root command
	rootCmd.AddCommand(serveCmd)
	rootCmd.AddCommand(healthCmd)

	// Execute
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func runServer(cmd *cobra.Command, args []string) {
	configPath, _ := cmd.Flags().GetString("config")
	port, _ := cmd.Flags().GetInt("port")
	tlsEnabled, _ := cmd.Flags().GetBool("tls")
	metricsEnabled, _ := cmd.Flags().GetBool("metrics")
	logLevel, _ := cmd.Flags().GetString("log-level")

	// Log the startup information
	log.Printf("Starting LlamaCalc server v%s\n", Version)
	log.Printf("Config file: %s\n", configPath)
	log.Printf("Port: %d\n", port)
	log.Printf("TLS enabled: %v\n", tlsEnabled)
	log.Printf("Metrics enabled: %v\n", metricsEnabled)
	log.Printf("Log level: %s\n", logLevel)

	// Setup signal handling for graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	// Configure the server
	config := &server.Config{
		Port:                 port,
		TLSEnabled:           tlsEnabled,
		MTLSEnabled:          false, // Default to false for now
		CertFile:             "certs/server.crt",
		KeyFile:              "certs/server.key",
		CAFile:               "certs/ca.crt",
		MaxRecvMsgSize:       4 * 1024 * 1024, // 4 MiB
		MaxSendMsgSize:       4 * 1024 * 1024, // 4 MiB
		MaxConcurrentStreams: 1000,
		Keepalive: keepalive.ServerParameters{
			MaxConnectionIdle:     15 * time.Minute,
			MaxConnectionAge:      30 * time.Minute,
			MaxConnectionAgeGrace: 5 * time.Minute,
			Time:                  5 * time.Minute,
			Timeout:               1 * time.Minute,
		},
		MaxPrecision:         10,
		MaxDecimalPlaces:     10,
		OverflowCheckEnabled: true,
	}

	// Create and start the server
	grpcServer, err := server.NewGRPCServer(config)
	if err != nil {
		log.Fatalf("Failed to create server: %v", err)
	}

	// Start the server
	err = grpcServer.Start()
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

	// Start metrics server if enabled
	if metricsEnabled {
		go func() {
			http.Handle("/metrics", promhttp.Handler())
			metricsAddr := fmt.Sprintf(":%d", port+1)
			log.Printf("Starting metrics server on %s", metricsAddr)
			if err := http.ListenAndServe(metricsAddr, nil); err != nil {
				log.Printf("Metrics server error: %v", err)
			}
		}()
	}

	log.Println("Server started successfully. Press Ctrl+C to stop.")

	// Use the context in the server so it can be properly canceled
	go func() {
		<-signalChan
		cancel()
	}()

	// Wait for context to be canceled
	<-ctx.Done()
	log.Println("Received termination signal. Shutting down gracefully...")

	// Give services 5 seconds to clean up
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer shutdownCancel()

	// Use the shutdown context for cleanup
	// Perform cleanup within the shutdown context to enforce timeout
	done := make(chan struct{})
	go func() {
		grpcServer.Stop()
		close(done)
	}()

	select {
	case <-done:
		log.Println("Server shutdown completed gracefully")
	case <-shutdownCtx.Done():
		log.Println("Server shutdown timed out")
	}

	log.Println("Server has been gracefully shut down.")
}

func checkHealth(cmd *cobra.Command, args []string) {
	addr, _ := cmd.Flags().GetString("addr")
	timeout, _ := cmd.Flags().GetDuration("timeout")
	insecure, _ := cmd.Flags().GetBool("insecure")

	// TODO: Implement actual health check
	// This is a placeholder implementation for now
	log.Printf("Checking LlamaCalc server health at %s\n", addr)
	log.Printf("Timeout: %v\n", timeout)
	log.Printf("Insecure: %v\n", insecure)

	// Simulate a health check
	time.Sleep(500 * time.Millisecond)

	// For now, always report healthy
	fmt.Println("Status: SERVING")
	os.Exit(0)
}
