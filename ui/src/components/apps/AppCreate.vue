<template>
    <div class="app-create">
        <div class="card">
            <div class="card-header">
                <h3>Create New App</h3>
            </div>
            <div class="card-body">
                <form @submit.prevent="createApp">
                    <div class="mb-3">
                        <label for="appName" class="form-label">App Name</label>
                        <input 
                            id="appName"
                            v-model="appData.name" 
                            type="text" 
                            class="form-control" 
                            required 
                        >
                    </div>
                    
                    <div class="mb-3">
                        <label for="appNamespace" class="form-label">Namespace</label>
                        <input 
                            id="appNamespace"
                            v-model="appData.namespace" 
                            type="text" 
                            class="form-control" 
                            required 
                        >
                    </div>
                    
                    <div class="mb-3">
                        <label for="appDescription" class="form-label">Description</label>
                        <textarea 
                            id="appDescription"
                            v-model="appData.description" 
                            class="form-control" 
                            rows="3"
                        />
                    </div>
                    
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary" :disabled="loading">
                            <span v-if="loading" class="spinner-border spinner-border-sm me-2" />
                            Create App
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

    const appData = reactive({
        name: "",
        namespace: "",
        description: ""
    });

    const emit = defineEmits<{
        created: [app: any]
    }>();

    const createApp = async () => {
        loading.value = true;
        try {
            // Simulate app creation - replace with actual API call
            const newApp = {
                id: Date.now().toString(),
                ...appData,
                createdAt: new Date().toISOString()
            };
        
            emit("created", newApp);
            router.push("/apps");
        } catch (error) {
            console.error("Failed to create app:", error);
        } finally {
            loading.value = false;
        }
    };

    const cancel = () => {
        router.push("/apps");
    };
</script>

<style scoped>
.app-create {
    max-width: 600px;
    margin: 0 auto;
    padding: 2rem;
}
</style>
