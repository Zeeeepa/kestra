<template>
    <TopNavBar :title="routeInfo.title" />
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">{{ $t('apps') }}</h5>
                        <el-button type="primary" @click="showCreateDialog = true">
                            <Plus class="me-2" />
                            {{ $t('create') }}
                        </el-button>
                    </div>
                    <div class="card-body">
                        <div v-if="apps.length === 0" class="text-center py-5">
                            <FormatListGroupPlus class="text-muted mb-3" style="font-size: 4rem;" />
                            <h6 class="text-muted">{{ $t('apps.empty.title') }}</h6>
                            <p class="text-muted">{{ $t('apps.empty.description') }}</p>
                            <el-button type="primary" @click="showCreateDialog = true">
                                {{ $t('apps.create_first') }}
                            </el-button>
                        </div>
                        <div v-else>
                            <div class="row">
                                <div v-for="app in apps" :key="app.id" class="col-md-6 col-lg-4 mb-4">
                                    <div class="card h-100">
                                        <div class="card-body">
                                            <div class="d-flex justify-content-between align-items-start mb-3">
                                                <h6 class="card-title">{{ app.name }}</h6>
                                                <el-dropdown @command="handleAppAction">
                                                    <el-button size="small" text>
                                                        <DotsVertical />
                                                    </el-button>
                                                    <template #dropdown>
                                                        <el-dropdown-menu>
                                                            <el-dropdown-item :command="{action: 'edit', app}">
                                                                {{ $t('edit') }}
                                                            </el-dropdown-item>
                                                            <el-dropdown-item :command="{action: 'delete', app}" divided>
                                                                {{ $t('delete') }}
                                                            </el-dropdown-item>
                                                        </el-dropdown-menu>
                                                    </template>
                                                </el-dropdown>
                                            </div>
                                            <p class="card-text text-muted small">{{ app.description }}</p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <small class="text-muted">
                                                    {{ $t('apps.last_updated') }}: {{ formatDate(app.updatedAt) }}
                                                </small>
                                                <el-button size="small" type="primary" @click="openApp(app)">
                                                    {{ $t('apps.open') }}
                                                </el-button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Create/Edit App Dialog -->
    <el-dialog v-model="showCreateDialog" :title="editingApp ? $t('apps.edit') : $t('apps.create')" width="600px">
        <el-form :model="appForm" label-width="120px">
            <el-form-item :label="$t('name')" required>
                <el-input v-model="appForm.name" :placeholder="$t('apps.name_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('description')">
                <el-input 
                    v-model="appForm.description" 
                    type="textarea" 
                    :rows="3"
                    :placeholder="$t('apps.description_placeholder')" 
                />
            </el-form-item>
            <el-form-item :label="$t('apps.type')">
                <el-select v-model="appForm.type" :placeholder="$t('apps.select_type')">
                    <el-option label="Form App" value="form" />
                    <el-option label="Dashboard App" value="dashboard" />
                    <el-option label="Workflow Trigger" value="trigger" />
                </el-select>
            </el-form-item>
            <el-form-item :label="$t('namespace')">
                <el-input v-model="appForm.namespace" :placeholder="$t('apps.namespace_placeholder')" />
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="showCreateDialog = false">{{ $t('cancel') }}</el-button>
            <el-button type="primary" @click="saveApp">
                {{ editingApp ? $t('update') : $t('create') }}
            </el-button>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
    import {ref, onMounted} from "vue";
    import {useI18n} from "vue-i18n";
    import {ElMessage, ElMessageBox} from "element-plus";
    import TopNavBar from "../layout/TopNavBar.vue";
    import Plus from "vue-material-design-icons/Plus.vue";
    import FormatListGroupPlus from "vue-material-design-icons/FormatListGroupPlus.vue";
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import useRouteContext from "../../mixins/useRouteContext";

    const {t} = useI18n();

    const routeInfo = ref({
        title: t("apps"),
    });

    useRouteContext(routeInfo);

    // Reactive data
    const apps = ref([
        {
            id: 1,
            name: "Customer Onboarding",
            description: "Form app for new customer registration workflow",
            type: "form",
            namespace: "customer",
            updatedAt: new Date('2024-01-15')
        },
        {
            id: 2,
            name: "Data Processing Dashboard",
            description: "Monitor and control data processing workflows",
            type: "dashboard", 
            namespace: "data",
            updatedAt: new Date('2024-01-10')
        }
    ]);

    const showCreateDialog = ref(false);
    const editingApp = ref(null);
    const appForm = ref({
        name: '',
        description: '',
        type: '',
        namespace: ''
    });

    // Methods
    function formatDate(date: Date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        }).format(date);
    }

    function openApp(app: any) {
        ElMessage.info(`Opening app: ${app.name}`);
        // TODO: Implement app opening logic
    }

    function handleAppAction(command: any) {
        if (command.action === 'edit') {
            editApp(command.app);
        } else if (command.action === 'delete') {
            deleteApp(command.app);
        }
    }

    function editApp(app: any) {
        editingApp.value = app;
        appForm.value = { ...app };
        showCreateDialog.value = true;
    }

    async function deleteApp(app: any) {
        try {
            await ElMessageBox.confirm(
                t('apps.delete_confirm', { name: app.name }),
                t('confirm'),
                {
                    confirmButtonText: t('delete'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );
            
            const index = apps.value.findIndex(a => a.id === app.id);
            if (index > -1) {
                apps.value.splice(index, 1);
                ElMessage.success(t('apps.deleted_success'));
            }
        } catch {
            // User cancelled
        }
    }

    function saveApp() {
        if (!appForm.value.name.trim()) {
            ElMessage.error(t('apps.name_required'));
            return;
        }

        if (editingApp.value) {
            // Update existing app
            const index = apps.value.findIndex(a => a.id === editingApp.value.id);
            if (index > -1) {
                apps.value[index] = { 
                    ...apps.value[index], 
                    ...appForm.value,
                    updatedAt: new Date()
                };
                ElMessage.success(t('apps.updated_success'));
            }
        } else {
            // Create new app
            const newApp = {
                id: Date.now(),
                ...appForm.value,
                updatedAt: new Date()
            };
            apps.value.push(newApp);
            ElMessage.success(t('apps.created_success'));
        }

        showCreateDialog.value = false;
        editingApp.value = null;
        appForm.value = {
            name: '',
            description: '',
            type: '',
            namespace: ''
        };
    }

    onMounted(() => {
        // TODO: Load apps from API
    });
</script>

<style lang="scss" scoped>
    .card {
        border: 1px solid var(--ks-border-primary);
        border-radius: 8px;
        
        .card-header {
            background-color: var(--ks-background-secondary);
            border-bottom: 1px solid var(--ks-border-primary);
        }
    }
</style>
