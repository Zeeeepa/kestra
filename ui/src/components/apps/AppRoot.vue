<template>
    <div class="app-root">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h3>{{ appData.name || 'App Details' }}</h3>
                            <div class="btn-group">
                                <button 
                                    class="btn btn-outline-primary"
                                    :class="{active: activeTab === 'details'}"
                                    @click="setActiveTab('details')"
                                >
                                    Details
                                </button>
                                <button 
                                    class="btn btn-outline-primary"
                                    :class="{active: activeTab === 'config'}"
                                    @click="setActiveTab('config')"
                                >
                                    Configuration
                                </button>
                                <button 
                                    class="btn btn-outline-primary"
                                    :class="{active: activeTab === 'executions'}"
                                    @click="setActiveTab('executions')"
                                >
                                    Executions
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <!-- Details Tab -->
                            <div v-if="activeTab === 'details'" class="tab-content">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label class="form-label">Name</label>
                                            <input 
                                                v-model="appData.name" 
                                                type="text" 
                                                class="form-control" 
                                                :readonly="!editing"
                                            >
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Namespace</label>
                                            <input 
                                                v-model="appData.namespace" 
                                                type="text" 
                                                class="form-control" 
                                                readonly
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label class="form-label">Description</label>
                                            <textarea 
                                                v-model="appData.description" 
                                                class="form-control" 
                                                rows="3"
                                                :readonly="!editing"
                                            />
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex gap-2">
                                    <button 
                                        v-if="!editing" 
                                        class="btn btn-primary" 
                                        @click="startEditing"
                                    >
                                        Edit
                                    </button>
                                    <template v-else>
                                        <button 
                                            class="btn btn-success" 
                                            @click="saveChanges"
                                            :disabled="saving"
                                        >
                                            <span v-if="saving" class="spinner-border spinner-border-sm me-2" />
                                            Save
                                        </button>
                                        <button 
                                            class="btn btn-secondary" 
                                            @click="cancelEditing"
                                        >
                                            Cancel
                                        </button>
                                    </template>
                                    <button class="btn btn-success" @click="executeApp">
                                        Execute App
                                    </button>
                                </div>
                            </div>

                            <!-- Configuration Tab -->
                            <div v-else-if="activeTab === 'config'" class="tab-content">
                                <div class="mb-3">
                                    <label class="form-label">App Configuration (YAML)</label>
                                    <textarea 
                                        v-model="appConfig" 
                                        class="form-control font-monospace" 
                                        rows="15"
                                        placeholder="Enter app configuration in YAML format..."
                                    />
                                </div>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-primary" @click="saveConfig">
                                        Save Configuration
                                    </button>
                                    <button class="btn btn-outline-secondary" @click="validateConfig">
                                        Validate
                                    </button>
                                </div>
                            </div>

                            <!-- Executions Tab -->
                            <div v-else-if="activeTab === 'executions'" class="tab-content">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5>Recent Executions</h5>
                                    <button class="btn btn-primary" @click="executeApp">
                                        New Execution
                                    </button>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Status</th>
                                                <th>Started</th>
                                                <th>Duration</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="execution in executions" :key="execution.id">
                                                <td>{{ execution.id }}</td>
                                                <td>
                                                    <span 
                                                        class="badge"
                                                        :class="getStatusBadgeClass(execution.status)"
                                                    >
                                                        {{ execution.status }}
                                                    </span>
                                                </td>
                                                <td>{{ formatDate(execution.startedAt) }}</td>
                                                <td>{{ execution.duration || '-' }}</td>
                                                <td>
                                                    <button class="btn btn-sm btn-outline-primary">
                                                        View
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr v-if="executions.length === 0">
                                                <td colspan="5" class="text-center text-muted">
                                                    No executions found
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
    import {ref, reactive, onMounted} from "vue";
    import {useRoute, useRouter} from "vue-router";

    const route = useRoute();
    const router = useRouter();

    const activeTab = ref(route.params.tab || "details");
    const editing = ref(false);
    const saving = ref(false);

    const appData = reactive({
        name: "",
        namespace: "",
        description: "",
        id: ""
    });

    const appConfig = ref("");
    const executions = ref([
        {
            id: "exec-001",
            status: "SUCCESS",
            startedAt: new Date().toISOString(),
            duration: "2.5s"
        },
        {
            id: "exec-002", 
            status: "RUNNING",
            startedAt: new Date().toISOString(),
            duration: null
        }
    ]);

    onMounted(() => {
        loadAppData();
    });

    const loadAppData = () => {
        // Simulate loading app data
        appData.name = "Sample App";
        appData.namespace = route.params.namespace as string;
        appData.id = route.params.id as string;
        appData.description = "This is a sample app for demonstration";
    
        appConfig.value = `# App Configuration
name: ${appData.name}
namespace: ${appData.namespace}
description: ${appData.description}

# Add your app configuration here
inputs:
  - name: input1
    type: string
    required: true

tasks:
  - id: task1
    type: io.kestra.core.tasks.log.Log
    message: "Hello from {{ inputs.input1 }}"`;
    };

    const setActiveTab = (tab: string) => {
        activeTab.value = tab;
        router.replace({
            ...route,
            params: {...route.params, tab}
        });
    };

    const startEditing = () => {
        editing.value = true;
    };

    const saveChanges = async () => {
        saving.value = true;
        try {
            // Simulate API call
            await new Promise(resolve => setTimeout(resolve, 1000));
            editing.value = false;
        } catch (error) {
            console.error("Failed to save changes:", error);
        } finally {
            saving.value = false;
        }
    };

    const cancelEditing = () => {
        editing.value = false;
        loadAppData(); // Reload original data
    };

    const saveConfig = async () => {
        try {
            // Simulate saving configuration
            await new Promise(resolve => setTimeout(resolve, 500));
            console.warn("Configuration saved");
        } catch (error) {
            console.error("Failed to save configuration:", error);
        }
    };

    const validateConfig = () => {
        try {
            // Basic YAML validation simulation
            console.warn("Configuration is valid");
        } catch (error) {
            console.error("Configuration validation failed:", error);
        }
    };

    const executeApp = async () => {
        try {
            // Simulate app execution
            const newExecution = {
                id: `exec-${Date.now()}`,
                status: "RUNNING",
                startedAt: new Date().toISOString(),
                duration: null
            };
            executions.value.unshift(newExecution);
        
            // Simulate completion after 3 seconds
            setTimeout(() => {
                newExecution.status = "SUCCESS";
                newExecution.duration = "3.2s";
            }, 3000);
        
        } catch (error) {
            console.error("Failed to execute app:", error);
        }
    };

    const getStatusBadgeClass = (status: string) => {
        switch (status) {
        case "SUCCESS": return "bg-success";
        case "RUNNING": return "bg-primary";
        case "FAILED": return "bg-danger";
        case "CANCELLED": return "bg-warning";
        default: return "bg-secondary";
        }
    };

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleString();
    };
</script>

<style scoped>
.app-root {
    padding: 1rem;
}

.tab-content {
    min-height: 400px;
}

.font-monospace {
    font-family: 'Courier New', monospace;
}
</style>
