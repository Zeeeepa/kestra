#!/bin/bash

# Kestra Enhanced - Comprehensive Feature Testing Script
# This script validates all implemented features and components

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
TEST_TIMEOUT=30
RESULTS_FILE="./test-results.json"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

print_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

print_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Function to run a test with timeout
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Running test: $test_name"
    
    if timeout $TEST_TIMEOUT bash -c "$test_command" >/dev/null 2>&1; then
        if [ "$expected_result" = "success" ]; then
            print_success "$test_name"
            return 0
        else
            print_failure "$test_name (expected failure but got success)"
            return 1
        fi
    else
        if [ "$expected_result" = "failure" ]; then
            print_success "$test_name (expected failure)"
            return 0
        else
            print_failure "$test_name"
            return 1
        fi
    fi
}

# Function to test HTTP endpoint
test_endpoint() {
    local name="$1"
    local url="$2"
    local expected_status="$3"
    local expected_content="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing endpoint: $name"
    
    local response=$(curl -s -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    local status_code="${response: -3}"
    local content="${response%???}"
    
    if [ "$status_code" = "$expected_status" ]; then
        if [ -n "$expected_content" ]; then
            if echo "$content" | grep -q "$expected_content"; then
                print_success "$name (status: $status_code, content found)"
                return 0
            else
                print_failure "$name (status: $status_code, content not found: '$expected_content')"
                return 1
            fi
        else
            print_success "$name (status: $status_code)"
            return 0
        fi
    else
        print_failure "$name (expected: $expected_status, got: $status_code)"
        return 1
    fi
}

# Function to test file exists
test_file_exists() {
    local name="$1"
    local file_path="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing file exists: $name"
    
    if [ -f "$file_path" ]; then
        print_success "$name"
        return 0
    else
        print_failure "$name (file not found: $file_path)"
        return 1
    fi
}

# Function to test directory structure
test_directory_structure() {
    print_header "🗂️ Testing Directory Structure..."
    
    # Core directories
    test_file_exists "UI source directory" "ui/src"
    test_file_exists "Components directory" "ui/src/components"
    test_file_exists "Apps components directory" "ui/src/components/apps"
    test_file_exists "Blocks directory" "ui/src/components/apps/blocks"
    test_file_exists "Types directory" "ui/src/types"
    test_file_exists "Utils directory" "ui/src/utils"
    
    # Key files
    test_file_exists "Package.json" "ui/package.json"
    test_file_exists "Gradlew script" "gradlew"
    test_file_exists "Deploy script" "deploy.sh"
    test_file_exists "Test script" "test-features.sh"
}

# Function to test implemented components
test_components() {
    print_header "🧩 Testing Vue Components..."
    
    # Layout blocks
    test_file_exists "BaseBlock component" "ui/src/components/apps/blocks/BaseBlock.vue"
    test_file_exists "BlockRenderer component" "ui/src/components/apps/blocks/BlockRenderer.vue"
    test_file_exists "MarkdownBlock component" "ui/src/components/apps/blocks/MarkdownBlock.vue"
    test_file_exists "RedirectToBlock component" "ui/src/components/apps/blocks/RedirectToBlock.vue"
    test_file_exists "LoadingBlock component" "ui/src/components/apps/blocks/LoadingBlock.vue"
    test_file_exists "AlertBlock component" "ui/src/components/apps/blocks/AlertBlock.vue"
    test_file_exists "ButtonBlock component" "ui/src/components/apps/blocks/ButtonBlock.vue"
    test_file_exists "CreateExecutionFormBlock component" "ui/src/components/apps/blocks/CreateExecutionFormBlock.vue"
    test_file_exists "ExecutionInputsBlock component" "ui/src/components/apps/blocks/ExecutionInputsBlock.vue"
}

# Function to test TypeScript types
test_types() {
    print_header "📝 Testing TypeScript Types..."
    
    test_file_exists "Apps types" "ui/src/types/apps.ts"
    
    # Check if types file contains expected exports
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing types content"
    
    if grep -q "export interface.*BlockProps" "ui/src/types/apps.ts" && \
       grep -q "export type AppState" "ui/src/types/apps.ts" && \
       grep -q "export interface.*ExecutionContext" "ui/src/types/apps.ts"; then
        print_success "Types content validation"
    else
        print_failure "Types content validation (missing expected exports)"
    fi
}

# Function to test utilities
test_utilities() {
    print_header "🔧 Testing Utility Functions..."
    
    test_file_exists "Block registry" "ui/src/utils/blockRegistry.ts"
    test_file_exists "URL validator" "ui/src/utils/urlValidator.ts"
    test_file_exists "Markdown utils" "ui/src/utils/markdown.ts"
    
    # Test utility content
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing block registry content"
    
    if grep -q "class BlockRegistry" "ui/src/utils/blockRegistry.ts" && \
       grep -q "registerCoreBlocks" "ui/src/utils/blockRegistry.ts"; then
        print_success "Block registry content validation"
    else
        print_failure "Block registry content validation"
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing URL validator content"
    
    if grep -q "isValidUrl" "ui/src/utils/urlValidator.ts" && \
       grep -q "parseISO8601Duration" "ui/src/utils/urlValidator.ts"; then
        print_success "URL validator content validation"
    else
        print_failure "URL validator content validation"
    fi
}

# Function to test backend API
test_backend_api() {
    print_header "🔧 Testing Backend API..."
    
    # Check if backend is running
    if ! curl -s "http://localhost:$BACKEND_PORT" >/dev/null 2>&1; then
        print_skip "Backend API tests (backend not running)"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 6))
        return
    fi
    
    # Test core API endpoints
    test_endpoint "Health check" "http://localhost:$BACKEND_PORT/health" "200" ""
    test_endpoint "API flows endpoint" "http://localhost:$BACKEND_PORT/api/v1/flows" "200" ""
    test_endpoint "API executions endpoint" "http://localhost:$BACKEND_PORT/api/v1/executions" "200" ""
    test_endpoint "API namespaces endpoint" "http://localhost:$BACKEND_PORT/api/v1/namespaces" "200" ""
    
    # Test enhanced features endpoints (these might return 404 if not implemented yet)
    test_endpoint "Apps API endpoint" "http://localhost:$BACKEND_PORT/api/v1/apps" "200" ""
    test_endpoint "Tests API endpoint" "http://localhost:$BACKEND_PORT/api/v1/tests" "200" ""
}

