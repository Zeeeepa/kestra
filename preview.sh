#!/bin/bash

# Kestra Enterprise Features - Complete System Preview
# ====================================================
# This script starts the complete Kestra system for preview and testing

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKEND_PORT="8080"
FRONTEND_PORT="3000"
BACKEND_PID=""
FRONTEND_PID=""
PREVIEW_LOG="preview.log"

# Trap to cleanup on exit
cleanup() {
    echo ""
    log "${YELLOW}🛑 Shutting down Kestra system...${NC}"
    
    if [[ -n "$FRONTEND_PID" ]] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
        log "${BLUE}[INFO]${NC} Stopping frontend (PID: $FRONTEND_PID)..."
        kill -TERM "$FRONTEND_PID" 2>/dev/null || true
        wait "$FRONTEND_PID" 2>/dev/null || true
    fi
    
    if [[ -n "$BACKEND_PID" ]] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        log "${BLUE}[INFO]${NC} Stopping backend (PID: $BACKEND_PID)..."
        kill -TERM "$BACKEND_PID" 2>/dev/null || true
        wait "$BACKEND_PID" 2>/dev/null || true
    fi
    
    # Cleanup any remaining processes on our ports
    cleanup_ports $BACKEND_PORT "backend"
    cleanup_ports $FRONTEND_PORT "frontend"
    
    log "${GREEN}✅ Cleanup completed${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# Logging function
log() {
    echo -e "$1" | tee -a "$PREVIEW_LOG"
}

# Port cleanup function
cleanup_ports() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        local pids=$(lsof -Pi :$port -sTCP:LISTEN -t)
        log "${YELLOW}[WARNING]${NC} Cleaning up $service processes on port $port: $pids"
        echo $pids | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
}

# Wait for service to be ready
wait_for_service() {
    local port=$1
    local service=$2
    local max_attempts=60
    local attempt=1
    
    log "${BLUE}[INFO]${NC} Waiting for $service to start on port $port..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s "http://localhost:$port" >/dev/null 2>&1 || \
           nc -z localhost $port >/dev/null 2>&1; then
            log "${GREEN}[SUCCESS]${NC} $service is ready on port $port"
            return 0
        fi
        
        if [[ $((attempt % 10)) -eq 0 ]]; then
            log "${YELLOW}[INFO]${NC} Still waiting for $service... (${attempt}s)"
        fi
        
        sleep 1
        ((attempt++))
    done
    
    log "${RED}[ERROR]${NC} $service failed to start within ${max_attempts}s"
    return 1
}

# Check if setup was completed
check_setup() {
    if [[ ! -f ".kestra-setup-complete" ]]; then
        log "${RED}[ERROR]${NC} System setup not completed!"
        log "${YELLOW}[INFO]${NC} Please run ${CYAN}./setup.sh${NC} first"
        exit 1
    fi
    
    if [[ ! -f "gradlew" ]]; then
        log "${RED}[ERROR]${NC} Gradle wrapper not found"
        exit 1
    fi
    
    if [[ ! -d "ui/node_modules" ]]; then
        log "${RED}[ERROR]${NC} Frontend dependencies not installed"
        log "${YELLOW}[INFO]${NC} Please run ${CYAN}./setup.sh${NC} first"
        exit 1
    fi
}

# Display system information
show_system_info() {
    log "${PURPLE}🖥️  System Information${NC}"
    log "${PURPLE}=====================${NC}"
    
    if [[ -f ".setup-complete" ]]; then
        source .setup-complete
        log "${BLUE}Setup Date:${NC}       $SETUP_DATE"
        log "${BLUE}System:${NC}           $SYSTEM"
        log "${BLUE}Java Version:${NC}     $JAVA_VERSION"
        log "${BLUE}Node Version:${NC}     $NODE_VERSION"
        log "${BLUE}Backend Port:${NC}     $BACKEND_PORT"
        log "${BLUE}Frontend Port:${NC}    $FRONTEND_PORT"
        log "${BLUE}Enterprise:${NC}       ${GREEN}$ENTERPRISE_FEATURES${NC}"
    else
        log "${BLUE}Java:${NC}             $(java -version 2>&1 | head -n1)"
        log "${BLUE}Node.js:${NC}          $(node -v)"
        log "${BLUE}Backend Port:${NC}     $BACKEND_PORT"
        log "${BLUE}Frontend Port:${NC}    $FRONTEND_PORT"
        log "${BLUE}Enterprise:${NC}       ${GREEN}ENABLED${NC}"
    fi
    log ""
}

