<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="execution-outputs-block">
            <div class="outputs-container">
                <div class="outputs-header">
                    <h5 class="outputs-title">
                        <i class="fas fa-sign-out-alt me-2" />
                        Execution Outputs
                    </h5>
                    <div class="outputs-actions">
                        <button 
                            @click="toggleView"
                            class="btn btn-sm btn-outline-secondary"
                            :title="viewMode === 'table' ? 'Switch to JSON view' : 'Switch to table view'"
                        >
                            <i :class="viewMode === 'table' ? 'fas fa-code' : 'fas fa-table'" />
                        </button>
                        <button 
                            @click="copyOutputs"
                            class="btn btn-sm btn-outline-primary ms-2"
                            title="Copy outputs to clipboard"
                        >
                            <i class="fas fa-copy" />
                        </button>
                        <button 
                            @click="downloadOutputs"
                            class="btn btn-sm btn-outline-info ms-2"
                            title="Download outputs as JSON"
                        >
                            <i class="fas fa-download" />
                        </button>
                    </div>
                </div>

                <!-- Loading State -->
                <div v-if="loading" class="loading-state">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading outputs...</span>
                    </div>
                    <p class="text-muted mt-2">
                        Loading execution outputs...
                    </p>
                </div>

                <!-- Empty State -->
                <div v-else-if="!outputs || Object.keys(outputs).length === 0" class="empty-state">
                    <i class="fas fa-inbox fa-3x text-muted mb-3" />
                    <h6 class="text-muted">
                        No Outputs
                    </h6>
                    <p class="text-muted small">
                        This execution has no output data.
                    </p>
                </div>

                <!-- Table View -->
                <div v-else-if="viewMode === 'table'" class="table-view">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th scope="col">
                                        <i class="fas fa-key me-1" />
                                        Output Key
                                    </th>
                                    <th scope="col">
                                        <i class="fas fa-tag me-1" />
                                        Type
                                    </th>
                                    <th scope="col">
                                        <i class="fas fa-eye me-1" />
                                        Value
                                    </th>
                                    <th scope="col" class="text-center">
                                        <i class="fas fa-cogs me-1" />
                                        Actions
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="(value, key) in outputs" :key="key">
                                    <td class="output-key">
                                        <code>{{ key }}</code>
                                    </td>
                                    <td class="output-type">
                                        <span :class="getTypeClass(value)">
                                            {{ getValueType(value) }}
                                        </span>
                                    </td>
                                    <td class="output-value">
                                        <div class="value-container">
                                            <span 
                                                v-if="isSimpleValue(value)"
                                                class="simple-value"
                                                :title="String(value)"
                                            >
                                                {{ formatValue(value) }}
                                            </span>
                                            <details v-else class="complex-value">
                                                <summary class="value-summary">
                                                    {{ getValueSummary(value) }}
                                                </summary>
                                                <pre class="value-detail">{{ JSON.stringify(value, null, 2) }}</pre>
                                            </details>
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <button 
                                            @click="copyValue(key, value)"
                                            class="btn btn-sm btn-outline-secondary"
                                            :title="`Copy ${key} value`"
                                        >
                                            <i class="fas fa-copy" />
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- JSON View -->
                <div v-else class="json-view">
                    <div class="json-container">
                        <pre class="json-content">{{ JSON.stringify(outputs, null, 2) }}</pre>
                    </div>
                </div>

                <!-- Success/Error Messages -->
                <div v-if="message" :class="['alert', messageType === 'success' ? 'alert-success' : 'alert-info']" class="mt-3">
                    <i :class="messageType === 'success' ? 'fas fa-check-circle' : 'fas fa-info-circle'" class="me-2" />
                    {{ message }}
                </div>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {ref, onMounted} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import type {ExecutionOutputsBlockProps} from "../../../types/apps";

    withDefaults(defineProps<ExecutionOutputsBlockProps>(), {
        states: () => ["SUCCESS", "FAILURE"],
        className: ""
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    // Reactive state
    const loading = ref(false);
    const viewMode = ref<"table" | "json">("table");
    const message = ref("");
    const messageType = ref<"success" | "info">("info");
    const outputs = ref<Record<string, any>>({});

    // Methods (reusing from ExecutionInputsBlock)
    function getValueType(value: any): string {
        if (value === null) return "null";
        if (value === undefined) return "undefined";
        if (Array.isArray(value)) return "array";
        if (typeof value === "object") return "object";
        if (typeof value === "string") return "string";
        if (typeof value === "number") return "number";
        if (typeof value === "boolean") return "boolean";
        return typeof value;
    }

    function getTypeClass(value: any): string {
        const type = getValueType(value);
        return `badge bg-${getTypeBadgeColor(type)}`;
    }

    function getTypeBadgeColor(type: string): string {
        switch (type) {
        case "string": return "success";
        case "number": return "primary";
        case "boolean": return "warning";
        case "array": return "info";
        case "object": return "secondary";
        case "null": return "dark";
        default: return "light";
        }
    }

    function isSimpleValue(value: any): boolean {
        return typeof value !== "object" || value === null;
    }

    function formatValue(value: any): string {
        if (value === null) return "null";
        if (value === undefined) return "undefined";
        if (typeof value === "string") {
            return value.length > 100 ? value.substring(0, 97) + "..." : value;
        }
        return String(value);
    }

    function getValueSummary(value: any): string {
        if (Array.isArray(value)) {
            return `Array (${value.length} items)`;
        }
        if (typeof value === "object" && value !== null) {
            const keys = Object.keys(value);
            return `Object (${keys.length} properties)`;
        }
        return String(value);
    }

    function toggleView() {
        viewMode.value = viewMode.value === "table" ? "json" : "table";
        emit("blockAction", "view_toggled", {mode: viewMode.value});
    }

    async function copyValue(key: string, value: any) {
        try {
            const textToCopy = typeof value === "object" 
                ? JSON.stringify(value, null, 2) 
                : String(value);
        
            await navigator.clipboard.writeText(textToCopy);
            showMessage(`Copied "${key}" value to clipboard`, "success");
            emit("blockAction", "value_copied", {key, type: getValueType(value)});
        } catch {
            showMessage("Failed to copy value to clipboard", "info");
            emit("blockError", "Failed to copy value");
        }
    }

    async function copyOutputs() {
        try {
            const textToCopy = JSON.stringify(outputs.value, null, 2);
            await navigator.clipboard.writeText(textToCopy);
            showMessage("All outputs copied to clipboard", "success");
            emit("blockAction", "outputs_copied", {count: Object.keys(outputs.value).length});
        } catch {
            showMessage("Failed to copy outputs to clipboard", "info");
            emit("blockError", "Failed to copy outputs");
        }
    }

    function downloadOutputs() {
        try {
            const dataStr = JSON.stringify(outputs.value, null, 2);
            const dataBlob = new Blob([dataStr], {type: "application/json"});
            const url = URL.createObjectURL(dataBlob);
        
            const link = document.createElement("a");
            link.href = url;
            link.download = `execution-outputs-${Date.now()}.json`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(url);
        
            showMessage("Outputs downloaded successfully", "success");
            emit("blockAction", "outputs_downloaded", {count: Object.keys(outputs.value).length});
        } catch {
            showMessage("Failed to download outputs", "info");
            emit("blockError", "Failed to download outputs");
        }
    }

    function showMessage(text: string, type: "success" | "info" = "info") {
        message.value = text;
        messageType.value = type;
        setTimeout(() => {
            message.value = "";
        }, 3000);
    }

    async function loadOutputs() {
        try {
            loading.value = true;
        
            // Mock data for demonstration
            await new Promise(resolve => setTimeout(resolve, 500));
        
            outputs.value = {
                result: "Processing completed successfully",
                processed_records: 1250,
                execution_time: 45.7,
                success: true,
                files_created: [
                    "output/data_2024.csv",
                    "output/summary_report.pdf"
                ],
                statistics: {
                    total_rows: 1250,
                    valid_rows: 1248,
                    invalid_rows: 2,
                    processing_rate: 27.5
                },
                metadata: {
                    version: "1.2.3",
                    environment: "production",
                    timestamp: "2024-01-15T10:30:00Z"
                }
            };
        
        } catch (err) {
            emit("blockError", "Failed to load execution outputs");
            console.error("Error loading outputs:", err);
        } finally {
            loading.value = false;
        }
    }

    // Lifecycle
    onMounted(() => {
        loadOutputs();
    });
</script>

<style scoped>
/* Reusing styles from ExecutionInputsBlock with minor adjustments */
.execution-outputs-block {
    padding: 1rem;
}

.outputs-container {
    background: #fff;
    border-radius: 0.5rem;
    border: 1px solid #e9ecef;
    overflow: hidden;
}

.outputs-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    background: #f8f9fa;
    border-bottom: 1px solid #e9ecef;
}

.outputs-title {
    margin: 0;
    color: #495057;
    font-weight: 600;
}

.outputs-actions {
    display: flex;
    gap: 0.5rem;
}

.loading-state,
.empty-state {
    text-align: center;
    padding: 3rem 2rem;
}

.table-view {
    padding: 0;
}

.table {
    margin: 0;
}

.table th {
    border-top: none;
    font-weight: 600;
    font-size: 0.875rem;
}

.output-key code {
    background: #f8f9fa;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.875rem;
    color: #495057;
}

.output-type .badge {
    font-size: 0.75rem;
    font-weight: 500;
}

.value-container {
    max-width: 300px;
}

.simple-value {
    display: block;
    word-break: break-word;
    font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
    font-size: 0.875rem;
}

.complex-value {
    margin: 0;
}

.value-summary {
    cursor: pointer;
    color: #007bff;
    font-weight: 500;
    font-size: 0.875rem;
}

.value-summary:hover {
    color: #0056b3;
}

.value-detail {
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 0.25rem;
    padding: 0.75rem;
    margin-top: 0.5rem;
    font-size: 0.75rem;
    max-height: 200px;
    overflow-y: auto;
}

.json-view {
    padding: 1.5rem;
}

.json-container {
    background: #f8f9fa;
    border-radius: 0.375rem;
    border: 1px solid #e9ecef;
    overflow: hidden;
}

.json-content {
    background: #2d3748;
    color: #e2e8f0;
    padding: 1.5rem;
    margin: 0;
    font-size: 0.875rem;
    line-height: 1.5;
    overflow-x: auto;
    max-height: 400px;
    overflow-y: auto;
}

.btn {
    border-radius: 0.375rem;
    font-weight: 500;
    transition: all 0.15s ease-in-out;
}

.btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
}

.alert {
    border-radius: 0.375rem;
    padding: 0.75rem 1rem;
    margin: 0;
}

.alert-success {
    color: #0f5132;
    background-color: #d1e7dd;
    border-color: #badbcc;
}

.alert-info {
    color: #055160;
    background-color: #cff4fc;
    border-color: #b6effb;
}

.visually-hidden {
    position: absolute !important;
    width: 1px !important;
    height: 1px !important;
    padding: 0 !important;
    margin: -1px !important;
    overflow: hidden !important;
    clip: rect(0, 0, 0, 0) !important;
    white-space: nowrap !important;
    border: 0 !important;
}

.spinner-border {
    display: inline-block;
    width: 2rem;
    height: 2rem;
    vertical-align: -0.125em;
    border: 0.25em solid currentcolor;
    border-right-color: transparent;
    border-radius: 50%;
    animation: 0.75s linear infinite spinner-border;
}

@keyframes spinner-border {
    to {
        transform: rotate(360deg);
    }
}
</style>
