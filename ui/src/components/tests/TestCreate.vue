<template>
    <div class="test-create">
        <div class="card">
            <div class="card-header">
                <h3>Create New Test Suite</h3>
            </div>
            <div class="card-body">
                <form @submit.prevent="createTest">
                    <div class="mb-3">
                        <label for="testName" class="form-label">Test Suite Name</label>
                        <input 
                            id="testName"
                            v-model="testData.name" 
                            type="text" 
                            class="form-control" 
                            required 
                        >
                    </div>
                    
                    <div class="mb-3">
                        <label for="testNamespace" class="form-label">Namespace</label>
                        <input 
                            id="testNamespace"
                            v-model="testData.namespace" 
                            type="text" 
                            class="form-control" 
                            required 
                        >
                    </div>
                    
                    <div class="mb-3">
                        <label for="testDescription" class="form-label">Description</label>
                        <textarea 
                            id="testDescription"
                            v-model="testData.description" 
                            class="form-control" 
                            rows="3"
                        />
                    </div>
                    
                    <div class="mb-3">
                        <label for="flowId" class="form-label">Associated Flow ID</label>
                        <input 
                            id="flowId"
                            v-model="testData.flowId" 
                            type="text" 
                            class="form-control" 
                            placeholder="Optional: Link to a specific flow"
                        >
                    </div>
                    
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary" :disabled="loading">
                            <span v-if="loading" class="spinner-border spinner-border-sm me-2" />
                            Create Test Suite
                        </button>
                        <button type="button" class="btn btn-secondary" @click="cancel">
                            Cancel
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
    import {ref, reactive} from "vue";
    import {useRouter} from "vue-router";

    const router = useRouter();
    const loading = ref(false);

    const testData = reactive({
        name: "",
        namespace: "",
        description: "",
        flowId: ""
    });

    const emit = defineEmits<{
        created: [test: any]
    }>();

    const createTest = async () => {
        loading.value = true;
        try {
            // Simulate test creation - replace with actual API call
            const newTest = {
                id: Date.now().toString(),
                ...testData,
                createdAt: new Date().toISOString(),
                testCaseCount: 0,
                successRate: 0,
                lastRunDate: null
            };
        
            emit("created", newTest);
            router.push("/tests");
        } catch (error) {
            console.error("Failed to create test suite:", error);
        } finally {
            loading.value = false;
        }
    };

    const cancel = () => {
        router.push("/tests");
    };
</script>

<style scoped>
.test-create {
    max-width: 600px;
    margin: 0 auto;
    padding: 2rem;
}
</style>
