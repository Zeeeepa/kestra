import {useAxios} from "../utils/axios";
import {apiUrl} from "override/utils/route";
import {makeToast} from "../utils/toast";
import {globalI18n} from "../translations/i18n";

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
     * Generate a flow from natural language description
     */
    async generateFlow(request: FlowGenerationRequest): Promise<FlowGenerationResponse> {
        try {
            const response = await this.axios.post(apiUrl("ai/generate-flow"), request);
            return response.data;
        } catch (error) {
            console.error("Error generating flow:", error);
            makeToast(this.t("ai.error.generate_flow"), "error");
            throw error;
        }
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
