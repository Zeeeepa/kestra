<template>
    <div 
        :class="[
            'app-block',
            `app-block--${blockType}`,
            `app-block--state-${currentState}`,
            className
        ]"
        :id="blockId"
    >
        <slot />
    </div>
</template>

<script setup lang="ts">
    import {computed, inject} from "vue";
    import type {BaseBlockProps, AppExecutionContext} from "../../../types/apps";

    interface Props extends BaseBlockProps {
        // Additional props can be added here
        [key: string]: any;
    }

    const props = withDefaults(defineProps<Props>(), {
        states: () => [],
        className: ""
    });

    // Inject execution context from parent app
    const executionContext = inject<AppExecutionContext>("executionContext");

    // Computed properties
    const blockType = computed(() => {
        const parts = props.type.split(".");
        return parts[parts.length - 1].toLowerCase();
    });

    const blockId = computed(() => {
        return props.id || `block-${blockType.value}-${Math.random().toString(36).substr(2, 9)}`;
    });

    const currentState = computed(() => {
        return executionContext?.state || "OPEN";
    });

    const isVisible = computed(() => {
        if (!props.states || props.states.length === 0) {
            return true;
        }
        return props.states.includes(currentState.value);
    });

    // Expose computed properties for child components
    defineExpose({
        blockType,
        blockId,
        currentState,
        isVisible,
        executionContext
    });
</script>

<style scoped>
.app-block {
    margin-bottom: 1rem;
    transition: all 0.3s ease;
}

.app-block--state-open {
    /* Styles for OPEN state */
}

.app-block--state-running {
    /* Styles for RUNNING state */
    opacity: 0.8;
}

.app-block--state-success {
    /* Styles for SUCCESS state */
    border-left: 4px solid #28a745;
}

.app-block--state-failure {
    /* Styles for FAILURE state */
    border-left: 4px solid #dc3545;
}

.app-block--state-pause {
    /* Styles for PAUSE state */
    border-left: 4px solid #ffc107;
}

/* Block type specific styles */
.app-block--markdown {
    /* Markdown block styles */
}

.app-block--button {
    /* Button block styles */
    text-align: center;
}

.app-block--alert {
    /* Alert block styles */
    padding: 1rem;
    border-radius: 0.375rem;
}

.app-block--loading {
    /* Loading block styles */
    text-align: center;
    padding: 2rem;
}
</style>
