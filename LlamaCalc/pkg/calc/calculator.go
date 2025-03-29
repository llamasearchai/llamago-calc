package calc

import (
	"context"
	"errors"
	"math"
	"time"
)

// Common errors
var (
	ErrDivideByZero = errors.New("division by zero")
	ErrOverflow     = errors.New("numeric overflow")
	ErrUnderflow    = errors.New("numeric underflow")
	ErrInvalidInput = errors.New("invalid input")
)

// Calculator represents the calculator service
type Calculator struct {
	// Service configuration
	MaxPrecision     int
	MaxDecimalPlaces int
	CheckOverflow    bool
}

// CalculationResult contains the result of a calculation
type CalculationResult struct {
	Value     float64
	Duration  time.Duration
	Operation string
	Error     error
}

// NewCalculator creates a new calculator service
func NewCalculator(maxPrecision, maxDecimalPlaces int, checkOverflow bool) *Calculator {
	return &Calculator{
		MaxPrecision:     maxPrecision,
		MaxDecimalPlaces: maxDecimalPlaces,
		CheckOverflow:    checkOverflow,
	}
}

// Add performs addition with error handling and metrics
func (c *Calculator) Add(ctx context.Context, a, b float64) CalculationResult {
	start := time.Now()

	// Validate inputs
	if !c.validateInput(a) || !c.validateInput(b) {
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Add",
			Error:     ErrInvalidInput,
		}
	}

	// Perform calculation
	result := a + b

	// Check for overflow/underflow
	if c.CheckOverflow && !c.validateInput(result) {
		var err error
		if result > 0 {
			err = ErrOverflow
		} else {
			err = ErrUnderflow
		}
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Add",
			Error:     err,
		}
	}

	// Return result
	return CalculationResult{
		Value:     c.roundToPrecision(result),
		Duration:  time.Since(start),
		Operation: "Add",
		Error:     nil,
	}
}

// Subtract performs subtraction with error handling and metrics
func (c *Calculator) Subtract(ctx context.Context, a, b float64) CalculationResult {
	start := time.Now()

	// Validate inputs
	if !c.validateInput(a) || !c.validateInput(b) {
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Subtract",
			Error:     ErrInvalidInput,
		}
	}

	// Perform calculation
	result := a - b

	// Check for overflow/underflow
	if c.CheckOverflow && !c.validateInput(result) {
		var err error
		if result > 0 {
			err = ErrOverflow
		} else {
			err = ErrUnderflow
		}
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Subtract",
			Error:     err,
		}
	}

	// Return result
	return CalculationResult{
		Value:     c.roundToPrecision(result),
		Duration:  time.Since(start),
		Operation: "Subtract",
		Error:     nil,
	}
}

// Multiply performs multiplication with error handling and metrics
func (c *Calculator) Multiply(ctx context.Context, a, b float64) CalculationResult {
	start := time.Now()

	// Validate inputs
	if !c.validateInput(a) || !c.validateInput(b) {
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Multiply",
			Error:     ErrInvalidInput,
		}
	}

	// Perform calculation
	result := a * b

	// Check for overflow/underflow
	if c.CheckOverflow && !c.validateInput(result) {
		var err error
		if result > 0 {
			err = ErrOverflow
		} else {
			err = ErrUnderflow
		}
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Multiply",
			Error:     err,
		}
	}

	// Return result
	return CalculationResult{
		Value:     c.roundToPrecision(result),
		Duration:  time.Since(start),
		Operation: "Multiply",
		Error:     nil,
	}
}

// Divide performs division with error handling and metrics
func (c *Calculator) Divide(ctx context.Context, a, b float64) CalculationResult {
	start := time.Now()

	// Validate inputs
	if !c.validateInput(a) || !c.validateInput(b) {
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Divide",
			Error:     ErrInvalidInput,
		}
	}

	// Check for division by zero
	if b == 0 {
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Divide",
			Error:     ErrDivideByZero,
		}
	}

	// Perform calculation
	result := a / b

	// Check for overflow/underflow
	if c.CheckOverflow && !c.validateInput(result) {
		var err error
		if result > 0 {
			err = ErrOverflow
		} else {
			err = ErrUnderflow
		}
		return CalculationResult{
			Value:     0,
			Duration:  time.Since(start),
			Operation: "Divide",
			Error:     err,
		}
	}

	// Return result
	return CalculationResult{
		Value:     c.roundToPrecision(result),
		Duration:  time.Since(start),
		Operation: "Divide",
		Error:     nil,
	}
}

// validateInput checks if a number is valid (not NaN or Infinity)
func (c *Calculator) validateInput(value float64) bool {
	return !math.IsNaN(value) && !math.IsInf(value, 0)
}

// roundToPrecision rounds a value to the configured precision
func (c *Calculator) roundToPrecision(value float64) float64 {
	multiplier := math.Pow10(c.MaxDecimalPlaces)
	return math.Round(value*multiplier) / multiplier
}