# Display feature overview
show_features() {
    log "${PURPLE}🎯 Available Enterprise Features${NC}"
    log "${PURPLE}================================${NC}"
    log "${GREEN}✅ Apps Tab${NC}              - Complete layout block system (15 blocks)"
    log "${GREEN}✅ Tests Tab${NC}             - Comprehensive testing framework"
    log "${GREEN}✅ Secrets Tab${NC}           - Full secrets management"
    log "${GREEN}✅ Administration Tab${NC}    - IAM, Audit Logs, Instance Management"
    log "${GREEN}✅ Custom Blueprints${NC}     - Extensible block registry system"
    log ""
}

# Start backend service
start_backend() {
    log "${BLUE}🚀 Starting Kestra Backend Server...${NC}"
    
    # Set environment variables
    export JAVA_OPTS="-Xmx4g -XX:+UseG1GC -XX:+UseStringDeduplication"
    export KESTRA_CONFIGURATION_PATH="./config"
    
    # Start backend in background
    ./gradlew run --args="server standalone" > logs/backend.log 2>&1 &
    BACKEND_PID=$!
    
    log "${BLUE}[INFO]${NC} Backend started with PID: $BACKEND_PID"
    
    # Wait for backend to be ready
    if wait_for_service $BACKEND_PORT "Backend"; then
        log "${GREEN}✅ Backend server is running${NC}"
        log "${CYAN}   API URL: http://localhost:$BACKEND_PORT${NC}"
    else
        log "${RED}[ERROR]${NC} Backend failed to start"
        log "${YELLOW}[INFO]${NC} Check logs/backend.log for details"
        exit 1
    fi
}

# Start frontend service
start_frontend() {
    log "${BLUE}🎨 Starting Kestra Frontend Development Server...${NC}"
    
    # Set environment variables
    export NODE_OPTIONS="--max-old-space-size=4096"
    
    # WSL2 optimizations
    if grep -q Microsoft /proc/version 2>/dev/null; then
        export CHOKIDAR_USEPOLLING=true
        export WATCHPACK_POLLING=true
        export FORCE_COLOR=1
    fi
    
    # Start frontend in background
    cd ui
    npm run dev > ../logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ..
    
    log "${BLUE}[INFO]${NC} Frontend started with PID: $FRONTEND_PID"
    
    # Wait for frontend to be ready
    if wait_for_service $FRONTEND_PORT "Frontend"; then
        log "${GREEN}✅ Frontend development server is running${NC}"
        log "${CYAN}   Development URL: http://localhost:$FRONTEND_PORT${NC}"
    else
        log "${RED}[ERROR]${NC} Frontend failed to start"
        log "${YELLOW}[INFO]${NC} Check logs/frontend.log for details"
        exit 1
    fi
}

# Display access information
show_access_info() {
    log ""
    log "${GREEN}🌐 Access URLs${NC}"
    log "${GREEN}==============${NC}"
    log "${CYAN}🎨 Frontend (Development):${NC}  http://localhost:$FRONTEND_PORT"
    log "${CYAN}🔧 Backend API:${NC}             http://localhost:$BACKEND_PORT"
    log "${CYAN}📊 Production UI:${NC}           http://localhost:$BACKEND_PORT"
    log ""
    log "${YELLOW}📱 Available Features:${NC}"
    log "   • Apps Tab - Layout blocks and workflow management"
    log "   • Tests Tab - Testing framework and validation"
    log "   • Secrets Tab - Secrets management (no restrictions)"
    log "   • Administration - IAM, Audit Logs, Instance management"
    log "   • Custom Blueprints - Block registry and templates"
    log ""
}

# Display monitoring information
show_monitoring() {
    log "${PURPLE}📊 System Monitoring${NC}"
    log "${PURPLE}===================${NC}"
    log "${BLUE}Process Status:${NC}"
    log "   Backend PID:  ${CYAN}$BACKEND_PID${NC}"
    log "   Frontend PID: ${CYAN}$FRONTEND_PID${NC}"
    log ""
    log "${BLUE}Log Files:${NC}"
    log "   Backend:  ${CYAN}logs/backend.log${NC}"
    log "   Frontend: ${CYAN}logs/frontend.log${NC}"
    log "   Preview:  ${CYAN}$PREVIEW_LOG${NC}"
    log ""
    log "${YELLOW}💡 Monitoring Commands:${NC}"
    log "   tail -f logs/backend.log   # Watch backend logs"
    log "   tail -f logs/frontend.log  # Watch frontend logs"
    log "   ./validate-implementation.sh  # Run system validation"
    log ""
}

