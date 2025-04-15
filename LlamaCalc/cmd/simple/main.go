package main

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"llamacalc/pkg/calc"
)

func main() {
	// Check if we have enough arguments
	if len(os.Args) != 4 {
		fmt.Println("Usage: go run main.go <operation> <a> <b>")
		fmt.Println("Operations: add, subtract, multiply, divide")
		os.Exit(1)
	}

	// Parse arguments
	operation := os.Args[1]
	a, err := strconv.ParseFloat(os.Args[2], 64)
	if err != nil {
		fmt.Printf("Error parsing first number: %v\n", err)
		os.Exit(1)
	}
	b, err := strconv.ParseFloat(os.Args[3], 64)
	if err != nil {
		fmt.Printf("Error parsing second number: %v\n", err)
		os.Exit(1)
	}

	// Create calculator service with default settings
	calculator := calc.NewCalculator(10, 2, true)

	// Create context
	ctx := context.Background()

	// Perform operation
	var result calc.CalculationResult
	switch operation {
	case "add":
		result = calculator.Add(ctx, a, b)
	case "subtract":
		result = calculator.Subtract(ctx, a, b)
	case "multiply":
		result = calculator.Multiply(ctx, a, b)
	case "divide":
		if b == 0 {
			fmt.Println("Error: Division by zero")
			os.Exit(1)
		}
		result = calculator.Divide(ctx, a, b)
	default:
		fmt.Println("Unknown operation. Use: add, subtract, multiply, divide")
		os.Exit(1)
	}

	// Check for errors
	if result.Error != nil {
		fmt.Printf("Error: %v\n", result.Error)
		os.Exit(1)
	}

	// Print result
	fmt.Printf("%s(%g, %g) = %g\n", operation, a, b, result.Value)
}
