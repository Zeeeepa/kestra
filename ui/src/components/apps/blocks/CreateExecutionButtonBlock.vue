<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="create-execution-button-block">
            <div class="button-container">
                <button 
                    @click="handleCreate"
                    :class="[
                        'btn',
                        `btn-${buttonClass}`,
                        `btn-${buttonSize}`
                    ]"
                    :disabled="disabled || loading"
                    :title="buttonTitle"
                >
                    <i v-if="loading" class="fas fa-spinner fa-spin me-2" />
                    <i v-else :class="buttonIcon" class="me-2" />
                    {{ loading ? 'Creating...' : text }}
                </button>
            </div>

            <!-- Success/Error Messages -->
            <div v-if="message" :class="['alert', 'mt-3', messageType === 'success' ? 'alert-success' : 'alert-danger']">
                <i :class="messageType === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle'" class="me-2" />
                {{ message }}
                <a v-if="messageType === 'success' && executionUrl" :href="executionUrl" target="_blank" class="alert-link ms-2">
                    View execution <i class="fas fa-external-link-alt ms-1" />
                </a>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {ref, computed} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import type {CreateExecutionButtonBlockProps} from "../../../types/apps";

    const props = withDefaults(defineProps<CreateExecutionButtonBlockProps>(), {
        text: "Create Execution",
        style: "SUCCESS",
        size: "MEDIUM",
        states: () => ["OPEN"],
        className: "",
        disabled: false,
        icon: "fas fa-rocket"
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    // Reactive state
    const loading = ref(false);
    const message = ref("");
    const messageType = ref<"success" | "error">("success");
    const executionUrl = ref("");

    // Computed properties
    const buttonClass = computed(() => {
        switch (props.style) {
        case "SUCCESS": return "success";
        case "DANGER": return "danger";
        case "INFO": return "info";
        case "DEFAULT": default: return "primary";
        }
    });

    const buttonSize = computed(() => {
        switch (props.size) {
        case "SMALL": return "sm";
        case "LARGE": return "lg";
        case "MEDIUM": default: return "md";
        }
    });

    const buttonIcon = computed(() => props.icon || "fas fa-rocket");
    const buttonTitle = computed(() => props.disabled ? "Cannot create execution" : "Create new workflow execution");
    const disabled = computed(() => props.disabled || loading.value);

    // Methods
    async function handleCreate() {
        if (disabled.value) return;

        try {
            loading.value = true;
            message.value = "";

            const executionData = {
                timestamp: new Date().toISOString(),
                flow: "demo-workflow"
            };

            emit("blockAction", "execution_created", executionData);
            await new Promise(resolve => setTimeout(resolve, 1200));

            const newExecutionId = `exec_${Date.now()}`;
            executionUrl.value = `/executions/${newExecutionId}`;
            message.value = `Execution ${newExecutionId} created successfully.`;
            messageType.value = "success";

            setTimeout(() => { message.value = ""; }, 5000);

        } catch (err) {
            message.value = err instanceof Error ? err.message : "Failed to create execution";
            messageType.value = "error";
            emit("blockError", message.value);
        } finally {
            loading.value = false;
        }
    }
</script>

<style scoped>
.create-execution-button-block {
    text-align: center;
    padding: 1rem 0;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.5rem 1rem;
    font-weight: 500;
    border-radius: 0.375rem;
    transition: all 0.15s ease-in-out;
    min-width: 140px;
}

.btn-success {
    color: #fff;
    background-color: #28a745;
    border-color: #28a745;
}

.btn-success:hover:not(:disabled) {
    background-color: #1e7e34;
    transform: translateY(-1px);
}

.btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}

.alert {
    border-radius: 0.375rem;
    padding: 0.75rem 1rem;
}

.alert-success {
    color: #0f5132;
    background-color: #d1e7dd;
    border-color: #badbcc;
}

.alert-danger {
    color: #721c24;
    background-color: #f8d7da;
    border-color: #f5c6cb;
}

.alert-link {
    font-weight: 600;
    text-decoration: none;
}

.alert-link:hover {
    text-decoration: underline;
}
</style>