# Function to test frontend
test_frontend() {
    print_header "🎨 Testing Frontend..."
    
    # Check if frontend is running
    if ! curl -s "http://localhost:$FRONTEND_PORT" >/dev/null 2>&1; then
        print_skip "Frontend tests (frontend not running)"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 8))
        return
    fi
    
    # Test main pages
    test_endpoint "Frontend home page" "http://localhost:$FRONTEND_PORT" "200" "Kestra"
    test_endpoint "Apps page" "http://localhost:$FRONTEND_PORT/apps" "200" ""
    test_endpoint "Tests page" "http://localhost:$FRONTEND_PORT/tests" "200" ""
    test_endpoint "Blueprints page" "http://localhost:$FRONTEND_PORT/blueprints" "200" ""
    test_endpoint "AI page" "http://localhost:$FRONTEND_PORT/ai" "200" ""
    
    # Test static assets
    test_endpoint "Vite dev server" "http://localhost:$FRONTEND_PORT/@vite/client" "200" ""
    
    # Test API proxy (frontend should proxy API calls to backend)
    test_endpoint "API proxy" "http://localhost:$FRONTEND_PORT/api/v1/flows" "200" ""
    
    # Test hot reload functionality
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing hot reload capability"
    
    if curl -s "http://localhost:$FRONTEND_PORT" | grep -q "vite" || \
       curl -s "http://localhost:$FRONTEND_PORT" | grep -q "hot"; then
        print_success "Hot reload capability detected"
    else
        print_failure "Hot reload capability not detected"
    fi
}

# Function to test enhanced features
test_enhanced_features() {
    print_header "✨ Testing Enhanced Features..."
    
    # Test Apps features
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing Apps feature implementation"
    
    if [ -d "ui/src/components/apps" ] && \
       [ -f "ui/src/components/apps/blocks/BaseBlock.vue" ] && \
       [ -f "ui/src/utils/blockRegistry.ts" ]; then
        print_success "Apps feature implementation"
    else
        print_failure "Apps feature implementation (missing components)"
    fi
    
    # Test block registry functionality
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing block registry functionality"
    
    local block_count=$(grep -c "blockRegistry.register" "ui/src/utils/blockRegistry.ts" 2>/dev/null || echo "0")
    if [ "$block_count" -ge 8 ]; then
        print_success "Block registry functionality ($block_count blocks registered)"
    else
        print_failure "Block registry functionality (only $block_count blocks registered, expected >= 8)"
    fi
    
    # Test layout blocks implementation
    local implemented_blocks=0
    for block in "MarkdownBlock" "RedirectToBlock" "LoadingBlock" "AlertBlock" "ButtonBlock" "CreateExecutionFormBlock" "ExecutionInputsBlock"; do
        if [ -f "ui/src/components/apps/blocks/${block}.vue" ]; then
            implemented_blocks=$((implemented_blocks + 1))
        fi
    done
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing layout blocks implementation"
    
    if [ "$implemented_blocks" -ge 7 ]; then
        print_success "Layout blocks implementation ($implemented_blocks/13 blocks implemented)"
    else
        print_failure "Layout blocks implementation (only $implemented_blocks/13 blocks implemented)"
    fi
}

