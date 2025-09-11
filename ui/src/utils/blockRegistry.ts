// Block Registry for Kestra Apps Layout Blocks

import {BlockDefinition, LayoutBlockProps, AppState} from "../types/apps";

class BlockRegistry {
    private blocks: Map<string, BlockDefinition> = new Map();

    /**
     * Register a new layout block
     */
    register(definition: BlockDefinition): void {
        this.blocks.set(definition.type, definition);
    }

    /**
     * Get a block definition by type
     */
    get(type: string): BlockDefinition | undefined {
        return this.blocks.get(type);
    }

    /**
     * Get all registered blocks
     */
    getAll(): BlockDefinition[] {
        return Array.from(this.blocks.values());
    }

    /**
     * Get blocks by category
     */
    getByCategory(category: "core" | "execution" | "ui"): BlockDefinition[] {
        return this.getAll().filter(block => block.category === category);
    }

    /**
     * Get blocks available for a specific state
     */
    getByState(state: AppState): BlockDefinition[] {
        return this.getAll().filter(block => 
            block.availableStates.includes(state)
        );
    }

    /**
     * Check if a block type is registered
     */
    has(type: string): boolean {
        return this.blocks.has(type);
    }

    /**
     * Validate block props against its definition
     */
    validateProps(type: string, props: LayoutBlockProps): { valid: boolean; errors: string[] } {
        const definition = this.get(type);
        if (!definition) {
            return {valid: false, errors: [`Block type '${type}' is not registered`]};
        }

        const errors: string[] = [];

        // Basic type validation
        if (props.type !== type) {
            errors.push(`Block type mismatch: expected '${type}', got '${props.type}'`);
        }

        // State validation
        if (props.states) {
            const invalidStates = props.states.filter(state => 
                !definition.availableStates.includes(state)
            );
            if (invalidStates.length > 0) {
                errors.push(`Invalid states for block type '${type}': ${invalidStates.join(", ")}`);
            }
        }

        return {valid: errors.length === 0, errors};
    }

    /**
     * Create default props for a block type
     */
    createDefaultProps(type: string): LayoutBlockProps | null {
        const definition = this.get(type);
        if (!definition) {
            return null;
        }

        return {
            type,
            ...definition.defaultProps
        } as LayoutBlockProps;
    }
}

// Global registry instance
export const blockRegistry = new BlockRegistry();

