#!/bin/bash

# EvoAgentX Deployment Script
# Usage: ./deploy.sh [port] [domain]

set -e

# Default values
DEFAULT_PORT=88888
DEFAULT_DOMAIN="evoagentx.evoagentx.naranja.lucienfc.eu.org"

# Parse arguments
PORT=${1:-$DEFAULT_PORT}
DOMAIN=${2:-$DEFAULT_DOMAIN}

echo "🚀 Deploying EvoAgentX..."
echo "📌 Port: $PORT"
echo "🌐 Domain: $DOMAIN"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update the .env file with your API keys before continuing."
    echo "   Required keys: OPENAI_API_KEY, ANTHROPIC_API_KEY, VOYAGE_API_KEY"
    read -p "   Press Enter to continue or Ctrl+C to cancel and update .env file..."
fi

# Update docker-compose.yml with custom port
echo "⚙️  Configuring application to run on port $PORT..."
sed -i.bak "s/8000:8000/${PORT}:8000/g" docker-compose.yml

# Build and start containers
echo "🔨 Building Docker images..."
docker-compose build

echo "🚀 Starting containers..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ All services are running!"
else
    echo "❌ Some services failed to start. Check logs with: docker-compose logs"
    exit 1
fi

# Display access information
echo ""
echo "==============================================="
echo "🎉 EvoAgentX Deployment Complete!"
echo "==============================================="
echo ""
echo "📊 Service Status:"
docker-compose ps
echo ""
echo "🌐 Access URLs:"
echo "   - API: http://localhost:${PORT}/"
echo "   - API Documentation: http://localhost:${PORT}/docs"
echo "   - ReDoc: http://localhost:${PORT}/redoc"
echo "   - Health Check: http://localhost:${PORT}/"
echo ""
echo "🔧 Management Commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop services: docker-compose down"
echo "   - Restart services: docker-compose restart"
echo "   - Rebuild and restart: docker-compose up -d --build"
echo ""
echo "⚠️  Important Notes:"
echo "   1. The application uses MongoDB and Redis. Data is persisted in Docker volumes."
echo "   2. Default MongoDB credentials: admin/admin123"
echo "   3. Application database: evoagentx"
echo "   4. Update the .env file with your actual API keys for full functionality."
echo ""
echo "📝 For domain setup with HTTPS (optional):"
echo "   Edit the nginx.conf file and set up SSL certificates in the ssl/ directory."
echo "   Then uncomment the nginx service in docker-compose.yml."
echo "==============================================="

# Create a simple health check
echo ""
echo "🩺 Testing API health..."
curl -f http://localhost:${PORT}/ || echo "⚠️  API health check failed (may still be starting up)"