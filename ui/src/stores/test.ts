import {computed, ref} from "vue";
import {defineStore} from "pinia";
import {useAxios} from "../utils/axios";
import {apiUrl} from "override/utils/route";
import {makeToast} from "../utils/toast";
import {globalI18n} from "../translations/i18n";
import {useAuthStore} from "override/stores/auth";
import {useRoute} from "vue-router";
import {defaultNamespace} from "../composables/useNamespaces.ts";

interface TestAssertion {
    type: 'equals' | 'contains' | 'not_null' | 'greater_than' | 'less_than' | 'regex' | 'custom';
    field: string;
    expected?: any;
    operator?: string;
    message?: string;
}

interface TestCase {
    id: string;
    name: string;
    description?: string;
    inputs?: Record<string, any>;
    assertions: TestAssertion[];
    timeout?: number;
    retries?: number;
    tags?: string[];
}

interface TestSuite {
    id: string;
    namespace: string;
    name: string;
    description?: string;
    flowId: string;
    flowRevision?: number;
    testCases: TestCase[];
    labels?: Record<string, string | boolean>;
    source: string;
    revision?: number;
    createdAt: Date;
    updatedAt: Date;
    createdBy?: string;
    updatedBy?: string;
    lastRunDate?: Date;
    totalRuns?: number;
    successRate?: number;
}

interface TestResult {
    id: string;
    testSuiteId: string;
    testCaseId: string;
    namespace: string;
    status: 'running' | 'passed' | 'failed' | 'skipped' | 'error';
    startDate: Date;
    endDate?: Date;
    duration?: number;
    executionId?: string;
    inputs?: Record<string, any>;
    outputs?: Record<string, any>;
    assertions?: {
        assertion: TestAssertion;
        result: boolean;
        actual?: any;
        message?: string;
    }[];
    error?: string;
    logs?: string[];
}

interface TestExecution {
    id: string;
    testSuiteId: string;
    namespace: string;
    status: 'running' | 'passed' | 'failed' | 'cancelled' | 'error';
    startDate: Date;
    endDate?: Date;
    duration?: number;
    totalTests: number;
    passedTests: number;
    failedTests: number;
    skippedTests: number;
    results: TestResult[];
    triggeredBy?: string;
    cicdContext?: {
        branch?: string;
        commit?: string;
        pullRequest?: string;
        pipeline?: string;
    };
}

interface TestValidations {
    constraints?: string;
    outdated?: boolean;
    infos?: string[];
    warnings?: string[];
    deprecationPaths?: string[];
}

