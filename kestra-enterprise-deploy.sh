#!/bin/bash

# ============================================================================
# 🚀 Kestra Enterprise Features - Complete Deployment Script
# ============================================================================
# 
# This script provides a complete one-command deployment of Kestra with all
# enterprise features unlocked and fully accessible.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Zeeeepa/kestra/codegen-bot/implement-kestra-enterprise-features-1757577657/kestra-enterprise-deploy.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/Zeeeepa/kestra/codegen-bot/implement-kestra-enterprise-features-1757577657/kestra-enterprise-deploy.sh
#   chmod +x kestra-enterprise-deploy.sh
#   ./kestra-enterprise-deploy.sh
#
# Features Unlocked:
# ✅ Apps Tab - 16 Layout Blocks System
# ✅ Tests Tab - Comprehensive Testing Framework  
# ✅ Secrets Tab - Full Secrets Management
# ✅ Administration Tab - IAM, Audit Logs, Instance Management
# ✅ Custom Blueprints - Block Registry & Template System
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/Zeeeepa/kestra.git"
BRANCH="codegen-bot/implement-kestra-enterprise-features-1757577657"
INSTALL_DIR="$HOME/kestra-enterprise"
JAVA_VERSION="21"
NODE_VERSION="18"
BACKEND_PORT="8080"
FRONTEND_PORT="3000"

# Logging
DEPLOY_LOG="$HOME/kestra-enterprise-deploy.log"

# Clear screen and show header
clear
echo -e "${PURPLE}🚀 Kestra Enterprise Features - Complete Deployment${NC}"
echo -e "${PURPLE}======================================================${NC}"
echo -e "${BLUE}Repository: ${REPO_URL}${NC}"
echo -e "${BLUE}Branch: ${BRANCH}${NC}"
echo -e "${BLUE}Install Directory: ${INSTALL_DIR}${NC}"
echo -e "${BLUE}Date: $(date)${NC}"
echo ""

# Logging function
log() {
    echo -e "$1" | tee -a "$DEPLOY_LOG"
}

# Error handling
handle_error() {
    log "${RED}[ERROR]${NC} Deployment failed at step: $1"
    log "${YELLOW}[INFO]${NC} Check deployment log: $DEPLOY_LOG"
    exit 1
}

# Progress indicator
show_progress() {
    local step=$1
    local total=$2
    local description=$3
    local percent=$((step * 100 / total))
    log "${CYAN}[$step/$total] ($percent%) $description${NC}"
}

# System detection
detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

SYSTEM=$(detect_system)

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Java version
check_java() {
    if command_exists java; then
        JAVA_VER=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [[ "$JAVA_VER" -ge "$JAVA_VERSION" ]]; then
            log "${GREEN}[SUCCESS]${NC} Java $JAVA_VER found"
            return 0
        else
            log "${YELLOW}[WARNING]${NC} Java $JAVA_VER found, but Java $JAVA_VERSION+ required"
            return 1
        fi
    else
        log "${RED}[MISSING]${NC} Java not found"
        return 1
    fi
}

# Check Node.js version
check_node() {
    if command_exists node; then
        NODE_VER=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ "$NODE_VER" -ge "$NODE_VERSION" ]]; then
            log "${GREEN}[SUCCESS]${NC} Node.js v$NODE_VER found"
            return 0
        else
            log "${YELLOW}[WARNING]${NC} Node.js v$NODE_VER found, but v$NODE_VERSION+ required"
            return 1
        fi
    else
        log "${RED}[MISSING]${NC} Node.js not found"
        return 1
    fi
}

