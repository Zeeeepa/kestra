import {computed, ref} from "vue";
import {defineStore} from "pinia";
import {useAxios} from "../utils/axios";
import {apiUrl} from "override/utils/route";
import {makeToast} from "../utils/toast";
import {globalI18n} from "../translations/i18n";
import {useAuthStore} from "override/stores/auth";
import {useRoute} from "vue-router";
import {defaultNamespace} from "../composables/useNamespaces.ts";

interface AppInput {
    id: string;
    type: string;
    required?: boolean;
    defaults?: any;
    description?: string;
}

interface AppConfig {
    theme?: string;
    layout?: string;
    permissions?: string[];
    settings?: Record<string, any>;
}

interface App {
    id: string;
    namespace: string;
    name: string;
    description?: string;
    type: "form" | "dashboard" | "workflow-trigger" | "custom";
    status: "active" | "inactive" | "draft";
    source: string;
    revision?: number;
    labels?: Record<string, string | boolean>;
    inputs?: AppInput[];
    config?: AppConfig;
    createdAt: Date;
    updatedAt: Date;
    createdBy?: string;
    updatedBy?: string;
    executionCount?: number;
    lastExecutionDate?: Date;
}

interface AppExecution {
    id: string;
    appId: string;
    namespace: string;
    status: "running" | "success" | "failed" | "cancelled";
    startDate: Date;
    endDate?: Date;
    duration?: number;
    inputs?: Record<string, any>;
    outputs?: Record<string, any>;
    logs?: string[];
    error?: string;
}

interface AppValidations {
    constraints?: string;
    outdated?: boolean;
    infos?: string[];
    warnings?: string[];
    deprecationPaths?: string[];
}

