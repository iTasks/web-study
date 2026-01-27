#!/bin/bash
# Setup script for the production Flask application

echo "🚀 Setting up Production Flask Application..."

# Check Python version
echo "Checking Python version..."
python3 --version

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Setup environment
echo "Setting up environment variables..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✓ .env file created. Please update it with your configuration."
else
    echo "✓ .env file already exists."
fi

# Generate gRPC files
echo "Generating gRPC files..."
cd app/grpc_service
python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. service.proto
cd ../..

# Create logs directory
echo "Creating logs directory..."
mkdir -p logs

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Activate virtual environment: source venv/bin/activate"
echo "2. Update .env file with your configuration"
echo "3. Run the application: python run.py"
echo "4. Run gRPC server (in separate terminal): python -m app.grpc_service.server"
echo "5. Visit http://localhost:5000 to see the application"
echo ""
