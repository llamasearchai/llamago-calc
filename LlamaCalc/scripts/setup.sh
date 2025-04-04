#!/bin/bash
set -e

# Colors for pretty output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}LlamaCalc Setup Script${NC}"
echo -e "${YELLOW}This script will create the necessary directories and files for LlamaCalc development.${NC}"
echo

# Create main directory structure
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p cmd/server
mkdir -p pkg/{auth,calc,config,errors,logging,middleware,monitoring,proto,rate,rbac,security,server,validation}
mkdir -p internal/utils
mkdir -p api/client/{go,python,javascript}
mkdir -p config
mkdir -p certs
mkdir -p test/{integration,unit,benchmarks}
mkdir -p docs/{api,examples}
mkdir -p examples/{simple,advanced}
mkdir -p scripts/{release,ci}
mkdir -p tools/{load-generator,cert-manager}
mkdir -p deployments/{kubernetes,docker}
mkdir -p grafana/provisioning/{dashboards,datasources}
mkdir -p prometheus

# Create basic config file
echo -e "${GREEN}Creating basic configuration file...${NC}"
cat > config/config.yaml << EOF
# LlamaCalc Configuration

# Server settings
server:
  port: 50051
  graceful_shutdown_timeout: 30s

# Security settings
security:
  tls:
    enabled: true
    cert_file: "certs/server.crt"
    key_file: "certs/server.key"
  authentication:
    jwt:
      enabled: true
      secret: "change-this-in-production"  # Only for development
      expiration: 24h
    mtls:
      enabled: true
      client_ca_file: "certs/ca.crt"
  authorization:
    rbac:
      enabled: true
      config_file: "config/rbac.yaml"

# Calculation service settings
calculator:
  precision: 10
  max_decimal_places: 10
  overflow_check: true

# Rate limiting
rate_limit:
  enabled: true
  requests_per_second: 1000
  burst: 50

# Observability
observability:
  logging:
    level: "info"
    format: "json"
  metrics:
    enabled: true
    prometheus:
      enabled: true
      endpoint: "/metrics"
  tracing:
    enabled: true
    jaeger:
      enabled: true
      endpoint: "http://jaeger:14268/api/traces"
      service_name: "llamacalc"
EOF

# Create basic RBAC config
echo -e "${GREEN}Creating RBAC configuration file...${NC}"
cat > config/rbac.yaml << EOF
# Role-Based Access Control Configuration

roles:
  - name: admin
    permissions:
      - "*"
  - name: operator
    permissions:
      - "Add"
      - "Subtract"
      - "Multiply"
      - "Divide"
      - "Health"
  - name: basic
    permissions:
      - "Add"
      - "Subtract"
      - "Health"
  - name: readonly
    permissions:
      - "Health"

users:
  - name: admin-user
    role: admin
  - name: operator-user
    role: operator
  - name: basic-user
    role: basic
  - name: guest-user
    role: readonly
EOF

# Generate test certificates (for development only)
echo -e "${GREEN}Generating test certificates...${NC}"
mkdir -p certs
openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/server.key -out certs/server.crt -days 365 -subj "/CN=localhost" 2>/dev/null
openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/client.key -out certs/client.crt -days 365 -subj "/CN=client" 2>/dev/null
openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/ca.key -out certs/ca.crt -days 365 -subj "/CN=ca" 2>/dev/null

# Create a basic go.mod file if it doesn't exist
if [ ! -f "go.mod" ]; then
  echo -e "${GREEN}Initializing Go module...${NC}"
  go mod init llamacalc
  
  echo -e "${GREEN}Adding dependencies...${NC}"
  go get -u google.golang.org/grpc
  go get -u google.golang.org/protobuf
  go get -u github.com/spf13/viper
  go get -u github.com/spf13/cobra
  go get -u github.com/golang-jwt/jwt/v5
  go get -u go.uber.org/zap
  go get -u github.com/prometheus/client_golang/prometheus
  go get -u github.com/stretchr/testify
  go get -u go.opentelemetry.io/otel
  go get -u golang.org/x/time/rate
  
  go mod tidy
fi

echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review and modify the configuration files in the config directory"
echo -e "  2. Implement the calculator service in pkg/calc"
echo -e "  3. Implement the gRPC server in pkg/server"
echo -e "  4. Build and run the service with 'make build' and './llamacalc'"
echo -e "  5. Or use Docker: 'make docker-build' and 'make docker-run'"
echo

# Create a basic go.mod file if it doesn't exist
if [ ! -f "go.mod" ]; then
  echo -e "${GREEN}Initializing Go module...${NC}"
  go mod init llamacalc
  
  echo -e "${GREEN}Adding dependencies...${NC}"
  go get -u google.golang.org/grpc
  go get -u google.golang.org/protobuf
  go get -u github.com/spf13/viper
  go get -u github.com/spf13/cobra
  go get -u github.com/golang-jwt/jwt/v5
  go get -u go.uber.org/zap
  go get -u github.com/prometheus/client_golang/prometheus
  go get -u github.com/stretchr/testify
  go get -u go.opentelemetry.io/otel
  go get -u golang.org/x/time/rate
  
  go mod tidy
fi 