export const useAppStore = defineStore("app", () => {
    const apps = ref<App[]>([]);
    const app = ref<App>();
    const appExecutions = ref<AppExecution[]>([]);
    const total = ref<number>(0);
    const overallTotal = ref<number>();
    const revisions = ref<any[]>();
    const appValidation = ref<AppValidations>();
    const metrics = ref<any[]>();
    const executeAppLoading = ref<boolean>(false);
    const lastSaveApp = ref<string>();
    const isCreating = ref<boolean>(false);
    const appYaml = ref<string>("");
    const appYamlOrigin = ref<string>("");
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
        return app.value !== undefined && !isCreating.value;
    });

    const canSave = computed(() => {
        return haveChange.value && appYaml.value && appYaml.value.trim() !== "";
    });

    const appStats = computed(() => {
        if (!apps.value) return {total: 0, active: 0, inactive: 0, draft: 0};
        
        return {
            total: apps.value.length,
            active: apps.value.filter(app => app.status === "active").length,
            inactive: apps.value.filter(app => app.status === "inactive").length,
            draft: apps.value.filter(app => app.status === "draft").length
        };
    });

    // Actions
    async function findApps(options: any = {}) {
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
            const response = await axios.get(apiUrl("apps"), {params});
            
            apps.value = response.data.results || [];
            total.value = response.data.total || 0;
            
            return response.data;
        } catch (error) {
            console.error("Error fetching apps:", error);
            makeToast(t("error.fetch_apps"), "error");
            apps.value = [];
            total.value = 0;
            return {results: [], total: 0};
        }
    }

    async function findApp(namespace: string, id: string, revision?: number) {
        try {
            const params = revision ? {revision} : {};
            const response = await axios.get(apiUrl(`apps/${namespace}/${id}`), {params});
            
            app.value = response.data;
            appYaml.value = response.data.source || "";
            appYamlOrigin.value = appYaml.value;
            haveChange.value = false;
            
            return response.data;
        } catch (error) {
            console.error("Error fetching app:", error);
            makeToast(t("error.fetch_app"), "error");
            throw error;
        }
    }

    async function createApp(appData: Partial<App>) {
        try {
            const response = await axios.post(apiUrl("apps"), appData, {
                headers: {"Content-Type": "application/x-yaml"}
            });
            
            makeToast(t("app.created_successfully"), "success");
            return response.data;
        } catch (error) {
            console.error("Error creating app:", error);
            makeToast(t("error.create_app"), "error");
            throw error;
        }
    }

    async function updateApp(namespace: string, id: string, appData: Partial<App>) {
        try {
            const response = await axios.put(apiUrl(`apps/${namespace}/${id}`), appData, {
                headers: {"Content-Type": "application/x-yaml"}
            });
            
            app.value = response.data;
            appYaml.value = response.data.source || "";
            appYamlOrigin.value = appYaml.value;
            haveChange.value = false;
            
            makeToast(t("app.updated_successfully"), "success");
            return response.data;
        } catch (error) {
            console.error("Error updating app:", error);
            makeToast(t("error.update_app"), "error");
            throw error;
        }
    }

    async function deleteApp(namespace: string, id: string) {
        try {
            await axios.delete(apiUrl(`apps/${namespace}/${id}`));
            
            // Remove from local state
            apps.value = apps.value.filter(a => !(a.namespace === namespace && a.id === id));
            total.value = Math.max(0, total.value - 1);
            
            makeToast(t("app.deleted_successfully"), "success");
        } catch (error) {
            console.error("Error deleting app:", error);
            makeToast(t("error.delete_app"), "error");
            throw error;
        }
    }

    async function executeAppAction(namespace: string, id: string, inputs?: Record<string, any>) {
        try {
            const response = await axios.post(apiUrl(`apps/${namespace}/${id}/execute`), {
                inputs: inputs || {}
            });
            
            makeToast(t("app.execution_started"), "success");
            return response.data;
        } catch (error) {
            console.error("Error executing app:", error);
            makeToast(t("error.execute_app"), "error");
            throw error;
        }
    }

    async function findAppExecutions(namespace: string, id: string, options: any = {}) {
        try {
            const params = {
                size: options.size || 25,
                page: options.page || 1,
                sort: options.sort || "startDate:desc",
                ...options
            };

            const response = await axios.get(apiUrl(`apps/${namespace}/${id}/executions`), {params});
            
            appExecutions.value = response.data.results || [];
            return response.data;
        } catch (error) {
            console.error("Error fetching app executions:", error);
            makeToast(t("error.fetch_app_executions"), "error");
            return {results: [], total: 0};
        }
    }

    async function validateApp(source: string) {
        try {
            const response = await axios.post(apiUrl("apps/validate"), source, {
                headers: {"Content-Type": "application/x-yaml"}
            });
            
            appValidation.value = response.data;
            return response.data;
        } catch (error) {
            console.error("Error validating app:", error);
            appValidation.value = {constraints: "Validation failed"};
            return appValidation.value;
        }
    }

    async function loadRevisions(namespace: string, id: string) {
        try {
            const response = await axios.get(apiUrl(`apps/${namespace}/${id}/revisions`));
            revisions.value = response.data;
            return response.data;
        } catch (error) {
            console.error("Error loading app revisions:", error);
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

            const response = await axios.get(apiUrl(`apps/${namespace}/${id}/metrics`), {params});
            metrics.value = response.data;
            return response.data;
        } catch (error) {
            console.error("Error loading app metrics:", error);
            metrics.value = [];
            return [];
        }
    }

    function updateAppYaml(yaml: string) {
        appYaml.value = yaml;
        haveChange.value = yaml !== appYamlOrigin.value;
    }

    function resetApp() {
        app.value = undefined;
        appYaml.value = "";
        appYamlOrigin.value = "";
        haveChange.value = false;
        isCreating.value = false;
        appValidation.value = undefined;
        revisions.value = [];
        metrics.value = [];
        appExecutions.value = [];
    }

    return {
        // State
        apps,
        app,
        appExecutions,
        total,
        overallTotal,
        revisions,
        appValidation,
        metrics,
        executeAppLoading,
        lastSaveApp,
        isCreating,
        appYaml,
        appYamlOrigin,
        haveChange,
        metadata,

        // Computed
        isEdit,
        canSave,
        appStats,

        // Actions
        findApps,
        findApp,
        createApp,
        updateApp,
        deleteApp,
        executeApp: executeAppAction,
        findAppExecutions,
        validateApp,
        loadRevisions,
        loadMetrics,
        updateAppYaml,
        resetApp
    };
});
