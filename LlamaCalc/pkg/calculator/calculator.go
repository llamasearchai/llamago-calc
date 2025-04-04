// Package calculator provides the core calculation functionality for LlamaCalc
package calculator

import (
	"context"
	"errors"
	"fmt"
	"math"
	"time"

	pb "llamacalc/pkg/proto"

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
	pb.UnimplementedCalculatorServer
}

// NewService creates a new calculator service
func NewService() *Service {
	return &Service{}
}

// Add implements the Add RPC method
func (s *Service) Add(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for potential overflow
	if (req.A > 0 && req.B > math.MaxFloat64-req.A) || (req.A < 0 && req.B < -math.MaxFloat64-req.A) {
		return &pb.CalculationResponse{
			Result:       0,
			StatusCode:   1,
			ErrorMessage: "overflow detected in addition operation",
			Operation:    string(OpAdd),
		}, nil
	}

	result := req.A + req.B

	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpAdd),
	}, nil
}

// Subtract implements the Subtract RPC method
func (s *Service) Subtract(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for potential overflow
	if (req.A > 0 && req.B < req.A-math.MaxFloat64) || (req.A < 0 && req.B > req.A+math.MaxFloat64) {
		return &pb.CalculationResponse{
			Result:       0,
			StatusCode:   1,
			ErrorMessage: "overflow detected in subtraction operation",
			Operation:    string(OpSubtract),
		}, nil
	}

	result := req.A - req.B

	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpSubtract),
	}, nil
}

// Multiply implements the Multiply RPC method
func (s *Service) Multiply(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for potential overflow
	absA, absB := math.Abs(req.A), math.Abs(req.B)
	if absA > 1 && absB > math.MaxFloat64/absA {
		return &pb.CalculationResponse{
			Result:       0,
			StatusCode:   1,
			ErrorMessage: "overflow detected in multiplication operation",
			Operation:    string(OpMultiply),
		}, nil
	}

	result := req.A * req.B

	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpMultiply),
	}, nil
}

// Divide implements the Divide RPC method
func (s *Service) Divide(ctx context.Context, req *pb.CalculationRequest) (*pb.CalculationResponse, error) {
	// Check for context timeout or cancellation
	if ctx.Err() != nil {
		return nil, status.Errorf(codes.Canceled, "request cancelled or timed out")
	}

	// Add a small delay to simulate processing time (for demonstration purposes)
	time.Sleep(10 * time.Millisecond)

	// Check for division by zero
	if req.B == 0 {
		return &pb.CalculationResponse{
			Result:       0,
			StatusCode:   2,
			ErrorMessage: "division by zero",
			Operation:    string(OpDivide),
		}, nil
	}

	result := req.A / req.B

	// Check for infinity or NaN
	if math.IsInf(result, 0) || math.IsNaN(result) {
		return &pb.CalculationResponse{
			Result:       0,
			StatusCode:   3,
			ErrorMessage: fmt.Sprintf("invalid result: %v", result),
			Operation:    string(OpDivide),
		}, nil
	}

	return &pb.CalculationResponse{
		Result:       result,
		StatusCode:   0,
		ErrorMessage: "",
		Operation:    string(OpDivide),
	}, nil
}

// Validate validates the request parameters for any calculation operation
func Validate(req *pb.CalculationRequest) error {
	// Check for NaN or infinity
	if math.IsNaN(req.A) || math.IsInf(req.A, 0) {
		return errors.New("first operand is NaN or infinity")
	}
	if math.IsNaN(req.B) || math.IsInf(req.B, 0) {
		return errors.New("second operand is NaN or infinity")
	}
	return nil
}
