import {useAxios} from "../utils/axios";
import {apiUrl} from "override/utils/route";
import {makeToast} from "../utils/toast";
import {globalI18n} from "../translations/i18n";
import {getApiKey, hasApiKey} from "../utils/apiKeyStorage";

interface AiProvider {
    type: 'gemini' | 'openai' | 'anthropic' | 'azure' | 'bedrock' | 'ollama';
    apiKey?: string;
    modelName?: string;
    endpoint?: string;
    temperature?: number;
    topP?: number;
    topK?: number;
    maxOutputTokens?: number;
}

interface AiRequest {
    prompt: string;
    context?: string;
    flowYaml?: string;
    provider?: AiProvider;
    options?: {
        temperature?: number;
        maxTokens?: number;
        stream?: boolean;
    };
}

interface AiResponse {
    content: string;
    usage?: {
        promptTokens: number;
        completionTokens: number;
        totalTokens: number;
    };
    model?: string;
    finishReason?: string;
}

interface FlowGenerationRequest {
    description: string;
    existingFlow?: string;
    namespace?: string;
    requirements?: string[];
    plugins?: string[];
}

interface FlowGenerationResponse {
    yaml: string;
    explanation: string;
    suggestions?: string[];
    warnings?: string[];
}

export class AiService {
    private axios = useAxios();

    private t = (key: string, values?: Record<string, any>) => {
        if (!globalI18n.value) {
            return key;
        }
        return globalI18n.value.t(key, values);
    };

    /**
     * Get available AI providers (only those with configured API keys)
     */
    getAvailableProviders(): AiProvider[] {
        const allProviders = [
            {
                type: 'gemini' as const,
                name: 'Google Gemini',
                models: ['gemini-1.5-pro', 'gemini-1.5-flash', 'gemini-pro'],
                capabilities: ['text', 'vision', 'function_calling'],
                maxTokens: 1048576,
                costPer1kTokens: 0.0015
            },
            {
                type: 'openai' as const,
                name: 'OpenAI',
                models: ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo'],
                capabilities: ['text', 'vision', 'function_calling'],
                maxTokens: 128000,
                costPer1kTokens: 0.03
            },
            {
                type: 'anthropic' as const,
                name: 'Anthropic Claude',
                models: ['claude-3-5-sonnet-20241022', 'claude-3-haiku-20240307', 'claude-3-opus-20240229'],
                capabilities: ['text', 'vision', 'function_calling'],
                maxTokens: 200000,
                costPer1kTokens: 0.015
            }
        ];

        // Only return providers that have API keys configured
        return allProviders.filter(provider => hasApiKey(provider.type));
    }

    /**
     * Check if any AI provider is configured
     */
    hasConfiguredProvider(): boolean {
        return hasApiKey('gemini') || hasApiKey('openai') || hasApiKey('anthropic');
    }

    /**
     * Get the preferred AI provider (first available one)
     */
    getPreferredProvider(): AiProvider | null {
        const available = this.getAvailableProviders();
        return available.length > 0 ? available[0] : null;
    }

    /**
     * Make direct API call to AI provider
     */
    private async callAiProvider(provider: AiProvider, prompt: string, model?: string): Promise<string> {
        const apiKey = getApiKey(provider.type);
        if (!apiKey) {
            throw new Error(`No API key configured for ${provider.name}`);
        }

        const selectedModel = model || provider.models[0];

        switch (provider.type) {
            case 'gemini':
                return await this.callGemini(apiKey, prompt, selectedModel);
            case 'openai':
                return await this.callOpenAI(apiKey, prompt, selectedModel);
            case 'anthropic':
                return await this.callAnthropic(apiKey, prompt, selectedModel);
            default:
                throw new Error(`Unsupported provider: ${provider.type}`);
        }
    }

