package calculator

import (
	"math"
)

// Calculator provides simple calculation operations
type Calculator struct{}

// NewCalculator creates a new Calculator
func NewCalculator() *Calculator {
	return &Calculator{}
}

// Add adds two numbers
func (c *Calculator) Add(a, b float64) float64 {
	return a + b
}

// Subtract subtracts b from a
func (c *Calculator) Subtract(a, b float64) float64 {
	return a - b
}

// Multiply multiplies two numbers
func (c *Calculator) Multiply(a, b float64) float64 {
	return a * b
}

// Divide divides a by b
func (c *Calculator) Divide(a, b float64) float64 {
	if b == 0 {
		return math.NaN()
	}
	return a / b
}
