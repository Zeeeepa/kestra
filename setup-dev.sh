#!/bin/bash

# Enhanced Kestra - Development Environment Setup Script
# This script automates the setup of the enhanced Kestra platform with hot-reload development mode

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Java version
check_java() {
    if command_exists java; then
        JAVA_VERSION=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -ge 21 ]; then
            print_success "Java $JAVA_VERSION detected"
            return 0
        else
            print_error "Java 21+ required, found Java $JAVA_VERSION"
            return 1
        fi
    else
        print_error "Java not found"
        return 1
    fi
}

# Function to check Node.js version
check_node() {
    if command_exists node; then
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            print_success "Node.js v$NODE_VERSION detected"
            return 0
        else
            print_error "Node.js 18+ required, found v$NODE_VERSION"
            return 1
        fi
    else
        print_error "Node.js not found"
        return 1
    fi
}

# Function to setup environment files
setup_env_files() {
    print_status "Setting up environment files..."
    
    # Create UI development environment file
    cat > ui/.env.development << EOF
# API Configuration
VITE_API_URL=http://localhost:8080
VITE_WS_URL=ws://localhost:8080

# Feature Flags
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_APPS=true
VITE_ENABLE_TESTS=true
VITE_ENABLE_CUSTOM_BLUEPRINTS=true

# Development Settings
VITE_DEV_MODE=true
VITE_LOG_LEVEL=debug
VITE_HOT_RELOAD=true
EOF

    # Create backend development configuration
    cat > application-dev.yml << EOF
kestra:
  server:
    port: 8080
    host: localhost
  
  datasource:
    url: jdbc:h2:mem:kestra
    username: sa
    password: ""
    
  storage:
    type: local
    local:
      base-path: ./storage
      
  features:
    ai-enabled: true
    apps-enabled: true
    tests-enabled: true
EOF

    print_success "Environment files created"
}

# Function to create VS Code workspace settings
setup_vscode() {
    if [ -d ".vscode" ] || [ "$1" = "--force-vscode" ]; then
        print_status "Setting up VS Code configuration..."
        
        mkdir -p .vscode
        
        # Extensions recommendations
        cat > .vscode/extensions.json << EOF
{
  "recommendations": [
    "Vue.volar",
    "Vue.vscode-typescript-vue-plugin",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next"
  ]
}
EOF

        # Workspace settings
        cat > .vscode/settings.json << EOF
{
  "typescript.preferences.includePackageJsonAutoImports": "on",
  "vue.server.hybridMode": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "eslint.validate": ["javascript", "typescript", "vue"],
  "files.associations": {
    "*.vue": "vue"
  }
}
EOF

        print_success "VS Code configuration created"
    fi
}

