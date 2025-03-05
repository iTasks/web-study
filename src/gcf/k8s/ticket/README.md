# Ticker

## Overview
This directory contains the Ticker service for Kubernetes.

## Running Instructions
1. Ensure you have [Docker](https://www.docker.com/) and [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.
2. Build the Docker image:
   `docker build -t ticker .`
3. Deploy to Kubernetes:
   `kubectl apply -f ticker-deployment.yaml`

## References
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
