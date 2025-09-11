#!/bin/bash

# Kestra Enhanced - WSL2 Hot Reload Development Deployment Script
# This script sets up and runs Kestra with hot-reload development mode
# Optimized for WSL2 environment with proper port forwarding and process management

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKEND_PORT=8080
FRONTEND_PORT=3000
PROJECT_NAME="kestra-enhanced"
LOG_DIR="./logs"
PID_FILE="./kestra.pid"

# Create logs directory
mkdir -p "$LOG_DIR"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    lsof -i ":$1" >/dev/null 2>&1
}

# Function to kill process on port
kill_port() {
    local port=$1
    local pids=$(lsof -ti ":$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        print_warning "Killing processes on port $port: $pids"
        echo "$pids" | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up processes..."
    
    # Kill backend process
    if [ -f "$PID_FILE" ]; then
        local backend_pid=$(cat "$PID_FILE" 2>/dev/null || true)
        if [ -n "$backend_pid" ] && kill -0 "$backend_pid" 2>/dev/null; then
            print_status "Stopping backend process (PID: $backend_pid)"
            kill -TERM "$backend_pid" 2>/dev/null || true
            sleep 3
            kill -KILL "$backend_pid" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    fi
    
    # Kill any remaining processes on our ports
    kill_port $BACKEND_PORT
    kill_port $FRONTEND_PORT
    
    print_success "Cleanup completed"
}

# Set trap for cleanup on script exit
trap cleanup EXIT INT TERM

# Function to check prerequisites
check_prerequisites() {
    print_header "🔍 Checking Prerequisites..."
    
    local missing_deps=()
    
    # Check Java
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$java_version" -ge 21 ] 2>/dev/null; then
            print_success "Java $java_version found"
        else
            print_error "Java 21+ required, found version: $java_version"
            missing_deps+=("java21")
        fi
    else
        print_error "Java not found"
        missing_deps+=("java21")
    fi
    
    # Check Node.js
    if command_exists node; then
        local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -ge 18 ] 2>/dev/null; then
            print_success "Node.js v$node_version found"
        else
            print_error "Node.js 18+ required, found version: v$node_version"
            missing_deps+=("nodejs")
        fi
    else
        print_error "Node.js not found"
        missing_deps+=("nodejs")
    fi
    
    # Check npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        print_success "npm v$npm_version found"
    else
        print_error "npm not found"
        missing_deps+=("npm")
    fi
    
    # Check Git
    if command_exists git; then
        print_success "Git found"
    else
        print_error "Git not found"
        missing_deps+=("git")
    fi
    
    # Check if we're in WSL2
    if grep -qi microsoft /proc/version 2>/dev/null; then
        print_success "Running in WSL2 environment"
        export WSL_ENV=true
    else
        print_warning "Not running in WSL2 - some features may not work optimally"
        export WSL_ENV=false
    fi
    
    # Report missing dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "To install missing dependencies:"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install openjdk-21-jdk nodejs npm git"
        echo "  Or use the installation commands from the README.md"
        exit 1
    fi
    
    print_success "All prerequisites satisfied!"
}

# Function to setup environment
setup_environment() {
    print_header "⚙️ Setting up Environment..."
    
    # Set Java options for better performance in WSL2
    export JAVA_OPTS="-Xmx4g -XX:+UseG1GC -XX:+UseStringDeduplication"
    export GRADLE_OPTS="-Xmx2g -XX:+UseG1GC"
    
    # Set Node.js options for better memory management
    export NODE_OPTIONS="--max-old-space-size=4096"
    
    # WSL2 specific optimizations
    if [ "$WSL_ENV" = true ]; then
        # Increase file watchers for hot reload
        echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf >/dev/null 2>&1 || true
        sudo sysctl -p >/dev/null 2>&1 || true
        
        # Set WSL2 specific environment variables
        export CHOKIDAR_USEPOLLING=true
        export WATCHPACK_POLLING=true
    fi
    
    print_success "Environment configured"
}

