<template>
    <div class="test-results">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h2>Test Results</h2>
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item">
                                        <router-link to="/tests">
                                            Tests
                                        </router-link>
                                    </li>
                                    <li class="breadcrumb-item">
                                        <router-link :to="`/tests/edit/${namespace}/${testId}`">
                                            {{ testName }}
                                        </router-link>
                                    </li>
                                    <li class="breadcrumb-item active">
                                        Results
                                    </li>
                                </ol>
                            </nav>
                        </div>
                        <button class="btn btn-primary" @click="runTests">
                            <i class="fas fa-play me-2" />
                            Run Tests
                        </button>
                    </div>
                    
                    <!-- Summary Cards -->
                    <div class="row mb-4">
                        <div class="col-md-3">
                            <div class="card text-center">
                                <div class="card-body">
                                    <div class="h3 text-primary">
                                        {{ summary.totalRuns }}
                                    </div>
                                    <div class="text-muted">
                                        Total Runs
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-center">
                                <div class="card-body">
                                    <div class="h3 text-success">
                                        {{ summary.successfulRuns }}
                                    </div>
                                    <div class="text-muted">
                                        Successful
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-center">
                                <div class="card-body">
                                    <div class="h3 text-danger">
                                        {{ summary.failedRuns }}
                                    </div>
                                    <div class="text-muted">
                                        Failed
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-center">
                                <div class="card-body">
                                    <div class="h3 text-info">
                                        {{ (summary.successRate * 100).toFixed(1) }}%
                                    </div>
                                    <div class="text-muted">
                                        Success Rate
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Results Table -->
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                Test Execution History
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Run ID</th>
                                            <th>Status</th>
                                            <th>Started</th>
                                            <th>Duration</th>
                                            <th>Test Cases</th>
                                            <th>Success Rate</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="result in results" :key="result.id">
                                            <td>
                                                <code>{{ result.id }}</code>
                                            </td>
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
                                            <td>
                                                <span class="text-success">{{ result.passed }}</span>
                                                /
                                                <span class="text-muted">{{ result.total }}</span>
                                            </td>
                                            <td>
                                                <div class="progress" style="height: 20px;">
                                                    <div 
                                                        class="progress-bar"
                                                        :class="getProgressBarClass(result.passed / result.total)"
                                                        :style="{width: (result.passed / result.total * 100) + '%'}"
                                                    >
                                                        {{ ((result.passed / result.total) * 100).toFixed(0) }}%
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <button 
                                                        class="btn btn-outline-primary"
                                                        @click="viewDetails(result)"
                                                    >
                                                        Details
                                                    </button>
                                                    <button 
                                                        class="btn btn-outline-secondary"
                                                        @click="downloadLogs(result)"
                                                    >
                                                        Logs
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr v-if="results.length === 0">
                                            <td colspan="7" class="text-center text-muted py-4">
                                                No test results found. 
                                                <button class="btn btn-link p-0" @click="runTests">
                                                    Run your first test
                                                </button>
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
        
        <!-- Details Modal -->
        <div 
            v-if="selectedResult" 
            class="modal fade show d-block" 
            tabindex="-1"
            style="background-color: rgba(0,0,0,0.5);"
        >
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            Test Run Details - {{ selectedResult.id }}
                        </h5>
                        <button 
                            type="button" 
                            class="btn-close" 
                            @click="closeDetails"
                        />
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Status:</strong>
                                <span 
                                    class="badge ms-2"
                                    :class="getStatusBadgeClass(selectedResult.status)"
                                >
                                    {{ selectedResult.status }}
                                </span>
                            </div>
                            <div class="col-md-6">
                                <strong>Duration:</strong> {{ selectedResult.duration || 'N/A' }}
                            </div>
                        </div>
                        
                        <h6>Test Case Results:</h6>
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Test Case</th>
                                        <th>Status</th>
                                        <th>Duration</th>
                                        <th>Message</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="testCase in selectedResult.testCases" :key="testCase.id">
                                        <td>{{ testCase.name }}</td>
                                        <td>
                                            <span 
                                                class="badge badge-sm"
                                                :class="getStatusBadgeClass(testCase.status)"
                                            >
                                                {{ testCase.status }}
                                            </span>
                                        </td>
                                        <td>{{ testCase.duration }}</td>
                                        <td>
                                            <small class="text-muted">{{ testCase.message }}</small>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" @click="closeDetails">
                            Close
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
    import {ref, reactive, onMounted} from "vue";
    import {useRoute} from "vue-router";

    const route = useRoute();

    const namespace = ref(route.params.namespace as string);
    const testId = ref(route.params.id as string);
    const testName = ref("Sample Test Suite");
    const selectedResult = ref(null);

    const summary = reactive({
        totalRuns: 0,
        successfulRuns: 0,
        failedRuns: 0,
        successRate: 0
    });

    const results = ref([
        {
            id: "run-001",
            status: "SUCCESS",
            startedAt: new Date().toISOString(),
            duration: "2m 15s",
            passed: 8,
            total: 10,
            testCases: [
                {id: "case-1", name: "API Test", status: "SUCCESS", duration: "15s", message: "All assertions passed"},
                {id: "case-2", name: "Data Test", status: "FAILED", duration: "30s", message: "Null value found in column X"}
            ]
        },
        {
            id: "run-002",
            status: "FAILED",
            startedAt: new Date(Date.now() - 3600000).toISOString(),
            duration: "1m 45s",
            passed: 6,
            total: 10,
            testCases: [
                {id: "case-1", name: "API Test", status: "SUCCESS", duration: "12s", message: "All assertions passed"},
                {id: "case-2", name: "Data Test", status: "FAILED", duration: "25s", message: "Connection timeout"}
            ]
        },
        {
            id: "run-003",
            status: "RUNNING",
            startedAt: new Date().toISOString(),
            duration: null,
            passed: 0,
            total: 10,
            testCases: []
        }
    ]);

    onMounted(() => {
        loadResults();
        calculateSummary();
    });

    const loadResults = async () => {
        // Simulate API call to load test results
        console.log("Loading test results for:", namespace.value, testId.value);
    };

    const calculateSummary = () => {
        summary.totalRuns = results.value.length;
        summary.successfulRuns = results.value.filter(r => r.status === "SUCCESS").length;
        summary.failedRuns = results.value.filter(r => r.status === "FAILED").length;
        summary.successRate = summary.totalRuns > 0 ? summary.successfulRuns / summary.totalRuns : 0;
    };

    const runTests = async () => {
        console.log("Running tests...");
        // Simulate test execution
        const newResult = {
            id: `run-${Date.now()}`,
            status: "RUNNING",
            startedAt: new Date().toISOString(),
            duration: null,
            passed: 0,
            total: 10,
            testCases: []
        };
        results.value.unshift(newResult);
    
        // Simulate completion
        setTimeout(() => {
            newResult.status = "SUCCESS";
            newResult.duration = "1m 32s";
            newResult.passed = 9;
            calculateSummary();
        }, 3000);
    };

    const viewDetails = (result: any) => {
        selectedResult.value = result;
    };

    const closeDetails = () => {
        selectedResult.value = null;
    };

    const downloadLogs = (result: any) => {
        console.log("Downloading logs for:", result.id);
    // Simulate log download
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

    const getProgressBarClass = (rate: number) => {
        if (rate >= 0.9) return "bg-success";
        if (rate >= 0.7) return "bg-warning";
        return "bg-danger";
    };

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleString();
    };
</script>

<style scoped>
.test-results {
    padding: 1rem;
}

.progress {
    min-width: 100px;
}

.modal.show {
    display: block !important;
}
</style>
