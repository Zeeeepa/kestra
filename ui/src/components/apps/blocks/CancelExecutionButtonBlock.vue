<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="cancel-execution-button-block">
            <div class="button-container">
                <button 
                    @click="handleCancel"
                    :class="[
                        'btn',
                        `btn-${buttonClass}`,
                        `btn-${buttonSize}`,
                        {'btn-loading': loading}
                    ]"
                    :disabled="disabled || loading"
                    :title="buttonTitle"
                >
                    <i v-if="loading" class="fas fa-spinner fa-spin me-2" />
                    <i v-else :class="buttonIcon" class="me-2" />
                    {{ loading ? loadingText : text }}
                </button>
            </div>

            <!-- Confirmation Modal -->
            <div v-if="showConfirmation" class="confirmation-overlay" @click="closeConfirmation">
                <div class="confirmation-modal" @click.stop>
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-exclamation-triangle text-warning me-2" />
                            Confirm Cancellation
                        </h5>
                        <button 
                            type="button" 
                            class="btn-close" 
                            @click="closeConfirmation"
                            aria-label="Close"
                        />
                    </div>
                    <div class="modal-body">
                        <p class="mb-3">
                            Are you sure you want to cancel this execution?
                        </p>
                        <div class="execution-details">
                            <div class="detail-item">
                                <strong>Execution ID:</strong> 
                                <code>{{ executionId }}</code>
                            </div>
                            <div class="detail-item">
                                <strong>Flow:</strong> 
                                {{ flowName }}
                            </div>
                            <div class="detail-item">
                                <strong>Status:</strong> 
                                <span class="badge bg-primary">{{ currentStatus }}</span>
                            </div>
                        </div>
                        <div class="alert alert-warning mt-3">
                            <i class="fas fa-info-circle me-2" />
                            <strong>Warning:</strong> This action cannot be undone. The execution will be permanently cancelled.
                        </div>
                        
                        <!-- Optional cancellation reason -->
                        <div class="mt-3">
                            <label for="cancellationReason" class="form-label">
                                Cancellation Reason (optional)
                            </label>
                            <textarea 
                                id="cancellationReason"
                                v-model="cancellationReason"
                                class="form-control"
                                rows="3"
                                placeholder="Provide a reason for cancelling this execution..."
                            />
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button 
                            type="button" 
                            class="btn btn-secondary" 
                            @click="closeConfirmation"
                        >
                            <i class="fas fa-times me-2" />
                            Keep Running
                        </button>
                        <button 
                            type="button" 
                            class="btn btn-danger" 
                            @click="confirmCancel"
                            :disabled="loading"
                        >
                            <i v-if="loading" class="fas fa-spinner fa-spin me-2" />
                            <i v-else class="fas fa-stop me-2" />
                            {{ loading ? 'Cancelling...' : 'Cancel Execution' }}
                        </button>
                    </div>
                </div>
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
    import {ref, computed, onMounted} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import type {CancelExecutionButtonBlockProps} from "../../../types/apps";

    const props = withDefaults(defineProps<CancelExecutionButtonBlockProps>(), {
        text: "Cancel",
        style: "DANGER",
        size: "MEDIUM",
        states: () => ["RUNNING", "CREATED"],
        className: "",
        disabled: false,
        requireConfirmation: true,
        icon: "fas fa-stop"
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    // Reactive state
    const loading = ref(false);
    const showConfirmation = ref(false);
    const message = ref("");
    const messageType = ref<"success" | "error">("success");
    const cancellationReason = ref("");
    const executionUrl = ref("");

    // Mock execution data
    const executionId = ref("");
    const flowName = ref("");
    const currentStatus = ref("RUNNING");

    // Computed properties
    const buttonClass = computed(() => {
        switch (props.style) {
        case "SUCCESS":
            return "success";
        case "DANGER":
            return "danger";
        case "INFO":
            return "info";
        case "DEFAULT":
        default:
            return "secondary";
        }
    });

    const buttonSize = computed(() => {
        switch (props.size) {
        case "SMALL":
            return "sm";
        case "LARGE":
            return "lg";
        case "MEDIUM":
        default:
            return "md";
        }
    });

    const buttonIcon = computed(() => {
        return props.icon || "fas fa-stop";
    });

    const buttonTitle = computed(() => {
        if (props.disabled) return "Cannot cancel execution";
        if (loading.value) return "Cancelling execution...";
        return `Cancel execution ${executionId.value}`;
    });

    const loadingText = computed(() => {
        return "Cancelling...";
    });

    const disabled = computed(() => {
        return props.disabled || loading.value;
    });

    // Methods
    function handleCancel() {
        if (disabled.value) return;

        if (props.requireConfirmation) {
            showConfirmation.value = true;
        } else {
            performCancel();
        }
    }

    function closeConfirmation() {
        if (loading.value) return;
        showConfirmation.value = false;
        cancellationReason.value = "";
    }

    function confirmCancel() {
        performCancel();
    }

    async function performCancel() {
        try {
            loading.value = true;
            message.value = "";

            // Prepare cancellation data
            const cancellationData = {
                executionId: executionId.value,
                reason: cancellationReason.value,
                timestamp: new Date().toISOString(),
                flow: flowName.value
            };

            // Emit action for tracking
            emit("blockAction", "execution_cancelled", cancellationData);

            // Mock API call - in real implementation, this would call the Kestra API
            await new Promise(resolve => setTimeout(resolve, 1500));

            // Mock successful response
            executionUrl.value = `/executions/${executionId.value}`;
            message.value = `Execution ${executionId.value} has been cancelled successfully.`;
            messageType.value = "success";
            currentStatus.value = "CANCELLED";

            // Close confirmation modal
            showConfirmation.value = false;
            cancellationReason.value = "";

            // Clear message after delay
            setTimeout(() => {
                message.value = "";
            }, 5000);

        } catch (err) {
            message.value = err instanceof Error ? err.message : "Failed to cancel execution";
            messageType.value = "error";
            emit("blockError", message.value);
        } finally {
            loading.value = false;
        }
    }

    async function loadExecutionInfo() {
        try {
            // Mock data for demonstration - in real implementation, this would fetch from API
            await new Promise(resolve => setTimeout(resolve, 300));
        
            executionId.value = `exec_${Date.now()}`;
            flowName.value = "io.kestra.demo.data-processing";
            currentStatus.value = "RUNNING";
        
        } catch (err) {
            console.error("Error loading execution info:", err);
            emit("blockError", "Failed to load execution information");
        }
    }

    // Lifecycle
    onMounted(() => {
        loadExecutionInfo();
    });
</script>

<style scoped>
.cancel-execution-button-block {
    text-align: center;
    padding: 1rem 0;
}

.button-container {
    display: inline-block;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.5rem 1rem;
    font-size: 1rem;
    font-weight: 500;
    line-height: 1.5;
    text-align: center;
    text-decoration: none;
    vertical-align: middle;
    cursor: pointer;
    user-select: none;
    border: 1px solid transparent;
    border-radius: 0.375rem;
    transition: all 0.15s ease-in-out;
    min-width: 120px;
}

.btn:hover:not(:disabled) {
    text-decoration: none;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn:active:not(:disabled) {
    transform: translateY(0);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn:focus {
    outline: 0;
    box-shadow: 0 0 0 0.25rem rgba(220, 53, 69, 0.25);
}

/* Button styles */
.btn-danger {
    color: #fff;
    background-color: #dc3545;
    border-color: #dc3545;
}

.btn-danger:hover:not(:disabled) {
    background-color: #c82333;
    border-color: #bd2130;
}

.btn-secondary {
    color: #fff;
    background-color: #6c757d;
    border-color: #6c757d;
}

.btn-secondary:hover:not(:disabled) {
    background-color: #5a6268;
    border-color: #545b62;
}

.btn-success {
    color: #fff;
    background-color: #28a745;
    border-color: #28a745;
}

.btn-success:hover:not(:disabled) {
    background-color: #1e7e34;
    border-color: #1c7430;
}

.btn-info {
    color: #fff;
    background-color: #17a2b8;
    border-color: #17a2b8;
}

.btn-info:hover:not(:disabled) {
    background-color: #138496;
    border-color: #117a8b;
}

/* Button sizes */
.btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
    border-radius: 0.25rem;
    min-width: 80px;
}

.btn-md {
    padding: 0.5rem 1rem;
    font-size: 1rem;
    border-radius: 0.375rem;
    min-width: 120px;
}

.btn-lg {
    padding: 0.75rem 1.5rem;
    font-size: 1.125rem;
    border-radius: 0.5rem;
    min-width: 160px;
}

/* Disabled state */
.btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
    pointer-events: none;
}

.btn:disabled:hover {
    transform: none;
    box-shadow: none;
}

/* Loading state */
.btn-loading {
    position: relative;
}

/* Confirmation Modal */
.confirmation-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1050;
}

.confirmation-modal {
    background: #fff;
    border-radius: 0.5rem;
    box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
}

.modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #e9ecef;
}

