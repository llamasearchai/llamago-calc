package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	pb "llamacalc/pkg/proto"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
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

	// Create gRPC connection without TLS for testing
	conn, err := grpc.Dial(
		serverAddr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		log.Fatalf("failed to connect: %v", err)
	}
	defer conn.Close()

	// Create calculator client
	client := pb.NewCalculatorClient(conn)

	// Prepare context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	// Prepare request
	req := &pb.CalculationRequest{
		A: *a,
		B: *b,
	}

	// Perform calculation based on operation
	var resp *pb.CalculationResponse
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