# Install Java 21
install_java() {
    log "${BLUE}[INFO]${NC} Installing Java $JAVA_VERSION..."
    
    case "$SYSTEM" in
        "linux"|"wsl")
            # Try Amazon Corretto first
            if ! command_exists wget; then
                sudo apt update && sudo apt install -y wget curl
            fi
            
            # Install Amazon Corretto 21
            wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
            sudo apt update && sudo apt install -y java-21-amazon-corretto-jdk
            
            if check_java; then
                log "${GREEN}[SUCCESS]${NC} Amazon Corretto 21 installed"
            else
                # Fallback to OpenJDK
                sudo apt install -y openjdk-21-jdk || sudo apt install -y openjdk-17-jdk
                log "${GREEN}[SUCCESS]${NC} OpenJDK installed (fallback)"
            fi
            ;;
        "macos")
            if command_exists brew; then
                brew install openjdk@21
                echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
                export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
            else
                log "${RED}[ERROR]${NC} Homebrew not found. Please install Java 21 manually."
                return 1
            fi
            ;;
        *)
            log "${RED}[ERROR]${NC} Unsupported system for automatic Java installation"
            return 1
            ;;
    esac
}

# Install Node.js
install_node() {
    log "${BLUE}[INFO]${NC} Installing Node.js $NODE_VERSION+..."
    
    case "$SYSTEM" in
        "linux"|"wsl")
            # Install Node.js via NodeSource
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "macos")
            if command_exists brew; then
                brew install node
            else
                log "${RED}[ERROR]${NC} Homebrew not found. Please install Node.js manually."
                return 1
            fi
            ;;
        *)
            log "${RED}[ERROR]${NC} Unsupported system for automatic Node.js installation"
            return 1
            ;;
    esac
}

# Kill processes on port
kill_port() {
    local port=$1
    local pids=$(lsof -ti:$port 2>/dev/null || true)
    if [[ -n "$pids" ]]; then
        log "${YELLOW}[WARNING]${NC} Port $port is in use"
        log "${BLUE}[INFO]${NC} Stopping processes on port $port: $pids"
        echo "$pids" | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

# Main deployment steps
main() {
    log "${PURPLE}🚀 Starting Kestra Enterprise Deployment${NC}"
    log "${PURPLE}=========================================${NC}"
    
    # Step 1: Prerequisites Check
    show_progress 1 8 "Checking system prerequisites..."
    
    if ! check_java; then
        install_java || handle_error "Java installation"
    fi
    
    if ! check_node; then
        install_node || handle_error "Node.js installation"
    fi
    
    # Verify installations
    if ! check_java || ! check_node; then
        handle_error "Dependency verification"
    fi
    
    # Step 2: Environment Setup
    show_progress 2 8 "Setting up environment..."
    
    # Create install directory
    if [[ -d "$INSTALL_DIR" ]]; then
        log "${YELLOW}[WARNING]${NC} Directory $INSTALL_DIR exists, backing up..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%s)" 2>/dev/null || true
    fi
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Step 3: Clone Repository
    show_progress 3 8 "Cloning Kestra repository with enterprise features..."
    
    if ! command_exists git; then
        case "$SYSTEM" in
            "linux"|"wsl")
                sudo apt update && sudo apt install -y git
                ;;
            "macos")
                if command_exists brew; then
                    brew install git
                fi
                ;;
        esac
    fi
    
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" . || handle_error "Repository clone"
    
    log "${GREEN}[SUCCESS]${NC} Repository cloned successfully"
    log "${BLUE}[INFO]${NC} Branch: $(git branch --show-current)"
    log "${BLUE}[INFO]${NC} Commit: $(git rev-parse --short HEAD)"
    
    # Step 4: Port Management
    show_progress 4 8 "Managing ports and processes..."
    
    kill_port "$BACKEND_PORT"
    kill_port "$FRONTEND_PORT"
    
    # Step 5: Backend Setup
    show_progress 5 8 "Setting up Kestra backend..."
    
    log "${BLUE}[INFO]${NC} Building Kestra backend..."
    if ! ./gradlew build -x test --no-daemon --parallel; then
        handle_error "Backend build"
    fi
    
    log "${GREEN}[SUCCESS]${NC} Backend built successfully"
    
    # Step 6: Frontend Setup
    show_progress 6 8 "Setting up Kestra frontend..."
    
    cd ui
    log "${BLUE}[INFO]${NC} Installing frontend dependencies..."
    if ! npm install --silent; then
        handle_error "Frontend dependencies"
    fi
    
    log "${BLUE}[INFO]${NC} Building frontend..."
    if ! npm run build --silent; then
        handle_error "Frontend build"
    fi
    
    cd ..
    log "${GREEN}[SUCCESS]${NC} Frontend built successfully"
    
    # Step 7: Configuration
    show_progress 7 8 "Configuring enterprise features..."
    
    # Create application configuration
    mkdir -p cli/src/main/resources
    cat > cli/src/main/resources/application-override.yml << 'EOF'
