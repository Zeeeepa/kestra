# Enhanced Kestra - Full Development Setup Guide

This guide provides step-by-step instructions to deploy and run the enhanced Kestra platform with hot-reload development mode for UI components.

## 🚀 Quick Start (TL;DR)

```bash
# Clone and setup
git clone https://github.com/Zeeeepa/kestra.git
cd kestra

# Backend (Terminal 1)
./gradlew run

# Frontend (Terminal 2) 
cd ui && npm install && npm run dev

# Access: http://localhost:3000 (UI) + http://localhost:8080 (API)
```

## 📋 Prerequisites

### Required Software

1. **Java 21+** (OpenJDK or Oracle JDK)
   ```bash
   # Check version
   java -version
   
   # Install on macOS
   brew install openjdk@21
   
   # Install on Ubuntu/Debian
   sudo apt update && sudo apt install openjdk-21-jdk
   
   # Install on Windows
   # Download from: https://adoptium.net/temurin/releases/
   ```

2. **Node.js 18+** and **npm**
   ```bash
   # Check versions
   node --version && npm --version
   
   # Install on macOS
   brew install node
   
   # Install on Ubuntu/Debian
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Install on Windows
   # Download from: https://nodejs.org/
   ```

3. **Git**
   ```bash
   # Check version
   git --version
   
   # Install on macOS
   brew install git
   
   # Install on Ubuntu/Debian
   sudo apt install git
   ```

### Optional Tools

- **Docker** (for containerized deployment)
- **PostgreSQL** (for production database)
- **VS Code** with Vue.js extensions (recommended IDE)

## 🔧 Step-by-Step Setup

### Step 1: Clone the Repository

```bash
# Clone the enhanced Kestra repository
git clone https://github.com/Zeeeepa/kestra.git
cd kestra

# Switch to the enhanced features branch
git checkout codegen-bot/upgrade-apps-tests-ai-features-1757554345

# Verify you have the enhanced components
ls ui/src/components/apps/
ls ui/src/components/tests/
ls ui/src/utils/apiKeyStorage.ts
```

### Step 2: Backend Setup (Kestra Server)

```bash
# Make gradlew executable (Linux/macOS)
chmod +x gradlew

# Build the project (this may take 5-10 minutes on first run)
./gradlew build -x test

# Start the Kestra server in development mode
./gradlew run

# Alternative: Run with custom configuration
./gradlew run --args="server standalone --config=application.yml"
```

**Expected Output:**
```
> Task :webserver:run
[main] INFO  io.kestra.webserver.Application - Starting Application
[main] INFO  io.kestra.webserver.Application - Started Application in X.XXX seconds
```

**Backend will be available at:** `http://localhost:8080`

### Step 3: Frontend Setup (UI with Hot Reload)

Open a **new terminal** and navigate to the UI directory:

```bash
cd ui

# Install dependencies (this may take 2-3 minutes)
npm install

# Verify enhanced components are present
npm run validate-components 2>/dev/null || echo "Components validation not available, continuing..."

# Start development server with hot reload
npm run dev

# Alternative: Start with specific host/port
npm run dev -- --host 0.0.0.0 --port 3000
```

**Expected Output:**
```
  VITE v4.x.x  ready in XXX ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: http://192.168.x.x:3000/
  ➜  press h to show help
```

**Frontend will be available at:** `http://localhost:3000`

### Step 4: Verify Setup

1. **Check Backend API:**
   ```bash
   curl http://localhost:8080/api/v1/flows
   ```

2. **Check Frontend:**
   - Open `http://localhost:3000` in your browser
   - You should see the Kestra UI with enhanced features

3. **Test Hot Reload:**
   - Edit any file in `ui/src/components/`
   - Save the file
   - Browser should automatically refresh with changes

## 🎨 Development Mode Features

### Hot Reload Configuration

The development setup includes:

- **Vite Hot Module Replacement (HMR)**: Instant updates for Vue components
- **CSS Hot Reload**: Immediate style updates without page refresh
- **TypeScript Compilation**: Real-time type checking
- **ESLint Integration**: Live code quality feedback

### Development URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend (Dev)** | http://localhost:3000 | Hot-reload UI development server |
| **Backend API** | http://localhost:8080 | Kestra server with API endpoints |
| **Production UI** | http://localhost:8080 | Production-built UI served by backend |

### Enhanced Features Available

1. **🤖 AI Copilot**
   - Access via floating button or `/ai` route
   - Configure API keys in Settings → API Keys

2. **📱 Apps Management**
   - Navigate to `/apps`
   - Full CRUD operations with hot-reload updates

3. **🧪 Tests Suite**
   - Navigate to `/tests`
   - Create and manage test suites

4. **📋 Custom Blueprints**
   - Navigate to `/blueprints`
   - Organization-specific templates

## ⚙️ Configuration

### Environment Variables

Create `ui/.env.development`:

```env
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
```

### Backend Configuration

Create `application-dev.yml`:

```yaml
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
```

## 🔑 AI Integration Setup

### Configure API Keys

1. **Start the application** (both backend and frontend)

2. **Navigate to Settings:**
   - Go to `http://localhost:3000`
   - Click on Settings (gear icon)
   - Select "API Keys" tab

3. **Add API Keys:**
   
   **Google Gemini:**
   ```
   API Key Format: AIza...
   Get Key: https://makersuite.google.com/app/apikey
   ```
   
   **OpenAI:**
   ```
   API Key Format: sk-...
   Get Key: https://platform.openai.com/api-keys
   ```
   
   **Anthropic Claude:**
   ```
   API Key Format: sk-ant-...
   Get Key: https://console.anthropic.com/account/keys
   ```

