# Component Testing Guide

This document provides a comprehensive testing guide for all the enhanced Kestra features.

## 🧪 Manual Testing Checklist

### 1. API Key Management Testing

#### ApiKeyStorage Utility
- [ ] **Store API Key**: Test storing a valid Gemini API key
- [ ] **Retrieve API Key**: Verify stored key can be retrieved correctly
- [ ] **Key Validation**: Test validation for different provider key formats
- [ ] **Key Encryption**: Verify keys are encrypted in localStorage
- [ ] **Key Masking**: Check that displayed keys are properly masked
- [ ] **Remove Key**: Test key removal functionality
- [ ] **Clear All Keys**: Test clearing all stored keys
- [ ] **Import/Export**: Test backup and restore functionality

#### ApiKeySettings Component
- [ ] **UI Rendering**: Component renders correctly with all providers
- [ ] **Key Input**: Can input API keys for each provider
- [ ] **Key Testing**: Test functionality works for valid keys
- [ ] **Key Saving**: Keys are saved and persist after page reload
- [ ] **Key Editing**: Can edit existing keys
- [ ] **Key Removal**: Can remove individual keys
- [ ] **Validation Messages**: Proper error messages for invalid keys
- [ ] **Help Links**: External links to API key providers work

### 2. AI Service Testing

#### Direct API Integration
- [ ] **Provider Detection**: Only shows providers with configured keys
- [ ] **Gemini Integration**: Can generate flows using Gemini API
- [ ] **OpenAI Integration**: Can generate flows using OpenAI API
- [ ] **Anthropic Integration**: Can generate flows using Anthropic API
- [ ] **Error Handling**: Proper error messages for API failures
- [ ] **Response Parsing**: AI responses are correctly parsed into YAML
- [ ] **Fallback Handling**: Fallback YAML generation works

### 3. Apps Component Testing

#### Core Functionality
- [ ] **App List**: Apps are displayed in DataTable format
- [ ] **Create App**: Can create new apps with form validation
- [ ] **Edit App**: Can edit existing apps
- [ ] **Delete App**: Can delete apps with confirmation
- [ ] **Bulk Operations**: Can select and operate on multiple apps
- [ ] **Status Management**: Can change app status (active/inactive)
- [ ] **Search**: Search functionality works across app properties
- [ ] **Filtering**: Advanced filtering with AppFilterLanguage works
- [ ] **Pagination**: Pagination works correctly
- [ ] **Sorting**: Column sorting works

#### Store Integration
- [ ] **State Management**: useAppStore manages state correctly
- [ ] **CRUD Operations**: All store operations work
- [ ] **Loading States**: Loading indicators show during operations
- [ ] **Error Handling**: Errors are handled and displayed properly

### 4. Tests Component Testing

#### Core Functionality
- [ ] **Test List**: Tests are displayed with statistics
- [ ] **Create Test**: Can create new test suites
- [ ] **Edit Test**: Can edit existing tests
- [ ] **Delete Test**: Can delete tests with confirmation
- [ ] **Execute Test**: Can run individual tests
- [ ] **Bulk Execute**: Can run multiple tests
- [ ] **Test Results**: Results are displayed correctly
- [ ] **Success Rate**: Statistics are calculated correctly
- [ ] **Search**: Search functionality works
- [ ] **Filtering**: TestFilterLanguage filtering works

#### Store Integration
- [ ] **State Management**: useTestStore manages state correctly
- [ ] **Execution Tracking**: Test executions are tracked
- [ ] **Results Storage**: Test results are stored and retrieved

### 5. AI Copilot Testing

#### Core Functionality
- [ ] **Component Rendering**: AiCopilot renders as floating assistant
- [ ] **Chat Interface**: Can send messages and receive responses
- [ ] **Flow Generation**: Can generate flows from natural language
- [ ] **Flow Refinement**: Can refine existing flows
- [ ] **Flow Explanation**: Can explain flow functionality
- [ ] **Provider Selection**: Can switch between AI providers
- [ ] **Error Handling**: Handles API errors gracefully

### 6. Custom Blueprints Testing

