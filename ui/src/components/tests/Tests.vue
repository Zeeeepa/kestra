<template>
    <div class="tests">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2>Test Suites</h2>
                        <router-link to="/tests/new" class="btn btn-primary">
                            <i class="fas fa-plus me-2" />
                            Create Test Suite
                        </router-link>
                    </div>
                    
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Name</th>
                                            <th>Namespace</th>
                                            <th>Test Cases</th>
                                            <th>Success Rate</th>
                                            <th>Last Run</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="test in tests" :key="test.id">
                                            <td>
                                                <router-link 
                                                    :to="`/tests/edit/${test.namespace}/${test.id}`"
                                                    class="text-decoration-none"
                                                >
                                                    {{ test.name }}
                                                </router-link>
                                            </td>
                                            <td>{{ test.namespace }}</td>
                                            <td>{{ test.testCaseCount }}</td>
                                            <td>
                                                <span 
                                                    class="badge"
                                                    :class="getSuccessRateBadgeClass(test.successRate)"
                                                >
                                                    {{ (test.successRate * 100).toFixed(1) }}%
                                                </span>
                                            </td>
                                            <td>{{ formatDate(test.lastRunDate) }}</td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <button 
                                                        class="btn btn-outline-primary"
                                                        @click="runTest(test)"
                                                    >
                                                        Run
                                                    </button>
                                                    <router-link 
                                                        :to="`/tests/${test.namespace}/${test.id}/results`"
                                                        class="btn btn-outline-info"
                                                    >
                                                        Results
                                                    </router-link>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr v-if="tests.length === 0">
                                            <td colspan="6" class="text-center text-muted py-4">
                                                No test suites found. 
                                                <router-link to="/tests/new">
                                                    Create your first test suite
                                                </router-link>
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
</template>

<script setup lang="ts">
    import {ref, onMounted} from "vue";

    interface TestSuite {
        id: string;
        name: string;
        namespace: string;
        testCaseCount: number;
        successRate: number;
        lastRunDate: string;
    }

    const tests = ref<TestSuite[]>([
        {
            id: "test-001",
            name: "API Integration Tests",
            namespace: "default",
            testCaseCount: 15,
            successRate: 0.93,
            lastRunDate: new Date().toISOString()
        },
        {
            id: "test-002",
            name: "Data Pipeline Tests",
            namespace: "data",
            testCaseCount: 8,
            successRate: 1.0,
            lastRunDate: new Date(Date.now() - 86400000).toISOString()
        }
    ]);

    onMounted(() => {
        loadTests();
    });

    const loadTests = async () => {
        // Simulate API call to load tests
        console.log("Loading test suites...");
    };

    const runTest = async (test: TestSuite) => {
        console.log("Running test:", test.name);
    // Simulate test execution
    };

    const getSuccessRateBadgeClass = (rate: number) => {
        if (rate >= 0.9) return "bg-success";
        if (rate >= 0.7) return "bg-warning";
        return "bg-danger";
    };

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleDateString();
    };
</script>

<style scoped>
.tests {
    padding: 1rem;
}
</style>
