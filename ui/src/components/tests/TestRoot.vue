<template>
    <div class="test-root">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h3>{{ testData.name || 'Test Suite Details' }}</h3>
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
                                    :class="{active: activeTab === 'cases'}"
                                    @click="setActiveTab('cases')"
                                >
                                    Test Cases
                                </button>
                                <button 
                                    class="btn btn-outline-primary"
                                    :class="{active: activeTab === 'results'}"
                                    @click="setActiveTab('results')"
                                >
                                    Results
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
                                                v-model="testData.name" 
                                                type="text" 
                                                class="form-control" 
                                                :readonly="!editing"
                                            >
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Namespace</label>
                                            <input 
                                                v-model="testData.namespace" 
                                                type="text" 
                                                class="form-control" 
                                                readonly
                                            >
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Flow ID</label>
                                            <input 
                                                v-model="testData.flowId" 
                                                type="text" 
                                                class="form-control" 
                                                :readonly="!editing"
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label class="form-label">Description</label>
                                            <textarea 
                                                v-model="testData.description" 
                                                class="form-control" 
                                                rows="3"
                                                :readonly="!editing"
                                            />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Statistics</label>
                                            <div class="row">
                                                <div class="col-4">
                                                    <div class="text-center">
                                                        <div class="h4 text-primary">
                                                            {{ testData.testCaseCount }}
                                                        </div>
                                                        <small class="text-muted">Test Cases</small>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div class="text-center">
                                                        <div class="h4 text-success">
                                                            {{ (testData.successRate * 100).toFixed(1) }}%
                                                        </div>
                                                        <small class="text-muted">Success Rate</small>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div class="text-center">
                                                        <div class="h4 text-info">
                                                            {{ testData.totalRuns }}
                                                        </div>
                                                        <small class="text-muted">Total Runs</small>
                                                    </div>
                                                </div>
                                            </div>
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
                                    <button class="btn btn-success" @click="runTests">
                                        Run Tests
                                    </button>
                                </div>
                            </div>

                            <!-- Test Cases Tab -->
                            <div v-else-if="activeTab === 'cases'" class="tab-content">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5>Test Cases</h5>
                                    <button class="btn btn-primary" @click="addTestCase">
                                        Add Test Case
                                    </button>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Type</th>
                                                <th>Expected Result</th>
                                                <th>Last Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="testCase in testCases" :key="testCase.id">
                                                <td>{{ testCase.name }}</td>
                                                <td>{{ testCase.type }}</td>
                                                <td>{{ testCase.expectedResult }}</td>
                                                <td>
                                                    <span 
                                                        class="badge"
                                                        :class="getStatusBadgeClass(testCase.lastStatus)"
                                                    >
                                                        {{ testCase.lastStatus }}
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <button class="btn btn-outline-primary">
                                                            Edit
                                                        </button>
                                                        <button class="btn btn-outline-danger">
                                                            Delete
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr v-if="testCases.length === 0">
                                                <td colspan="5" class="text-center text-muted">
                                                    No test cases defined
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Results Tab -->
                            <div v-else-if="activeTab === 'results'" class="tab-content">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5>Test Results</h5>
                                    <button class="btn btn-primary" @click="runTests">
                                        Run Tests
                                    </button>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Run ID</th>
                                                <th>Status</th>
                                                <th>Started</th>
                                                <th>Duration</th>
                                                <th>Passed/Total</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="result in testResults" :key="result.id">
                                                <td>{{ result.id }}</td>
                                                <td>
                                                    <span 
                                                        class="badge"
                                                        :class="getStatusBadgeClass(result.status)"
                                                    >
                                                        {{ result.status }}
                                                    </span>
                                                </td>
                                                <td>{{ formatDate(result.startedAt) }}</td>
                                                <td>{{ result.duration || '-' }}</td>
                                                <td>{{ result.passed }}/{{ result.total }}</td>
                                                <td>
                                                    <button class="btn btn-sm btn-outline-primary">
                                                        View Details
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr v-if="testResults.length === 0">
                                                <td colspan="6" class="text-center text-muted">
                                                    No test results found
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

    const testData = reactive({
        name: "",
        namespace: "",
        description: "",
        flowId: "",
        id: "",
        testCaseCount: 0,
        successRate: 0,
        totalRuns: 0
    });

    const testCases = ref([
        {
            id: "case-001",
            name: "API Response Validation",
            type: "API Test",
            expectedResult: "Status 200",
            lastStatus: "PASSED"
        },
        {
            id: "case-002",
            name: "Data Integrity Check",
            type: "Data Test",
            expectedResult: "No null values",
            lastStatus: "FAILED"
        }
    ]);

    const testResults = ref([
        {
            id: "run-001",
            status: "SUCCESS",
            startedAt: new Date().toISOString(),
            duration: "45s",
            passed: 8,
            total: 10
        },
        {
            id: "run-002",
            status: "RUNNING",
            startedAt: new Date().toISOString(),
            duration: null,
            passed: 0,
            total: 10
        }
    ]);

    onMounted(() => {
        loadTestData();
    });

    const loadTestData = () => {
        // Simulate loading test data
        testData.name = "Sample Test Suite";
        testData.namespace = route.params.namespace as string;
        testData.id = route.params.id as string;
        testData.description = "This is a sample test suite for demonstration";
        testData.flowId = "sample-flow-id";
        testData.testCaseCount = testCases.value.length;
        testData.successRate = 0.8;
        testData.totalRuns = 25;
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
        loadTestData(); // Reload original data
    };

    const runTests = async () => {
        try {
            // Simulate test execution
            const newResult = {
                id: `run-${Date.now()}`,
                status: "RUNNING",
                startedAt: new Date().toISOString(),
                duration: null,
                passed: 0,
                total: testCases.value.length
            };
            testResults.value.unshift(newResult);
        
            // Simulate completion after 5 seconds
            setTimeout(() => {
                newResult.status = "SUCCESS";
                newResult.duration = "42s";
                newResult.passed = Math.floor(Math.random() * testCases.value.length) + 1;
            }, 5000);
        
        } catch (error) {
            console.error("Failed to run tests:", error);
        }
    };

    const addTestCase = () => {
        // Simulate adding a new test case
        const newCase = {
            id: `case-${Date.now()}`,
            name: "New Test Case",
            type: "Custom Test",
            expectedResult: "Success",
            lastStatus: "NOT_RUN"
        };
        testCases.value.push(newCase);
    };

    const getStatusBadgeClass = (status: string) => {
        switch (status) {
        case "SUCCESS":
        case "PASSED": return "bg-success";
        case "RUNNING": return "bg-primary";
        case "FAILED": return "bg-danger";
        case "CANCELLED": return "bg-warning";
        case "NOT_RUN": return "bg-secondary";
        default: return "bg-secondary";
        }
    };

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleString();
    };
</script>

<style scoped>
.test-root {
    padding: 1rem;
}

.tab-content {
    min-height: 400px;
}
</style>
