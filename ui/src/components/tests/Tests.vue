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
                        @change="importTests()"
                        class="d-none"
                    >
                </li>
                <li>
                    <router-link :to="{name: 'tests/search'}">
                        <el-button :icon="TextBoxSearch">
                            {{ $t("source search") }}
                        </el-button>
                    </router-link>
                </li>
                <li>
                    <el-button :icon="PlayCircle" @click="runAllTests" type="success">
                        {{ $t("tests.run_all") }}
                    </el-button>
                </li>
                <li>
                    <router-link
                        :to="{
                            name: 'tests/create',
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

    <!-- Test Statistics Dashboard -->
    <section class="container mb-4" v-if="ready">
        <div class="row">
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-primary">{{ testStore.overallTestStats.total }}</h3>
                        <p class="mb-0">{{ $t('tests.total_suites') }}</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-success">{{ testStore.overallTestStats.avgSuccessRate }}%</h3>
                        <p class="mb-0">{{ $t('tests.avg_success_rate') }}</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-info">{{ testStore.overallTestStats.totalRuns }}</h3>
                        <p class="mb-0">{{ $t('tests.total_runs') }}</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-warning">{{ testStore.testStats.running }}</h3>
                        <p class="mb-0">{{ $t('tests.running_now') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section
        data-component="FILENAME_PLACEHOLDER"
        :class="{container: true}"
        v-if="ready"
    >
        <div>
            <DataTable
                @page-changed="onPageChanged"
                ref="dataTable"
                :total="testStore.total"
                :hideTopPagination="!!namespace"
            >
                <template #navbar>
                    <KestraFilter
                        prefix="tests"
                        :language="TestFilterLanguage"
                        :buttons="{
                            refresh: {shown: false},
                            settings: {shown: false}
                        }"
                        :properties="{
                            shown: true,
                            columns: optionalColumns,
                            displayColumns,
                            storageKey: 'tests',
                        }"
                        @update-properties="updateDisplayColumns"
                    />
                </template>

                <template #table>
                    <SelectTable
                        ref="selectTable"
                        :data="testStore.testSuites"
                        :defaultSort="{prop: 'name', order: 'ascending'}"
                        tableLayout="auto"
                        fixed
                        @row-dblclick="onRowDoubleClick"
                        @sort-change="onSort"
                        :rowClassName="rowClasses"
                        @selection-change="handleSelectionChange"
                        :selectable="canCheck"
                        :no-data-text="$t('no_results.tests')"
                        class="tests-table"
                    >
                        <template #select-actions>
                            <BulkSelect
                                :selectAll="queryBulkAction"
                                :selections="selection"
                                :total="testStore.total"
                                @update:select-all="toggleAllSelection"
                                @unselect="toggleAllUnselected"
                            >
                                <el-button
                                    v-if="canRead"
                                    :icon="Download"
                                    @click="exportTests()"
                                >
                                    {{ $t("export") }}
                                </el-button>
                                <el-button
                                    v-if="canUpdate"
                                    :icon="PlayCircle"
                                    @click="runSelectedTests"
                                    type="success"
                                >
                                    {{ $t("tests.run_selected") }}
                                </el-button>
                                <el-button
                                    v-if="canDelete"
                                    @click="deleteTests"
                                    :icon="TrashCan"
                                >
                                    {{ $t("delete") }}
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
                                    <div class="test-name">
                                        <router-link
                                            :to="{
                                                name: 'tests/update',
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
                                prop="flowId"
                                v-if="displayColumn('flowId')"
                                :label="$t('flow')"
                                width="200"
                            >
                                <template #default="scope">
                                    <router-link
                                        :to="{
                                            name: 'flows/update',
                                            params: {
                                                namespace: scope.row.namespace,
                                                id: scope.row.flowId,
                                            },
                                        }"
                                        class="text-primary"
                                    >
                                        {{ scope.row.flowId }}
                                    </router-link>
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
                                prop="testCases"
                                v-if="displayColumn('testCases')"
                                :label="$t('tests.test_cases')"
                                width="100"
                                align="center"
                            >
                                <template #default="scope">
                                    <el-tag size="small" type="info">
                                        {{ scope.row.testCases?.length || 0 }}
                                    </el-tag>
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="successRate"
                                v-if="displayColumn('successRate')"
                                :label="$t('tests.success_rate')"
                                width="120"
                                align="center"
                            >
                                <template #default="scope">
                                    <el-progress
                                        :percentage="Math.round((scope.row.successRate || 0) * 100)"
                                        :color="getSuccessRateColor(scope.row.successRate)"
                                        :stroke-width="6"
                                        text-inside
                                    />
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="lastRunDate"
                                v-if="displayColumn('lastRunDate')"
                                :label="$t('tests.last_run')"
                                width="180"
                            >
                                <template #default="scope">
                                    <DateAgo
                                        v-if="scope.row.lastRunDate"
                                        :inverted="true"
                                        :date="scope.row.lastRunDate"
                                    />
                                    <span v-else class="text-muted">{{ $t('never') }}</span>
                                </template>
                            </el-table-column>

                            <el-table-column
                                prop="totalRuns"
                                v-if="displayColumn('totalRuns')"
                                :label="$t('tests.total_runs')"
                                width="100"
                                align="right"
                            >
                                <template #default="scope">
                                    <span class="text-muted">{{ scope.row.totalRuns || 0 }}</span>
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
                                    <el-dropdown @command="handleTestAction">
                                        <el-button size="small" text>
                                            <DotsVertical />
                                        </el-button>
                                        <template #dropdown>
                                            <el-dropdown-menu>
                                                <el-dropdown-item :command="{action: 'run', test: scope.row}">
                                                    <PlayCircle class="me-2" />
                                                    {{ $t('tests.run') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'results', test: scope.row}">
                                                    <ChartLine class="me-2" />
                                                    {{ $t('tests.view_results') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'edit', test: scope.row}">
                                                    <Pencil class="me-2" />
                                                    {{ $t('edit') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'duplicate', test: scope.row}">
                                                    <ContentDuplicate class="me-2" />
                                                    {{ $t('duplicate') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'delete', test: scope.row}" divided>
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
    
    // Components
    import TopNavBar from "../layout/TopNavBar.vue";
    import DataTable from "../layout/DataTable.vue";
    import SelectTable from "../layout/SelectTable.vue";
    import BulkSelect from "../layout/BulkSelect.vue";
    import KestraFilter from "../filter/KestraFilter.vue";
    import Labels from "../misc/Labels.vue";
    import DateAgo from "../misc/DateAgo.vue";
    import MarkdownTooltip from "../misc/MarkdownTooltip.vue";
    
    // Icons
    import Plus from "vue-material-design-icons/Plus.vue";
    import Upload from "vue-material-design-icons/Upload.vue";
    import Download from "vue-material-design-icons/Download.vue";
    import TextBoxSearch from "vue-material-design-icons/TextBoxSearch.vue";
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import PlayCircle from "vue-material-design-icons/PlayCircle.vue";
    import ChartLine from "vue-material-design-icons/ChartLine.vue";
    import Pencil from "vue-material-design-icons/Pencil.vue";
    import ContentDuplicate from "vue-material-design-icons/ContentDuplicate.vue";
    import TrashCan from "vue-material-design-icons/TrashCan.vue";
    
    // Stores and composables
    import {useTestStore} from "../../stores/test";
    import {useCoreStore} from "../../stores/core";
    import {useAuthStore} from "override/stores/auth";
    import useRouteContext from "../../mixins/useRouteContext";
    import permission from "../../models/permission";
    import action from "../../models/action";
    
    // Filter language
    import {TestFilterLanguage} from "../../composables/monaco/languages/filters/testFilterLanguage";

    const {t} = useI18n();
    const route = useRoute();
    const router = useRouter();
    const testStore = useTestStore();
    const coreStore = useCoreStore();
    const authStore = useAuthStore();

    // Route context
    const routeInfo = ref({
        title: t("tests"),
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
        { key: "flowId", label: t("flow") },
        { key: "labels", label: t("labels") },
        { key: "namespace", label: t("namespace") },
        { key: "testCases", label: t("tests.test_cases") },
        { key: "successRate", label: t("tests.success_rate") },
        { key: "lastRunDate", label: t("tests.last_run") },
        { key: "totalRuns", label: t("tests.total_runs") },
        { key: "updatedAt", label: t("updated") },
    ];

    const displayColumns = ref(
        JSON.parse(localStorage.getItem("tests-display-columns") || JSON.stringify([
            "flowId", "namespace", "testCases", "successRate", "lastRunDate", "totalRuns", "updatedAt"
        ]))
    );

    // Computed properties
    const canCreate = computed(() => {
        return authStore.user?.isAllowed(permission.TEST, action.CREATE, namespace.value);
    });

    const canRead = computed(() => {
        return authStore.user?.isAllowed(permission.TEST, action.READ, namespace.value);
    });

    const canUpdate = computed(() => {
        return authStore.user?.isAllowed(permission.TEST, action.UPDATE, namespace.value);
    });

    const canDelete = computed(() => {
        return authStore.user?.isAllowed(permission.TEST, action.DELETE, namespace.value);
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
        localStorage.setItem("tests-display-columns", JSON.stringify(columns));
    }

    function getSuccessRateColor(rate: number) {
        if (rate >= 0.9) return '#67c23a';
        if (rate >= 0.7) return '#e6a23c';
        return '#f56c6c';
    }

    function rowClasses({row}: {row: any}) {
        const classes = [];
        if (row.successRate < 0.5) {
            classes.push('test-failing');
        }
        return classes.join(' ');
    }

    async function onPageChanged(stats: any) {
        await loadTests({
            page: stats.page,
            size: stats.size,
            sort: stats.sort,
            q: stats.q
        });
    }

    function onRowDoubleClick(row: any) {
        router.push({
            name: "tests/update",
            params: {
                namespace: row.namespace,
                id: row.id,
            },
        });
    }

    async function onSort({prop, order}: {prop: string, order: string}) {
        const sort = order === 'ascending' ? `${prop}:asc` : `${prop}:desc`;
        await loadTests({
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

    async function handleTestAction({action: actionType, test}: {action: string, test: any}) {
        switch (actionType) {
            case 'run':
                await runTest(test);
                break;
            case 'results':
                router.push({
                    name: "tests/results",
                    params: {
                        namespace: test.namespace,
                        id: test.id,
                    },
                });
                break;
            case 'edit':
                router.push({
                    name: "tests/update",
                    params: {
                        namespace: test.namespace,
                        id: test.id,
                    },
                });
                break;
            case 'duplicate':
                router.push({
                    name: "tests/create",
                    query: {
                        copy: true,
                        namespace: test.namespace,
                        id: test.id,
                    },
                });
                break;
            case 'delete':
                await deleteTest(test);
                break;
        }
    }

    async function runTest(test: any) {
        try {
            await testStore.executeTestSuite(test.namespace, test.id);
            ElMessage.success(t("tests.execution_started"));
        } catch (error) {
            console.error("Error running test:", error);
        }
    }

    async function runAllTests() {
        try {
            ElMessage.info(t("tests.running_all_tests"));
            // Implementation for running all tests
        } catch (error) {
            console.error("Error running all tests:", error);
        }
    }

    async function runSelectedTests() {
        if (selection.value.length === 0) return;

        try {
            for (const test of selection.value) {
                await testStore.executeTestSuite(test.namespace, test.id);
            }
            ElMessage.success(t("tests.selected_tests_started"));
        } catch (error) {
            console.error("Error running selected tests:", error);
        }
    }

    async function deleteTest(test: any) {
        try {
            await ElMessageBox.confirm(
                t("tests.delete_confirm", {name: test.name}),
                t("delete"),
                {
                    confirmButtonText: t("delete"),
                    cancelButtonText: t("cancel"),
                    type: "warning",
                }
            );

            await testStore.deleteTestSuite(test.namespace, test.id);
            await loadTests();
        } catch (error) {
            if (error !== "cancel") {
                console.error("Error deleting test:", error);
            }
        }
    }

    async function deleteTests() {
        if (selection.value.length === 0) return;

        try {
            await ElMessageBox.confirm(
                t("tests.delete_multiple_confirm", {count: selection.value.length}),
                t("delete"),
                {
                    confirmButtonText: t("delete"),
                    cancelButtonText: t("cancel"),
                    type: "warning",
                }
            );

            for (const test of selection.value) {
                await testStore.deleteTestSuite(test.namespace, test.id);
            }

            await loadTests();
            selectTable.value?.clearSelection();
        } catch (error) {
            if (error !== "cancel") {
                console.error("Error deleting tests:", error);
            }
        }
    }

    async function exportTests() {
        // Implementation for export
        ElMessage.info(t("feature.coming_soon"));
    }

    async function importTests() {
        // Implementation for import
        ElMessage.info(t("feature.coming_soon"));
    }

    async function loadTests(options: any = {}) {
        try {
            await testStore.findTestSuites({
                ...options,
                namespace: namespace.value
            });
        } catch (error) {
            console.error("Error loading tests:", error);
        }
    }

    // Lifecycle
    onMounted(async () => {
        await loadTests();
        ready.value = true;
    });

    // Watchers
    watch(() => route.query, async () => {
        await loadTests();
    });
</script>

<style lang="scss" scoped>
    .tests-table {
        .test-name {
            display: flex;
            align-items: center;
        }

        .test-failing {
            background-color: rgba(245, 108, 108, 0.1);
        }
    }

    .card {
        border: 1px solid var(--ks-border-primary);
        border-radius: 8px;
        
        .card-body {
            padding: 1.5rem;
        }
    }
</style>