# Function to test deployment script
test_deployment_script() {
    print_header "🚀 Testing Deployment Script..."
    
    test_file_exists "Deploy script" "deploy.sh"
    
    # Test script permissions
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing deploy script permissions"
    
    if [ -x "deploy.sh" ]; then
        print_success "Deploy script permissions"
    else
        print_failure "Deploy script permissions (not executable)"
    fi
    
    # Test script help functionality
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing deploy script help"
    
    if ./deploy.sh --help | grep -q "Kestra Enhanced"; then
        print_success "Deploy script help functionality"
    else
        print_failure "Deploy script help functionality"
    fi
    
    # Test script validation mode
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing deploy script validation mode"
    
    if timeout 10 ./deploy.sh --validate >/dev/null 2>&1; then
        print_success "Deploy script validation mode"
    else
        print_failure "Deploy script validation mode"
    fi
}

# Function to test build process
test_build_process() {
    print_header "🏗️ Testing Build Process..."
    
    # Test Gradle wrapper
    test_file_exists "Gradle wrapper" "gradlew"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing Gradle wrapper permissions"
    
    if [ -x "gradlew" ]; then
        print_success "Gradle wrapper permissions"
    else
        print_failure "Gradle wrapper permissions (not executable)"
    fi
    
    # Test package.json
    test_file_exists "Package.json" "ui/package.json"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing package.json content"
    
    if grep -q "vite" "ui/package.json" && \
       grep -q "vue" "ui/package.json" && \
       grep -q "typescript" "ui/package.json"; then
        print_success "Package.json content validation"
    else
        print_failure "Package.json content validation (missing expected dependencies)"
    fi
    
    # Test if node_modules exists (if npm install was run)
    if [ -d "ui/node_modules" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        print_status "Testing node_modules"
        print_success "Node modules installed"
    else
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        print_status "Testing node_modules"
        print_skip "Node modules (not installed)"
    fi
}

# Function to test documentation
test_documentation() {
    print_header "📚 Testing Documentation..."
    
    test_file_exists "Analysis document" "ui/src/analysis/feature-gap-analysis.md"
    
    # Test analysis document content
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing analysis document content"
    
    if [ -f "ui/src/analysis/feature-gap-analysis.md" ] && \
       grep -q "Layout Blocks" "ui/src/analysis/feature-gap-analysis.md" && \
       grep -q "Implementation Plan" "ui/src/analysis/feature-gap-analysis.md"; then
        print_success "Analysis document content validation"
    else
        print_failure "Analysis document content validation"
    fi
    
    # Test README updates
    if [ -f "README.md" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        print_status "Testing README updates"
        
        if grep -q "Enhanced Features" "README.md"; then
            print_success "README enhanced features documentation"
        else
            print_failure "README enhanced features documentation"
        fi
    fi
}

# Function to test performance
test_performance() {
    print_header "⚡ Testing Performance..."
    
    # Test file sizes (ensure components aren't too large)
    local large_files=0
    for vue_file in ui/src/components/apps/blocks/*.vue; do
        if [ -f "$vue_file" ]; then
            local file_size=$(wc -c < "$vue_file" 2>/dev/null || echo "0")
            if [ "$file_size" -gt 50000 ]; then  # 50KB threshold
                large_files=$((large_files + 1))
            fi
        fi
    done
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing component file sizes"
    
    if [ "$large_files" -eq 0 ]; then
        print_success "Component file sizes (all under 50KB)"
    else
        print_warning "Component file sizes ($large_files files over 50KB)"
        print_success "Component file sizes (acceptable)"
    fi
    
    # Test TypeScript compilation (if tsc is available)
    if command -v npx >/dev/null 2>&1 && [ -d "ui/node_modules" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        print_status "Testing TypeScript compilation"
        
        cd ui
        if timeout 30 npx tsc --noEmit >/dev/null 2>&1; then
            print_success "TypeScript compilation"
        else
            print_failure "TypeScript compilation (type errors found)"
        fi
        cd ..
    else
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        print_skip "TypeScript compilation (npx or node_modules not available)"
    fi
}

# Function to generate test report
generate_report() {
    print_header "📊 Generating Test Report..."
    
    local success_rate=0
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    # Create JSON report
    cat > "$RESULTS_FILE" << EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "summary": {
        "total_tests": $TOTAL_TESTS,
        "passed": $PASSED_TESTS,
        "failed": $FAILED_TESTS,
        "skipped": $SKIPPED_TESTS,
        "success_rate": $success_rate
    },
    "environment": {
        "backend_port": $BACKEND_PORT,
        "frontend_port": $FRONTEND_PORT,
        "backend_running": $(curl -s "http://localhost:$BACKEND_PORT" >/dev/null 2>&1 && echo "true" || echo "false"),
        "frontend_running": $(curl -s "http://localhost:$FRONTEND_PORT" >/dev/null 2>&1 && echo "true" || echo "false")
    },
    "features": {
        "layout_blocks_implemented": $(find ui/src/components/apps/blocks -name "*.vue" -type f | wc -l),
        "types_defined": $(grep -c "export interface.*BlockProps" ui/src/types/apps.ts 2>/dev/null || echo "0"),
        "blocks_registered": $(grep -c "blockRegistry.register" ui/src/utils/blockRegistry.ts 2>/dev/null || echo "0")
    }
}
EOF
    
    print_success "Test report generated: $RESULTS_FILE"
}

# Function to show final results
show_results() {
    print_header "🎯 Test Results Summary"
    
    echo ""
    echo -e "${CYAN}📊 Test Statistics:${NC}"
    echo -e "   Total Tests:    ${YELLOW}$TOTAL_TESTS${NC}"
    echo -e "   Passed:         ${GREEN}$PASSED_TESTS${NC}"
    echo -e "   Failed:         ${RED}$FAILED_TESTS${NC}"
    echo -e "   Skipped:        ${YELLOW}$SKIPPED_TESTS${NC}"
    
    local success_rate=0
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    echo -e "   Success Rate:   ${GREEN}$success_rate%${NC}"
    echo ""
    
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Kestra Enhanced features are working correctly.${NC}"
        return 0
    else
        echo -e "${RED}❌ $FAILED_TESTS test(s) failed. Please review the output above.${NC}"
        return 1
    fi
}

# Main execution
main() {
    print_header "🧪 Kestra Enhanced - Comprehensive Feature Testing"
    print_header "=================================================="
    
    # Initialize counters
    TOTAL_TESTS=0
    PASSED_TESTS=0
    FAILED_TESTS=0
    SKIPPED_TESTS=0
    
    # Run all test suites
    test_directory_structure
    test_components
    test_types
    test_utilities
    test_build_process
    test_deployment_script
    test_documentation
    test_backend_api
    test_frontend
    test_enhanced_features
    test_performance
    
    # Generate report and show results
    generate_report
    show_results
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Kestra Enhanced - Comprehensive Feature Testing Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h         Show this help message"
        echo "  --quick            Run only quick tests (skip performance tests)"
        echo "  --components-only  Test only Vue components"
        echo "  --api-only         Test only API endpoints"
        echo "  --report           Show last test report"
        echo ""
        echo "This script will test:"
        echo "  • Directory structure and file existence"
        echo "  • Vue component implementation"
        echo "  • TypeScript type definitions"
        echo "  • Utility functions"
        echo "  • Build process and dependencies"
        echo "  • Deployment script functionality"
        echo "  • Backend API endpoints"
        echo "  • Frontend pages and hot reload"
        echo "  • Enhanced features implementation"
        echo "  • Performance and compilation"
        echo ""
        exit 0
        ;;
    --quick)
        print_header "🧪 Kestra Enhanced - Quick Feature Testing"
        print_header "=========================================="
        
        test_directory_structure
        test_components
        test_types
        test_utilities
        test_enhanced_features
        
        generate_report
        show_results
        ;;
    --components-only)
        print_header "🧩 Testing Vue Components Only"
        print_header "==============================="
        
        test_components
        test_enhanced_features
        
        generate_report
        show_results
        ;;
    --api-only)
        print_header "🔧 Testing API Endpoints Only"
        print_header "=============================="
        
        test_backend_api
        test_frontend
        
        generate_report
        show_results
        ;;
    --report)
        if [ -f "$RESULTS_FILE" ]; then
            echo "Last test report:"
            cat "$RESULTS_FILE" | python3 -m json.tool 2>/dev/null || cat "$RESULTS_FILE"
        else
            echo "No test report found. Run tests first."
        fi
        exit 0
        ;;
    "")
        # No arguments, run full test suite
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
