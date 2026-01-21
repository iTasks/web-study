# Helm Chart Example - Web Application

This is a production-ready Helm chart for deploying a web application to Kubernetes.

## Chart Structure

```
helm-webapp/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration values
└── templates/          # Kubernetes resource templates
    └── deployment.yaml # Deployment template
```

## Features

- **Autoscaling**: Horizontal Pod Autoscaler (HPA) enabled
- **Resource Management**: CPU and memory limits/requests
- **Ingress**: Optional ingress with TLS support
- **Health Checks**: Liveness and readiness probes
- **Configurable**: All settings in values.yaml

## Installation

```bash
# Install with default values
helm install myapp ./helm-webapp

# Install with custom values
helm install myapp ./helm-webapp \
  --set replicaCount=5 \
  --set image.tag=2.0

# Install with values file
helm install myapp ./helm-webapp -f custom-values.yaml
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade myapp ./helm-webapp \
  --set image.tag=2.1

# Rollback to previous version
helm rollback myapp
```

## Uninstallation

```bash
helm uninstall myapp
```

## Customization

Edit `values.yaml` to customize:
- Number of replicas
- Image repository and tag
- Resource limits
- Autoscaling parameters
- Ingress configuration
- Environment variables

## Example: Custom Values

Create `custom-values.yaml`:
```yaml
replicaCount: 5

image:
  repository: myregistry/myapp
  tag: "2.0"

resources:
  limits:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  minReplicas: 5
  maxReplicas: 20
```

Then install:
```bash
helm install myapp ./helm-webapp -f custom-values.yaml
```
