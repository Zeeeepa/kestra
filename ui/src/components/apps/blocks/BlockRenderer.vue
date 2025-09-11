<template>
    <div class="block-renderer">
        <component
            v-if="blockComponent && isBlockVisible"
            :is="blockComponent"
            v-bind="blockProps"
            :key="blockKey"
            @block-action="handleBlockAction"
            @block-error="handleBlockError"
        />
        <div v-else-if="!isBlockVisible" class="block-hidden">
            <!-- Block is hidden for current state -->
        </div>
        <div v-else class="block-error">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle me-2" />
                <strong>Block Error:</strong> Unknown block type "{{ blockProps.type }}"
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
    import {computed, ref, watch, onMounted} from "vue";
    import {blockRegistry} from "../../../utils/blockRegistry";
    import type {LayoutBlockProps, AppExecutionContext} from "../../../types/apps";

    interface Props {
        block: LayoutBlockProps;
        executionContext?: AppExecutionContext;
    }

    const props = defineProps<Props>();

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string, block: LayoutBlockProps];
    }>();

    // Reactive state
    const blockComponent = ref<any>(null);
    const loading = ref(false);
    const error = ref<string | null>(null);

    // Computed properties
    const blockProps = computed(() => props.block);

    const blockKey = computed(() => {
        // Create unique key for component re-rendering
        return `${props.block.type}-${props.executionContext?.state || "OPEN"}-${Date.now()}`;
    });

    const isBlockVisible = computed(() => {
        const currentState = props.executionContext?.state || "OPEN";
    
        // If no states specified, block is always visible
        if (!props.block.states || props.block.states.length === 0) {
            const definition = blockRegistry.get(props.block.type);
            if (definition) {
                return definition.availableStates.includes(currentState);
            }
            return true;
        }
    
        // Check if current state is in block's allowed states
        return props.block.states.includes(currentState);
    });

    // Methods
    async function loadBlockComponent() {
        loading.value = true;
        error.value = null;
    
        try {
            const definition = blockRegistry.get(props.block.type);
            if (!definition) {
                throw new Error(`Block type "${props.block.type}" is not registered`);
            }

            // Validate block props
            const validation = blockRegistry.validateProps(props.block.type, props.block);
            if (!validation.valid) {
                throw new Error(`Invalid block props: ${validation.errors.join(", ")}`);
            }

            // Load component dynamically
            if (typeof definition.component === "function") {
                const componentModule = await definition.component();
                blockComponent.value = componentModule.default || componentModule;
            } else {
                blockComponent.value = definition.component;
            }
        } catch (err) {
            error.value = err instanceof Error ? err.message : "Unknown error loading block";
            console.error("Error loading block component:", err);
            emit("blockError", error.value, props.block);
        } finally {
            loading.value = false;
        }
    }

    function handleBlockAction(action: string, data: any) {
        emit("blockAction", action, data);
    }

    function handleBlockError(error: string) {
        emit("blockError", error, props.block);
    }

    // Watchers
    watch(
        () => props.block.type,
        () => {
            loadBlockComponent();
        },
        {immediate: true}
    );

    // Lifecycle
    onMounted(() => {
        loadBlockComponent();
    });
</script>

<style scoped>
.block-renderer {
    position: relative;
}

.block-hidden {
    display: none;
}

.block-error {
    margin: 1rem 0;
}

.block-error .alert {
    margin: 0;
    padding: 0.75rem 1rem;
    border: 1px solid #f5c6cb;
    border-radius: 0.375rem;
    background-color: #f8d7da;
    color: #721c24;
}

.block-loading {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 2rem;
    color: #6c757d;
}

.block-loading i {
    margin-right: 0.5rem;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
</style>