.modal-title {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 500;
    color: #495057;
}

.btn-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: #6c757d;
    opacity: 0.5;
}

.btn-close:hover {
    opacity: 0.75;
}

.modal-body {
    padding: 1.5rem;
}

.execution-details {
    background: #f8f9fa;
    border-radius: 0.375rem;
    padding: 1rem;
    margin: 1rem 0;
}

.detail-item {
    margin-bottom: 0.5rem;
}

.detail-item:last-child {
    margin-bottom: 0;
}

.detail-item code {
    background: #e9ecef;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.875rem;
}

.badge {
    font-size: 0.75rem;
    font-weight: 500;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
}

.bg-primary {
    background-color: #007bff !important;
}

.modal-footer {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 0.5rem;
    padding: 1rem 1.5rem;
    border-top: 1px solid #e9ecef;
}

.form-control {
    border: 1px solid #ced4da;
    border-radius: 0.375rem;
    padding: 0.5rem 0.75rem;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.form-control:focus {
    border-color: #007bff;
    box-shadow: 0 0 0 0.25rem rgba(0, 123, 255, 0.25);
}

.form-label {
    font-weight: 600;
    color: #495057;
    margin-bottom: 0.5rem;
}

.alert {
    border-radius: 0.375rem;
    padding: 0.75rem 1rem;
    margin-bottom: 0;
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

.alert-warning {
    color: #664d03;
    background-color: #fff3cd;
    border-color: #ffecb5;
}

.alert-link {
    font-weight: 600;
    text-decoration: none;
}

.alert-link:hover {
    text-decoration: underline;
}

.text-warning {
    color: #ffc107 !important;
}

/* Responsive adjustments */
@media (max-width: 576px) {
    .btn {
        width: 100%;
        max-width: 300px;
    }
    
    .confirmation-modal {
        width: 95%;
        margin: 1rem;
    }
    
    .modal-footer {
        flex-direction: column;
    }
    
    .modal-footer .btn {
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
