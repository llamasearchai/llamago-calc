package main

import (
	"context"
	"log"
	"net"

	pb "llamacalc/pkg/proto"

	"google.golang.org/grpc"
)

const (
	port = ":50051"
)

// CalculatorServer implements the Calculator service
type CalculatorServer struct {
	pb.UnimplementedCalculatorServer
}

// Add implements the Add method of the Calculator service
func (s *CalculatorServer) Add(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := req.A + req.B
	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    "ADD",
	}, nil
}

// Subtract implements the Subtract method of the Calculator service
func (s *CalculatorServer) Subtract(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := req.A - req.B
	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    "SUBTRACT",
	}, nil
}

// Multiply implements the Multiply method of the Calculator service
func (s *CalculatorServer) Multiply(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	result := req.A * req.B
	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    "MULTIPLY",
	}, nil
}

// Divide implements the Divide method of the Calculator service
func (s *CalculatorServer) Divide(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	if req.B == 0 {
		return &pb.CalculationResponse{
			Result:       0,
			StatusCode:   2,
			ErrorMessage: "division by zero",
			Operation:    "DIVIDE",
		}, nil
	}

	result := req.A / req.B
	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    "DIVIDE",
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterCalculatorServer(grpcServer, &CalculatorServer{})

	log.Printf("Starting gRPC server on %s", port)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
