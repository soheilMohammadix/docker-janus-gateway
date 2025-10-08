# Kubernetes Manifests for Janus Gateway

This directory contains Kubernetes manifests to deploy Janus WebRTC Gateway.

## Files Overview

- `namespace.yaml` - Creates the janus-gateway namespace
- `configmap.yaml` - Janus configuration
- `secret.yaml` - Sensitive data (passwords, keys)
- `deployment.yaml` - Main deployment configuration
- `service.yaml` - Services for HTTP, Admin, WebSocket, and UDP traffic
- `ingress.yaml` - Ingress configuration for external access
- `pvc.yaml` - Persistent storage for recordings and logs
- `networkpolicy.yaml` - Network security policies
- `hpa.yaml` - Horizontal Pod Autoscaler configuration

## Deployment

### Quick Start
```bash
kubectl apply -f k8s/
```

### Step by Step
```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy configuration and secrets
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

# Deploy storage
kubectl apply -f k8s/pvc.yaml

# Deploy the application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Configure external access
kubectl apply -f k8s/ingress.yaml

# Optional: Configure autoscaling and security
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/networkpolicy.yaml
```

## Configuration

### Environment Variables
Update the `secret.yaml` file with your actual secrets:
```bash
# Base64 encode your secrets
echo -n "your-admin-secret" | base64
echo -n "your-videoroom-key" | base64
echo -n "your-streaming-key" | base64
```

### Ingress Configuration
Update the hostnames in `ingress.yaml` to match your domain:
```yaml
- host: janus.yourdomain.com
- host: janus-ws.yourdomain.com
```

### Storage
The PVCs use the `standard` storage class. Adjust the storage class and sizes based on your cluster setup.

## Access

Once deployed, you can access Janus Gateway at:
- HTTP API: `http://janus.yourdomain.com`
- WebSocket: `ws://janus-ws.yourdomain.com`
- Admin API: Internal only (port 8188)

## Monitoring

Check the deployment status:
```bash
kubectl get pods -n janus-gateway
kubectl logs -f deployment/janus-gateway -n janus-gateway
```

## Scaling

The HPA will automatically scale the deployment based on CPU and memory usage. You can also manually scale:
```bash
kubectl scale deployment janus-gateway --replicas=3 -n janus-gateway
```