#### Core Functionality
- [ ] **Blueprint List**: Blueprints are displayed with statistics
- [ ] **Create Blueprint**: Can create new blueprints
- [ ] **Edit Blueprint**: Can edit existing blueprints
- [ ] **Delete Blueprint**: Can delete blueprints
- [ ] **Use Blueprint**: Can use blueprints to create flows
- [ ] **Export Blueprint**: Can export blueprints as JSON
- [ ] **Import Blueprint**: Can import blueprint configurations
- [ ] **Search/Filter**: Search and filtering work correctly

### 7. Filter Languages Testing

#### AppFilterLanguage
- [ ] **Basic Queries**: Simple text searches work
- [ ] **Status Filtering**: Can filter by app status
- [ ] **Type Filtering**: Can filter by app type
- [ ] **Date Filtering**: Can filter by creation/update dates
- [ ] **Complex Queries**: Combined filters work correctly

#### TestFilterLanguage
- [ ] **Basic Queries**: Simple text searches work
- [ ] **Success Rate Filtering**: Can filter by success rate
- [ ] **Status Filtering**: Can filter by test status
- [ ] **Execution Filtering**: Can filter by execution count
- [ ] **Complex Queries**: Combined filters work correctly

### 8. Translation Testing

#### Internationalization
- [ ] **Key Coverage**: All UI text uses translation keys
- [ ] **Missing Keys**: No missing translation keys in console
- [ ] **Context**: Translations make sense in context
- [ ] **Error Messages**: Error messages are properly translated

### 9. Integration Testing

#### Component Integration
- [ ] **Navigation**: All routes work correctly
- [ ] **State Sharing**: Components share state appropriately
- [ ] **Event Handling**: Component events are handled correctly
- [ ] **Error Boundaries**: Errors don't crash the application

#### API Integration
- [ ] **Backend Compatibility**: Components work with Kestra backend
- [ ] **WebSocket**: Real-time updates work if applicable
- [ ] **Authentication**: Respects authentication state
- [ ] **Permissions**: Respects user permissions

## 🚀 Automated Testing

### Unit Tests
```bash
# Run component unit tests
cd ui && npm test

# Run specific component tests
npm test -- --testNamePattern="ApiKeyStorage"
npm test -- --testNamePattern="AiService"
```

### Integration Tests
```bash
# Run integration tests
npm run test:integration

# Run E2E tests (if available)
npm run test:e2e
```

### Performance Tests
```bash
# Run performance tests
npm run test:performance

# Check bundle size
npm run analyze
```

## 🔧 Testing Environment Setup

### Prerequisites
1. **API Keys**: Configure at least one AI provider API key
2. **Backend**: Ensure Kestra backend is running
3. **Database**: Use test database for integration tests
4. **Browser**: Use latest Chrome/Firefox for testing

### Test Data Setup
```javascript
// Example test data for Apps
const testApp = {
  name: "Test App",
  description: "Test application for validation",
  type: "dashboard",
  status: "active",
  configuration: {}
};

// Example test data for Tests
const testSuite = {
  name: "Test Suite",
  description: "Test suite for validation",
  tests: [
    {
      name: "Basic Test",
      type: "unit",
      configuration: {}
    }
  ]
};
```

## 📊 Test Results Documentation

### Test Execution Log
- **Date**: [Test execution date]
- **Environment**: [Development/Staging/Production]
- **Browser**: [Browser version]
- **Results**: [Pass/Fail counts]
- **Issues Found**: [List of issues]
- **Performance**: [Load times, responsiveness]

### Known Issues
- [ ] **Issue 1**: Description and workaround
- [ ] **Issue 2**: Description and workaround

### Performance Benchmarks
- **Component Load Time**: < 100ms
- **API Response Time**: < 500ms
- **Search Response Time**: < 200ms
- **Bundle Size**: < 2MB

## 🐛 Bug Reporting

When reporting bugs, include:
1. **Steps to Reproduce**
2. **Expected Behavior**
3. **Actual Behavior**
4. **Browser/Environment**
5. **Screenshots/Videos**
6. **Console Errors**

## ✅ Testing Sign-off

- [ ] **All Manual Tests Pass**
- [ ] **All Automated Tests Pass**
- [ ] **Performance Benchmarks Met**
- [ ] **No Critical Issues**
- [ ] **Documentation Updated**
- [ ] **Ready for Production**

**Tested By**: [Name]
**Date**: [Date]
**Version**: [Version]
**Sign-off**: [Approved/Needs Work]
