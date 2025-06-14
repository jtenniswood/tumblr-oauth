#!/bin/bash

# Tumblr OAuth App - Easy Run Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Tumblr OAuth App Setup${NC}"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Docker Compose is not available. Please install Docker Compose.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are available${NC}"

# Function to build and run with Docker Compose
run_with_compose() {
    echo -e "${YELLOW}📦 Building and starting the application...${NC}"
    $COMPOSE_CMD -f docker/docker-compose.yml up --build -d
    
    echo -e "${GREEN}✅ Application is starting!${NC}"
    echo -e "${BLUE}🌐 The app will be available at: http://localhost:8080${NC}"
    echo ""
    echo -e "${YELLOW}📋 Useful commands:${NC}"
    echo -e "  View logs:    ${COMPOSE_CMD} -f docker/docker-compose.yml logs -f"
    echo -e "  Stop app:     ${COMPOSE_CMD} -f docker/docker-compose.yml down"
    echo -e "  Restart:      ${COMPOSE_CMD} -f docker/docker-compose.yml restart"
    echo ""
    
    # Wait a moment and check if the container is running
    sleep 3
    if $COMPOSE_CMD -f docker/docker-compose.yml ps | grep -q "Up"; then
        echo -e "${GREEN}🎉 Application is running successfully!${NC}"
        echo -e "${BLUE}Visit http://localhost:8080 to get started${NC}"
    else
        echo -e "${RED}❌ Something went wrong. Check logs with: ${COMPOSE_CMD} logs${NC}"
    fi
}

# Function to build and run with Docker directly
run_with_docker() {
    echo -e "${YELLOW}📦 Building Docker image...${NC}"
    docker build -f docker/Dockerfile -t tumblr-oauth-app .
    
    echo -e "${YELLOW}🚀 Starting container...${NC}"
    docker run -d --name tumblr-oauth-app -p 8080:5000 tumblr-oauth-app
    
    echo -e "${GREEN}✅ Application is starting!${NC}"
    echo -e "${BLUE}🌐 The app will be available at: http://localhost:8080${NC}"
    echo ""
    echo -e "${YELLOW}📋 Useful commands:${NC}"
    echo -e "  View logs:    docker logs tumblr-oauth-app -f"
    echo -e "  Stop app:     docker stop tumblr-oauth-app"
    echo -e "  Remove:       docker rm tumblr-oauth-app"
    echo ""
    
    # Wait a moment and check if the container is running
    sleep 3
    if docker ps | grep -q "tumblr-oauth-app"; then
        echo -e "${GREEN}🎉 Application is running successfully!${NC}"
        echo -e "${BLUE}Visit http://localhost:8080 to get started${NC}"
    else
        echo -e "${RED}❌ Something went wrong. Check logs with: docker logs tumblr-oauth-app${NC}"
    fi
}

# Check for command line arguments
case "${1:-}" in
    "compose"|"docker-compose")
        run_with_compose
        ;;
    "docker")
        run_with_docker
        ;;
    "stop")
        echo -e "${YELLOW}🛑 Stopping application...${NC}"
        if command -v $COMPOSE_CMD &> /dev/null && [ -f docker/docker-compose.yml ]; then
            $COMPOSE_CMD -f docker/docker-compose.yml down
        fi
        if docker ps | grep -q "tumblr-oauth-app"; then
            docker stop tumblr-oauth-app
            docker rm tumblr-oauth-app
        fi
        echo -e "${GREEN}✅ Application stopped${NC}"
        ;;
    "logs")
        echo -e "${BLUE}📄 Showing application logs...${NC}"
        if command -v $COMPOSE_CMD &> /dev/null && [ -f docker/docker-compose.yml ]; then
            $COMPOSE_CMD -f docker/docker-compose.yml logs -f
        elif docker ps | grep -q "tumblr-oauth-app"; then
            docker logs tumblr-oauth-app -f
        else
            echo -e "${RED}❌ No running application found${NC}"
        fi
        ;;
    "help"|"-h"|"--help")
        echo -e "${BLUE}Usage: $0 [command]${NC}"
        echo ""
        echo "Commands:"
        echo "  (no args)     - Run with Docker Compose (default)"
        echo "  compose       - Run with Docker Compose"
        echo "  docker        - Run with Docker directly"
        echo "  stop          - Stop the application"
        echo "  logs          - Show application logs"
        echo "  help          - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                    # Start with Docker Compose"
        echo "  $0 docker             # Start with Docker directly"
        echo "  $0 stop               # Stop the application"
        echo "  $0 logs               # View logs"
        ;;
    *)
        # Default: use Docker Compose if available, otherwise Docker
        if [ -f docker/docker-compose.yml ]; then
            run_with_compose
        else
            run_with_docker
        fi
        ;;
esac 