export const useTestStore = defineStore("test", () => {
    const testSuites = ref<TestSuite[]>([]);
    const testSuite = ref<TestSuite>();
    const testExecutions = ref<TestExecution[]>([]);
    const testResults = ref<TestResult[]>([]);
    const total = ref<number>(0);
    const overallTotal = ref<number>();
    const revisions = ref<any[]>();
    const testValidation = ref<TestValidations>();
    const metrics = ref<any[]>();
    const executeTest = ref<boolean>(false);
    const lastSaveTest = ref<string>();
    const isCreating = ref<boolean>(false);
    const testYaml = ref<string>("");
    const testYamlOrigin = ref<string>("");
    const haveChange = ref<boolean>(false);
    const metadata = ref<Record<string, any>>();

    const axios = useAxios();

    const t = (key: string, values?: Record<string, any>) => {
        if (!globalI18n.value) {
            return key;
        }
        return globalI18n.value.t(key, values);
    };

    // Computed properties
    const isEdit = computed(() => {
        return testSuite.value !== undefined && !isCreating.value;
    });

    const canSave = computed(() => {
        return haveChange.value && testYaml.value && testYaml.value.trim() !== "";
    });

    const testStats = computed(() => {
        if (!testExecutions.value) return { total: 0, passed: 0, failed: 0, running: 0 };
        
        const recent = testExecutions.value.slice(0, 10); // Last 10 executions
        return {
            total: recent.length,
            passed: recent.filter(exec => exec.status === 'passed').length,
            failed: recent.filter(exec => exec.status === 'failed').length,
            running: recent.filter(exec => exec.status === 'running').length
        };
    });

    const overallTestStats = computed(() => {
        if (!testSuites.value) return { total: 0, avgSuccessRate: 0, totalRuns: 0 };
        
        const totalRuns = testSuites.value.reduce((sum, suite) => sum + (suite.totalRuns || 0), 0);
        const avgSuccessRate = testSuites.value.length > 0 
            ? testSuites.value.reduce((sum, suite) => sum + (suite.successRate || 0), 0) / testSuites.value.length
            : 0;
        
        return {
            total: testSuites.value.length,
            avgSuccessRate: Math.round(avgSuccessRate * 100) / 100,
            totalRuns
        };
    });

    // Actions
    async function findTestSuites(options: any = {}) {
        const route = useRoute();
        const authStore = useAuthStore();
        
        const params = {
            size: options.size || 25,
            page: options.page || 1,
            sort: options.sort || "name:asc",
            ...options
        };

        if (route.query.namespace) {
            params.namespace = route.query.namespace;
        } else if (authStore.user?.defaultNamespace) {
            params.namespace = authStore.user.defaultNamespace;
        } else {
            params.namespace = defaultNamespace();
        }

        try {
            const response = await axios.get(apiUrl("tests"), { params });
            
            testSuites.value = response.data.results || [];
            total.value = response.data.total || 0;
            
            return response.data;
        } catch (error) {
            console.error("Error fetching test suites:", error);
            makeToast(t("error.fetch_tests"), "error");
            testSuites.value = [];
            total.value = 0;
            return { results: [], total: 0 };
        }
    }

    async function findTestSuite(namespace: string, id: string, revision?: number) {
        try {
            const params = revision ? { revision } : {};
            const response = await axios.get(apiUrl(`tests/${namespace}/${id}`), { params });
            
            testSuite.value = response.data;
            testYaml.value = response.data.source || "";
            testYamlOrigin.value = testYaml.value;
            haveChange.value = false;
            
            return response.data;
        } catch (error) {
            console.error("Error fetching test suite:", error);
            makeToast(t("error.fetch_test"), "error");
            throw error;
        }
    }

    async function createTestSuite(testData: Partial<TestSuite>) {
        try {
            const response = await axios.post(apiUrl("tests"), testData, {
                headers: { "Content-Type": "application/x-yaml" }
            });
            
            makeToast(t("test.created_successfully"), "success");
            return response.data;
        } catch (error) {
            console.error("Error creating test suite:", error);
            makeToast(t("error.create_test"), "error");
            throw error;
        }
    }

    async function updateTestSuite(namespace: string, id: string, testData: Partial<TestSuite>) {
        try {
            const response = await axios.put(apiUrl(`tests/${namespace}/${id}`), testData, {
                headers: { "Content-Type": "application/x-yaml" }
            });
            
            testSuite.value = response.data;
            testYaml.value = response.data.source || "";
            testYamlOrigin.value = testYaml.value;
            haveChange.value = false;
            
            makeToast(t("test.updated_successfully"), "success");
            return response.data;
        } catch (error) {
            console.error("Error updating test suite:", error);
            makeToast(t("error.update_test"), "error");
            throw error;
        }
    }

    async function deleteTestSuite(namespace: string, id: string) {
        try {
            await axios.delete(apiUrl(`tests/${namespace}/${id}`));
            
            // Remove from local state
            testSuites.value = testSuites.value.filter(t => !(t.namespace === namespace && t.id === id));
            total.value = Math.max(0, total.value - 1);
            
            makeToast(t("test.deleted_successfully"), "success");
        } catch (error) {
            console.error("Error deleting test suite:", error);
            makeToast(t("error.delete_test"), "error");
            throw error;
        }
    }

    async function executeTestSuite(namespace: string, id: string, options?: { testCases?: string[], cicdContext?: any }) {
        try {
            const response = await axios.post(apiUrl(`tests/${namespace}/${id}/execute`), {
                testCases: options?.testCases || [],
                cicdContext: options?.cicdContext || {}
            });
            
            makeToast(t("test.execution_started"), "success");
            return response.data;
        } catch (error) {
            console.error("Error executing test suite:", error);
            makeToast(t("error.execute_test"), "error");
            throw error;
        }
    }

    async function findTestExecutions(namespace: string, id: string, options: any = {}) {
        try {
            const params = {
                size: options.size || 25,
                page: options.page || 1,
                sort: options.sort || "startDate:desc",
                ...options
            };

            const response = await axios.get(apiUrl(`tests/${namespace}/${id}/executions`), { params });
            
            testExecutions.value = response.data.results || [];
            return response.data;
        } catch (error) {
            console.error("Error fetching test executions:", error);
            makeToast(t("error.fetch_test_executions"), "error");
            return { results: [], total: 0 };
        }
    }

    async function findTestResults(executionId: string) {
        try {
            const response = await axios.get(apiUrl(`tests/executions/${executionId}/results`));
            
            testResults.value = response.data.results || [];
            return response.data;
        } catch (error) {
            console.error("Error fetching test results:", error);
            makeToast(t("error.fetch_test_results"), "error");
            return { results: [], total: 0 };
        }
    }

    async function validateTestSuite(source: string) {
        try {
            const response = await axios.post(apiUrl("tests/validate"), source, {
                headers: { "Content-Type": "application/x-yaml" }
            });
            
            testValidation.value = response.data;
            return response.data;
        } catch (error) {
            console.error("Error validating test suite:", error);
            testValidation.value = { constraints: "Validation failed" };
            return testValidation.value;
        }
    }

    async function loadRevisions(namespace: string, id: string) {
        try {
            const response = await axios.get(apiUrl(`tests/${namespace}/${id}/revisions`));
            revisions.value = response.data;
            return response.data;
        } catch (error) {
            console.error("Error loading test revisions:", error);
            revisions.value = [];
            return [];
        }
    }

    async function loadMetrics(namespace: string, id: string, options: any = {}) {
        try {
            const params = {
                startDate: options.startDate,
                endDate: options.endDate,
                ...options
            };

            const response = await axios.get(apiUrl(`tests/${namespace}/${id}/metrics`), { params });
            metrics.value = response.data;
            return response.data;
        } catch (error) {
            console.error("Error loading test metrics:", error);
            metrics.value = [];
            return [];
        }
    }

    async function runTestsForFlow(namespace: string, flowId: string, options?: { revision?: number }) {
        try {
            const response = await axios.post(apiUrl(`tests/flows/${namespace}/${flowId}/run`), {
                revision: options?.revision
            });
            
            makeToast(t("test.flow_tests_started"), "success");
            return response.data;
        } catch (error) {
            console.error("Error running tests for flow:", error);
            makeToast(t("error.run_flow_tests"), "error");
            throw error;
        }
    }

    async function generateTestsFromFlow(namespace: string, flowId: string, options?: { revision?: number, testTypes?: string[] }) {
        try {
            const response = await axios.post(apiUrl(`tests/generate`), {
                namespace,
                flowId,
                revision: options?.revision,
                testTypes: options?.testTypes || ['smoke', 'integration']
            });
            
            makeToast(t("test.generated_successfully"), "success");
            return response.data;
        } catch (error) {
            console.error("Error generating tests:", error);
            makeToast(t("error.generate_tests"), "error");
            throw error;
        }
    }

    function updateTestYaml(yaml: string) {
        testYaml.value = yaml;
        haveChange.value = yaml !== testYamlOrigin.value;
    }

    function resetTest() {
        testSuite.value = undefined;
        testYaml.value = "";
        testYamlOrigin.value = "";
        haveChange.value = false;
        isCreating.value = false;
        testValidation.value = undefined;
        revisions.value = [];
        metrics.value = [];
        testExecutions.value = [];
        testResults.value = [];
    }

    return {
        // State
        testSuites,
        testSuite,
        testExecutions,
        testResults,
        total,
        overallTotal,
        revisions,
        testValidation,
        metrics,
        executeTest,
        lastSaveTest,
        isCreating,
        testYaml,
        testYamlOrigin,
        haveChange,
        metadata,

        // Computed
        isEdit,
        canSave,
        testStats,
        overallTestStats,

        // Actions
        findTestSuites,
        findTestSuite,
        createTestSuite,
        updateTestSuite,
        deleteTestSuite,
        executeTestSuite,
        findTestExecutions,
        findTestResults,
        validateTestSuite,
        loadRevisions,
        loadMetrics,
        runTestsForFlow,
        generateTestsFromFlow,
        updateTestYaml,
        resetTest
    };
});
