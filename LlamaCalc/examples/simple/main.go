package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	client "llamacalc/api/client/go"
)

func main() {
	// Create a default client configuration
	config := client.DefaultClientConfig()

	// Customize configuration if needed
	config.ServerAddress = getEnv("LLAMACALC_SERVER", "localhost:50051")
	config.Timeout = 5 * time.Second
	config.Insecure = true // Use insecure connection for this example

	// Create a client
	c, err := client.NewLlamaCalcClient(config)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer c.Close()

	// Check server health
	health, err := c.CheckHealth(context.Background())
	if err != nil {
		log.Fatalf("Failed to check health: %v", err)
	}
	fmt.Printf("Server health: %s\n", health)

	// Perform calculations
	a := 42.5
	b := 17.8

	// Addition
	result, err := c.Add(context.Background(), a, b)
	if err != nil {
		log.Fatalf("Addition failed: %v", err)
	}
	fmt.Printf("%.2f + %.2f = %.2f\n", a, b, result)

	// Subtraction
	result, err = c.Subtract(context.Background(), a, b)
	if err != nil {
		log.Fatalf("Subtraction failed: %v", err)
	}
	fmt.Printf("%.2f - %.2f = %.2f\n", a, b, result)

	// Multiplication
	result, err = c.Multiply(context.Background(), a, b)
	if err != nil {
		log.Fatalf("Multiplication failed: %v", err)
	}
	fmt.Printf("%.2f * %.2f = %.2f\n", a, b, result)

	// Division
	result, err = c.Divide(context.Background(), a, b)
	if err != nil {
		log.Fatalf("Division failed: %v", err)
	}
	fmt.Printf("%.2f / %.2f = %.2f\n", a, b, result)

	// Division by zero (should fail)
	result, err = c.Divide(context.Background(), a, 0)
	if err != nil {
		fmt.Printf("Division by zero correctly failed: %v\n", err)
	} else {
		log.Fatalf("Division by zero should have failed but returned: %.2f\n", result)
	}
}

// Helper function to get environment variables with defaults
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
