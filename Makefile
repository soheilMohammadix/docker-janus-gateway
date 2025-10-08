.PHONY: help build build-dev build-full run run-dev run-full clean logs logs-dev logs-full test stop stop-dev stop-full

# Default target
help:
	@echo "Janus Gateway Docker Compose Helper"
	@echo ""
	@echo "Available commands:"
	@echo "  build      - Build the basic Janus Gateway image"
	@echo "  build-dev  - Build the development image (stops at build stage)"
	@echo "  build-full - Build the full stack image with all services"
	@echo "  run        - Run the basic Janus Gateway"
	@echo "  run-dev    - Run the development environment"
	@echo "  run-full   - Run the full stack with all services"
	@echo "  clean      - Clean up Docker resources"
	@echo "  logs       - Show logs for basic setup"
	@echo "  logs-dev   - Show logs for development setup"
	@echo "  logs-full  - Show logs for full stack"
	@echo "  test       - Test Janus Gateway API"
	@echo "  stop       - Stop basic setup"
	@echo "  stop-dev   - Stop development setup"
	@echo "  stop-full  - Stop full stack"
	@echo ""
	@echo "Environment setup:"
	@echo "  cp .env.example .env"
	@echo "  # Edit .env with your configuration"

# Build targets
build:
	docker-compose build

build-dev:
	docker-compose -f docker-compose.dev.yml build

build-full:
	docker-compose -f docker-compose.full.yml build

# Run targets
run: build
	docker-compose up -d

run-dev: build-dev
	docker-compose -f docker-compose.dev.yml up -d

run-full: build-full
	docker-compose -f docker-compose.full.yml up -d

# Interactive run targets
run-interactive: build
	docker-compose up

run-dev-interactive: build-dev
	docker-compose -f docker-compose.dev.yml up

run-full-interactive: build-full
	docker-compose -f docker-compose.full.yml up

# Log targets
logs:
	docker-compose logs -f janus

logs-dev:
	docker-compose -f docker-compose.dev.yml logs -f

logs-full:
	docker-compose -f docker-compose.full.yml logs -f

# Test targets
test:
	@echo "Testing Janus Gateway API..."
	curl -s http://localhost:8088/janus/info | jq '.' || echo "Janus API not responding"

test-websocket:
	@echo "Testing WebSocket connection..."
	wscat -c ws://localhost:8189 || echo "WebSocket not available"

# Stop targets
stop:
	docker-compose down

stop-dev:
	docker-compose -f docker-compose.dev.yml down

stop-full:
	docker-compose -f docker-compose.full.yml down

# Clean targets
clean: stop
	docker system prune -f
	docker volume prune -f

clean-all: stop-dev stop-full clean
	docker rmi $(shell docker images "swmansion/janus-gateway*" -q) 2>/dev/null || true

# Development helpers
shell:
	docker-compose exec janus /bin/bash

shell-dev:
	docker-compose -f docker-compose.dev.yml exec janus /bin/bash

shell-full:
	docker-compose -f docker-compose.full.yml exec janus /bin/bash

# Configuration helpers
setup-env:
	@if [ ! -f .env ]; then \
		echo "Creating .env file from template..."; \
		cp .env.example .env; \
		echo "Please edit .env file with your configuration"; \
	else \
		echo ".env file already exists"; \
	fi

setup-dirs:
	@echo "Creating necessary directories..."
	mkdir -p configs recordings logs nginx/conf.d nginx/ssl rabbitmq redis graylog/config html

# Status helpers
status:
	docker-compose ps

status-dev:
	docker-compose -f docker-compose.dev.yml ps

status-full:
	docker-compose -f docker-compose.full.yml ps

# Quick start
quick-start: setup-env setup-dirs build run
	@echo "Janus Gateway is starting..."
	@echo "API: http://localhost:8088/janus/info"
	@echo "Admin API: http://localhost:8188/admin/info"
	@echo "WebSocket: ws://localhost:8189"
	@echo ""
	@echo "Use 'make logs' to follow the logs"
	@echo "Use 'make test' to test the API"

# Development quick start
dev-start: setup-env setup-dirs build-dev run-dev
	@echo "Development environment is starting..."
	@echo "Use 'make shell-dev' to access the container"
	@echo "Use 'make logs-dev' to follow the logs"

# Full stack quick start
full-start: setup-env setup-dirs build-full run-full
	@echo "Full stack is starting..."
	@echo "Janus API: http://localhost:8088/janus/info"
	@echo "RabbitMQ Management: http://localhost:15672 (janus/janus123)"
	@echo "Redis: localhost:6379"
	@echo "Nginx: http://localhost"
	@echo "Graylog: http://localhost:9000 (admin/admin)"
	@echo ""
	@echo "Use 'make logs-full' to follow the logs"