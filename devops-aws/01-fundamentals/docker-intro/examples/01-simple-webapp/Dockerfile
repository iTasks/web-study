# Use official Python runtime as base image
FROM python:3.11-slim

# Set metadata
LABEL maintainer="devops-student@example.com"
LABEL description="Simple Flask web application for Docker tutorial"
LABEL version="1.0"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PORT=5000 \
    ENV=production

# Set working directory
WORKDIR /app

# Copy requirements first (for better layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose the application port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run the application
CMD ["python", "app.py"]