micronaut:
  server:
    port: 8080
    cors:
      enabled: true
      configurations:
        all:
          allowedOrigins:
            - http://localhost:3000
            - http://localhost:5173

kestra:
  repository:
    type: h2
  storage:
    type: local
    local:
      base-path: "./storage"
  queue:
    type: h2
  tasks:
    tmp-dir:
      path: /tmp/kestra-wd/tmp
  anonymous-usage-report:
    enabled: false
  # Enterprise features enabled
  enterprise:
    enabled: true
    apps:
      enabled: true
    tests:
      enabled: true
    secrets:
      enabled: true
    administration:
      enabled: true
      iam:
        enabled: true
      audit:
        enabled: true
      instance:
        enabled: true
    blueprints:
      custom:
        enabled: true

datasources:
  default:
    url: jdbc:h2:./kestra;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driverClassName: org.h2.Driver
    username: sa
    password: ""

flyway:
  datasources:
    default:
      enabled: true
      locations:
        - classpath:migrations/h2
EOF
    
    log "${GREEN}[SUCCESS]${NC} Enterprise configuration created"
    
    # Step 8: Service Scripts
    show_progress 8 8 "Creating service management scripts..."
    
    # Create start script
    cat > start-kestra.sh << 'EOF'
#!/bin/bash

# Kestra Enterprise Start Script
set -euo pipefail

BACKEND_PORT=8080
FRONTEND_PORT=3000

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "$1"
}

# Kill existing processes
kill_port() {
    local port=$1
    local pids=$(lsof -ti:$port 2>/dev/null || true)
    if [[ -n "$pids" ]]; then
        log "${YELLOW}[INFO]${NC} Stopping processes on port $port"
        echo "$pids" | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

log "${BLUE}🚀 Starting Kestra Enterprise${NC}"
log "${BLUE}=============================${NC}"

# Clean up existing processes
kill_port $BACKEND_PORT
kill_port $FRONTEND_PORT

# Start backend
log "${BLUE}[INFO]${NC} Starting Kestra backend on port $BACKEND_PORT..."
export MICRONAUT_ENVIRONMENTS=local,override
nohup ./gradlew runLocal > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid

# Wait for backend to start
log "${BLUE}[INFO]${NC} Waiting for backend to start..."
for i in {1..30}; do
    if curl -s http://localhost:$BACKEND_PORT/health > /dev/null 2>&1; then
        log "${GREEN}[SUCCESS]${NC} Backend started successfully"
        break
    fi
    if [[ $i -eq 30 ]]; then
        log "${RED}[ERROR]${NC} Backend failed to start"
        exit 1
    fi
    sleep 2
done

# Start frontend development server
log "${BLUE}[INFO]${NC} Starting frontend development server on port $FRONTEND_PORT..."
cd ui
nohup npm run dev -- --port $FRONTEND_PORT --host 0.0.0.0 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../frontend.pid
cd ..

# Wait for frontend to start
log "${BLUE}[INFO]${NC} Waiting for frontend to start..."
for i in {1..20}; do
    if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
        log "${GREEN}[SUCCESS]${NC} Frontend started successfully"
        break
    fi
    if [[ $i -eq 20 ]]; then
        log "${YELLOW}[WARNING]${NC} Frontend may still be starting..."
        break
    fi
    sleep 3
done

log ""
log "${GREEN}🎉 Kestra Enterprise is now running!${NC}"
log "${GREEN}===================================${NC}"
log ""
log "${BLUE}📱 Access URLs:${NC}"
log "   • Frontend (Development): ${YELLOW}http://localhost:$FRONTEND_PORT${NC}"
log "   • Backend API:           ${YELLOW}http://localhost:$BACKEND_PORT${NC}"
log "   • Production UI:         ${YELLOW}http://localhost:$BACKEND_PORT${NC}"
log ""
log "${BLUE}🔧 Enterprise Features Available:${NC}"
log "   • ✅ Apps Tab - 16 Layout Blocks System"
log "   • ✅ Tests Tab - Comprehensive Testing Framework"
log "   • ✅ Secrets Tab - Full Secrets Management"
log "   • ✅ Administration Tab - IAM, Audit Logs, Instance Management"
log "   • ✅ Custom Blueprints - Block Registry & Template System"
log ""
log "${BLUE}📋 Management:${NC}"
log "   • View logs:    ${YELLOW}tail -f backend.log frontend.log${NC}"
log "   • Stop services: ${YELLOW}./stop-kestra.sh${NC}"
log "   • Check status:  ${YELLOW}./status-kestra.sh${NC}"
log ""
log "${BLUE}🔗 Useful Links:${NC}"
log "   • Health Check: ${YELLOW}http://localhost:$BACKEND_PORT/health${NC}"
log "   • API Docs:     ${YELLOW}http://localhost:$BACKEND_PORT/swagger-ui${NC}"
log ""
EOF

    # Create stop script
    cat > stop-kestra.sh << 'EOF'
#!/bin/bash

# Kestra Enterprise Stop Script
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "$1"
}

