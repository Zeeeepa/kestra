<template>
    <TopNavBar :title="routeInfo.title">
        <template #additional-right>
            <ul>
                <li>
                    <el-button :icon="Upload" @click="file?.click()">
                        {{ $t("import") }}
                    </el-button>
                    <input
                        ref="file"
                        type="file"
                        accept=".zip, .yml, .yaml"
                        @change="importApps()"
                        class="d-none"
                    >
                </li>
                <li>
                    <router-link :to="{name: 'apps/search'}">
                        <el-button :icon="TextBoxSearch">
                            {{ $t("source search") }}
                        </el-button>
                    </router-link>
                </li>
                <li>
                    <router-link
                        :to="{
                            name: 'apps/create',
                            query: {namespace: $route.query.namespace},
                        }"
                        v-if="canCreate"
                    >
                        <el-button :icon="Plus" type="primary">
                            {{ $t("create") }}
                        </el-button>
                    </router-link>
                </li>
            </ul>
        </template>
    </TopNavBar>
    <section
        data-component="FILENAME_PLACEHOLDER"
        :class="{container: true}"
        v-if="ready"
    >
        <div>
            <DataTable
                @page-changed="onPageChanged"
                ref="dataTable"
                :total="appStore.total"
                :hideTopPagination="!!namespace"
            >
                <template #navbar>
                    <KestraFilter
                        prefix="apps"
                        :language="AppFilterLanguage"
                        :buttons="{
                            refresh: {shown: false},
                            settings: {shown: false}
                        }"
                        :properties="{
                            shown: true,
                            columns: optionalColumns,
                            displayColumns,
                            storageKey: 'apps',
                        }"
                        @update-properties="updateDisplayColumns"
                    />
                </template>

                <template #table>
                    <SelectTable
                        ref="selectTable"
                        :data="appStore.apps"
                        :defaultSort="{prop: 'name', order: 'ascending'}"
                        tableLayout="auto"
                        fixed
                        @row-dblclick="onRowDoubleClick"
                        @sort-change="onSort"
                        :rowClassName="rowClasses"
                        @selection-change="handleSelectionChange"
                        :selectable="canCheck"
                        :no-data-text="$t('no_results.apps')"
                        class="apps-table"
                    >
                        <template #select-actions>
                            <BulkSelect
                                :selectAll="queryBulkAction"
                                :selections="selection"
                                :total="appStore.total"
                                @update:select-all="toggleAllSelection"
                                @unselect="toggleAllUnselected"
                            >
                                <el-button
                                    v-if="canRead"
                                    :icon="Download"
                                    @click="exportApps()"
                                >
                                    {{ $t("export") }}
                                </el-button>
                                <el-button
                                    v-if="canDelete"
                                    @click="deleteApps"
                                    :icon="TrashCan"
                                >
                                    {{ $t("delete") }}
                                </el-button>
                                <el-button
                                    v-if="canUpdate && anyAppInactive()"
                                    @click="activateApps"
                                    :icon="FileDocumentCheckOutline"
                                >
                                    {{ $t("activate") }}
                                </el-button>
                                <el-button
                                    v-if="canUpdate && anyAppActive()"
                                    @click="deactivateApps"
                                    :icon="FileDocumentRemoveOutline"
                                >
                                    {{ $t("deactivate") }}
                                </el-button>
                            </BulkSelect>
                        </template>
                        <template #default>
                            <el-table-column
                                prop="name"
                                sortable="custom"
                                :sortOrders="['ascending', 'descending']"
                                :label="$t('name')"
                            >
                                <template #default="scope">
                                    <div class="app-name">
                                        <router-link
                                            :to="{
                                                name: 'apps/update',
                                                params: {
                                                    namespace: scope.row.namespace,
                                                    id: scope.row.id,
                                                },
                                            }"
                                            class="me-1"
                                        >
                                            {{
                                                $filters.invisibleSpace(
                                                    scope.row.name,
                                                )
                                            }}
                                        </router-link>
                                        <MarkdownTooltip
                                            :id="
                                                scope.row.namespace +
                                                    '-' +
                                                    scope.row.id
                                            "
                                            :description="scope.row.description"
                                            :title="
                                                scope.row.namespace +
                                                    '.' +
                                                    scope.row.id
                                            "
                                        />
                                    </div>
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="type"
                                v-if="displayColumn('type')"
                                :label="$t('type')"
                                width="120"
                            >
                                <template #default="scope">
                                    <el-tag :type="getAppTypeColor(scope.row.type)" size="small">
                                        {{ $t(`apps.types.${scope.row.type}`) }}
                                    </el-tag>
                                </template>
                            </el-table-column>

                            <el-table-column
                                v-if="displayColumn('labels')"
                                :label="$t('labels')"
                            >
                                <template #default="scope">
                                    <Labels :labels="scope.row.labels" />
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="namespace"
                                v-if="displayColumn('namespace')"
                                sortable="custom"
                                :sortOrders="['ascending', 'descending']"
                                :label="$t('namespace')"
                                :formatter="
                                    (_, __, cellValue) =>
                                        $filters.invisibleSpace(cellValue)
                                "
                            />

                            <el-table-column
                                prop="status"
                                v-if="displayColumn('status')"
                                :label="$t('status')"
                                width="100"
                            >
                                <template #default="scope">
                                    <Status :status="scope.row.status" size="small" />
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="lastExecutionDate"
                                v-if="displayColumn('lastExecutionDate')"
                                :label="$t('last execution date')"
                                width="180"
                            >
                                <template #default="scope">
                                    <DateAgo
                                        v-if="scope.row.lastExecutionDate"
                                        :inverted="true"
                                        :date="scope.row.lastExecutionDate"
                                    />
                                    <span v-else class="text-muted">{{ $t('never') }}</span>
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="executionCount"
                                v-if="displayColumn('executionCount')"
                                :label="$t('executions')"
                                width="100"
                                align="right"
                            >
                                <template #default="scope">
                                    <span class="text-muted">{{ scope.row.executionCount || 0 }}</span>
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="updatedAt"
                                v-if="displayColumn('updatedAt')"
                                :label="$t('updated')"
                                width="180"
                            >
                                <template #default="scope">
                                    <DateAgo
                                        :inverted="true"
                                        :date="scope.row.updatedAt"
                                    />
                                </template>
                            </el-table-column>

                            <el-table-column :label="$t('actions')" width="80" fixed="right">
                                <template #default="scope">
                                    <el-dropdown @command="handleAppAction">
                                        <el-button size="small" text>
                                            <DotsVertical />
                                        </el-button>
                                        <template #dropdown>
                                            <el-dropdown-menu>
                                                <el-dropdown-item :command="{action: 'execute', app: scope.row}">
                                                    <Play class="me-2" />
                                                    {{ $t('execute') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'edit', app: scope.row}">
                                                    <Pencil class="me-2" />
                                                    {{ $t('edit') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'duplicate', app: scope.row}">
                                                    <ContentDuplicate class="me-2" />
                                                    {{ $t('duplicate') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'delete', app: scope.row}" divided>
                                                    <TrashCan class="me-2" />
                                                    {{ $t('delete') }}
                                                </el-dropdown-item>
                                            </el-dropdown-menu>
                                        </template>
                                    </el-dropdown>
                                </template>
                            </el-table-column>
                        </template>
                    </SelectTable>
                </template>
            </DataTable>
        </div>
    </section>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted, watch} from "vue";
    import {useI18n} from "vue-i18n";
    import {useRoute, useRouter} from "vue-router";
    import {ElMessage, ElMessageBox} from "element-plus";
    import {storeToRefs, mapStores} from "pinia";
    
    // Components
    import TopNavBar from "../layout/TopNavBar.vue";
    import DataTable from "../layout/DataTable.vue";
    import SelectTable from "../layout/SelectTable.vue";
    import BulkSelect from "../layout/BulkSelect.vue";
    import KestraFilter from "../filter/KestraFilter.vue";
    import Labels from "../misc/Labels.vue";
    import Status from "../misc/Status.vue";
    import DateAgo from "../misc/DateAgo.vue";
    import MarkdownTooltip from "../misc/MarkdownTooltip.vue";
    
    // Icons
    import Plus from "vue-material-design-icons/Plus.vue";
    import Upload from "vue-material-design-icons/Upload.vue";
    import Download from "vue-material-design-icons/Download.vue";
    import TextBoxSearch from "vue-material-design-icons/TextBoxSearch.vue";
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import Play from "vue-material-design-icons/Play.vue";
    import Pencil from "vue-material-design-icons/Pencil.vue";
    import ContentDuplicate from "vue-material-design-icons/ContentDuplicate.vue";
    import TrashCan from "vue-material-design-icons/TrashCan.vue";
    import FileDocumentCheckOutline from "vue-material-design-icons/FileDocumentCheckOutline.vue";
    import FileDocumentRemoveOutline from "vue-material-design-icons/FileDocumentRemoveOutline.vue";
    
    // Stores and composables
    import {useAppStore} from "../../stores/app";
    import {useCoreStore} from "../../stores/core";
    import {useAuthStore} from "override/stores/auth";
    import useRouteContext from "../../mixins/useRouteContext";
    import permission from "../../models/permission";
    import action from "../../models/action";
    
    // Filter language
    import {AppFilterLanguage} from "../../composables/monaco/languages/filters/appFilterLanguage";

    const {t} = useI18n();
    const route = useRoute();
    const router = useRouter();
    const appStore = useAppStore();
    const coreStore = useCoreStore();
    const authStore = useAuthStore();

    // Route context
    const routeInfo = ref({
        title: t("apps"),
    });
    useRouteContext(routeInfo);

    // Reactive state
    const ready = ref(false);
    const namespace = computed(() => route.query.namespace as string);
    const file = ref<HTMLInputElement>();
    const dataTable = ref();
    const selectTable = ref();
    const selection = ref([]);

    // Display columns configuration
    const optionalColumns = [
        { key: "type", label: t("type") },
        { key: "labels", label: t("labels") },
        { key: "namespace", label: t("namespace") },
        { key: "status", label: t("status") },
        { key: "lastExecutionDate", label: t("last execution date") },
        { key: "executionCount", label: t("executions") },
        { key: "updatedAt", label: t("updated") },
    ];

    const displayColumns = ref(
        JSON.parse(localStorage.getItem("apps-display-columns") || JSON.stringify([
            "type", "namespace", "status", "lastExecutionDate", "executionCount", "updatedAt"
        ]))
    );

    // Computed properties
    const canCreate = computed(() => {
        return authStore.user?.isAllowed(permission.APP, action.CREATE, namespace.value);
    });

    const canRead = computed(() => {
        return authStore.user?.isAllowed(permission.APP, action.READ, namespace.value);
    });

    const canUpdate = computed(() => {
        return authStore.user?.isAllowed(permission.APP, action.UPDATE, namespace.value);
    });

    const canDelete = computed(() => {
        return authStore.user?.isAllowed(permission.APP, action.DELETE, namespace.value);
    });

    const canCheck = computed(() => {
        return canUpdate.value || canDelete.value;
    });

    const queryBulkAction = computed(() => {
        return route.query.bulk === "true";
    });

    // Methods
    function displayColumn(column: string) {
        return displayColumns.value.includes(column);
    }

    function updateDisplayColumns(columns: string[]) {
        displayColumns.value = columns;
        localStorage.setItem("apps-display-columns", JSON.stringify(columns));
    }

    function getAppTypeColor(type: string) {
        switch (type) {
            case 'form': return 'primary';
            case 'dashboard': return 'success';
            case 'workflow-trigger': return 'warning';
            case 'custom': return 'info';
            default: return '';
        }
    }

    function rowClasses({row}: {row: any}) {
        const classes = [];
        if (row.status === 'inactive') {
            classes.push('app-inactive');
        }
        return classes.join(' ');
    }

    async function onPageChanged(stats: any) {
        await loadApps({
            page: stats.page,
            size: stats.size,
            sort: stats.sort,
            q: stats.q
        });
    }

    function onRowDoubleClick(row: any) {
        router.push({
            name: "apps/update",
            params: {
                namespace: row.namespace,
                id: row.id,
            },
        });
    }

    async function onSort({prop, order}: {prop: string, order: string}) {
        const sort = order === 'ascending' ? `${prop}:asc` : `${prop}:desc`;
        await loadApps({
            sort,
            page: 1
        });
    }

    function handleSelectionChange(val: any[]) {
        selection.value = val;
    }

    function toggleAllSelection(selectAll: boolean) {
        if (selectAll) {
            selectTable.value?.toggleAllSelection();
        } else {
            selectTable.value?.clearSelection();
        }
    }

    function toggleAllUnselected() {
        selectTable.value?.clearSelection();
    }

    async function handleAppAction({action: actionType, app}: {action: string, app: any}) {
        switch (actionType) {
            case 'execute':
                await executeApp(app);
                break;
            case 'edit':
                router.push({
                    name: "apps/update",
                    params: {
                        namespace: app.namespace,
                        id: app.id,
                    },
                });
                break;
            case 'duplicate':
                router.push({
                    name: "apps/create",
                    query: {
                        copy: true,
                        namespace: app.namespace,
                        id: app.id,
                    },
                });
                break;
            case 'delete':
                await deleteApp(app);
                break;
        }
    }

    async function executeApp(app: any) {
        try {
            await appStore.executeApp(app.namespace, app.id);
            ElMessage.success(t("app.execution_started"));
        } catch (error) {
            console.error("Error executing app:", error);
        }
    }

    async function deleteApp(app: any) {
        try {
            await ElMessageBox.confirm(
                t("app.delete_confirm", {name: app.name}),
                t("delete"),
                {
                    confirmButtonText: t("delete"),
                    cancelButtonText: t("cancel"),
                    type: "warning",
                }
            );

            await appStore.deleteApp(app.namespace, app.id);
            await loadApps();
        } catch (error) {
            if (error !== "cancel") {
                console.error("Error deleting app:", error);
            }
        }
    }

    async function deleteApps() {
        if (selection.value.length === 0) return;

        try {
            await ElMessageBox.confirm(
                t("app.delete_multiple_confirm", {count: selection.value.length}),
                t("delete"),
                {
                    confirmButtonText: t("delete"),
                    cancelButtonText: t("cancel"),
                    type: "warning",
                }
            );

            for (const app of selection.value) {
                await appStore.deleteApp(app.namespace, app.id);
            }

            await loadApps();
            selectTable.value?.clearSelection();
        } catch (error) {
            if (error !== "cancel") {
                console.error("Error deleting apps:", error);
            }
        }
    }

    function anyAppActive() {
        return selection.value.some((app: any) => app.status === 'active');
    }

    function anyAppInactive() {
        return selection.value.some((app: any) => app.status === 'inactive');
    }

    async function activateApps() {
        // Implementation for bulk activation
        ElMessage.info(t("feature.coming_soon"));
    }

    async function deactivateApps() {
        // Implementation for bulk deactivation
        ElMessage.info(t("feature.coming_soon"));
    }

    async function exportApps() {
        // Implementation for export
        ElMessage.info(t("feature.coming_soon"));
    }

    async function importApps() {
        // Implementation for import
        ElMessage.info(t("feature.coming_soon"));
    }

    async function loadApps(options: any = {}) {
        try {
            await appStore.findApps({
                ...options,
                namespace: namespace.value
            });
        } catch (error) {
            console.error("Error loading apps:", error);
        }
    }

    // Lifecycle
    onMounted(async () => {
        await loadApps();
        ready.value = true;
    });

    // Watchers
    watch(() => route.query, async () => {
        await loadApps();
    });
</script>

<style lang="scss" scoped>
    .apps-table {
        .app-name {
            display: flex;
            align-items: center;
        }

        .app-inactive {
            opacity: 0.6;
        }
    }
</style>

