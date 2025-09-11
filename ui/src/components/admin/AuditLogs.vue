<template>
    <TopNavBar :title="routeInfo.title" />
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">{{ $t('auditlogs') }}</h5>
                        <div class="d-flex gap-2">
                            <el-button @click="exportLogs">
                                <Download class="me-2" />
                                {{ $t('audit.export') }}
                            </el-button>
                            <el-button @click="refreshLogs">
                                <Refresh class="me-2" />
                                {{ $t('refresh') }}
                            </el-button>
                        </div>
                    </div>
                    <div class="card-body">
                        <!-- Filters -->
                        <div class="row mb-4">
                            <div class="col-md-3">
                                <el-select v-model="filters.action" :placeholder="$t('audit.filter_action')" clearable>
                                    <el-option v-for="action in availableActions" :key="action" :label="action" :value="action" />
                                </el-select>
                            </div>
                            <div class="col-md-3">
                                <el-select v-model="filters.user" :placeholder="$t('audit.filter_user')" clearable>
                                    <el-option v-for="user in availableUsers" :key="user" :label="user" :value="user" />
                                </el-select>
                            </div>
                            <div class="col-md-3">
                                <el-select v-model="filters.resource" :placeholder="$t('audit.filter_resource')" clearable>
                                    <el-option v-for="resource in availableResources" :key="resource" :label="resource" :value="resource" />
                                </el-select>
                            </div>
                            <div class="col-md-3">
                                <el-date-picker
                                    v-model="filters.dateRange"
                                    type="datetimerange"
                                    :placeholder="$t('audit.date_range')"
                                    format="YYYY-MM-DD HH:mm:ss"
                                    value-format="YYYY-MM-DD HH:mm:ss"
                                />
                            </div>
                        </div>

                        <!-- Audit Logs Table -->
                        <el-table :data="filteredLogs" style="width: 100%" v-loading="loading">
                            <el-table-column prop="timestamp" :label="$t('audit.timestamp')" width="180">
                                <template #default="scope">
                                    {{ formatDate(scope.row.timestamp) }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="user" :label="$t('user')" width="120" />
                            <el-table-column prop="action" :label="$t('action')" width="120">
                                <template #default="scope">
                                    <el-tag :type="getActionType(scope.row.action)" size="small">
                                        {{ scope.row.action }}
                                    </el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column prop="resource" :label="$t('resource')" width="150">
                                <template #default="scope">
                                    <div class="d-flex align-items-center">
                                        <component :is="getResourceIcon(scope.row.resourceType)" class="me-2 text-muted" />
                                        {{ scope.row.resource }}
                                    </div>
                                </template>
                            </el-table-column>
                            <el-table-column prop="resourceType" :label="$t('audit.resource_type')" width="120" />
                            <el-table-column prop="namespace" :label="$t('namespace')" width="120" />
                            <el-table-column prop="ipAddress" :label="$t('audit.ip_address')" width="130" />
                            <el-table-column prop="userAgent" :label="$t('audit.user_agent')" min-width="200">
                                <template #default="scope">
                                    <span class="text-truncate" :title="scope.row.userAgent">
                                        {{ scope.row.userAgent }}
                                    </span>
                                </template>
                            </el-table-column>
                            <el-table-column :label="$t('actions')" width="80">
                                <template #default="scope">
                                    <el-button size="small" text @click="viewDetails(scope.row)">
                                        <Eye />
                                    </el-button>
                                </template>
                            </el-table-column>
                        </el-table>

                        <!-- Pagination -->
                        <div class="d-flex justify-content-center mt-4">
                            <el-pagination
                                v-model:current-page="currentPage"
                                v-model:page-size="pageSize"
                                :page-sizes="[10, 25, 50, 100]"
                                :total="totalLogs"
                                layout="total, sizes, prev, pager, next, jumper"
                                @size-change="handleSizeChange"
                                @current-change="handleCurrentChange"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Audit Log Details Dialog -->
    <el-dialog v-model="showDetailsDialog" :title="$t('audit.log_details')" width="800px">
        <div v-if="selectedLog">
            <el-descriptions :column="2" border>
                <el-descriptions-item :label="$t('audit.timestamp')">
                    {{ formatDate(selectedLog.timestamp) }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('user')">
                    {{ selectedLog.user }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('action')">
                    <el-tag :type="getActionType(selectedLog.action)" size="small">
                        {{ selectedLog.action }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item :label="$t('resource')">
                    {{ selectedLog.resource }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('audit.resource_type')">
                    {{ selectedLog.resourceType }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('namespace')">
                    {{ selectedLog.namespace }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('audit.ip_address')">
                    {{ selectedLog.ipAddress }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('audit.session_id')">
                    {{ selectedLog.sessionId }}
                </el-descriptions-item>
                <el-descriptions-item :label="$t('audit.user_agent')" :span="2">
                    {{ selectedLog.userAgent }}
                </el-descriptions-item>
            </el-descriptions>
            
            <div class="mt-4" v-if="selectedLog.details">
                <h6>{{ $t('audit.additional_details') }}</h6>
                <el-input
                    v-model="selectedLog.details"
                    type="textarea"
                    :rows="6"
                    readonly
                />
            </div>
        </div>
        <template #footer>
            <el-button @click="showDetailsDialog = false">{{ $t('close') }}</el-button>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted} from "vue";
    import {useI18n} from "vue-i18n";
    import {ElMessage} from "element-plus";
    import TopNavBar from "../layout/TopNavBar.vue";
    import Download from "vue-material-design-icons/Download.vue";
    import Refresh from "vue-material-design-icons/Refresh.vue";
    import Eye from "vue-material-design-icons/Eye.vue";
    import FileTreeOutline from "vue-material-design-icons/FileTreeOutline.vue";
    import TimelineClockOutline from "vue-material-design-icons/TimelineClockOutline.vue";
    import ShieldKeyOutline from "vue-material-design-icons/ShieldKeyOutline.vue";
    import AccountOutline from "vue-material-design-icons/AccountOutline.vue";
    import useRouteContext from "../../mixins/useRouteContext";

    const {t} = useI18n();

    const routeInfo = ref({
        title: t("auditlogs"),
    });

    useRouteContext(routeInfo);

    // Reactive data
    const loading = ref(false);
    const showDetailsDialog = ref(false);
    const selectedLog = ref(null);
    const currentPage = ref(1);
    const pageSize = ref(25);
    const totalLogs = ref(0);

    const filters = ref({
        action: '',
        user: '',
        resource: '',
        dateRange: null
    });

    const auditLogs = ref([
        {
            id: 1,
            timestamp: new Date('2024-01-15T10:30:00'),
            user: 'admin',
            action: 'CREATE',
            resource: 'customer-processing',
            resourceType: 'Flow',
            namespace: 'customer',
            ipAddress: '192.168.1.100',
            sessionId: 'sess_abc123',
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            details: '{"flowId": "customer-processing", "version": "1.0", "changes": ["Added new task: ValidateCustomer"]}'
        },
        {
            id: 2,
            timestamp: new Date('2024-01-15T10:25:00'),
            user: 'developer',
            action: 'UPDATE',
            resource: 'payment-flow',
            resourceType: 'Flow',
            namespace: 'finance',
            ipAddress: '192.168.1.101',
            sessionId: 'sess_def456',
            userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            details: '{"flowId": "payment-flow", "version": "2.1", "changes": ["Modified task: ProcessPayment", "Updated timeout to 30s"]}'
        },
        {
            id: 3,
            timestamp: new Date('2024-01-15T10:20:00'),
            user: 'admin',
            action: 'DELETE',
            resource: 'old-secret',
            resourceType: 'Secret',
            namespace: 'default',
            ipAddress: '192.168.1.100',
            sessionId: 'sess_abc123',
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            details: '{"secretKey": "old-secret", "reason": "No longer needed"}'
        },
        {
            id: 4,
            timestamp: new Date('2024-01-15T10:15:00'),
            user: 'viewer',
            action: 'READ',
            resource: 'data-export',
            resourceType: 'Execution',
            namespace: 'data',
            ipAddress: '192.168.1.102',
            sessionId: 'sess_ghi789',
            userAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
            details: '{"executionId": "exec_123", "duration": "2.5s", "status": "SUCCESS"}'
        },
        {
            id: 5,
            timestamp: new Date('2024-01-15T10:10:00'),
            user: 'admin',
            action: 'LOGIN',
            resource: 'system',
            resourceType: 'Authentication',
            namespace: 'system',
            ipAddress: '192.168.1.100',
            sessionId: 'sess_abc123',
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            details: '{"loginMethod": "password", "success": true}'
        }
    ]);

    const availableActions = ref(['CREATE', 'READ', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'EXECUTE']);
    const availableUsers = ref(['admin', 'developer', 'viewer']);
    const availableResources = ref(['Flow', 'Execution', 'Secret', 'Template', 'Authentication']);

    // Computed
    const filteredLogs = computed(() => {
        let logs = auditLogs.value;

        if (filters.value.action) {
            logs = logs.filter(log => log.action === filters.value.action);
        }

        if (filters.value.user) {
            logs = logs.filter(log => log.user === filters.value.user);
        }

        if (filters.value.resource) {
            logs = logs.filter(log => log.resourceType === filters.value.resource);
        }

        if (filters.value.dateRange && filters.value.dateRange.length === 2) {
            const [start, end] = filters.value.dateRange;
            logs = logs.filter(log => {
                const logTime = log.timestamp.getTime();
                return logTime >= new Date(start).getTime() && logTime <= new Date(end).getTime();
            });
        }

        totalLogs.value = logs.length;
        
        // Pagination
        const startIndex = (currentPage.value - 1) * pageSize.value;
        const endIndex = startIndex + pageSize.value;
        return logs.slice(startIndex, endIndex);
    });

    // Methods
    function getActionType(action: string) {
        switch (action) {
            case 'CREATE': return 'success';
            case 'UPDATE': return 'primary';
            case 'DELETE': return 'danger';
            case 'READ': return 'info';
            case 'LOGIN': return 'success';
            case 'LOGOUT': return 'warning';
            case 'EXECUTE': return 'primary';
            default: return '';
        }
    }

    function getResourceIcon(resourceType: string) {
        switch (resourceType) {
            case 'Flow': return FileTreeOutline;
            case 'Execution': return TimelineClockOutline;
            case 'Secret': return ShieldKeyOutline;
            case 'Authentication': return AccountOutline;
            default: return FileTreeOutline;
        }
    }

    function formatDate(date: Date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        }).format(date);
    }

    function viewDetails(log: any) {
        selectedLog.value = log;
        showDetailsDialog.value = true;
    }

    function refreshLogs() {
        loading.value = true;
        ElMessage.info(t('audit.refreshing_logs'));
        
        // Simulate API call
        setTimeout(() => {
            loading.value = false;
            ElMessage.success(t('audit.logs_refreshed'));
        }, 1000);
    }

    function exportLogs() {
        ElMessage.info(t('audit.exporting_logs'));
        
        // Simulate export
        setTimeout(() => {
            ElMessage.success(t('audit.logs_exported'));
        }, 2000);
    }

    function handleSizeChange(val: number) {
        pageSize.value = val;
        currentPage.value = 1;
    }

    function handleCurrentChange(val: number) {
        currentPage.value = val;
    }

    onMounted(() => {
        totalLogs.value = auditLogs.value.length;
        // TODO: Load audit logs from API
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

    .text-truncate {
        max-width: 200px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
</style>