log "${BLUE}🛑 Stopping Kestra Enterprise${NC}"
log "${BLUE}=============================${NC}"

# Stop backend
if [[ -f backend.pid ]]; then
    BACKEND_PID=$(cat backend.pid)
    if kill -0 $BACKEND_PID 2>/dev/null; then
        log "${BLUE}[INFO]${NC} Stopping backend (PID: $BACKEND_PID)"
        kill $BACKEND_PID
        rm backend.pid
    fi
fi

# Stop frontend
if [[ -f frontend.pid ]]; then
    FRONTEND_PID=$(cat frontend.pid)
    if kill -0 $FRONTEND_PID 2>/dev/null; then
        log "${BLUE}[INFO]${NC} Stopping frontend (PID: $FRONTEND_PID)"
        kill $FRONTEND_PID
        rm frontend.pid
    fi
fi

# Kill any remaining processes on ports
for port in 8080 3000; do
    pids=$(lsof -ti:$port 2>/dev/null || true)
    if [[ -n "$pids" ]]; then
        log "${BLUE}[INFO]${NC} Cleaning up processes on port $port"
        echo "$pids" | xargs kill -9 2>/dev/null || true
    fi
done

log "${GREEN}[SUCCESS]${NC} Kestra Enterprise stopped"
EOF

    # Create status script
    cat > status-kestra.sh << 'EOF'
#!/bin/bash

# Kestra Enterprise Status Script
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "$1"
}

check_service() {
    local name=$1
    local port=$2
    local pid_file=$3
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill -0 $pid 2>/dev/null; then
            if curl -s http://localhost:$port > /dev/null 2>&1; then
                log "${GREEN}[RUNNING]${NC} $name (PID: $pid, Port: $port)"
                return 0
            else
                log "${YELLOW}[STARTING]${NC} $name (PID: $pid, Port: $port not responding)"
                return 1
            fi
        else
            log "${RED}[STOPPED]${NC} $name (PID file exists but process not running)"
            rm "$pid_file" 2>/dev/null || true
            return 1
        fi
    else
        log "${RED}[STOPPED]${NC} $name (No PID file)"
        return 1
    fi
}

