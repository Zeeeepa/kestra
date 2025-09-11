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
                        @change="importBlueprints()"
                        class="d-none"
                    >
                </li>
                <li>
                    <el-button :icon="Plus" type="primary" @click="showCreateDialog = true">
                        {{ $t("create") }}
                    </el-button>
                </li>
            </ul>
        </template>
    </TopNavBar>

    <section class="container" v-if="ready">
        <div class="row">
            <div class="col-12">
                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h3 class="text-primary">{{ blueprints.length }}</h3>
                                <p class="mb-0">{{ $t('blueprints.total') }}</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h3 class="text-success">{{ activeBlueprints }}</h3>
                                <p class="mb-0">{{ $t('blueprints.active') }}</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h3 class="text-info">{{ totalUsage }}</h3>
                                <p class="mb-0">{{ $t('blueprints.total_usage') }}</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h3 class="text-warning">{{ recentlyUsed }}</h3>
                                <p class="mb-0">{{ $t('blueprints.recently_used') }}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Search and Filter -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <el-input
                                    v-model="searchQuery"
                                    :placeholder="$t('blueprints.search_placeholder')"
                                    :prefix-icon="Search"
                                    clearable
                                />
                            </div>
                            <div class="col-md-3">
                                <el-select v-model="selectedCategory" :placeholder="$t('blueprints.all_categories')" clearable>
                                    <el-option
                                        v-for="category in categories"
                                        :key="category"
                                        :label="category"
                                        :value="category"
                                    />
                                </el-select>
                            </div>
                            <div class="col-md-3">
                                <el-select v-model="selectedTag" :placeholder="$t('blueprints.all_tags')" clearable>
                                    <el-option
                                        v-for="tag in tags"
                                        :key="tag"
                                        :label="tag"
                                        :value="tag"
                                    />
                                </el-select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Blueprints Grid -->
                <div v-if="filteredBlueprints.length === 0" class="text-center py-5">
                    <FileDocumentMultipleOutline class="text-muted mb-3" style="font-size: 4rem;" />
                    <h6 class="text-muted">{{ $t('blueprints.empty.title') }}</h6>
                    <p class="text-muted">{{ $t('blueprints.empty.description') }}</p>
                    <el-button type="primary" @click="showCreateDialog = true">
                        {{ $t('blueprints.create_first') }}
                    </el-button>
                </div>

                <div v-else class="row">
                    <div v-for="blueprint in filteredBlueprints" :key="blueprint.id" class="col-md-6 col-lg-4 mb-4">
                        <div class="card h-100 blueprint-card" @click="selectBlueprint(blueprint)">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div>
                                        <h6 class="card-title">{{ blueprint.name }}</h6>
                                        <small class="text-muted">{{ blueprint.category }}</small>
                                    </div>
                                    <el-dropdown @command="handleBlueprintAction" @click.stop>
                                        <el-button size="small" text>
                                            <DotsVertical />
                                        </el-button>
                                        <template #dropdown>
                                            <el-dropdown-menu>
                                                <el-dropdown-item :command="{action: 'use', blueprint}">
                                                    <Play class="me-2" />
                                                    {{ $t('blueprints.use') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'edit', blueprint}">
                                                    <Pencil class="me-2" />
                                                    {{ $t('edit') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'duplicate', blueprint}">
                                                    <ContentDuplicate class="me-2" />
                                                    {{ $t('duplicate') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'export', blueprint}">
                                                    <Download class="me-2" />
                                                    {{ $t('export') }}
                                                </el-dropdown-item>
                                                <el-dropdown-item :command="{action: 'delete', blueprint}" divided>
                                                    <TrashCan class="me-2" />
                                                    {{ $t('delete') }}
                                                </el-dropdown-item>
                                            </el-dropdown-menu>
                                        </template>
                                    </el-dropdown>
                                </div>
                                
                                <p class="card-text text-muted small">{{ blueprint.description }}</p>
                                
                                <div class="blueprint-tags mb-3">
                                    <el-tag
                                        v-for="tag in blueprint.tags"
                                        :key="tag"
                                        size="small"
                                        class="me-1 mb-1"
                                    >
                                        {{ tag }}
                                    </el-tag>
                                </div>

                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="d-flex align-items-center">
                                        <Account class="me-1" />
                                        <small class="text-muted">{{ blueprint.createdBy }}</small>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <Eye class="me-1" />
                                        <small class="text-muted">{{ blueprint.usageCount || 0 }}</small>
                                    </div>
                                </div>
                                
                                <div class="mt-2">
                                    <small class="text-muted">
                                        {{ $t('blueprints.updated') }}: {{ formatDate(blueprint.updatedAt) }}
                                    </small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Create/Edit Blueprint Dialog -->
    <el-dialog v-model="showCreateDialog" :title="editingBlueprint ? $t('blueprints.edit') : $t('blueprints.create')" width="800px">
        <el-form :model="blueprintForm" label-width="120px">
            <el-form-item :label="$t('name')" required>
                <el-input v-model="blueprintForm.name" :placeholder="$t('blueprints.name_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('description')">
                <el-input 
                    v-model="blueprintForm.description" 
                    type="textarea" 
                    :rows="3"
                    :placeholder="$t('blueprints.description_placeholder')" 
                />
            </el-form-item>
            <el-form-item :label="$t('category')">
                <el-input v-model="blueprintForm.category" :placeholder="$t('blueprints.category_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('tags')">
                <el-input v-model="blueprintForm.tagsString" :placeholder="$t('blueprints.tags_placeholder')" />
                <small class="text-muted">{{ $t('blueprints.tags_help') }}</small>
            </el-form-item>
            <el-form-item :label="$t('blueprints.template')">
                <el-input 
                    v-model="blueprintForm.template" 
                    type="textarea" 
                    :rows="10"
                    :placeholder="$t('blueprints.template_placeholder')" 
                />
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="showCreateDialog = false">{{ $t('cancel') }}</el-button>
            <el-button type="primary" @click="saveBlueprint">
                {{ editingBlueprint ? $t('update') : $t('create') }}
            </el-button>
        </template>
    </el-dialog>

    <!-- Blueprint Detail Dialog -->
    <el-dialog v-model="showDetailDialog" :title="selectedBlueprint?.name" width="900px">
        <div v-if="selectedBlueprint">
            <div class="mb-3">
                <p>{{ selectedBlueprint.description }}</p>
                <div class="blueprint-tags mb-3">
                    <el-tag
                        v-for="tag in selectedBlueprint.tags"
                        :key="tag"
                        size="small"
                        class="me-1"
                    >
                        {{ tag }}
                    </el-tag>
                </div>
            </div>
            
            <el-tabs>
                <el-tab-pane :label="$t('blueprints.template')" name="template">
                    <pre class="blueprint-template">{{ selectedBlueprint.template }}</pre>
                </el-tab-pane>
                <el-tab-pane :label="$t('blueprints.usage')" name="usage">
                    <div class="text-center py-4">
                        <h4>{{ selectedBlueprint.usageCount || 0 }}</h4>
                        <p class="text-muted">{{ $t('blueprints.times_used') }}</p>
                    </div>
                </el-tab-pane>
            </el-tabs>
        </div>
        <template #footer>
            <el-button @click="showDetailDialog = false">{{ $t('close') }}</el-button>
            <el-button type="primary" @click="useBlueprint(selectedBlueprint)">
                {{ $t('blueprints.use') }}
            </el-button>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted} from "vue";
    import {useI18n} from "vue-i18n";
    import {useRouter} from "vue-router";
    import {ElMessage, ElMessageBox} from "element-plus";
    
    // Components
    import TopNavBar from "../../layout/TopNavBar.vue";
    
    // Icons
    import Plus from "vue-material-design-icons/Plus.vue";
    import Upload from "vue-material-design-icons/Upload.vue";
    import Download from "vue-material-design-icons/Download.vue";
    import Search from "vue-material-design-icons/Magnify.vue";
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import Play from "vue-material-design-icons/Play.vue";
    import Pencil from "vue-material-design-icons/Pencil.vue";
    import ContentDuplicate from "vue-material-design-icons/ContentDuplicate.vue";
    import TrashCan from "vue-material-design-icons/TrashCan.vue";
    import Account from "vue-material-design-icons/Account.vue";
    import Eye from "vue-material-design-icons/Eye.vue";
    import FileDocumentMultipleOutline from "vue-material-design-icons/FileDocumentMultipleOutline.vue";
    
    // Composables
    import useRouteContext from "../../../mixins/useRouteContext";

    const {t} = useI18n();
    const router = useRouter();

    // Route context
    const routeInfo = ref({
        title: t("blueprints.custom"),
    });
    useRouteContext(routeInfo);

    // State
    const ready = ref(false);
    const file = ref<HTMLInputElement>();
    const searchQuery = ref('');
    const selectedCategory = ref('');
    const selectedTag = ref('');
    const showCreateDialog = ref(false);
    const showDetailDialog = ref(false);
    const editingBlueprint = ref<any>(null);
    const selectedBlueprint = ref<any>(null);

    // Mock data - replace with actual API calls
    const blueprints = ref([
        {
            id: '1',
            name: 'Data Pipeline Template',
            description: 'A comprehensive template for building data processing pipelines with error handling and monitoring.',
            category: 'Data Processing',
            tags: ['etl', 'data', 'pipeline', 'monitoring'],
            template: `id: data-pipeline-template
namespace: templates
description: Data processing pipeline with monitoring

tasks:
  - id: extract
    type: io.kestra.plugin.core.log.Log
    message: "Extracting data..."
  
  - id: transform
    type: io.kestra.plugin.core.log.Log
    message: "Transforming data..."
  
  - id: load
    type: io.kestra.plugin.core.log.Log
    message: "Loading data..."

triggers:
  - id: schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 2 * * *"`,
            createdBy: 'admin',
            createdAt: new Date('2024-01-15'),
            updatedAt: new Date('2024-01-20'),
            usageCount: 15
        },
        {
            id: '2',
            name: 'API Integration Flow',
            description: 'Template for integrating with external APIs with retry logic and error handling.',
            category: 'Integration',
            tags: ['api', 'integration', 'http', 'retry'],
            template: `id: api-integration-template
namespace: templates
description: API integration with retry logic

tasks:
  - id: api-call
    type: io.kestra.plugin.core.http.Request
    uri: "https://api.example.com/data"
    method: GET
    retry:
      maxAttempt: 3
      delay: PT30S`,
            createdBy: 'developer',
            createdAt: new Date('2024-01-10'),
            updatedAt: new Date('2024-01-18'),
            usageCount: 8
        }
    ]);

    const blueprintForm = ref({
        name: '',
        description: '',
        category: '',
        tagsString: '',
        template: ''
    });

    // Computed properties
    const categories = computed(() => {
        return [...new Set(blueprints.value.map(b => b.category))];
    });

    const tags = computed(() => {
        const allTags = blueprints.value.flatMap(b => b.tags);
        return [...new Set(allTags)];
    });

    const filteredBlueprints = computed(() => {
        return blueprints.value.filter(blueprint => {
            const matchesSearch = !searchQuery.value || 
                blueprint.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                blueprint.description.toLowerCase().includes(searchQuery.value.toLowerCase());
            
            const matchesCategory = !selectedCategory.value || blueprint.category === selectedCategory.value;
            const matchesTag = !selectedTag.value || blueprint.tags.includes(selectedTag.value);
            
            return matchesSearch && matchesCategory && matchesTag;
        });
    });

    const activeBlueprints = computed(() => {
        return blueprints.value.length; // All blueprints are considered active
    });

    const totalUsage = computed(() => {
        return blueprints.value.reduce((sum, b) => sum + (b.usageCount || 0), 0);
    });

    const recentlyUsed = computed(() => {
        const oneWeekAgo = new Date();
        oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
        return blueprints.value.filter(b => b.updatedAt > oneWeekAgo).length;
    });

    // Methods
    function selectBlueprint(blueprint: any) {
        selectedBlueprint.value = blueprint;
        showDetailDialog.value = true;
    }

    function useBlueprint(blueprint: any) {
        router.push({
            name: 'flows/create',
            query: {
                blueprint: blueprint.id
            }
        });
        showDetailDialog.value = false;
    }

    async function handleBlueprintAction({action, blueprint}: {action: string, blueprint: any}) {
        switch (action) {
            case 'use':
                useBlueprint(blueprint);
                break;
            case 'edit':
                editBlueprint(blueprint);
                break;
            case 'duplicate':
                duplicateBlueprint(blueprint);
                break;
            case 'export':
                exportBlueprint(blueprint);
                break;
            case 'delete':
                await deleteBlueprint(blueprint);
                break;
        }
    }

    function editBlueprint(blueprint: any) {
        editingBlueprint.value = blueprint;
        blueprintForm.value = {
            name: blueprint.name,
            description: blueprint.description,
            category: blueprint.category,
            tagsString: blueprint.tags.join(', '),
            template: blueprint.template
        };
        showCreateDialog.value = true;
    }

    function duplicateBlueprint(blueprint: any) {
        blueprintForm.value = {
            name: `${blueprint.name} (Copy)`,
            description: blueprint.description,
            category: blueprint.category,
            tagsString: blueprint.tags.join(', '),
            template: blueprint.template
        };
        editingBlueprint.value = null;
        showCreateDialog.value = true;
    }

    function exportBlueprint(blueprint: any) {
        const dataStr = JSON.stringify(blueprint, null, 2);
        const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
        
        const exportFileDefaultName = `${blueprint.name.replace(/\s+/g, '-').toLowerCase()}-blueprint.json`;
        
        const linkElement = document.createElement('a');
        linkElement.setAttribute('href', dataUri);
        linkElement.setAttribute('download', exportFileDefaultName);
        linkElement.click();
        
        ElMessage.success(t('blueprints.exported_successfully'));
    }

    async function deleteBlueprint(blueprint: any) {
        try {
            await ElMessageBox.confirm(
                t("blueprints.delete_confirm", {name: blueprint.name}),
                t("delete"),
                {
                    confirmButtonText: t("delete"),
                    cancelButtonText: t("cancel"),
                    type: "warning",
                }
            );

            const index = blueprints.value.findIndex(b => b.id === blueprint.id);
            if (index > -1) {
                blueprints.value.splice(index, 1);
                ElMessage.success(t('blueprints.deleted_successfully'));
            }
        } catch (error) {
            if (error !== "cancel") {
                console.error("Error deleting blueprint:", error);
            }
        }
    }

    function saveBlueprint() {
        const tags = blueprintForm.value.tagsString
            .split(',')
            .map(tag => tag.trim())
            .filter(tag => tag.length > 0);

        if (editingBlueprint.value) {
            // Update existing blueprint
            const index = blueprints.value.findIndex(b => b.id === editingBlueprint.value.id);
            if (index > -1) {
                blueprints.value[index] = {
                    ...blueprints.value[index],
                    name: blueprintForm.value.name,
                    description: blueprintForm.value.description,
                    category: blueprintForm.value.category,
                    tags,
                    template: blueprintForm.value.template,
                    updatedAt: new Date()
                };
            }
            ElMessage.success(t('blueprints.updated_successfully'));
        } else {
            // Create new blueprint
            const newBlueprint = {
                id: Date.now().toString(),
                name: blueprintForm.value.name,
                description: blueprintForm.value.description,
                category: blueprintForm.value.category,
                tags,
                template: blueprintForm.value.template,
                createdBy: 'current-user',
                createdAt: new Date(),
                updatedAt: new Date(),
                usageCount: 0
            };
            blueprints.value.push(newBlueprint);
            ElMessage.success(t('blueprints.created_successfully'));
        }

        showCreateDialog.value = false;
        editingBlueprint.value = null;
        resetForm();
    }

    function resetForm() {
        blueprintForm.value = {
            name: '',
            description: '',
            category: '',
            tagsString: '',
            template: ''
        };
    }

    function importBlueprints() {
        ElMessage.info(t("feature.coming_soon"));
    }

    function formatDate(date: Date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        }).format(date);
    }

    // Lifecycle
    onMounted(() => {
        ready.value = true;
    });
</script>

<style lang="scss" scoped>
    .blueprint-card {
        cursor: pointer;
        transition: transform 0.2s, box-shadow 0.2s;
        
        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
    }

    .blueprint-tags {
        min-height: 32px;
    }

    .blueprint-template {
        background: var(--ks-background-secondary);
        border: 1px solid var(--ks-border-primary);
        border-radius: 4px;
        padding: 16px;
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 12px;
        overflow-x: auto;
        max-height: 400px;
        overflow-y: auto;
    }

    .card {
        border: 1px solid var(--ks-border-primary);
        border-radius: 8px;
        
        .card-body {
            padding: 1.5rem;
        }
    }
</style>
