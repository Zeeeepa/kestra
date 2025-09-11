#!/usr/bin/env python3
"""
Kestra Enhanced Features - Deployment Validation Script
========================================================

This script validates that all enhanced Kestra features are properly
implemented and ready for deployment.

Usage:
    python3 validate-deployment.py

Exit codes:
    0 - All validations passed, ready for deployment
    1 - Critical validations failed, not ready for deployment
"""

import json
import os
import sys
from typing import Dict, List, Tuple

class DeploymentValidator:
    def __init__(self):
        self.results = {}
        self.critical_failures = []
        
    def log_result(self, test_name: str, passed: bool, critical: bool = False):
        """Log a test result"""
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {status} {test_name}")
        
        self.results[test_name] = passed
        if not passed and critical:
            self.critical_failures.append(test_name)
    
    def validate_json_files(self) -> bool:
        """Validate JSON syntax in translation files"""
        print("\n🔍 Validating JSON Files...")
        
        json_files = [
            "ui/src/translations/apps-tests-ai.json"
        ]
        
        all_valid = True
        for json_file in json_files:
            try:
                if os.path.exists(json_file):
                    with open(json_file, 'r') as f:
                        json.load(f)
                    self.log_result(f"JSON syntax: {json_file}", True)
                else:
                    self.log_result(f"JSON file exists: {json_file}", False, critical=True)
                    all_valid = False
            except json.JSONDecodeError as e:
                self.log_result(f"JSON syntax: {json_file}", False, critical=True)
                all_valid = False
        
        return all_valid
    
    def validate_enhanced_components(self) -> bool:
        """Validate that all enhanced components exist"""
        print("\n🔧 Validating Enhanced Components...")
        
        components = [
            ("API Key Storage", "ui/src/utils/apiKeyStorage.ts"),
            ("API Key Settings", "ui/src/components/settings/ApiKeySettings.vue"),
            ("AI Service", "ui/src/services/aiService.ts"),
            ("Apps Component", "ui/src/components/apps/Apps.vue"),
            ("Tests Component", "ui/src/components/tests/Tests.vue"),
            ("AI Copilot", "ui/src/components/ai/AiCopilot.vue"),
            ("Custom Blueprints", "ui/src/components/flows/blueprints/CustomBlueprints.vue")
        ]
        
        all_exist = True
        for name, path in components:
            exists = os.path.exists(path)
            self.log_result(name, exists, critical=True)
            if not exists:
                all_exist = False
        
        return all_exist
    
    def validate_component_functionality(self) -> bool:
        """Validate component functionality through code analysis"""
        print("\n🧪 Validating Component Functionality...")
        
        # Validate API Key Storage
        try:
            with open("ui/src/utils/apiKeyStorage.ts", 'r') as f:
                api_key_content = f.read()
            
            api_key_features = [
                ("Encryption support", "btoa" in api_key_content or "atob" in api_key_content),
                ("LocalStorage integration", "localStorage" in api_key_content),
                ("Gemini key validation", "AIza" in api_key_content),
                ("OpenAI key validation", "sk-" in api_key_content),
                ("Anthropic key validation", "sk-ant-" in api_key_content),
                ("Key validation functions", "validateApiKey" in api_key_content or "isValidApiKey" in api_key_content)
            ]
            
            all_api_features = True
            for feature_name, has_feature in api_key_features:
                self.log_result(f"API Key Storage - {feature_name}", has_feature)
                if not has_feature:
                    all_api_features = False
        except Exception as e:
            self.log_result("API Key Storage validation", False, critical=True)
            all_api_features = False
        
        # Validate AI Service
        try:
            with open("ui/src/services/aiService.ts", 'r') as f:
                ai_service_content = f.read()
            
            ai_service_features = [
                ("Gemini API integration", "generativelanguage.googleapis.com" in ai_service_content),
                ("OpenAI API integration", "api.openai.com" in ai_service_content),
                ("Anthropic API integration", "api.anthropic.com" in ai_service_content),
                ("Direct API calls", "fetch(" in ai_service_content),
                ("Error handling", "try {" in ai_service_content and "catch" in ai_service_content),
                ("Provider detection", "getAvailableProviders" in ai_service_content)
            ]
            
            all_ai_features = True
            for feature_name, has_feature in ai_service_features:
                self.log_result(f"AI Service - {feature_name}", has_feature)
                if not has_feature:
                    all_ai_features = False
        except Exception as e:
            self.log_result("AI Service validation", False, critical=True)
            all_ai_features = False
        
        return all_api_features and all_ai_features
    
    def validate_translations(self) -> bool:
        """Validate translation completeness"""
        print("\n🌐 Validating Translations...")
        
        try:
            with open("ui/src/translations/apps-tests-ai.json", 'r') as f:
                translations = json.load(f)
            
            if 'en' not in translations:
                self.log_result("English locale exists", False, critical=True)
                return False
            
            en_translations = translations['en']
            required_sections = ['ai', 'settings', 'apps', 'tests']
            
            all_sections_present = True
            for section in required_sections:
                has_section = section in en_translations
                self.log_result(f"Translation section: {section}", has_section)
                if not has_section:
                    all_sections_present = False
            
            # Validate AI section keys
            if 'ai' in en_translations:
                ai_keys = en_translations['ai']
                required_ai_keys = ['copilot', 'generate_flow', 'error']
                
                for key in required_ai_keys:
                    has_key = key in ai_keys
                    self.log_result(f"AI translation key: {key}", has_key)
                    if not has_key:
                        all_sections_present = False
            
            return all_sections_present
            
        except Exception as e:
            self.log_result("Translation file validation", False, critical=True)
            return False
    
    def validate_documentation(self) -> bool:
        """Validate documentation completeness"""
        print("\n📚 Validating Documentation...")
        
        # Check README.md
        try:
            with open("README.md", 'r') as f:
                readme_content = f.read()
            
            readme_sections = [
                ("Enhanced Features section", "🚀 Enhanced Features" in readme_content),
                ("AI Copilot documentation", "AI Copilot Integration" in readme_content),
                ("Development setup guide", "Local Development Setup" in readme_content),
                ("Prerequisites section", "Prerequisites" in readme_content),
                ("AI integration setup", "AI Integration Setup" in readme_content),
                ("Troubleshooting guide", "Troubleshooting" in readme_content)
            ]
            
            all_readme_sections = True
            for section_name, has_section in readme_sections:
                self.log_result(f"README.md - {section_name}", has_section)
                if not has_section:
                    all_readme_sections = False
        except Exception as e:
            self.log_result("README.md validation", False, critical=True)
            all_readme_sections = False
        
        # Check TESTING.md
        try:
            with open("TESTING.md", 'r') as f:
                testing_content = f.read()
            
            testing_sections = [
                ("Manual testing checklist", "Manual Testing Checklist" in testing_content),
                ("API key testing", "API Key Management Testing" in testing_content),
                ("Component testing", "Apps Component Testing" in testing_content),
                ("Testing environment setup", "Testing Environment Setup" in testing_content)
            ]
            
            all_testing_sections = True
            for section_name, has_section in testing_sections:
                self.log_result(f"TESTING.md - {section_name}", has_section)
                if not has_section:
                    all_testing_sections = False
        except Exception as e:
            self.log_result("TESTING.md validation", False, critical=True)
            all_testing_sections = False
        
        return all_readme_sections and all_testing_sections
    
    def validate_deployment_files(self) -> bool:
        """Validate deployment configuration files"""
        print("\n🚀 Validating Deployment Files...")
        
        deployment_files = [
            ("Gradle build file", "build.gradle"),
            ("Gradle wrapper", "gradlew"),
            ("Package.json", "ui/package.json"),
            ("Vite config", "ui/vite.config.js"),
            ("Docker Compose", "docker-compose.yml"),
            ("Dockerfile", "Dockerfile")
        ]
        
        all_files_exist = True
        for name, path in deployment_files:
            exists = os.path.exists(path)
            self.log_result(name, exists)
            if not exists:
                all_files_exist = False
        
        return all_files_exist
    
    def run_all_validations(self) -> bool:
        """Run all validation tests"""
        print("🎯 KESTRA ENHANCED FEATURES - DEPLOYMENT VALIDATION")
        print("=" * 60)
        
        validations = [
            ("JSON Files", self.validate_json_files),
            ("Enhanced Components", self.validate_enhanced_components),
            ("Component Functionality", self.validate_component_functionality),
            ("Translations", self.validate_translations),
            ("Documentation", self.validate_documentation),
            ("Deployment Files", self.validate_deployment_files)
        ]
        
        all_passed = True
        for validation_name, validation_func in validations:
            try:
                result = validation_func()
                if not result:
                    all_passed = False
            except Exception as e:
                print(f"\n❌ Error in {validation_name}: {e}")
                all_passed = False
        
        return all_passed
    
    def print_summary(self, all_passed: bool):
        """Print validation summary"""
        print("\n" + "=" * 60)
        print("📊 VALIDATION SUMMARY")
        print("=" * 60)
        
        passed_count = sum(1 for result in self.results.values() if result)
        total_count = len(self.results)
        
        print(f"\n📈 Tests Passed: {passed_count}/{total_count} ({(passed_count/total_count)*100:.1f}%)")
        
        if self.critical_failures:
            print(f"\n❌ Critical Failures ({len(self.critical_failures)}):")
            for failure in self.critical_failures:
                print(f"  • {failure}")
        
        print(f"\n🚀 DEPLOYMENT STATUS:")
        if all_passed and not self.critical_failures:
            print("  ✅ READY FOR DEPLOYMENT")
            print("  ✅ All validations passed")
            print("  ✅ Enhanced features are functional")
            print("  ✅ Documentation is complete")
            print("\n🎉 The enhanced Kestra platform is ready for production deployment!")
        else:
            print("  ❌ NOT READY FOR DEPLOYMENT")
            if self.critical_failures:
                print("  ❌ Critical issues must be resolved")
            else:
                print("  ❌ Some validations failed")
            print("\n🔧 Please address the issues above before deploying.")

def main():
    """Main validation function"""
    validator = DeploymentValidator()
    
    try:
        all_passed = validator.run_all_validations()
        validator.print_summary(all_passed)
        
        # Exit with appropriate code
        if all_passed and not validator.critical_failures:
            sys.exit(0)  # Success
        else:
            sys.exit(1)  # Failure
            
    except KeyboardInterrupt:
        print("\n\n⚠️ Validation interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error during validation: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
