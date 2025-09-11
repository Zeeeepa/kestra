<template>
    <TopNavBar :title="routeInfo.title" />
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">{{ $t('demos.tests.header') }}</h5>
                        <div class="d-flex gap-2">
                            <el-button @click="runAllTests" :loading="runningAll">
                                <PlayArrow class="me-2" />
                                {{ $t('tests.run_all') }}
                            </el-button>
                            <el-button type="primary" @click="showCreateDialog = true">
                                <Plus class="me-2" />
                                {{ $t('tests.create') }}
                            </el-button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div v-if="tests.length === 0" class="text-center py-5">
                            <FlaskOutline class="text-muted mb-3" style="font-size: 4rem;" />
                            <h6 class="text-muted">{{ $t('tests.empty.title') }}</h6>
                            <p class="text-muted">{{ $t('tests.empty.description') }}</p>
                            <el-button type="primary" @click="showCreateDialog = true">
                                {{ $t('tests.create_first') }}
                            </el-button>
                        </div>
                        <div v-else>
                            <!-- Test Statistics -->
                            <div class="row mb-4">
                                <div class="col-md-3">
                                    <div class="stat-card text-center p-3 border rounded">
                                        <div class="stat-number text-primary">{{ testStats.total }}</div>
                                        <div class="stat-label">{{ $t('tests.total') }}</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat-card text-center p-3 border rounded">
                                        <div class="stat-number text-success">{{ testStats.passed }}</div>
                                        <div class="stat-label">{{ $t('tests.passed') }}</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat-card text-center p-3 border rounded">
                                        <div class="stat-number text-danger">{{ testStats.failed }}</div>
                                        <div class="stat-label">{{ $t('tests.failed') }}</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat-card text-center p-3 border rounded">
                                        <div class="stat-number text-warning">{{ testStats.pending }}</div>
                                        <div class="stat-label">{{ $t('tests.pending') }}</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Tests Table -->
                            <el-table :data="tests" style="width: 100%">
                                <el-table-column prop="name" :label="$t('name')" min-width="200">
                                    <template #default="scope">
                                        <div class="d-flex align-items-center">
                                            <FlaskOutline class="me-2 text-muted" />
                                            {{ scope.row.name }}
                                        </div>
                                    </template>
                                </el-table-column>
                                <el-table-column prop="flow" :label="$t('flow')" min-width="150" />
                                <el-table-column prop="namespace" :label="$t('namespace')" width="120" />
                                <el-table-column prop="status" :label="$t('status')" width="100">
                                    <template #default="scope">
                                        <el-tag 
                                            :type="getStatusType(scope.row.status)"
                                            size="small"
                                        >
                                            {{ $t(`tests.status.${scope.row.status}`) }}
                                        </el-tag>
                                    </template>
                                </el-table-column>
                                <el-table-column prop="lastRun" :label="$t('tests.last_run')" width="150">
                                    <template #default="scope">
                                        <span v-if="scope.row.lastRun">
                                            {{ formatDate(scope.row.lastRun) }}
                                        </span>
                                        <span v-else class="text-muted">{{ $t('never') }}</span>
                                    </template>
                                </el-table-column>
                                <el-table-column prop="duration" :label="$t('tests.duration')" width="100">
                                    <template #default="scope">
                                        <span v-if="scope.row.duration">{{ scope.row.duration }}ms</span>
                                        <span v-else>-</span>
                                    </template>
                                </el-table-column>
                                <el-table-column :label="$t('actions')" width="150">
                                    <template #default="scope">
                                        <el-button 
                                            size="small" 
                                            @click="runTest(scope.row)"
                                            :loading="scope.row.running"
                                        >
                                            <PlayArrow />
                                        </el-button>
                                        <el-dropdown @command="handleTestAction">
                                            <el-button size="small" text>
                                                <DotsVertical />
                                            </el-button>
                                            <template #dropdown>
                                                <el-dropdown-menu>
                                                    <el-dropdown-item :command="{action: 'edit', test: scope.row}">
                                                        {{ $t('edit') }}
                                                    </el-dropdown-item>
                                                    <el-dropdown-item :command="{action: 'view', test: scope.row}">
                                                        {{ $t('tests.view_results') }}
                                                    </el-dropdown-item>
                                                    <el-dropdown-item :command="{action: 'delete', test: scope.row}" divided>
                                                        {{ $t('delete') }}
                                                    </el-dropdown-item>
                                                </el-dropdown-menu>
                                            </template>
                                        </el-dropdown>
                                    </template>
                                </el-table-column>
                            </el-table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Create/Edit Test Dialog -->
    <el-dialog v-model="showCreateDialog" :title="editingTest ? $t('tests.edit') : $t('tests.create')" width="700px">
        <el-form :model="testForm" label-width="120px">
            <el-form-item :label="$t('name')" required>
                <el-input v-model="testForm.name" :placeholder="$t('tests.name_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('description')">
                <el-input 
                    v-model="testForm.description" 
                    type="textarea" 
                    :rows="2"
                    :placeholder="$t('tests.description_placeholder')" 
                />
            </el-form-item>
            <el-form-item :label="$t('flow')" required>
                <el-input v-model="testForm.flow" :placeholder="$t('tests.flow_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('namespace')" required>
                <el-input v-model="testForm.namespace" :placeholder="$t('tests.namespace_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('tests.test_data')">
                <el-input 
                    v-model="testForm.testData" 
                    type="textarea" 
                    :rows="6"
                    :placeholder="$t('tests.test_data_placeholder')" 
                />
            </el-form-item>
            <el-form-item :label="$t('tests.expected_output')">
                <el-input 
                    v-model="testForm.expectedOutput" 
                    type="textarea" 
                    :rows="4"
                    :placeholder="$t('tests.expected_output_placeholder')" 
                />
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="showCreateDialog = false">{{ $t('cancel') }}</el-button>
            <el-button type="primary" @click="saveTest">
                {{ editingTest ? $t('update') : $t('create') }}
            </el-button>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted} from "vue";
    import {useI18n} from "vue-i18n";
    import {ElMessage, ElMessageBox} from "element-plus";
    import TopNavBar from "../layout/TopNavBar.vue";
    import Plus from "vue-material-design-icons/Plus.vue";
    import PlayArrow from "vue-material-design-icons/PlayArrow.vue";
    import FlaskOutline from "vue-material-design-icons/FlaskOutline.vue";
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import useRouteContext from "../../mixins/useRouteContext";

    const {t} = useI18n();

    const routeInfo = ref({
        title: t("demos.tests.header"),
    });

    useRouteContext(routeInfo);

    // Reactive data
    const tests = ref([
        {
            id: 1,
            name: "Customer Data Validation",
            description: "Test customer data processing flow",
            flow: "customer-processing",
            namespace: "customer",
            status: "passed",
            lastRun: new Date('2024-01-15T10:30:00'),
            duration: 1250,
            running: false
        },
        {
            id: 2,
            name: "Payment Processing Test",
            description: "Validate payment workflow",
            flow: "payment-flow",
            namespace: "finance",
            status: "failed",
            lastRun: new Date('2024-01-14T15:45:00'),
            duration: 890,
            running: false
        },
        {
            id: 3,
            name: "Data Export Validation",
            description: "Test data export functionality",
            flow: "data-export",
            namespace: "data",
            status: "pending",
            lastRun: null,
            duration: null,
            running: false
        }
    ]);

    const showCreateDialog = ref(false);
    const editingTest = ref(null);
    const runningAll = ref(false);
    const testForm = ref({
        name: '',
        description: '',
        flow: '',
        namespace: '',
        testData: '',
        expectedOutput: ''
    });

    // Computed
    const testStats = computed(() => {
        const total = tests.value.length;
        const passed = tests.value.filter(t => t.status === 'passed').length;
        const failed = tests.value.filter(t => t.status === 'failed').length;
        const pending = tests.value.filter(t => t.status === 'pending').length;
        
        return { total, passed, failed, pending };
    });

    // Methods
    function getStatusType(status: string) {
        switch (status) {
            case 'passed': return 'success';
            case 'failed': return 'danger';
            case 'pending': return 'warning';
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

    async function runTest(test: any) {
        test.running = true;
        ElMessage.info(`Running test: ${test.name}`);
        
        // Simulate test execution
        setTimeout(() => {
            test.running = false;
            test.lastRun = new Date();
            test.duration = Math.floor(Math.random() * 2000) + 500;
            test.status = Math.random() > 0.3 ? 'passed' : 'failed';
            
            ElMessage.success(`Test completed: ${test.name}`);
        }, 2000);
    }

    async function runAllTests() {
        runningAll.value = true;
        ElMessage.info('Running all tests...');
        
        // Simulate running all tests
        setTimeout(() => {
            tests.value.forEach(test => {
                test.lastRun = new Date();
                test.duration = Math.floor(Math.random() * 2000) + 500;
                test.status = Math.random() > 0.2 ? 'passed' : 'failed';
            });
            
            runningAll.value = false;
            ElMessage.success('All tests completed');
        }, 3000);
    }

    function handleTestAction(command: any) {
        if (command.action === 'edit') {
            editTest(command.test);
        } else if (command.action === 'delete') {
            deleteTest(command.test);
        } else if (command.action === 'view') {
            viewTestResults(command.test);
        }
    }

    function editTest(test: any) {
        editingTest.value = test;
        testForm.value = { ...test };
        showCreateDialog.value = true;
    }

    function viewTestResults(test: any) {
        ElMessage.info(`Viewing results for: ${test.name}`);
        // TODO: Implement test results view
    }

    async function deleteTest(test: any) {
        try {
            await ElMessageBox.confirm(
                t('tests.delete_confirm', { name: test.name }),
                t('confirm'),
                {
                    confirmButtonText: t('delete'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );
            
            const index = tests.value.findIndex(t => t.id === test.id);
            if (index > -1) {
                tests.value.splice(index, 1);
                ElMessage.success(t('tests.deleted_success'));
            }
        } catch {
            // User cancelled
        }
    }

    function saveTest() {
        if (!testForm.value.name.trim()) {
            ElMessage.error(t('tests.name_required'));
            return;
        }

        if (editingTest.value) {
            // Update existing test
            const index = tests.value.findIndex(t => t.id === editingTest.value.id);
            if (index > -1) {
                tests.value[index] = { 
                    ...tests.value[index], 
                    ...testForm.value,
                    status: 'pending',
                    lastRun: null,
                    duration: null
                };
                ElMessage.success(t('tests.updated_success'));
            }
        } else {
            // Create new test
            const newTest = {
                id: Date.now(),
                ...testForm.value,
                status: 'pending',
                lastRun: null,
                duration: null,
                running: false
            };
            tests.value.push(newTest);
            ElMessage.success(t('tests.created_success'));
        }

        showCreateDialog.value = false;
        editingTest.value = null;
        testForm.value = {
            name: '',
            description: '',
            flow: '',
            namespace: '',
            testData: '',
            expectedOutput: ''
        };
    }

    onMounted(() => {
        // TODO: Load tests from API
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

    .stat-card {
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
        }
        
        .stat-label {
            font-size: 0.875rem;
            color: var(--ks-content-secondary);
        }
    }
</style>
