<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="create-execution-form-block">
            <div class="form-container">
                <div class="form-header">
                    <h4 class="form-title">
                        <i class="fas fa-play-circle me-2" />
                        Create New Execution
                    </h4>
                    <p class="form-description text-muted">
                        Configure and start a new workflow execution
                    </p>
                </div>

                <form @submit.prevent="handleSubmit" class="execution-form">
                    <!-- Flow Selection -->
                    <div class="mb-3">
                        <label for="flowId" class="form-label">
                            <i class="fas fa-project-diagram me-1" />
                            Flow <span class="text-danger">*</span>
                        </label>
                        <select 
                            id="flowId"
                            v-model="formData.flowId"
                            class="form-select"
                            required
                            :disabled="loading"
                        >
                            <option value="">
                                Select a flow...
                            </option>
                            <option 
                                v-for="flow in availableFlows" 
                                :key="flow.id" 
                                :value="flow.id"
                            >
                                {{ flow.namespace }}.{{ flow.id }}
                            </option>
                        </select>
                    </div>

                    <!-- Namespace (if not auto-selected) -->
                    <div class="mb-3" v-if="!selectedFlow">
                        <label for="namespace" class="form-label">
                            <i class="fas fa-folder me-1" />
                            Namespace
                        </label>
                        <input 
                            id="namespace"
                            v-model="formData.namespace"
                            type="text"
                            class="form-control"
                            placeholder="e.g., io.kestra.demo"
                            :disabled="loading"
                        >
                    </div>

                    <!-- Execution ID (optional) -->
                    <div class="mb-3">
                        <label for="executionId" class="form-label">
                            <i class="fas fa-fingerprint me-1" />
                            Execution ID (optional)
                        </label>
                        <input 
                            id="executionId"
                            v-model="formData.executionId"
                            type="text"
                            class="form-control"
                            placeholder="Auto-generated if empty"
                            :disabled="loading"
                        >
                        <div class="form-text">
                            Leave empty to auto-generate a unique ID
                        </div>
                    </div>

                    <!-- Inputs -->
                    <div class="mb-3" v-if="selectedFlow && selectedFlow.inputs && selectedFlow.inputs.length > 0">
                        <label class="form-label">
                            <i class="fas fa-cogs me-1" />
                            Flow Inputs
                        </label>
                        <div class="inputs-container">
                            <div 
                                v-for="input in selectedFlow.inputs" 
                                :key="input.id"
                                class="input-group mb-2"
                            >
                                <span class="input-group-text">{{ input.id }}</span>
                                <input 
                                    v-model="formData.inputs[input.id]"
                                    :type="getInputType(input.type)"
                                    class="form-control"
                                    :placeholder="input.description || `Enter ${input.id}`"
                                    :required="input.required"
                                    :disabled="loading"
                                >
                                <span v-if="input.required" class="input-group-text text-danger">*</span>
                            </div>
                        </div>
                    </div>

                    <!-- Labels -->
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="fas fa-tags me-1" />
                            Labels (optional)
                        </label>
                        <div class="labels-container">
                            <div 
                                v-for="(label, index) in formData.labels" 
                                :key="index"
                                class="label-input-group mb-2"
                            >
                                <div class="row">
                                    <div class="col-5">
                                        <input 
                                            v-model="label.key"
                                            type="text"
                                            class="form-control"
                                            placeholder="Key"
                                            :disabled="loading"
                                        >
                                    </div>
                                    <div class="col-5">
                                        <input 
                                            v-model="label.value"
                                            type="text"
                                            class="form-control"
                                            placeholder="Value"
                                            :disabled="loading"
                                        >
                                    </div>
                                    <div class="col-2">
                                        <button 
                                            type="button"
                                            @click="removeLabel(index)"
                                            class="btn btn-outline-danger btn-sm"
                                            :disabled="loading"
                                        >
                                            <i class="fas fa-times" />
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <button 
                                type="button"
                                @click="addLabel"
                                class="btn btn-outline-secondary btn-sm"
                                :disabled="loading"
                            >
                                <i class="fas fa-plus me-1" />
                                Add Label
                            </button>
                        </div>
                    </div>

                    <!-- Form Actions -->
                    <div class="form-actions">
                        <button 
                            type="submit"
                            class="btn btn-primary"
                            :disabled="!canSubmit || loading"
                        >
                            <i v-if="loading" class="fas fa-spinner fa-spin me-2" />
                            <i v-else class="fas fa-play me-2" />
                            {{ loading ? 'Creating...' : 'Create Execution' }}
                        </button>
                        <button 
                            type="button"
                            @click="resetForm"
                            class="btn btn-outline-secondary ms-2"
                            :disabled="loading"
                        >
                            <i class="fas fa-undo me-2" />
                            Reset
                        </button>
                    </div>
                </form>

                <!-- Error Display -->
                <div v-if="error" class="alert alert-danger mt-3">
                    <i class="fas fa-exclamation-triangle me-2" />
                    {{ error }}
                </div>

                <!-- Success Display -->
                <div v-if="success" class="alert alert-success mt-3">
                    <i class="fas fa-check-circle me-2" />
                    Execution created successfully! 
                    <a :href="executionUrl" target="_blank" class="alert-link">
                        View execution <i class="fas fa-external-link-alt ms-1" />
                    </a>
                </div>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import type {CreateExecutionFormBlockProps, Flow} from "../../../types/apps";

    withDefaults(defineProps<CreateExecutionFormBlockProps>(), {
        states: () => ["OPEN", "CREATED"],
        className: ""
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    // Reactive state
    const loading = ref(false);
    const error = ref("");
    const success = ref(false);
    const executionUrl = ref("");
    const availableFlows = ref<Flow[]>([]);

    const formData = ref({
        flowId: "",
        namespace: "",
        executionId: "",
        inputs: {} as Record<string, any>,
        labels: [{key: "", value: ""}]
    });

    // Computed properties
    const selectedFlow = computed(() => {
        return availableFlows.value.find(flow => flow.id === formData.value.flowId);
    });

    const canSubmit = computed(() => {
        return formData.value.flowId && !loading.value;
    });

    // Methods
    function getInputType(type: string): string {
        switch (type?.toLowerCase()) {
        case "int":
        case "integer":
        case "number":
            return "number";
        case "bool":
        case "boolean":
            return "checkbox";
        case "date":
            return "date";
        case "datetime":
            return "datetime-local";
        case "email":
            return "email";
        case "url":
            return "url";
        case "password":
            return "password";
        default:
            return "text";
        }
    }

    function addLabel() {
        formData.value.labels.push({key: "", value: ""});
    }

    function removeLabel(index: number) {
        formData.value.labels.splice(index, 1);
        if (formData.value.labels.length === 0) {
            addLabel();
        }
    }

    function resetForm() {
        formData.value = {
            flowId: "",
            namespace: "",
            executionId: "",
            inputs: {},
            labels: [{key: "", value: ""}]
        };
        error.value = "";
        success.value = false;
        executionUrl.value = "";
    }

    async function loadAvailableFlows() {
        try {
            loading.value = true;
            // Mock data for now - in real implementation, this would fetch from API
            availableFlows.value = [
                {
                    id: "hello-world",
                    namespace: "io.kestra.demo",
                    description: "Simple hello world flow",
                    inputs: [
                        {id: "name", type: "STRING", required: true, description: "Your name"}
                    ]
                },
                {
                    id: "data-processing",
                    namespace: "io.kestra.etl",
                    description: "Data processing pipeline",
                    inputs: [
                        {id: "source", type: "STRING", required: true, description: "Data source path"},
                        {id: "batch_size", type: "INT", required: false, description: "Batch size for processing"}
                    ]
                }
            ];
        } catch (err) {
            error.value = "Failed to load available flows";
            console.error("Error loading flows:", err);
        } finally {
            loading.value = false;
        }
    }

    async function handleSubmit() {
        try {
            loading.value = true;
            error.value = "";
            success.value = false;

            // Validate form
            if (!formData.value.flowId) {
                throw new Error("Please select a flow");
            }

            // Prepare execution data
            const executionData = {
                flowId: formData.value.flowId,
                namespace: selectedFlow.value?.namespace || formData.value.namespace,
                executionId: formData.value.executionId || undefined,
                inputs: formData.value.inputs,
                labels: formData.value.labels
                    .filter(label => label.key && label.value)
                    .reduce((acc, label) => {
                        acc[label.key] = label.value;
                        return acc;
                    }, {} as Record<string, string>)
            };

            // Emit action for tracking
            emit("blockAction", "execution_created", executionData);

            // Mock API call - in real implementation, this would call the Kestra API
            await new Promise(resolve => setTimeout(resolve, 1000));
        
            // Mock successful response
            const mockExecutionId = formData.value.executionId || `exec_${Date.now()}`;
            executionUrl.value = `/executions/${mockExecutionId}`;
            success.value = true;

            // Reset form after success
            setTimeout(() => {
                resetForm();
            }, 3000);

        } catch (err) {
            error.value = err instanceof Error ? err.message : "Failed to create execution";
            emit("blockError", error.value);
        } finally {
            loading.value = false;
        }
    }

    // Lifecycle
    onMounted(() => {
        loadAvailableFlows();
    });
</script>

<style scoped>
.create-execution-form-block {
    max-width: 600px;
    margin: 0 auto;
    padding: 1.5rem;
}

.form-container {
    background: #fff;
    border-radius: 0.5rem;
    border: 1px solid #e9ecef;
    padding: 2rem;
}

.form-header {
    text-align: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e9ecef;
}

.form-title {
    color: #495057;
    margin-bottom: 0.5rem;
}

.form-description {
    margin-bottom: 0;
}

.execution-form {
    margin-bottom: 0;
}

.form-label {
    font-weight: 600;
    color: #495057;
    margin-bottom: 0.5rem;
}

.form-control,
.form-select {
    border: 1px solid #ced4da;
    border-radius: 0.375rem;
    padding: 0.5rem 0.75rem;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.form-control:focus,
.form-select:focus {
    border-color: #007bff;
    box-shadow: 0 0 0 0.25rem rgba(0, 123, 255, 0.25);
}

.inputs-container,
.labels-container {
    background: #f8f9fa;
    border-radius: 0.375rem;
    padding: 1rem;
    border: 1px solid #e9ecef;
}

.input-group-text {
    background-color: #e9ecef;
    border: 1px solid #ced4da;
    font-weight: 500;
    min-width: 100px;
}

.label-input-group {
    background: #fff;
    border-radius: 0.375rem;
    padding: 0.75rem;
    border: 1px solid #dee2e6;
}

.form-actions {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    margin-top: 2rem;
    padding-top: 1rem;
    border-top: 1px solid #e9ecef;
}

.btn {
    padding: 0.5rem 1.5rem;
    font-weight: 500;
    border-radius: 0.375rem;
    transition: all 0.15s ease-in-out;
}

.btn-primary {
    background-color: #007bff;
    border-color: #007bff;
}

.btn-primary:hover:not(:disabled) {
    background-color: #0056b3;
    border-color: #004085;
}

.btn-outline-secondary {
    color: #6c757d;
    border-color: #6c757d;
}

.btn-outline-secondary:hover:not(:disabled) {
    background-color: #6c757d;
    color: #fff;
}

.btn-outline-danger {
    color: #dc3545;
    border-color: #dc3545;
}

.btn-outline-danger:hover:not(:disabled) {
    background-color: #dc3545;
    color: #fff;
}

.btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}

.alert {
    border-radius: 0.375rem;
    padding: 0.75rem 1rem;
    margin-bottom: 0;
}

.alert-danger {
    color: #721c24;
    background-color: #f8d7da;
    border-color: #f5c6cb;
}

.alert-success {
    color: #0f5132;
    background-color: #d1e7dd;
    border-color: #badbcc;
}

.alert-link {
    font-weight: 600;
    text-decoration: none;
}

.alert-link:hover {
    text-decoration: underline;
}

.text-danger {
    color: #dc3545 !important;
}

.text-muted {
    color: #6c757d !important;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .create-execution-form-block {
        padding: 1rem;
    }
    
    .form-container {
        padding: 1.5rem;
    }
    
    .form-actions {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
    }
}

/* Animation for loading spinner */
@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.fa-spin {
    animation: spin 1s linear infinite;
}
</style>
