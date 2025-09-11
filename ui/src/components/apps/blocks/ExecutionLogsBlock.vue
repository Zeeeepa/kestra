<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="execution-logs-block">
            <div class="logs-container">
                <div class="logs-header">
                    <h5 class="logs-title">
                        <i class="fas fa-file-alt me-2" />
                        Execution Logs
                    </h5>
                    <div class="logs-actions">
                        <select v-model="logLevel" class="form-select form-select-sm me-2">
                            <option value="">
                                All Levels
                            </option>
                            <option value="ERROR">
                                ERROR
                            </option>
                            <option value="WARN">
                                WARN
                            </option>
                            <option value="INFO">
                                INFO
                            </option>
                            <option value="DEBUG">
                                DEBUG
                            </option>
                        </select>
                        <button @click="refreshLogs" class="btn btn-sm btn-outline-secondary me-2">
                            <i class="fas fa-sync-alt" />
                        </button>
                        <button @click="downloadLogs" class="btn btn-sm btn-outline-info">
                            <i class="fas fa-download" />
                        </button>
                    </div>
                </div>

                <div v-if="loading" class="loading-state">
                    <div class="spinner-border text-primary" role="status" />
                    <p class="text-muted mt-2">
                        Loading logs...
                    </p>
                </div>

                <div v-else-if="filteredLogs.length === 0" class="empty-state">
                    <i class="fas fa-file-alt fa-3x text-muted mb-3" />
                    <h6 class="text-muted">
                        No Logs
                    </h6>
                    <p class="text-muted small">
                        No logs found for the current filters.
                    </p>
                </div>

                <div v-else class="logs-content">
                    <div class="log-entry" v-for="log in filteredLogs" :key="log.id" :class="`log-${log.level.toLowerCase()}`">
                        <div class="log-header">
                            <span class="log-timestamp">{{ formatTimestamp(log.timestamp) }}</span>
                            <span :class="`badge bg-${getLevelColor(log.level)} log-level`">{{ log.level }}</span>
                            <span class="log-task">{{ log.taskId }}</span>
                        </div>
                        <div class="log-message">
                            {{ log.message }}
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
    import type {ExecutionLogsBlockProps} from "../../../types/apps";

    withDefaults(defineProps<ExecutionLogsBlockProps>(), {
        states: () => ["SUCCESS", "FAILURE", "RUNNING"],
        className: ""
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    interface LogEntry {
        id: string;
        timestamp: Date;
        level: "ERROR" | "WARN" | "INFO" | "DEBUG";
        taskId: string;
        message: string;
    }

    const loading = ref(false);
    const logLevel = ref("");
    const logs = ref<LogEntry[]>([]);

    const filteredLogs = computed(() => {
        if (!logLevel.value) return logs.value;
        return logs.value.filter(log => log.level === logLevel.value);
    });

    function getLevelColor(level: string): string {
        switch (level) {
        case "ERROR": return "danger";
        case "WARN": return "warning";
        case "INFO": return "info";
        case "DEBUG": return "secondary";
        default: return "light";
        }
    }

    function formatTimestamp(timestamp: Date): string {
        return timestamp.toLocaleString();
    }

    async function refreshLogs() {
        loading.value = true;
        await new Promise(resolve => setTimeout(resolve, 500));
    
        logs.value = [
            {id: "1", timestamp: new Date(), level: "INFO", taskId: "task-1", message: "Starting data processing..."},
            {id: "2", timestamp: new Date(), level: "DEBUG", taskId: "task-1", message: "Loading configuration from config.yaml"},
            {id: "3", timestamp: new Date(), level: "INFO", taskId: "task-2", message: "Processing 1000 records..."},
            {id: "4", timestamp: new Date(), level: "WARN", taskId: "task-2", message: "Found 2 invalid records, skipping..."},
            {id: "5", timestamp: new Date(), level: "INFO", taskId: "task-3", message: "Data processing completed successfully"}
        ];
    
        loading.value = false;
        emit("blockAction", "logs_refreshed", {count: logs.value.length});
    }

    function downloadLogs() {
        const logText = logs.value.map(log => 
            `[${formatTimestamp(log.timestamp)}] ${log.level} ${log.taskId}: ${log.message}`
        ).join("\n");
    
        const blob = new Blob([logText], {type: "text/plain"});
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = url;
        link.download = `execution-logs-${Date.now()}.txt`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    
        emit("blockAction", "logs_downloaded", {count: logs.value.length});
    }

    onMounted(() => {
        refreshLogs();
    });
</script>

<style scoped>
.execution-logs-block {
    padding: 1rem;
}

.logs-container {
    background: #fff;
    border-radius: 0.5rem;
    border: 1px solid #e9ecef;
    overflow: hidden;
}

.logs-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    background: #f8f9fa;
    border-bottom: 1px solid #e9ecef;
}

.logs-title {
    margin: 0;
    color: #495057;
    font-weight: 600;
}

.logs-actions {
    display: flex;
    align-items: center;
}

.logs-content {
    max-height: 400px;
    overflow-y: auto;
    padding: 1rem;
}

.log-entry {
    margin-bottom: 1rem;
    padding: 0.75rem;
    border-radius: 0.375rem;
    border-left: 4px solid #e9ecef;
}

.log-entry.log-error {
    background-color: #f8d7da;
    border-left-color: #dc3545;
}

.log-entry.log-warn {
    background-color: #fff3cd;
    border-left-color: #ffc107;
}

.log-entry.log-info {
    background-color: #cff4fc;
    border-left-color: #17a2b8;
}

.log-entry.log-debug {
    background-color: #f8f9fa;
    border-left-color: #6c757d;
}

.log-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
}

.log-timestamp {
    color: #6c757d;
    font-family: monospace;
}

.log-level {
    font-size: 0.75rem;
}

.log-task {
    color: #495057;
    font-weight: 500;
}

.log-message {
    font-family: monospace;
    font-size: 0.875rem;
    color: #495057;
    white-space: pre-wrap;
}

.loading-state,
.empty-state {
    text-align: center;
    padding: 3rem 2rem;
}

.form-select-sm {
    width: auto;
    min-width: 120px;
}
</style>
