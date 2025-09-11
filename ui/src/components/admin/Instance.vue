<template>
    <TopNavBar :title="routeInfo.title" />
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <el-tabs v-model="activeTab" class="instance-tabs">
                    <!-- Overview Tab -->
                    <el-tab-pane :label="$t('instance.overview')" name="overview">
                        <div class="row">
                            <!-- System Status Cards -->
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card status-card">
                                    <div class="card-body text-center">
                                        <div class="status-icon text-success mb-2">
                                            <CheckCircle style="font-size: 2.5rem;" />
                                        </div>
                                        <h6 class="card-title">{{ $t('instance.system_status') }}</h6>
                                        <p class="card-text text-success">{{ $t('instance.healthy') }}</p>
                                        <small class="text-muted">{{ $t('instance.uptime') }}: {{ systemInfo.uptime }}</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card status-card">
                                    <div class="card-body text-center">
                                        <div class="status-icon text-primary mb-2">
                                            <Memory style="font-size: 2.5rem;" />
                                        </div>
                                        <h6 class="card-title">{{ $t('instance.memory_usage') }}</h6>
                                        <p class="card-text">{{ systemInfo.memoryUsage }}%</p>
                                        <el-progress :percentage="systemInfo.memoryUsage" :color="getProgressColor(systemInfo.memoryUsage)" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card status-card">
                                    <div class="card-body text-center">
                                        <div class="status-icon text-warning mb-2">
                                            <Cpu style="font-size: 2.5rem;" />
                                        </div>
                                        <h6 class="card-title">{{ $t('instance.cpu_usage') }}</h6>
                                        <p class="card-text">{{ systemInfo.cpuUsage }}%</p>
                                        <el-progress :percentage="systemInfo.cpuUsage" :color="getProgressColor(systemInfo.cpuUsage)" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card status-card">
                                    <div class="card-body text-center">
                                        <div class="status-icon text-info mb-2">
                                            <HardDisk style="font-size: 2.5rem;" />
                                        </div>
                                        <h6 class="card-title">{{ $t('instance.disk_usage') }}</h6>
                                        <p class="card-text">{{ systemInfo.diskUsage }}%</p>
                                        <el-progress :percentage="systemInfo.diskUsage" :color="getProgressColor(systemInfo.diskUsage)" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Services Status -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">{{ $t('instance.services_status') }}</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div v-for="service in services" :key="service.name" class="col-md-6 col-lg-4 mb-3">
                                        <div class="service-item d-flex align-items-center p-3 border rounded">
                                            <div class="service-status me-3">
                                                <CheckCircle v-if="service.status === 'running'" class="text-success" />
                                                <AlertCircle v-else-if="service.status === 'warning'" class="text-warning" />
                                                <XCircle v-else class="text-danger" />
                                            </div>
                                            <div class="service-info flex-grow-1">
                                                <h6 class="mb-1">{{ service.name }}</h6>
                                                <small class="text-muted">{{ service.description }}</small>
                                                <div class="mt-1">
                                                    <el-tag :type="getServiceStatusType(service.status)" size="small">
                                                        {{ $t(`instance.service_status.${service.status}`) }}
                                                    </el-tag>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </el-tab-pane>

                    <!-- Maintenance Tab -->
                    <el-tab-pane :label="$t('instance.maintenance')" name="maintenance">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">{{ $t('instance.maintenance_mode') }}</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <el-alert
                                            v-if="maintenanceMode.enabled"
                                            :title="$t('instance.maintenance_active')"
                                            type="warning"
                                            :description="$t('instance.maintenance_active_desc')"
                                            show-icon
                                            :closable="false"
                                        />
                                        <el-form :model="maintenanceMode" label-width="150px">
                                            <el-form-item :label="$t('instance.enable_maintenance')">
                                                <el-switch 
                                                    v-model="maintenanceMode.enabled" 
                                                    @change="toggleMaintenanceMode"
                                                />
                                            </el-form-item>
                                            <el-form-item :label="$t('instance.maintenance_message')" v-if="maintenanceMode.enabled">
                                                <el-input 
                                                    v-model="maintenanceMode.message" 
                                                    type="textarea" 
                                                    :rows="3"
                                                    :placeholder="$t('instance.maintenance_message_placeholder')"
                                                />
                                            </el-form-item>
                                            <el-form-item :label="$t('instance.scheduled_end')" v-if="maintenanceMode.enabled">
                                                <el-date-picker
                                                    v-model="maintenanceMode.scheduledEnd"
                                                    type="datetime"
                                                    :placeholder="$t('instance.select_end_time')"
                                                />
                                            </el-form-item>
                                            <el-form-item v-if="maintenanceMode.enabled">
                                                <el-button type="primary" @click="updateMaintenanceMode">
                                                    {{ $t('instance.update_maintenance') }}
                                                </el-button>
                                            </el-form-item>
                                        </el-form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </el-tab-pane>

                    <!-- Announcements Tab -->
                    <el-tab-pane :label="$t('instance.announcements')" name="announcements">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">{{ $t('instance.system_announcements') }}</h5>
                                <el-button type="primary" @click="showAnnouncementDialog = true">
                                    <Plus class="me-2" />
                                    {{ $t('instance.create_announcement') }}
                                </el-button>
                            </div>
                            <div class="card-body">
                                <div v-if="announcements.length === 0" class="text-center py-5">
                                    <Bullhorn class="text-muted mb-3" style="font-size: 4rem;" />
                                    <h6 class="text-muted">{{ $t('instance.no_announcements') }}</h6>
                                    <p class="text-muted">{{ $t('instance.no_announcements_desc') }}</p>
                                </div>
                                <div v-else>
                                    <div v-for="announcement in announcements" :key="announcement.id" class="announcement-item mb-3">
                                        <el-alert
                                            :title="announcement.title"
                                            :type="announcement.type"
                                            :description="announcement.message"
                                            show-icon
                                            :closable="false"
                                        >
                                            <template #default>
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div>
                                                        <h6>{{ announcement.title }}</h6>
                                                        <p class="mb-2">{{ announcement.message }}</p>
                                                        <small class="text-muted">
                                                            {{ $t('instance.created_by') }}: {{ announcement.createdBy }} | 
                                                            {{ formatDate(announcement.createdAt) }}
                                                        </small>
                                                    </div>
                                                    <el-dropdown @command="handleAnnouncementAction">
                                                        <el-button size="small" text>
                                                            <DotsVertical />
                                                        </el-button>
                                                        <template #dropdown>
                                                            <el-dropdown-menu>
                                                                <el-dropdown-item :command="{action: 'edit', announcement}">
                                                                    {{ $t('edit') }}
                                                                </el-dropdown-item>
                                                                <el-dropdown-item :command="{action: 'delete', announcement}" divided>
                                                                    {{ $t('delete') }}
                                                                </el-dropdown-item>
                                                            </el-dropdown-menu>
                                                        </template>
                                                    </el-dropdown>
                                                </div>
                                            </template>
                                        </el-alert>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </el-tab-pane>

                    <!-- System Info Tab -->
                    <el-tab-pane :label="$t('instance.system_info')" name="system">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">{{ $t('instance.system_information') }}</h5>
                            </div>
                            <div class="card-body">
                                <el-descriptions :column="2" border>
                                    <el-descriptions-item :label="$t('instance.version')">
                                        {{ systemInfo.version }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.build_date')">
                                        {{ formatDate(systemInfo.buildDate) }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.java_version')">
                                        {{ systemInfo.javaVersion }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.os')">
                                        {{ systemInfo.operatingSystem }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.total_memory')">
                                        {{ systemInfo.totalMemory }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.available_processors')">
                                        {{ systemInfo.availableProcessors }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.database_type')">
                                        {{ systemInfo.databaseType }}
                                    </el-descriptions-item>
                                    <el-descriptions-item :label="$t('instance.storage_type')">
                                        {{ systemInfo.storageType }}
                                    </el-descriptions-item>
                                </el-descriptions>
                            </div>
                        </div>
                    </el-tab-pane>
                </el-tabs>
            </div>
        </div>
    </div>

    <!-- Announcement Dialog -->
    <el-dialog v-model="showAnnouncementDialog" :title="editingAnnouncement ? $t('instance.edit_announcement') : $t('instance.create_announcement')" width="600px">
        <el-form :model="announcementForm" label-width="120px">
            <el-form-item :label="$t('title')" required>
                <el-input v-model="announcementForm.title" :placeholder="$t('instance.announcement_title_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('type')" required>
                <el-select v-model="announcementForm.type" :placeholder="$t('instance.select_type')">
                    <el-option label="Info" value="info" />
                    <el-option label="Success" value="success" />
                    <el-option label="Warning" value="warning" />
                    <el-option label="Error" value="error" />
                </el-select>
            </el-form-item>
            <el-form-item :label="$t('message')" required>
                <el-input 
                    v-model="announcementForm.message" 
                    type="textarea" 
                    :rows="4"
                    :placeholder="$t('instance.announcement_message_placeholder')" 
                />
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="showAnnouncementDialog = false">{{ $t('cancel') }}</el-button>
            <el-button type="primary" @click="saveAnnouncement">
                {{ editingAnnouncement ? $t('update') : $t('create') }}
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
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import CheckCircle from "vue-material-design-icons/CheckCircle.vue";
    import AlertCircle from "vue-material-design-icons/AlertCircle.vue";
    import XCircle from "vue-material-design-icons/XCircle.vue";
    import Memory from "vue-material-design-icons/Memory.vue";
    import Cpu from "vue-material-design-icons/Cpu.vue";
    import HardDisk from "vue-material-design-icons/HardDisk.vue";
    import Bullhorn from "vue-material-design-icons/Bullhorn.vue";
    import useRouteContext from "../../mixins/useRouteContext";

    const {t} = useI18n();

    const routeInfo = ref({
        title: t("instance"),
    });

    useRouteContext(routeInfo);

    // Reactive data
    const activeTab = ref('overview');
    const showAnnouncementDialog = ref(false);
    const editingAnnouncement = ref(null);

    const systemInfo = ref({
        uptime: '7 days, 14 hours',
        memoryUsage: 65,
        cpuUsage: 23,
        diskUsage: 45,
        version: '0.15.0',
        buildDate: new Date('2024-01-10T10:00:00'),
        javaVersion: 'OpenJDK 21.0.1',
        operatingSystem: 'Linux Ubuntu 22.04',
        totalMemory: '8 GB',
        availableProcessors: '4 cores',
        databaseType: 'PostgreSQL 15.2',
        storageType: 'Local File System'
    });

    const services = ref([
        {
            name: 'Webserver',
            description: 'HTTP API and Web UI',
            status: 'running'
        },
        {
            name: 'Scheduler',
            description: 'Flow scheduling service',
            status: 'running'
        },
        {
            name: 'Executor',
            description: 'Task execution engine',
            status: 'running'
        },
        {
            name: 'Worker',
            description: 'Task processing workers',
            status: 'warning'
        },
        {
            name: 'Indexer',
            description: 'Search indexing service',
            status: 'running'
        },
        {
            name: 'Database',
            description: 'PostgreSQL database',
            status: 'running'
        }
    ]);

    const maintenanceMode = ref({
        enabled: false,
        message: '',
        scheduledEnd: null
    });

    const announcements = ref([
        {
            id: 1,
            title: 'Scheduled Maintenance',
            message: 'System maintenance is scheduled for this weekend. Some services may be temporarily unavailable.',
            type: 'warning',
            createdBy: 'admin',
            createdAt: new Date('2024-01-14T09:00:00')
        },
        {
            id: 2,
            title: 'New Features Available',
            message: 'We have released new workflow templates and improved performance monitoring.',
            type: 'success',
            createdBy: 'admin',
            createdAt: new Date('2024-01-12T15:30:00')
        }
    ]);

    const announcementForm = ref({
        title: '',
        type: '',
        message: ''
    });

    // Methods
    function getProgressColor(percentage: number) {
        if (percentage < 50) return '#67c23a';
        if (percentage < 80) return '#e6a23c';
        return '#f56c6c';
    }

    function getServiceStatusType(status: string) {
        switch (status) {
            case 'running': return 'success';
            case 'warning': return 'warning';
            case 'stopped': return 'danger';
            default: return 'info';
        }
    }

    function formatDate(date: Date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    }

    function toggleMaintenanceMode(enabled: boolean) {
        if (enabled) {
            ElMessage.warning(t('instance.maintenance_enabled'));
        } else {
            ElMessage.success(t('instance.maintenance_disabled'));
        }
    }

    function updateMaintenanceMode() {
        ElMessage.success(t('instance.maintenance_updated'));
    }

    function handleAnnouncementAction(command: any) {
        if (command.action === 'edit') {
            editAnnouncement(command.announcement);
        } else if (command.action === 'delete') {
            deleteAnnouncement(command.announcement);
        }
    }

    function editAnnouncement(announcement: any) {
        editingAnnouncement.value = announcement;
        announcementForm.value = { ...announcement };
        showAnnouncementDialog.value = true;
    }

    async function deleteAnnouncement(announcement: any) {
        try {
            await ElMessageBox.confirm(
                t('instance.delete_announcement_confirm', { title: announcement.title }),
                t('confirm'),
                {
                    confirmButtonText: t('delete'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );
            
            const index = announcements.value.findIndex(a => a.id === announcement.id);
            if (index > -1) {
                announcements.value.splice(index, 1);
                ElMessage.success(t('instance.announcement_deleted'));
            }
        } catch {
            // User cancelled
        }
    }

    function saveAnnouncement() {
        if (!announcementForm.value.title.trim() || !announcementForm.value.message.trim()) {
            ElMessage.error(t('instance.announcement_fields_required'));
            return;
        }

        if (editingAnnouncement.value) {
            // Update existing announcement
            const index = announcements.value.findIndex(a => a.id === editingAnnouncement.value.id);
            if (index > -1) {
                announcements.value[index] = { 
                    ...announcements.value[index], 
                    ...announcementForm.value
                };
                ElMessage.success(t('instance.announcement_updated'));
            }
        } else {
            // Create new announcement
            const newAnnouncement = {
                id: Date.now(),
                ...announcementForm.value,
                createdBy: 'admin',
                createdAt: new Date()
            };
            announcements.value.unshift(newAnnouncement);
            ElMessage.success(t('instance.announcement_created'));
        }

        showAnnouncementDialog.value = false;
        editingAnnouncement.value = null;
        announcementForm.value = {
            title: '',
            type: '',
            message: ''
        };
    }

    onMounted(() => {
        // TODO: Load system information from API
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

    .instance-tabs {
        :deep(.el-tabs__header) {
            margin-bottom: 20px;
        }
    }

    .status-card {
        .status-icon {
            opacity: 0.8;
        }
    }

    .service-item {
        transition: all 0.2s ease;
        
        &:hover {
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
    }

    .announcement-item {
        :deep(.el-alert) {
            .el-alert__content {
                width: 100%;
            }
        }
    }
</style>
