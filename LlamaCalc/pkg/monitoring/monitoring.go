// Package monitoring provides Prometheus-based monitoring for LlamaCalc
package monitoring

import (
	"context"
	"strings"
	"time"

	pb "llamacalc/pkg/proto"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/status"
)

// MetricsCollector collects metrics for the Calculator service
type MetricsCollector struct {
	requestCounter     *prometheus.CounterVec
	errorCounter       *prometheus.CounterVec
	responseTimeMetric *prometheus.HistogramVec
}

// NewMetricsCollector creates a new metrics collector
func NewMetricsCollector() *MetricsCollector {
	const namespace = "llamacalc"
	const subsystem = "grpc"

	requestCounter := promauto.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: namespace,
			Subsystem: subsystem,
			Name:      "requests_total",
			Help:      "Total number of gRPC requests",
		},
		[]string{"method", "operation"},
	)

	errorCounter := promauto.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: namespace,
			Subsystem: subsystem,
			Name:      "errors_total",
			Help:      "Total number of gRPC errors",
		},
		[]string{"method", "operation", "error_code"},
	)

	responseTimeMetric := promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Namespace: namespace,
			Subsystem: subsystem,
			Name:      "response_time_seconds",
			Help:      "Response time of gRPC requests in seconds",
			Buckets:   prometheus.DefBuckets,
		},
		[]string{"method", "operation"},
	)

	return &MetricsCollector{
		requestCounter:     requestCounter,
		errorCounter:       errorCounter,
		responseTimeMetric: responseTimeMetric,
	}
}

// RecordRequest records a request metric
func (c *MetricsCollector) RecordRequest(method, operation string) {
	c.requestCounter.WithLabelValues(method, operation).Inc()
}

// RecordError records an error metric
func (c *MetricsCollector) RecordError(method, operation string, errorCode int32) {
	c.errorCounter.WithLabelValues(method, operation, string(rune(errorCode))).Inc()
}

// RecordResponseTime records the response time for a request
func (c *MetricsCollector) RecordResponseTime(method, operation string, duration time.Duration) {
	c.responseTimeMetric.WithLabelValues(method, operation).Observe(duration.Seconds())
}

// MetricsInterceptor creates a gRPC interceptor for collecting metrics
func (c *MetricsCollector) MetricsInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		method := info.FullMethod

		// Extract operation from method name
		operation := "UNKNOWN"
		switch {
		case strings.Contains(method, "Add"):
			operation = "ADD"
		case strings.Contains(method, "Subtract"):
			operation = "SUBTRACT"
		case strings.Contains(method, "Multiply"):
			operation = "MULTIPLY"
		case strings.Contains(method, "Divide"):
			operation = "DIVIDE"
		}

		c.RecordRequest(method, operation)
		startTime := time.Now()

		// Call the RPC method
		resp, err := handler(ctx, req)

		// Record response time
		duration := time.Since(startTime)
		c.RecordResponseTime(method, operation, duration)

		// Record error if any
		if err != nil {
			st, ok := status.FromError(err)
			if ok {
				c.RecordError(method, operation, int32(st.Code()))
			} else {
				c.RecordError(method, operation, -1) // Unknown error
			}
		} else if calcResp, ok := resp.(*pb.CalculationResponse); ok && calcResp.StatusCode != 0 {
			c.RecordError(method, operation, calcResp.StatusCode)
		}

		return resp, err
	}
}