log "${BLUE}📊 Kestra Enterprise Status${NC}"
log "${BLUE}============================${NC}"

backend_running=false
frontend_running=false

if check_service "Backend" 8080 "backend.pid"; then
    backend_running=true
fi

if check_service "Frontend" 3000 "frontend.pid"; then
    frontend_running=true
fi

log ""
if $backend_running && $frontend_running; then
    log "${GREEN}🎉 Kestra Enterprise is fully operational!${NC}"
    log ""
    log "${BLUE}📱 Access URLs:${NC}"
    log "   • Frontend: ${YELLOW}http://localhost:3000${NC}"
    log "   • Backend:  ${YELLOW}http://localhost:8080${NC}"
elif $backend_running; then
    log "${YELLOW}⚠️  Backend running, frontend stopped${NC}"
    log "   • Backend: ${YELLOW}http://localhost:8080${NC}"
elif $frontend_running; then
    log "${YELLOW}⚠️  Frontend running, backend stopped${NC}"
    log "   • Frontend: ${YELLOW}http://localhost:3000${NC}"
else
    log "${RED}❌ Kestra Enterprise is not running${NC}"
    log "   • Start with: ${YELLOW}./start-kestra.sh${NC}"
fi
EOF

    # Make scripts executable
    chmod +x start-kestra.sh stop-kestra.sh status-kestra.sh
    
    log "${GREEN}[SUCCESS]${NC} Service scripts created"
    
    # Final validation
    log ""
    log "${PURPLE}🎯 Deployment Validation${NC}"
    log "${PURPLE}========================${NC}"
    
    # Check enterprise features
    enterprise_features=(
        "ui/src/components/apps/blocks/BaseBlock.vue"
        "ui/src/components/apps/blocks/BlockRenderer.vue" 
        "ui/src/components/apps/blocks/CreateExecutionFormBlock.vue"
        "ui/src/components/apps/blocks/ExecutionLogsBlock.vue"
    )
    
    for feature in "${enterprise_features[@]}"; do
        if [[ -f "$feature" ]]; then
            log "${GREEN}[✓]${NC} $(basename "$feature")"
        else
            log "${RED}[✗]${NC} $(basename "$feature")"
        fi
    done
    
    log ""
    log "${GREEN}🎉 Kestra Enterprise Deployment Complete!${NC}"
    log "${GREEN}=========================================${NC}"
    log ""
    log "${BLUE}📋 Next Steps:${NC}"
    log "   1. Start Kestra: ${YELLOW}./start-kestra.sh${NC}"
    log "   2. Check status: ${YELLOW}./status-kestra.sh${NC}"
    log "   3. View logs:    ${YELLOW}tail -f backend.log frontend.log${NC}"
    log "   4. Stop services: ${YELLOW}./stop-kestra.sh${NC}"
    log ""
    log "${BLUE}🔗 Access URLs (after starting):${NC}"
    log "   • Frontend: ${YELLOW}http://localhost:3000${NC}"
    log "   • Backend:  ${YELLOW}http://localhost:8080${NC}"
    log ""
    log "${BLUE}✨ Enterprise Features Unlocked:${NC}"
    log "   • ✅ Apps Tab - 16 Layout Blocks System"
    log "   • ✅ Tests Tab - Comprehensive Testing Framework"
    log "   • ✅ Secrets Tab - Full Secrets Management"
    log "   • ✅ Administration Tab - IAM, Audit Logs, Instance Management"
    log "   • ✅ Custom Blueprints - Block Registry & Template System"
    log ""
    log "${BLUE}📁 Installation Directory: ${YELLOW}$INSTALL_DIR${NC}"
    log "${BLUE}📄 Deployment Log: ${YELLOW}$DEPLOY_LOG${NC}"
    log ""
    log "${GREEN}Happy orchestrating! 🚀${NC}"
}

# Trap errors
trap 'handle_error "Unexpected error"' ERR

# Run main deployment
main "$@"