# Main setup function
main() {
    echo "🚀 Enhanced Kestra - Development Environment Setup"
    echo "=================================================="
    
    # Check if we're in the right directory
    if [ ! -f "build.gradle" ] || [ ! -d "ui" ]; then
        print_error "Please run this script from the Kestra project root directory"
        exit 1
    fi
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    PREREQ_OK=true
    
    if ! check_java; then
        print_warning "Install Java 21+: https://adoptium.net/temurin/releases/"
        PREREQ_OK=false
    fi
    
    if ! check_node; then
        print_warning "Install Node.js 18+: https://nodejs.org/"
        PREREQ_OK=false
    fi
    
    if ! command_exists git; then
        print_error "Git not found"
        PREREQ_OK=false
    else
        print_success "Git detected"
    fi
    
    if [ "$PREREQ_OK" = false ]; then
        print_error "Please install missing prerequisites and run again"
        exit 1
    fi
    
    # Setup environment files
    setup_env_files
    
    # Setup VS Code if requested or .vscode exists
    if [ "$1" = "--with-vscode" ] || [ -d ".vscode" ]; then
        setup_vscode
    fi
    
    # Make gradlew executable
    if [ -f "gradlew" ]; then
        chmod +x gradlew
        print_success "Made gradlew executable"
    fi
    
    # Install UI dependencies
    print_status "Installing UI dependencies..."
    cd ui
    if npm install; then
        print_success "UI dependencies installed"
    else
        print_error "Failed to install UI dependencies"
        exit 1
    fi
    cd ..
    
    # Validate enhanced components
    print_status "Validating enhanced components..."
    if python3 validate-deployment.py > /dev/null 2>&1; then
        print_success "All enhanced components validated"
    else
        print_warning "Some validation checks failed, but setup can continue"
    fi
    
    # Create startup scripts
    print_status "Creating startup scripts..."
    
    # Backend startup script
    cat > start-backend.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Kestra Backend..."
echo "Backend will be available at: http://localhost:8080"
echo "Press Ctrl+C to stop"
echo ""
./gradlew run
EOF
    chmod +x start-backend.sh
    
    # Frontend startup script
    cat > start-frontend.sh << 'EOF'
#!/bin/bash
echo "🎨 Starting Kestra Frontend with Hot Reload..."
echo "Frontend will be available at: http://localhost:3000"
echo "Press Ctrl+C to stop"
echo ""
cd ui && npm run dev
EOF
    chmod +x start-frontend.sh
    
    # Combined startup script
    cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Enhanced Kestra Development Environment"
echo "=================================================="
echo ""
echo "This will start both backend and frontend in parallel"
echo "Backend: http://localhost:8080"
echo "Frontend: http://localhost:3000 (with hot reload)"
echo ""
echo "Press Ctrl+C to stop both services"
echo ""

# Function to cleanup background processes
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    wait $BACKEND_PID $FRONTEND_PID 2>/dev/null
    echo "✅ Services stopped"
    exit 0
}

# Set trap to cleanup on exit
trap cleanup SIGINT SIGTERM

# Start backend in background
echo "🚀 Starting backend..."
./gradlew run > backend.log 2>&1 &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 5

# Start frontend in background
echo "🎨 Starting frontend..."
cd ui && npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Services starting..."
echo "📊 Backend logs: tail -f backend.log"
echo "🎨 Frontend logs: tail -f frontend.log"
echo ""
echo "🌐 Open http://localhost:3000 when ready"
echo ""

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID
EOF
    chmod +x start-dev.sh
    
    print_success "Startup scripts created"
    
    # Final instructions
    echo ""
    echo "🎉 Setup Complete!"
    echo "=================="
    echo ""
    echo "📋 Next Steps:"
    echo ""
    echo "1. Start Development Environment:"
    echo "   ./start-dev.sh          # Start both backend and frontend"
    echo "   # OR start separately:"
    echo "   ./start-backend.sh      # Terminal 1: Backend only"
    echo "   ./start-frontend.sh     # Terminal 2: Frontend only"
    echo ""
    echo "2. Access the Application:"
    echo "   🌐 Frontend (Hot Reload): http://localhost:3000"
    echo "   🔧 Backend API:          http://localhost:8080"
    echo ""
    echo "3. Configure AI Features:"
    echo "   • Go to Settings → API Keys"
    echo "   • Add your AI provider keys (Gemini, OpenAI, Anthropic)"
    echo "   • Test the keys before saving"
    echo ""
    echo "4. Enhanced Features Available:"
    echo "   🤖 AI Copilot:        Floating button or /ai route"
    echo "   📱 Apps Management:   /apps route"
    echo "   🧪 Tests Suite:       /tests route"
    echo "   📋 Custom Blueprints: /blueprints route"
    echo ""
    echo "📚 Documentation:"
    echo "   • Full setup guide:    DEVELOPMENT_SETUP.md"
    echo "   • Testing procedures:  TESTING.md"
    echo "   • Validation script:   python3 validate-deployment.py"
    echo ""
    echo "🔥 Hot Reload Features:"
    echo "   • Vue components update instantly"
    echo "   • CSS changes apply without refresh"
    echo "   • TypeScript compilation in real-time"
    echo "   • ESLint feedback as you type"
    echo ""
    print_success "Enhanced Kestra development environment is ready!"
}

# Run main function with all arguments
main "$@"