# Function to check and clean ports
prepare_ports() {
    print_header "🔌 Preparing Ports..."
    
    # Check if ports are available
    if port_in_use $BACKEND_PORT; then
        print_warning "Port $BACKEND_PORT is in use"
        kill_port $BACKEND_PORT
    fi
    
    if port_in_use $FRONTEND_PORT; then
        print_warning "Port $FRONTEND_PORT is in use"
        kill_port $FRONTEND_PORT
    fi
    
    # Wait a moment for ports to be freed
    sleep 2
    
    # Verify ports are now free
    if port_in_use $BACKEND_PORT; then
        print_error "Unable to free port $BACKEND_PORT"
        exit 1
    fi
    
    if port_in_use $FRONTEND_PORT; then
        print_error "Unable to free port $FRONTEND_PORT"
        exit 1
    fi
    
    print_success "Ports $BACKEND_PORT and $FRONTEND_PORT are ready"
}

# Function to build backend
build_backend() {
    print_header "🏗️ Building Backend..."
    
    # Make gradlew executable
    chmod +x ./gradlew
    
    # Clean and build (skip tests for faster startup)
    print_status "Running Gradle build (this may take a few minutes)..."
    ./gradlew clean build -x test --parallel --build-cache 2>&1 | tee "$LOG_DIR/gradle-build.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Backend build completed"
    else
        print_error "Backend build failed. Check $LOG_DIR/gradle-build.log for details"
        exit 1
    fi
}

# Function to setup frontend
setup_frontend() {
    print_header "📦 Setting up Frontend..."
    
    cd ui
    
    # Check if node_modules exists and is recent
    if [ -d "node_modules" ] && [ "package.json" -ot "node_modules" ]; then
        print_status "Node modules are up to date"
    else
        print_status "Installing/updating npm dependencies..."
        npm ci --prefer-offline --no-audit 2>&1 | tee "../$LOG_DIR/npm-install.log"
        
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            print_success "Frontend dependencies installed"
        else
            print_error "Frontend dependency installation failed. Check $LOG_DIR/npm-install.log for details"
            cd ..
            exit 1
        fi
    fi
    
    cd ..
}

# Function to start backend
start_backend() {
    print_header "🚀 Starting Backend Server..."
    
    print_status "Starting Kestra server on port $BACKEND_PORT..."
    
    # Start backend in background
    nohup ./gradlew run --args="server standalone" > "$LOG_DIR/backend.log" 2>&1 &
    local backend_pid=$!
    echo $backend_pid > "$PID_FILE"
    
    print_status "Backend starting with PID: $backend_pid"
    print_status "Waiting for backend to be ready..."
    
    # Wait for backend to start (max 120 seconds)
    local count=0
    local max_attempts=120
    
    while [ $count -lt $max_attempts ]; do
        if curl -s "http://localhost:$BACKEND_PORT/api/v1/flows" >/dev/null 2>&1; then
            print_success "Backend is ready! (http://localhost:$BACKEND_PORT)"
            return 0
        fi
        
        # Check if process is still running
        if ! kill -0 $backend_pid 2>/dev/null; then
            print_error "Backend process died. Check $LOG_DIR/backend.log for details"
            tail -20 "$LOG_DIR/backend.log"
            exit 1
        fi
        
        sleep 1
        count=$((count + 1))
        
        # Show progress every 10 seconds
        if [ $((count % 10)) -eq 0 ]; then
            print_status "Still waiting for backend... ($count/$max_attempts seconds)"
        fi
    done
    
    print_error "Backend failed to start within $max_attempts seconds"
    print_error "Check the backend log:"
    tail -20 "$LOG_DIR/backend.log"
    exit 1
}