    /**
     * Call Gemini API directly
     */
    private async callGemini(apiKey: string, prompt: string, model: string): Promise<string> {
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                contents: [{
                    parts: [{
                        text: prompt
                    }]
                }],
                generationConfig: {
                    temperature: 0.7,
                    topK: 40,
                    topP: 0.95,
                    maxOutputTokens: 8192,
                }
            })
        });

        if (!response.ok) {
            throw new Error(`Gemini API error: ${response.statusText}`);
        }

        const data = await response.json();
        return data.candidates?.[0]?.content?.parts?.[0]?.text || '';
    }

    /**
     * Call OpenAI API directly
     */
    private async callOpenAI(apiKey: string, prompt: string, model: string): Promise<string> {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify({
                model: model,
                messages: [{
                    role: 'user',
                    content: prompt
                }],
                temperature: 0.7,
                max_tokens: 4096
            })
        });

        if (!response.ok) {
            throw new Error(`OpenAI API error: ${response.statusText}`);
        }

        const data = await response.json();
        return data.choices?.[0]?.message?.content || '';
    }

    /**
     * Call Anthropic API directly
     */
    private async callAnthropic(apiKey: string, prompt: string, model: string): Promise<string> {
        const response = await fetch('https://api.anthropic.com/v1/messages', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': apiKey,
                'anthropic-version': '2023-06-01'
            },
            body: JSON.stringify({
                model: model,
                max_tokens: 4096,
                messages: [{
                    role: 'user',
                    content: prompt
                }]
            })
        });

        if (!response.ok) {
            throw new Error(`Anthropic API error: ${response.statusText}`);
        }

        const data = await response.json();
        return data.content?.[0]?.text || '';
    }

    /**
     * Generate a flow from natural language description
     */
    async generateFlow(request: FlowGenerationRequest): Promise<FlowGenerationResponse> {
        try {
            // Check if we have a configured AI provider
            if (!this.hasConfiguredProvider()) {
                throw new Error(this.t("ai.error.no_provider_configured"));
            }

            const provider = this.getPreferredProvider();
            if (!provider) {
                throw new Error(this.t("ai.error.no_provider_available"));
            }

            // Create a comprehensive prompt for flow generation
            const prompt = this.createFlowGenerationPrompt(request);
            
            // Call the AI provider directly
            const aiResponse = await this.callAiProvider(provider, prompt);
            
            // Parse the AI response to extract YAML and explanation
            return this.parseFlowGenerationResponse(aiResponse, request);
        } catch (error) {
            console.error("Error generating flow:", error);
            makeToast(this.t("ai.error.generate_flow"), "error");
            throw error;
        }
    }

    /**
     * Create a comprehensive prompt for flow generation
     */
    private createFlowGenerationPrompt(request: FlowGenerationRequest): string {
        return `You are an expert Kestra workflow engineer. Generate a complete Kestra flow YAML based on the following requirements:

**Description:** ${request.description}
**Namespace:** ${request.namespace || 'default'}
**Flow ID:** ${request.flowId || 'generated-flow'}

**Requirements:**
- Create a valid Kestra flow YAML
- Include appropriate tasks for the described functionality
- Add error handling where appropriate
- Use best practices for task naming and organization
- Include comments explaining complex logic

**Response Format:**
Please respond with a JSON object containing:
{
  "yaml": "the complete flow YAML",
  "explanation": "detailed explanation of the flow",
  "suggestions": ["optional improvement suggestions"],
  "warnings": ["any potential issues or considerations"]
}

Generate the flow now:`;
    }

    /**
     * Parse AI response to extract flow components
     */
    private parseFlowGenerationResponse(aiResponse: string, request: FlowGenerationRequest): FlowGenerationResponse {
        try {
            // Try to parse as JSON first
            const parsed = JSON.parse(aiResponse);
            if (parsed.yaml && parsed.explanation) {
                return parsed;
            }
        } catch (error) {
            // If JSON parsing fails, try to extract YAML manually
        }

        // Fallback: extract YAML from response
        const yamlMatch = aiResponse.match(/```ya?ml\n([\s\S]*?)\n```/);
        const yaml = yamlMatch ? yamlMatch[1] : this.generateFallbackYaml(request);
        
        return {
            yaml,
            explanation: this.t("ai.generated_flow_explanation"),
            suggestions: [this.t("ai.review_generated_flow")],
            warnings: [this.t("ai.test_before_production")]
        };
    }

    /**
     * Generate a fallback YAML if AI response parsing fails
     */
    private generateFallbackYaml(request: FlowGenerationRequest): string {
        return `id: ${request.flowId || 'generated-flow'}
namespace: ${request.namespace || 'default'}
description: ${request.description}

tasks:
  - id: log-start
    type: io.kestra.plugin.core.log.Log
    message: "Starting flow: ${request.description}"
  
  - id: main-task
    type: io.kestra.plugin.core.log.Log
    message: "TODO: Implement main logic for: ${request.description}"
  
  - id: log-end
    type: io.kestra.plugin.core.log.Log
    message: "Flow completed successfully"`;
    }

    /**
     * Refine an existing flow with AI suggestions
     */
    async refineFlow(flowYaml: string, instructions: string): Promise<FlowGenerationResponse> {
        try {
            const response = await this.axios.post(apiUrl("ai/refine-flow"), {
                flowYaml,
                instructions
            });
            return response.data;
        } catch (error) {
            console.error("Error refining flow:", error);
            makeToast(this.t("ai.error.refine_flow"), "error");
            throw error;
        }
    }

    /**
     * Add tasks to an existing flow
     */
    async addTasks(flowYaml: string, taskDescription: string): Promise<FlowGenerationResponse> {
        try {
            const response = await this.axios.post(apiUrl("ai/add-tasks"), {
                flowYaml,
                taskDescription
            });
            return response.data;
        } catch (error) {
            console.error("Error adding tasks:", error);
            makeToast(this.t("ai.error.add_tasks"), "error");
            throw error;
        }
    }

    /**
     * Add triggers to an existing flow
     */
    async addTriggers(flowYaml: string, triggerDescription: string): Promise<FlowGenerationResponse> {
        try {
            const response = await this.axios.post(apiUrl("ai/add-triggers"), {
                flowYaml,
                triggerDescription
            });
            return response.data;
        } catch (error) {
            console.error("Error adding triggers:", error);
            makeToast(this.t("ai.error.add_triggers"), "error");
            throw error;
        }
    }

    /**
     * Explain a flow or specific parts of it
     */
    async explainFlow(flowYaml: string, focus?: string): Promise<{ explanation: string }> {
        try {
            const response = await this.axios.post(apiUrl("ai/explain-flow"), {
                flowYaml,
                focus
            });
            return response.data;
        } catch (error) {
            console.error("Error explaining flow:", error);
            makeToast(this.t("ai.error.explain_flow"), "error");
            throw error;
        }
    }

    /**
     * Optimize a flow for performance or best practices
     */
    async optimizeFlow(flowYaml: string, optimizationType: 'performance' | 'readability' | 'best-practices'): Promise<FlowGenerationResponse> {
        try {
            const response = await this.axios.post(apiUrl("ai/optimize-flow"), {
                flowYaml,
                optimizationType
            });
            return response.data;
        } catch (error) {
            console.error("Error optimizing flow:", error);
            makeToast(this.t("ai.error.optimize_flow"), "error");
            throw error;
        }
    }

    /**
     * Generate test cases for a flow
     */
    async generateTests(flowYaml: string, testTypes: string[] = ['smoke', 'integration']): Promise<{ yaml: string, explanation: string }> {
        try {
            const response = await this.axios.post(apiUrl("ai/generate-tests"), {
                flowYaml,
                testTypes
            });
            return response.data;
        } catch (error) {
            console.error("Error generating tests:", error);
            makeToast(this.t("ai.error.generate_tests"), "error");
            throw error;
        }
    }

    /**
     * Generate documentation for a flow
     */
    async generateDocumentation(flowYaml: string, format: 'markdown' | 'html' = 'markdown'): Promise<{ documentation: string }> {
        try {
            const response = await this.axios.post(apiUrl("ai/generate-docs"), {
                flowYaml,
                format
            });
            return response.data;
        } catch (error) {
            console.error("Error generating documentation:", error);
            makeToast(this.t("ai.error.generate_docs"), "error");
            throw error;
        }
    }

    /**
     * Convert flow between different formats or versions
     */
    async convertFlow(flowYaml: string, targetFormat: string): Promise<FlowGenerationResponse> {
        try {
            const response = await this.axios.post(apiUrl("ai/convert-flow"), {
                flowYaml,
                targetFormat
            });
            return response.data;
        } catch (error) {
            console.error("Error converting flow:", error);
            makeToast(this.t("ai.error.convert_flow"), "error");
            throw error;
        }
    }

    /**
     * Get AI suggestions for improving a flow
     */
    async getSuggestions(flowYaml: string): Promise<{ suggestions: Array<{ type: string, message: string, severity: 'info' | 'warning' | 'error' }> }> {
        try {
            const response = await this.axios.post(apiUrl("ai/suggestions"), {
                flowYaml
            });
            return response.data;
        } catch (error) {
            console.error("Error getting suggestions:", error);
            makeToast(this.t("ai.error.get_suggestions"), "error");
            throw error;
        }
    }

    /**
     * Chat with AI about flows and Kestra concepts
     */
    async chat(message: string, context?: { flowYaml?: string, conversationHistory?: Array<{ role: 'user' | 'assistant', content: string }> }): Promise<{ response: string }> {
        try {
            const response = await this.axios.post(apiUrl("ai/chat"), {
                message,
                context
            });
            return response.data;
        } catch (error) {
            console.error("Error in AI chat:", error);
            makeToast(this.t("ai.error.chat"), "error");
            throw error;
        }
    }

    /**
     * Check AI service availability and configuration
     */
    async checkAvailability(): Promise<{ available: boolean, provider?: string, model?: string, features?: string[] }> {
        try {
            const response = await this.axios.get(apiUrl("ai/status"));
            return response.data;
        } catch (error) {
            console.error("Error checking AI availability:", error);
            return { available: false };
        }
    }

    /**
     * Get available AI models and providers
     */
    async getProviders(): Promise<{ providers: Array<{ type: string, name: string, models: string[], features: string[] }> }> {
        try {
            const response = await this.axios.get(apiUrl("ai/providers"));
            return response.data;
        } catch (error) {
            console.error("Error getting AI providers:", error);
            return { providers: [] };
        }
    }
}
