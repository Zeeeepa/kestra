<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="task-outputs-block">
            <div class="outputs-container">
                <div class="outputs-header">
                    <h5 class="outputs-title">
                        <i class="fas fa-tasks me-2" />
                        Task Outputs
                    </h5>
                    <div class="outputs-actions">
                        <select v-model="selectedTask" class="form-select form-select-sm me-2">
                            <option value="">
                                All Tasks
                            </option>
                            <option v-for="task in availableTasks" :key="task" :value="task">
                                {{ task }}
                            </option>
                        </select>
                        <button @click="refreshOutputs" class="btn btn-sm btn-outline-secondary">
                            <i class="fas fa-sync-alt" />
                        </button>
                    </div>
                </div>

                <div v-if="loading" class="loading-state">
                    <div class="spinner-border text-primary" role="status" />
                    <p class="text-muted mt-2">
                        Loading task outputs...
                    </p>
                </div>

                <div v-else-if="filteredOutputs.length === 0" class="empty-state">
                    <i class="fas fa-tasks fa-3x text-muted mb-3" />
                    <h6 class="text-muted">
                        No Task Outputs
                    </h6>
                    <p class="text-muted small">
                        No outputs found for the selected tasks.
                    </p>
                </div>

                <div v-else class="outputs-content">
                    <div class="task-output" v-for="output in filteredOutputs" :key="output.taskId">
                        <div class="task-header">
                            <h6 class="task-name">
                                <i class="fas fa-cog me-2" />
                                {{ output.taskId }}
                            </h6>
                            <span :class="`badge bg-${getStatusColor(output.status)}`">{{ output.status }}</span>
                        </div>
                        <div class="task-data">
                            <div class="row">
                                <div class="col-md-6" v-for="(value, key) in output.outputs" :key="key">
                                    <div class="output-item">
                                        <label class="output-label">{{ key }}</label>
                                        <div class="output-value">
                                            <code v-if="typeof value === 'string'">{{ value }}</code>
                                            <span v-else-if="typeof value === 'number'" class="badge bg-primary">{{ value }}</span>
                                            <span v-else-if="typeof value === 'boolean'" :class="`badge bg-${value ? 'success' : 'danger'}`">{{ value }}</span>
                                            <details v-else>
                                                <summary>{{ getValueSummary(value) }}</summary>
                                                <pre class="mt-2">{{ JSON.stringify(value, null, 2) }}</pre>
                                            </details>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import type {TaskOutputsBlockProps} from "../../../types/apps";

    withDefaults(defineProps<TaskOutputsBlockProps>(), {
        states: () => ["SUCCESS", "RUNNING"],
        className: ""
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    interface TaskOutput {
        taskId: string;
        status: "SUCCESS" | "RUNNING" | "FAILED";
        outputs: Record<string, any>;
    }

    const loading = ref(false);
    const selectedTask = ref("");
    const taskOutputs = ref<TaskOutput[]>([]);

    const availableTasks = computed(() => {
        return [...new Set(taskOutputs.value.map(output => output.taskId))];
    });

    const filteredOutputs = computed(() => {
        if (!selectedTask.value) return taskOutputs.value;
        return taskOutputs.value.filter(output => output.taskId === selectedTask.value);
    });

    function getStatusColor(status: string): string {
        switch (status) {
        case "SUCCESS": return "success";
        case "RUNNING": return "primary";
        case "FAILED": return "danger";
        default: return "secondary";
        }
    }

    function getValueSummary(value: any): string {
        if (Array.isArray(value)) return `Array (${value.length} items)`;
        if (typeof value === "object" && value !== null) return `Object (${Object.keys(value).length} properties)`;
        return String(value);
    }

    async function refreshOutputs() {
        loading.value = true;
        await new Promise(resolve => setTimeout(resolve, 500));
    
        taskOutputs.value = [
            {
                taskId: "data-extraction",
                status: "SUCCESS",
                outputs: {
                    records_extracted: 1500,
                    file_path: "/tmp/extracted_data.csv",
                    extraction_time: "2.3s",
                    success: true
                }
            },
            {
                taskId: "data-transformation",
                status: "SUCCESS",
                outputs: {
                    records_processed: 1500,
                    records_valid: 1498,
                    records_invalid: 2,
                    output_file: "/tmp/transformed_data.json"
                }
            },
            {
                taskId: "data-loading",
                status: "RUNNING",
                outputs: {
                    progress: 75,
                    loaded_records: 1123,
                    remaining_records: 375
                }
            }
        ];
    
        loading.value = false;
        emit("blockAction", "outputs_refreshed", {count: taskOutputs.value.length});
    }

    onMounted(() => {
        refreshOutputs();
    });
</script>

<style scoped>
.task-outputs-block {
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
    align-items: center;
}

.outputs-content {
    padding: 1rem;
}

.task-output {
    margin-bottom: 2rem;
    padding: 1rem;
    border: 1px solid #e9ecef;
    border-radius: 0.375rem;
    background: #f8f9fa;
}

.task-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid #e9ecef;
}

.task-name {
    margin: 0;
    color: #495057;
}

.task-data {
    background: #fff;
    padding: 1rem;
    border-radius: 0.375rem;
}

.output-item {
    margin-bottom: 1rem;
}

.output-label {
    font-weight: 600;
    color: #6c757d;
    font-size: 0.875rem;
    margin-bottom: 0.25rem;
    display: block;
}

.output-value code {
    background: #f8f9fa;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.875rem;
}

.loading-state,
.empty-state {
    text-align: center;
    padding: 3rem 2rem;
}

.form-select-sm {
    width: auto;
    min-width: 150px;
}

.badge {
    font-size: 0.75rem;
}
</style>