# Function to start frontend
start_frontend() {
    print_header "🎨 Starting Frontend Development Server..."
    
    cd ui
    
    # Create development environment file if it doesn't exist
    if [ ! -f ".env.development" ]; then
        print_status "Creating development environment configuration..."
        cat > .env.development << EOF
# API Configuration
VITE_API_URL=http://localhost:$BACKEND_PORT
VITE_WS_URL=ws://localhost:$BACKEND_PORT

# Feature Flags
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_APPS=true
VITE_ENABLE_TESTS=true
VITE_ENABLE_CUSTOM_BLUEPRINTS=true

# Development Settings
VITE_DEV_MODE=true
VITE_LOG_LEVEL=debug
VITE_HOT_RELOAD=true

# WSL2 Optimizations
CHOKIDAR_USEPOLLING=true
WATCHPACK_POLLING=true
EOF
        print_success "Development environment configured"
    fi
    
    print_status "Starting Vite development server on port $FRONTEND_PORT..."
    print_status "Frontend will be available at: http://localhost:$FRONTEND_PORT"
    
    # Start frontend with hot reload
    npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT 2>&1 | tee "../$LOG_DIR/frontend.log" &
    local frontend_pid=$!
    
    cd ..
    
    print_status "Frontend starting with PID: $frontend_pid"
    print_status "Waiting for frontend to be ready..."
    
    # Wait for frontend to start (max 60 seconds)
    local count=0
    local max_attempts=60
    
    while [ $count -lt $max_attempts ]; do
        if curl -s "http://localhost:$FRONTEND_PORT" >/dev/null 2>&1; then
            print_success "Frontend is ready! (http://localhost:$FRONTEND_PORT)"
            return 0
        fi
        
        # Check if process is still running
        if ! kill -0 $frontend_pid 2>/dev/null; then
            print_error "Frontend process died. Check $LOG_DIR/frontend.log for details"
            tail -20 "$LOG_DIR/frontend.log"
            exit 1
        fi
        
        sleep 1
        count=$((count + 1))
        
        # Show progress every 10 seconds
        if [ $((count % 10)) -eq 0 ]; then
            print_status "Still waiting for frontend... ($count/$max_attempts seconds)"
        fi
    done
    
    print_error "Frontend failed to start within $max_attempts seconds"
    print_error "Check the frontend log:"
    tail -20 "$LOG_DIR/frontend.log"
    exit 1
}

# Function to show status and URLs
show_status() {
    print_header "✅ Deployment Complete!"
    
    echo ""
    echo -e "${GREEN}🎉 Kestra Enhanced is now running in development mode!${NC}"
    echo ""
    echo -e "${CYAN}📍 Access URLs:${NC}"
    echo -e "   🖥️  Frontend (Hot Reload): ${YELLOW}http://localhost:$FRONTEND_PORT${NC}"
    echo -e "   🔧 Backend API:           ${YELLOW}http://localhost:$BACKEND_PORT${NC}"
    echo -e "   📊 Production UI:         ${YELLOW}http://localhost:$BACKEND_PORT${NC}"
    echo ""
    echo -e "${CYAN}🔧 Enhanced Features Available:${NC}"
    echo -e "   🤖 AI Copilot:           ${YELLOW}http://localhost:$FRONTEND_PORT/ai${NC}"
    echo -e "   📱 Apps Management:      ${YELLOW}http://localhost:$FRONTEND_PORT/apps${NC}"
    echo -e "   🧪 Tests Suite:          ${YELLOW}http://localhost:$FRONTEND_PORT/tests${NC}"
    echo -e "   📋 Custom Blueprints:    ${YELLOW}http://localhost:$FRONTEND_PORT/blueprints${NC}"
    echo ""
    echo -e "${CYAN}📁 Log Files:${NC}"
    echo -e "   Backend:  $LOG_DIR/backend.log"
    echo -e "   Frontend: $LOG_DIR/frontend.log"
    echo -e "   Build:    $LOG_DIR/gradle-build.log"
    echo ""
    echo -e "${CYAN}🛠️ Development Tips:${NC}"
    echo -e "   • Edit Vue components in ui/src/ for instant hot reload"
    echo -e "   • Backend changes require restart (Ctrl+C then ./deploy.sh)"
    echo -e "   • Check logs with: tail -f $LOG_DIR/backend.log"
    echo -e "   • Monitor frontend: tail -f $LOG_DIR/frontend.log"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
}

