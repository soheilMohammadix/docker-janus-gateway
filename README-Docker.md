# Janus Gateway Docker Setup

This directory contains Docker Compose configurations to help you build and run Janus Gateway locally.

## Quick Start

### 1. Basic Setup

```bash
# Setup environment and directories
make quick-start

# Or manually:
cp .env.example .env
# Edit .env with your configuration (especially GATEWAY_IP)
make build
make run
```

### 2. Development Setup

```bash
make dev-start
```

### 3. Full Stack Setup

```bash
make full-start
```

## Available Docker Compose Files

### `docker-compose.yml` - Basic Setup
- Janus Gateway only
- HTTP REST API, Admin API, and WebSocket support
- Basic configuration for testing and development

### `docker-compose.dev.yml` - Development Setup
- Janus Gateway (build stage only)
- RabbitMQ for message queuing
- Redis for caching
- Nginx reverse proxy
- Useful for development and debugging

### `docker-compose.full.yml` - Full Stack Setup
- Complete production-ready setup
- Janus Gateway with all features enabled
- RabbitMQ with management UI
- Redis with persistence
- Nginx with SSL termination
- Graylog for centralized logging
- Health checks and monitoring

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and modify as needed:

```bash
cp .env.example .env
```

Key variables to configure:

- `GATEWAY_IP` - Your local IP address (important for WebRTC)
- `ADMIN_SECRET` - Admin API secret
- `RABBITMQ_PASSWORD` - RabbitMQ password
- `REDIS_PASSWORD` - Redis password

### Port Mappings

| Service | Port | Description |
|---------|------|-------------|
| Janus HTTP API | 8088 | REST API |
| Janus Admin API | 8188 | Admin/monitoring API |
| Janus WebSocket | 8189 | WebSocket API |
| RTP/RTCP | 10000-10099 | Media ports |
| RabbitMQ Management | 15672 | RabbitMQ UI (full stack) |
| Redis | 6379 | Redis server (full stack) |
| Nginx HTTP | 80 | Web server (full stack) |
| Nginx HTTPS | 443 | SSL web server (full stack) |
| Graylog | 9000 | Log management (full stack) |

## Makefile Commands

### Build Commands
```bash
make build          # Build basic image
make build-dev      # Build development image
make build-full     # Build full stack image
```

### Run Commands
```bash
make run            # Run basic setup
make run-dev        # Run development setup
make run-full       # Run full stack
```

### Management Commands
```bash
make logs           # View logs (basic)
make logs-dev       # View logs (dev)
make logs-full      # View logs (full stack)

make status         # Check status (basic)
make status-dev     # Check status (dev)
make status-full    # Check status (full stack)

make stop           # Stop services (basic)
make stop-dev       # Stop services (dev)
make stop-full      # Stop services (full stack)
```

### Development Commands
```bash
make shell          # Access container shell (basic)
make shell-dev      # Access container shell (dev)
make shell-full     # Access container shell (full stack)

make test           # Test API endpoints
make test-websocket # Test WebSocket connection
```

### Cleanup Commands
```bash
make clean          # Clean up Docker resources
make clean-all      # Clean up everything including images
```

## Usage Examples

### Testing the API

```bash
# Check Janus info
curl http://localhost:8088/janus/info

# Check admin API
curl http://localhost:8188/admin/info

# Create a session
curl -X POST -H "Content-Type: application/json" \
  -d '{"janus": "create", "transaction": "test"}' \
  http://localhost:8088/janus
```

### WebSocket Testing

```bash
# Using wscat (npm install -g wscat)
wscat -c ws://localhost:8189

# Send create session message
{"janus": "create", "transaction": "test"}
```

### Accessing Management Interfaces

**Full Stack Setup:**
- RabbitMQ Management: http://localhost:15672
  - Username: `janus`
  - Password: from `.env` file (default: `janus123`)
- Graylog: http://localhost:9000
  - Username: `admin`
  - Password: `admin`

## Directory Structure

```
.
├── docker-compose.yml          # Basic setup
├── docker-compose.dev.yml      # Development setup
├── docker-compose.full.yml     # Full stack setup
├── .env.example                # Environment variables template
├── Makefile                    # Helper commands
├── configs/                    # Custom Janus configs
├── recordings/                 # Recording storage
├── logs/                       # Log files
├── nginx/                      # Nginx configuration
├── rabbitmq/                   # RabbitMQ configuration
├── redis/                      # Redis configuration
├── graylog/                    # Graylog configuration
└── html/                       # Static web files
```

## Custom Configuration

### Custom Janus Configs

Place your custom configuration files in the `configs/` directory:

```bash
mkdir -p configs
# Copy and modify default configs
docker run --rm -v $(pwd)/configs:/target swmansion/janus-gateway:1.3.2-0 \
  cp -r /opt/janus/etc/janus/* /target/
```

### SSL Certificates for Nginx

Place SSL certificates in `nginx/ssl/`:

```bash
mkdir -p nginx/ssl
# Place your cert.pem and key.pem files
cp your-cert.pem nginx/ssl/cert.pem
cp your-key.pem nginx/ssl/key.pem
```

### Custom Web Interface

Place your web application files in `html/`:

```bash
mkdir -p html
# Copy your web application files
cp -r your-web-app/* html/
```

## Troubleshooting

### Common Issues

1. **Gateway IP Configuration**
   - Make sure `GATEWAY_IP` in `.env` is set to your actual local IP
   - Use `ifconfig` or `ip addr` to find your IP address

2. **Port Conflicts**
   - Make sure ports 8088, 8188, 8189, and 10000-10099 are available
   - Modify port mappings in docker-compose files if needed

3. **Permission Issues**
   - Make sure the `recordings` and `logs` directories are writable
   - Run `chmod 755 recordings logs` if needed

4. **Docker Issues**
   - Make sure Docker is running and you have sufficient permissions
   - Run `docker info` to check Docker status

### Debugging

```bash
# Check container logs
make logs

# Access container shell
make shell

# Check container status
docker ps

# Inspect container
docker inspect janus-gateway
```

## Development Workflow

1. **Initial Setup**
   ```bash
   make dev-start
   ```

2. **Development**
   ```bash
   make shell-dev
   # Make changes inside the container
   ```

3. **Testing**
   ```bash
   make test
   make test-websocket
   ```

4. **Cleanup**
   ```bash
   make stop-dev
   make clean
   ```

## Production Deployment

For production deployment, use the full stack setup:

1. Configure all environment variables in `.env`
2. Set up SSL certificates
3. Configure proper logging and monitoring
4. Set up backup strategies for data volumes
5. Review security settings

```bash
make full-start
```

## Support

- Janus Gateway Documentation: https://janus.conf.meetecho.com/docs/
- Docker Compose Documentation: https://docs.docker.com/compose/
- Issues: Report issues in the project repository