4. **Test Configuration:**
   - Use the "Test Key" button for each provider
   - Verify the key works before saving

### Using AI Features

1. **AI Copilot:**
   - Click the floating AI button
   - Ask questions about workflows
   - Generate flows from natural language

2. **Flow Generation:**
   - Navigate to Flows → Create
   - Use the AI-powered flow generator
   - Describe your workflow in plain English

## 🛠️ Development Workflow

### Making Changes

1. **UI Components:**
   ```bash
   # Edit any Vue component
   vi ui/src/components/apps/Apps.vue
   
   # Changes auto-reload in browser
   # No restart needed
   ```

2. **Backend Changes:**
   ```bash
   # Edit Java files
   vi core/src/main/java/io/kestra/core/...
   
   # Restart backend
   ./gradlew run
   ```

3. **Translations:**
   ```bash
   # Edit translation files
   vi ui/src/translations/apps-tests-ai.json
   
   # Changes auto-reload
   ```

### Testing Changes

1. **Run Validation:**
   ```bash
   python3 validate-deployment.py
   ```

2. **Component Testing:**
   ```bash
   cd ui
   npm test
   ```

3. **Manual Testing:**
   - Follow checklist in `TESTING.md`
   - Test all enhanced features
   - Verify hot-reload functionality

## 🐛 Troubleshooting

### Common Issues

1. **Port Already in Use:**
   ```bash
   # Check what's using port 8080
   lsof -i :8080
   
   # Kill the process
   kill -9 <PID>
   
   # Or use different port
   ./gradlew run --args="server standalone --server.port=8081"
   ```

2. **Node.js Version Issues:**
   ```bash
   # Use Node Version Manager
   nvm install 18
   nvm use 18
   
   # Verify version
   node --version
   ```

3. **Java Version Issues:**
   ```bash
   # Check Java version
   java -version
   
   # Set JAVA_HOME
   export JAVA_HOME=/path/to/java21
   ```

4. **Hot Reload Not Working:**
   ```bash
   # Clear Vite cache
   cd ui
   rm -rf node_modules/.vite
   npm run dev
   ```

5. **Build Failures:**
   ```bash
   # Clean and rebuild
   ./gradlew clean build -x test
   
   # Clear npm cache
   cd ui && npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

### Performance Issues

1. **Slow Hot Reload:**
   ```bash
   # Increase Node.js memory
   export NODE_OPTIONS="--max-old-space-size=4096"
   npm run dev
   ```

2. **Backend Slow Start:**
   ```bash
   # Use parallel builds
   ./gradlew run --parallel
   
   # Increase JVM memory
   export GRADLE_OPTS="-Xmx4g"
   ./gradlew run
   ```

## 📊 Development Tools

### Recommended VS Code Extensions

```json
{
  "recommendations": [
    "Vue.volar",
    "Vue.vscode-typescript-vue-plugin",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint"
  ]
}
```

### Browser DevTools

1. **Vue DevTools:**
   - Install browser extension
   - Debug Vue components and state

2. **Network Tab:**
   - Monitor API calls to backend
   - Debug WebSocket connections

3. **Console:**
   - Check for JavaScript errors
   - View debug logs

## 🚀 Production Build

### Build for Production

```bash
# Build backend
./gradlew build

# Build frontend
cd ui
npm run build

# The built UI will be in ui/dist/
# Backend will serve it automatically
```

### Run Production Build

```bash
# Start production server
java -jar build/libs/kestra-*.jar server standalone

# Access at http://localhost:8080
```

## 📝 Development Tips

### Hot Reload Best Practices

1. **Component Structure:**
   - Keep components small and focused
   - Use composition API for better hot-reload
   - Avoid side effects in component setup

2. **State Management:**
   - Use Pinia stores for shared state
   - State persists through hot reloads

3. **CSS/Styling:**
   - Use scoped styles in Vue components
   - Tailwind classes update instantly

### Debugging Tips

1. **Vue Components:**
   ```javascript
   // Add debug logs
   console.log('Component data:', this.$data)
   
   // Use Vue DevTools
   // Inspect component state and props
   ```

2. **API Calls:**
   ```javascript
   // Debug API responses
   console.log('API Response:', response.data)
   
   // Check network tab for failed requests
   ```

3. **Hot Reload Issues:**
   ```bash
   # Force refresh if hot reload breaks
   # Press 'r' in Vite terminal
   # Or refresh browser manually
   ```

## 🎯 Next Steps

1. **Start Development:**
   - Follow the setup steps above
   - Configure AI API keys
   - Begin building workflows

2. **Explore Enhanced Features:**
   - Test Apps management
   - Try AI-powered flow generation
   - Create custom blueprints

3. **Contribute:**
   - Make changes with hot reload
   - Test thoroughly
   - Submit improvements

## 📞 Support

If you encounter issues:

1. **Check the troubleshooting section above**
2. **Review logs in both terminals**
3. **Validate setup with:** `python3 validate-deployment.py`
4. **Check the comprehensive testing guide:** `TESTING.md`

---

**🎉 You're now ready to develop with the enhanced Kestra platform!**

The hot-reload development environment will automatically update your browser as you make changes to Vue components, making development fast and efficient. All enhanced features including AI integration, Apps management, Tests suite, and Custom Blueprints are ready to use.