# Function to monitor services
monitor_services() {
    print_status "Monitoring services... (Press Ctrl+C to stop)"
    
    while true; do
        # Check backend
        if [ -f "$PID_FILE" ]; then
            local backend_pid=$(cat "$PID_FILE" 2>/dev/null || true)
            if [ -n "$backend_pid" ] && ! kill -0 "$backend_pid" 2>/dev/null; then
                print_error "Backend process died unexpectedly!"
                print_error "Check $LOG_DIR/backend.log for details:"
                tail -10 "$LOG_DIR/backend.log"
                exit 1
            fi
        fi
        
        # Check if ports are still responding
        if ! curl -s "http://localhost:$BACKEND_PORT/api/v1/flows" >/dev/null 2>&1; then
            print_warning "Backend not responding on port $BACKEND_PORT"
        fi
        
        if ! curl -s "http://localhost:$FRONTEND_PORT" >/dev/null 2>&1; then
            print_warning "Frontend not responding on port $FRONTEND_PORT"
        fi
        
        sleep 10
    done
}

# Function to validate deployment
validate_deployment() {
    print_header "🔍 Validating Deployment..."
    
    local validation_errors=0
    
    # Test backend API
    print_status "Testing backend API..."
    if curl -s "http://localhost:$BACKEND_PORT/api/v1/flows" | grep -q "flows" 2>/dev/null; then
        print_success "Backend API is responding"
    else
        print_error "Backend API test failed"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Test frontend
    print_status "Testing frontend..."
    if curl -s "http://localhost:$FRONTEND_PORT" | grep -q "Kestra" 2>/dev/null; then
        print_success "Frontend is responding"
    else
        print_error "Frontend test failed"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Test enhanced features endpoints (these might not exist yet, so just check if they return something)
    print_status "Testing enhanced features..."
    local features_tested=0
    local features_working=0
    
    for endpoint in "/apps" "/tests" "/blueprints"; do
        features_tested=$((features_tested + 1))
        if curl -s "http://localhost:$FRONTEND_PORT$endpoint" >/dev/null 2>&1; then
            features_working=$((features_working + 1))
        fi
    done
    
    print_status "Enhanced features: $features_working/$features_tested endpoints responding"
    
    if [ $validation_errors -eq 0 ]; then
        print_success "Deployment validation passed!"
        return 0
    else
        print_warning "Deployment validation completed with $validation_errors errors"
        return 1
    fi
}

# Main execution
main() {
    print_header "🚀 Kestra Enhanced - WSL2 Hot Reload Deployment"
    print_header "=================================================="
    
    # Check if we're in the right directory
    if [ ! -f "gradlew" ] || [ ! -d "ui" ]; then
        print_error "This script must be run from the Kestra project root directory"
        print_error "Make sure you have both 'gradlew' file and 'ui' directory"
        exit 1
    fi
    
    # Run all setup steps
    check_prerequisites
    setup_environment
    prepare_ports
    build_backend
    setup_frontend
    start_backend
    start_frontend
    
    # Validate deployment
    sleep 5  # Give services a moment to fully start
    validate_deployment
    
    # Show status and start monitoring
    show_status
    monitor_services
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Kestra Enhanced - WSL2 Hot Reload Deployment Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --validate     Only validate the deployment"
        echo "  --stop         Stop all running services"
        echo "  --logs         Show recent logs"
        echo ""
        echo "This script will:"
        echo "  1. Check prerequisites (Java 21+, Node.js 18+, npm, git)"
        echo "  2. Build the backend with Gradle"
        echo "  3. Install frontend dependencies"
        echo "  4. Start backend server on port $BACKEND_PORT"
        echo "  5. Start frontend dev server on port $FRONTEND_PORT"
        echo "  6. Enable hot reload for Vue.js components"
        echo "  7. Monitor services and provide access URLs"
        echo ""
        exit 0
        ;;
    --validate)
        validate_deployment
        exit $?
        ;;
    --stop)
        cleanup
        exit 0
        ;;
    --logs)
        echo "=== Backend Logs ==="
        tail -20 "$LOG_DIR/backend.log" 2>/dev/null || echo "No backend logs found"
        echo ""
        echo "=== Frontend Logs ==="
        tail -20 "$LOG_DIR/frontend.log" 2>/dev/null || echo "No frontend logs found"
        exit 0
        ;;
    "")
        # No arguments, run main deployment
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