# Main execution
main() {
    # Clear previous log
    > "$PREVIEW_LOG"
    
    # Header
    clear
    log "${PURPLE}🚀 Kestra Enterprise Features - System Preview${NC}"
    log "${PURPLE}===============================================${NC}"
    log "${BLUE}Starting complete Kestra system with all enterprise features...${NC}"
    log ""
    
    # Pre-flight checks
    log "${YELLOW}🔍 Pre-flight Checks${NC}"
    check_setup
    log "${GREEN}✅ Setup validation passed${NC}"
    log ""
    
    # Show system information
    show_system_info
    show_features
    
    # Create logs directory
    mkdir -p logs
    
    # Cleanup any existing processes
    cleanup_ports $BACKEND_PORT "backend"
    cleanup_ports $FRONTEND_PORT "frontend"
    
    # Start services
    start_backend
    sleep 3  # Give backend a moment to stabilize
    start_frontend
    
    # Show access information
    show_access_info
    show_monitoring
    
    # Success message
    log "${GREEN}🎉 Kestra Enterprise System is now running!${NC}"
    log "${GREEN}===========================================${NC}"
    log ""
    log "${YELLOW}🎯 Quick Start:${NC}"
    log "   1. Open ${CYAN}http://localhost:$FRONTEND_PORT${NC} in your browser"
    log "   2. Explore all enterprise features (Apps, Tests, Secrets, Administration, Blueprints)"
    log "   3. Press ${CYAN}Ctrl+C${NC} to stop the system"
    log ""
    log "${BLUE}[INFO]${NC} System is ready for use. Press Ctrl+C to stop..."
    
    # Keep the script running and monitor services
    while true; do
        # Check if services are still running
        if [[ -n "$BACKEND_PID" ]] && ! kill -0 "$BACKEND_PID" 2>/dev/null; then
            log "${RED}[ERROR]${NC} Backend process died unexpectedly"
            log "${YELLOW}[INFO]${NC} Check logs/backend.log for details"
            exit 1
        fi
        
        if [[ -n "$FRONTEND_PID" ]] && ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
            log "${RED}[ERROR]${NC} Frontend process died unexpectedly"
            log "${YELLOW}[INFO]${NC} Check logs/frontend.log for details"
            exit 1
        fi
        
        sleep 5
    done
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Kestra Enterprise Features - System Preview"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --status       Show system status"
        echo "  --logs         Show recent logs"
        echo "  --validate     Run system validation"
        echo ""
        echo "This script starts the complete Kestra system with all enterprise features:"
        echo "  • Backend server on port 8080"
        echo "  • Frontend development server on port 3000"
        echo "  • All enterprise features enabled (Apps, Tests, Secrets, Administration, Blueprints)"
        echo ""
        echo "Access URLs:"
        echo "  • Frontend: http://localhost:3000"
        echo "  • Backend:  http://localhost:8080"
        echo ""
        exit 0
        ;;
    --status)
        echo "🔍 Kestra System Status"
        echo "======================"
        
        if [[ -f ".kestra-setup-complete" ]]; then
            echo "✅ Setup: Complete"
        else
            echo "❌ Setup: Not completed (run ./setup.sh)"
        fi
        
        if lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "✅ Backend: Running on port $BACKEND_PORT"
        else
            echo "❌ Backend: Not running"
        fi
        
        if lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "✅ Frontend: Running on port $FRONTEND_PORT"
        else
            echo "❌ Frontend: Not running"
        fi
        
        exit 0
        ;;
    --logs)
        echo "📋 Recent System Logs"
        echo "===================="
        
        if [[ -f "logs/backend.log" ]]; then
            echo ""
            echo "🔧 Backend Logs (last 20 lines):"
            tail -20 logs/backend.log
        fi
        
        if [[ -f "logs/frontend.log" ]]; then
            echo ""
            echo "🎨 Frontend Logs (last 20 lines):"
            tail -20 logs/frontend.log
        fi
        
        exit 0
        ;;
    --validate)
        if [[ -f "validate-implementation.sh" ]]; then
            echo "🧪 Running System Validation..."
            ./validate-implementation.sh
        else
            echo "❌ Validation script not found"
            exit 1
        fi
        exit 0
        ;;
esac

# Run main function
main
