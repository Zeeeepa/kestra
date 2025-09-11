<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="resume-execution-form-block">
            <div class="form-container">
                <div class="form-header">
                    <h4 class="form-title">
                        <i class="fas fa-play me-2" />
                        Resume Execution
                    </h4>
                    <p class="form-description text-muted">
                        Resume a paused workflow execution with additional inputs
                    </p>
                </div>

                <form @submit.prevent="handleSubmit" class="resume-form">
                    <!-- Execution Info -->
                    <div class="execution-info mb-4">
                        <div class="info-card">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="info-item">
                                        <label class="info-label">Execution ID</label>
                                        <div class="info-value">
                                            <code>{{ executionId || 'Loading...' }}</code>
                                            <button 
                                                v-if="executionId"
                                                type="button"
                                                @click="copyExecutionId"
                                                class="btn btn-sm btn-outline-secondary ms-2"
                                                title="Copy execution ID"
                                            >
                                                <i class="fas fa-copy" />
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="info-item">
                                        <label class="info-label">Flow</label>
                                        <div class="info-value">
                                            {{ flowInfo.namespace }}.{{ flowInfo.id }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row mt-2">
                                <div class="col-md-6">
                                    <div class="info-item">
                                        <label class="info-label">Status</label>
                                        <div class="info-value">
                                            <span class="badge bg-warning">
                                                <i class="fas fa-pause me-1" />
                                                PAUSED
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="info-item">
                                        <label class="info-label">Paused At</label>
                                        <div class="info-value">
                                            {{ formatDate(pausedAt) }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Resume Inputs -->
                    <div class="mb-3" v-if="resumeInputs && resumeInputs.length > 0">
                        <label class="form-label">
                            <i class="fas fa-cogs me-1" />
                            Resume Inputs
                        </label>
                        <div class="inputs-container">
                            <div 
                                v-for="input in resumeInputs" 
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

                    <!-- Resume Message -->
                    <div class="mb-3">
                        <label for="resumeMessage" class="form-label">
                            <i class="fas fa-comment me-1" />
                            Resume Message (optional)
                        </label>
                        <textarea 
                            id="resumeMessage"
                            v-model="formData.message"
                            class="form-control"
                            rows="3"
                            placeholder="Add a message explaining why this execution is being resumed..."
                            :disabled="loading"
                        />
                        <div class="form-text">
                            This message will be logged with the resume action
                        </div>
                    </div>

                    <!-- Additional Labels -->
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="fas fa-tags me-1" />
                            Additional Labels (optional)
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
                            class="btn btn-success"
                            :disabled="!canSubmit || loading"
                        >
                            <i v-if="loading" class="fas fa-spinner fa-spin me-2" />
                            <i v-else class="fas fa-play me-2" />
                            {{ loading ? 'Resuming...' : 'Resume Execution' }}
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
                        <button 
                            type="button"
                            @click="viewExecution"
                            class="btn btn-outline-info ms-2"
                            :disabled="loading"
                        >
                            <i class="fas fa-eye me-2" />
                            View Execution
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
                    Execution resumed successfully! 
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
    import type {ResumeExecutionFormBlockProps, ExecutionInput} from "../../../types/apps";

    withDefaults(defineProps<ResumeExecutionFormBlockProps>(), {
        states: () => ["PAUSE"],
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
    const executionId = ref("");
    const pausedAt = ref(new Date());

    const flowInfo = ref({
        id: "approval-workflow",
        namespace: "io.kestra.demo"
    });

    const resumeInputs = ref<ExecutionInput[]>([
        {id: "approval_decision", type: "STRING", required: true, description: "Approval decision (approve/reject)"},
        {id: "reviewer_notes", type: "STRING", required: false, description: "Additional reviewer notes"}
    ]);

    const formData = ref({
        inputs: {} as Record<string, any>,
        message: "",
        labels: [{key: "", value: ""}]
    });

    // Computed properties
    const canSubmit = computed(() => {
        // Check if all required inputs are filled
        const requiredInputsFilled = resumeInputs.value
            .filter(input => input.required)
            .every(input => formData.value.inputs[input.id]);
    
        return requiredInputsFilled && !loading.value;
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
            inputs: {},
            message: "",
            labels: [{key: "", value: ""}]
        };
        error.value = "";
        success.value = false;
        executionUrl.value = "";
    }

    function formatDate(date: Date): string {
        return date.toLocaleString();
    }

    async function copyExecutionId() {
        try {
            await navigator.clipboard.writeText(executionId.value);
            emit("blockAction", "execution_id_copied", {executionId: executionId.value});
        } catch {
            emit("blockError", "Failed to copy execution ID");
        }
    }

    function viewExecution() {
        const url = `/executions/${executionId.value}`;
        window.open(url, "_blank");
        emit("blockAction", "execution_viewed", {executionId: executionId.value});
    }

    async function loadExecutionInfo() {
        try {
            loading.value = true;
        
            // Mock data for demonstration - in real implementation, this would fetch from API
            await new Promise(resolve => setTimeout(resolve, 500));
        
            executionId.value = `exec_${Date.now()}`;
            pausedAt.value = new Date(Date.now() - 300000); // 5 minutes ago
        
            // Initialize form inputs with default values
            resumeInputs.value.forEach(input => {
                if (!formData.value.inputs[input.id]) {
                    formData.value.inputs[input.id] = "";
                }
            });
        
        } catch (err) {
            error.value = "Failed to load execution information";
            emit("blockError", error.value);
            console.error("Error loading execution info:", err);
        } finally {
            loading.value = false;
        }
    }

    async function handleSubmit() {
        try {
            loading.value = true;
            error.value = "";
            success.value = false;

            // Validate required inputs
            const missingInputs = resumeInputs.value
                .filter(input => input.required && !formData.value.inputs[input.id])
                .map(input => input.id);

            if (missingInputs.length > 0) {
                throw new Error(`Missing required inputs: ${missingInputs.join(", ")}`);
            }

            // Prepare resume data
            const resumeData = {
                executionId: executionId.value,
                inputs: formData.value.inputs,
                message: formData.value.message,
                labels: formData.value.labels
                    .filter(label => label.key && label.value)
                    .reduce((acc, label) => {
                        acc[label.key] = label.value;
                        return acc;
                    }, {} as Record<string, string>)
            };

            // Emit action for tracking
            emit("blockAction", "execution_resumed", resumeData);

            // Mock API call - in real implementation, this would call the Kestra API
            await new Promise(resolve => setTimeout(resolve, 1000));
        
            // Mock successful response
            executionUrl.value = `/executions/${executionId.value}`;
            success.value = true;

            // Reset form after success
            setTimeout(() => {
                resetForm();
            }, 3000);

        } catch (err) {
            error.value = err instanceof Error ? err.message : "Failed to resume execution";
            emit("blockError", error.value);
        } finally {
            loading.value = false;
        }
    }

    // Lifecycle
    onMounted(() => {
        loadExecutionInfo();
    });
</script>

<style scoped>
.resume-execution-form-block {
    max-width: 700px;
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

.execution-info {
    background: #f8f9fa;
    border-radius: 0.5rem;
    padding: 0;
}

.info-card {
    background: #fff;
    border-radius: 0.5rem;
    border: 1px solid #e9ecef;
    padding: 1.5rem;
}

.info-item {
    margin-bottom: 0.5rem;
}

.info-label {
    font-weight: 600;
    color: #6c757d;
    font-size: 0.875rem;
    margin-bottom: 0.25rem;
    display: block;
}

.info-value {
    color: #495057;
    font-size: 0.95rem;
    display: flex;
    align-items: center;
}

.info-value code {
    background: #f8f9fa;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.875rem;
    color: #495057;
}

.badge {
    font-size: 0.75rem;
    font-weight: 500;
}

.resume-form {
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
    min-width: 120px;
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

.btn-success {
    background-color: #28a745;
    border-color: #28a745;
}

.btn-success:hover:not(:disabled) {
    background-color: #1e7e34;
    border-color: #1c7430;
}

.btn-outline-secondary {
    color: #6c757d;
    border-color: #6c757d;
}

.btn-outline-secondary:hover:not(:disabled) {
    background-color: #6c757d;
    color: #fff;
}

.btn-outline-info {
    color: #17a2b8;
    border-color: #17a2b8;
}

.btn-outline-info:hover:not(:disabled) {
    background-color: #17a2b8;
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
    .resume-execution-form-block {
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
    
    .info-value {
        flex-direction: column;
        align-items: flex-start;
    }
    
    .info-value .btn {
        margin-top: 0.5rem;
        margin-left: 0 !important;
        width: auto;
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