// Helper function to register all core blocks
export function registerCoreBlocks(): void {
    // Import and register all block definitions
    // This will be called during app initialization
    
    // Core blocks
    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.core.blocks.Markdown",
        component: () => import("../components/apps/blocks/MarkdownBlock.vue"),
        name: "Markdown",
        description: "Display rich text content using Markdown",
        category: "core",
        availableStates: ["OPEN", "CREATED", "RUNNING", "PAUSE", "RESUME", "SUCCESS", "FAILURE", "FALLBACK"],
        defaultProps: {
            content: "# Welcome\n\nThis is a markdown block."
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.blocks.RedirectTo",
        component: () => import("../components/apps/blocks/RedirectToBlock.vue"),
        name: "Redirect To",
        description: "Redirect users to another URL with optional delay",
        category: "core",
        availableStates: ["OPEN", "CREATED", "RUNNING", "PAUSE", "RESUME", "SUCCESS", "FAILURE", "ERROR", "FALLBACK"],
        defaultProps: {
            url: "https://kestra.io/docs",
            delay: "PT60S"
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.core.blocks.Loading",
        component: () => import("../components/apps/blocks/LoadingBlock.vue"),
        name: "Loading",
        description: "Display loading spinner and progress indicators",
        category: "ui",
        availableStates: ["RUNNING"],
        defaultProps: {}
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.core.blocks.Alert",
        component: () => import("../components/apps/blocks/AlertBlock.vue"),
        name: "Alert",
        description: "Display status alerts with different styles",
        category: "ui",
        availableStates: ["FAILURE"],
        defaultProps: {
            style: "ERROR",
            showIcon: true,
            content: "An error occurred!"
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.core.blocks.Button",
        component: () => import("../components/apps/blocks/ButtonBlock.vue"),
        name: "Button",
        description: "Display clickable button with URL navigation",
        category: "ui",
        availableStates: ["SUCCESS", "FAILURE"],
        defaultProps: {
            text: "More examples",
            url: "https://github.com/kestra-io/examples",
            style: "INFO"
        }
    });

    // Execution blocks
    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.CreateExecutionForm",
        component: () => import("../components/apps/blocks/CreateExecutionFormBlock.vue"),
        name: "Create Execution Form",
        description: "Form to trigger new workflow executions",
        category: "execution",
        availableStates: ["OPEN"],
        defaultProps: {}
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.ResumeExecutionForm",
        component: () => import("../components/apps/blocks/ResumeExecutionFormBlock.vue"),
        name: "Resume Execution Form",
        description: "Form to resume paused workflow executions",
        category: "execution",
        availableStates: ["PAUSE"],
        defaultProps: {}
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.CreateExecutionButton",
        component: () => import("../components/apps/blocks/CreateExecutionButtonBlock.vue"),
        name: "Create Execution Button",
        description: "Button to trigger new workflow executions",
        category: "execution",
        availableStates: ["OPEN"],
        defaultProps: {
            text: "Submit",
            style: "SUCCESS",
            size: "MEDIUM"
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.CancelExecutionButton",
        component: () => import("../components/apps/blocks/CancelExecutionButtonBlock.vue"),
        name: "Cancel Execution Button",
        description: "Button to cancel running executions",
        category: "execution",
        availableStates: ["CREATED", "RUNNING", "PAUSE"],
        defaultProps: {
            text: "Reject",
            style: "DANGER",
            size: "SMALL"
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.ResumeExecutionButton",
        component: () => import("../components/apps/blocks/ResumeExecutionButtonBlock.vue"),
        name: "Resume Execution Button",
        description: "Button to resume paused executions",
        category: "execution",
        availableStates: ["PAUSE"],
        defaultProps: {
            text: "Approve",
            style: "SUCCESS",
            size: "LARGE"
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.Inputs",
        component: () => import("../components/apps/blocks/ExecutionInputsBlock.vue"),
        name: "Execution Inputs",
        description: "Display execution inputs with filtering",
        category: "execution",
        availableStates: ["PAUSE", "RESUME", "SUCCESS", "FAILURE"],
        defaultProps: {
            filter: {
                include: [],
                exclude: []
            }
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.Outputs",
        component: () => import("../components/apps/blocks/ExecutionOutputsBlock.vue"),
        name: "Execution Outputs",
        description: "Display execution outputs with filtering",
        category: "execution",
        availableStates: ["PAUSE", "RESUME", "SUCCESS", "FAILURE"],
        defaultProps: {
            filter: {
                include: [],
                exclude: []
            }
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.Logs",
        component: () => import("../components/apps/blocks/ExecutionLogsBlock.vue"),
        name: "Execution Logs",
        description: "Display execution logs with filtering",
        category: "execution",
        availableStates: ["PAUSE", "RESUME", "SUCCESS", "FAILURE", "FALLBACK"],
        defaultProps: {
            filter: {
                logLevel: "INFO",
                taskIds: []
            }
        }
    });

    blockRegistry.register({
        type: "io.kestra.plugin.ee.apps.execution.blocks.TaskOutputs",
        component: () => import("../components/apps/blocks/TaskOutputsBlock.vue"),
        name: "Task Outputs",
        description: "Display task outputs with data visualization",
        category: "execution",
        availableStates: ["RUNNING", "PAUSE", "RESUME", "SUCCESS"],
        defaultProps: {
            outputs: []
        }
    });
}

// Export types for external use
export type {BlockDefinition, LayoutBlockProps, AppState};
