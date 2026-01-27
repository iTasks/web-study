FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Generate gRPC files
RUN cd app/grpc_service && \
    python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. service.proto || true

# Create necessary directories
RUN mkdir -p logs

# Expose ports
EXPOSE 5000 50051

# Run with gunicorn for production
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "--timeout", "120", "run:app"]
