<template>
    <el-dialog
        v-model="visible"
        :title="$t('settings.api_keys')"
        width="800px"
        :close-on-click-modal="false"
        @close="handleClose"
    >
        <div class="api-key-settings">
            <!-- Header with description -->
            <div class="settings-header mb-4">
                <p class="text-muted">
                    {{ $t('settings.api_keys_description') }}
                </p>
                <el-alert
                    :title="$t('settings.security_notice')"
                    type="info"
                    :closable="false"
                    show-icon
                    class="mb-3"
                >
                    <template #default>
                        {{ $t('settings.security_notice_text') }}
                    </template>
                </el-alert>
            </div>

            <!-- API Key Providers -->
            <div class="providers-section">
                <h6 class="mb-3">{{ $t('settings.configure_providers') }}</h6>
                
                <!-- Gemini API Key -->
                <div class="provider-card mb-4">
                    <div class="provider-header">
                        <div class="d-flex align-items-center">
                            <Robot class="me-2 text-primary" />
                            <h6 class="mb-0">Google Gemini</h6>
                            <el-tag v-if="hasGeminiKey" type="success" size="small" class="ms-2">
                                {{ $t('settings.configured') }}
                            </el-tag>
                        </div>
                        <el-button
                            v-if="hasGeminiKey"
                            size="small"
                            type="danger"
                            text
                            @click="removeKey('gemini')"
                        >
                            {{ $t('remove') }}
                        </el-button>
                    </div>
                    
                    <div class="provider-body">
                        <p class="text-muted small mb-2">
                            {{ $t('settings.gemini_description') }}
                        </p>
                        
                        <div v-if="!hasGeminiKey || editingProvider === 'gemini'">
                            <el-input
                                v-model="apiKeys.gemini"
                                type="password"
                                :placeholder="$t('settings.enter_gemini_key')"
                                show-password
                                class="mb-2"
                            />
                            <div class="d-flex gap-2">
                                <el-button
                                    size="small"
                                    type="primary"
                                    @click="saveKey('gemini')"
                                    :loading="testing.gemini"
                                    :disabled="!apiKeys.gemini"
                                >
                                    {{ $t('save') }}
                                </el-button>
                                <el-button
                                    size="small"
                                    @click="testKey('gemini')"
                                    :loading="testing.gemini"
                                    :disabled="!apiKeys.gemini"
                                >
                                    {{ $t('settings.test_key') }}
                                </el-button>
                                <el-button
                                    v-if="editingProvider === 'gemini'"
                                    size="small"
                                    @click="cancelEdit"
                                >
                                    {{ $t('cancel') }}
                                </el-button>
                            </div>
                        </div>
                        
                        <div v-else class="configured-key">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="masked-key">{{ getMaskedKey('gemini') }}</span>
                                <el-button
                                    size="small"
                                    text
                                    @click="editKey('gemini')"
                                >
                                    {{ $t('edit') }}
                                </el-button>
                            </div>
                        </div>
                        
                        <div class="help-links mt-2">
                            <el-link
                                href="https://makersuite.google.com/app/apikey"
                                target="_blank"
                                type="primary"
                                :underline="false"
                            >
                                <ExternalLink class="me-1" />
                                {{ $t('settings.get_gemini_key') }}
                            </el-link>
                        </div>
                    </div>
                </div>

                <!-- OpenAI API Key -->
                <div class="provider-card mb-4">
                    <div class="provider-header">
                        <div class="d-flex align-items-center">
                            <Brain class="me-2 text-success" />
                            <h6 class="mb-0">OpenAI</h6>
                            <el-tag v-if="hasOpenAIKey" type="success" size="small" class="ms-2">
                                {{ $t('settings.configured') }}
                            </el-tag>
                        </div>
                        <el-button
                            v-if="hasOpenAIKey"
                            size="small"
                            type="danger"
                            text
                            @click="removeKey('openai')"
                        >
                            {{ $t('remove') }}
                        </el-button>
                    </div>
                    
                    <div class="provider-body">
                        <p class="text-muted small mb-2">
                            {{ $t('settings.openai_description') }}
                        </p>
                        
                        <div v-if="!hasOpenAIKey || editingProvider === 'openai'">
                            <el-input
                                v-model="apiKeys.openai"
                                type="password"
                                :placeholder="$t('settings.enter_openai_key')"
                                show-password
                                class="mb-2"
                            />
                            <div class="d-flex gap-2">
                                <el-button
                                    size="small"
                                    type="primary"
                                    @click="saveKey('openai')"
                                    :loading="testing.openai"
                                    :disabled="!apiKeys.openai"
                                >
                                    {{ $t('save') }}
                                </el-button>
                                <el-button
                                    size="small"
                                    @click="testKey('openai')"
                                    :loading="testing.openai"
                                    :disabled="!apiKeys.openai"
                                >
                                    {{ $t('settings.test_key') }}
                                </el-button>
                                <el-button
                                    v-if="editingProvider === 'openai'"
                                    size="small"
                                    @click="cancelEdit"
                                >
                                    {{ $t('cancel') }}
                                </el-button>
                            </div>
                        </div>
                        
                        <div v-else class="configured-key">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="masked-key">{{ getMaskedKey('openai') }}</span>
                                <el-button
                                    size="small"
                                    text
                                    @click="editKey('openai')"
                                >
                                    {{ $t('edit') }}
                                </el-button>
                            </div>
                        </div>
                        
                        <div class="help-links mt-2">
                            <el-link
                                href="https://platform.openai.com/api-keys"
                                target="_blank"
                                type="primary"
                                :underline="false"
                            >
                                <ExternalLink class="me-1" />
                                {{ $t('settings.get_openai_key') }}
                            </el-link>
                        </div>
                    </div>
                </div>

                <!-- Anthropic API Key -->
                <div class="provider-card mb-4">
                    <div class="provider-header">
                        <div class="d-flex align-items-center">
                            <MessageText class="me-2 text-warning" />
                            <h6 class="mb-0">Anthropic Claude</h6>
                            <el-tag v-if="hasAnthropicKey" type="success" size="small" class="ms-2">
                                {{ $t('settings.configured') }}
                            </el-tag>
                        </div>
                        <el-button
                            v-if="hasAnthropicKey"
                            size="small"
                            type="danger"
                            text
                            @click="removeKey('anthropic')"
                        >
                            {{ $t('remove') }}
                        </el-button>
                    </div>
                    
                    <div class="provider-body">
                        <p class="text-muted small mb-2">
                            {{ $t('settings.anthropic_description') }}
                        </p>
                        
                        <div v-if="!hasAnthropicKey || editingProvider === 'anthropic'">
                            <el-input
                                v-model="apiKeys.anthropic"
                                type="password"
                                :placeholder="$t('settings.enter_anthropic_key')"
                                show-password
                                class="mb-2"
                            />
                            <div class="d-flex gap-2">
                                <el-button
                                    size="small"
                                    type="primary"
                                    @click="saveKey('anthropic')"
                                    :loading="testing.anthropic"
                                    :disabled="!apiKeys.anthropic"
                                >
                                    {{ $t('save') }}
                                </el-button>
                                <el-button
                                    size="small"
                                    @click="testKey('anthropic')"
                                    :loading="testing.anthropic"
                                    :disabled="!apiKeys.anthropic"
                                >
                                    {{ $t('settings.test_key') }}
                                </el-button>
                                <el-button
                                    v-if="editingProvider === 'anthropic'"
                                    size="small"
                                    @click="cancelEdit"
                                >
                                    {{ $t('cancel') }}
                                </el-button>
                            </div>
                        </div>
                        
                        <div v-else class="configured-key">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="masked-key">{{ getMaskedKey('anthropic') }}</span>
                                <el-button
                                    size="small"
                                    text
                                    @click="editKey('anthropic')"
                                >
                                    {{ $t('edit') }}
                                </el-button>
                            </div>
                        </div>
                        
                        <div class="help-links mt-2">
                            <el-link
                                href="https://console.anthropic.com/account/keys"
                                target="_blank"
                                type="primary"
                                :underline="false"
                            >
                                <ExternalLink class="me-1" />
                                {{ $t('settings.get_anthropic_key') }}
                            </el-link>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Advanced Options -->
            <div class="advanced-section">
                <h6 class="mb-3">{{ $t('settings.advanced_options') }}</h6>
                
                <div class="d-flex gap-2 mb-3">
                    <el-button
                        size="small"
                        @click="exportKeys"
                        :icon="Download"
                    >
                        {{ $t('settings.export_keys') }}
                    </el-button>
                    
                    <el-button
                        size="small"
                        @click="importKeysDialog = true"
                        :icon="Upload"
                    >
                        {{ $t('settings.import_keys') }}
                    </el-button>
                    
                    <el-button
                        size="small"
                        type="danger"
                        @click="clearAllKeys"
                        :icon="TrashCan"
                    >
                        {{ $t('settings.clear_all_keys') }}
                    </el-button>
                </div>
            </div>
        </div>

        <template #footer>
            <div class="d-flex justify-content-between">
                <div class="text-muted small">
                    {{ $t('settings.keys_stored_locally') }}
                </div>
                <div>
                    <el-button @click="handleClose">
                        {{ $t('close') }}
                    </el-button>
                </div>
            </div>
        </template>
    </el-dialog>

    <!-- Import Keys Dialog -->
    <el-dialog
        v-model="importKeysDialog"
        :title="$t('settings.import_keys')"
        width="600px"
    >
        <div>
            <p class="text-muted mb-3">
                {{ $t('settings.import_keys_description') }}
            </p>
            
            <el-input
                v-model="importData"
                type="textarea"
                :rows="10"
                :placeholder="$t('settings.paste_export_data')"
            />
        </div>
        
        <template #footer>
            <el-button @click="importKeysDialog = false">
                {{ $t('cancel') }}
            </el-button>
            <el-button
                type="primary"
                @click="performImport"
                :disabled="!importData"
            >
                {{ $t('import') }}
            </el-button>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted, watch} from "vue";
    import {useI18n} from "vue-i18n";
    import {ElMessage, ElMessageBox} from "element-plus";
    
    // Icons
    import Robot from "vue-material-design-icons/Robot.vue";
    import Brain from "vue-material-design-icons/Brain.vue";
    import MessageText from "vue-material-design-icons/MessageText.vue";
    import ExternalLink from "vue-material-design-icons/OpenInNew.vue";
    import Download from "vue-material-design-icons/Download.vue";
    import Upload from "vue-material-design-icons/Upload.vue";
    import TrashCan from "vue-material-design-icons/TrashCan.vue";
    
    // API Key Storage
    import {
        storeApiKey,
        getApiKey,
        removeApiKey,
        hasApiKey,
        getMaskedApiKey,
        clearAllApiKeys,
        exportApiKeys,
        importApiKeys,
        testApiKey,
        validateApiKey
    } from "../../utils/apiKeyStorage";

    interface Props {
        modelValue: boolean;
    }

    const props = defineProps<Props>();
    const emit = defineEmits<{
        'update:modelValue': [value: boolean];
        'keys-updated': [];
    }>();

    const {t} = useI18n();

    // State
    const visible = ref(props.modelValue);
    const editingProvider = ref<string | null>(null);
    const importKeysDialog = ref(false);
    const importData = ref('');

    const apiKeys = ref({
        gemini: '',
        openai: '',
        anthropic: ''
    });

    const testing = ref({
        gemini: false,
        openai: false,
        anthropic: false
    });

    // Computed
    const hasGeminiKey = computed(() => hasApiKey('gemini'));
    const hasOpenAIKey = computed(() => hasApiKey('openai'));
    const hasAnthropicKey = computed(() => hasApiKey('anthropic'));

    // Methods
    function getMaskedKey(provider: string): string {
        return getMaskedApiKey(provider) || '';
    }

    async function saveKey(provider: string) {
        const key = apiKeys.value[provider as keyof typeof apiKeys.value];
        
        if (!key) {
            ElMessage.error(t('settings.api_key_required'));
            return;
        }

        const validation = validateApiKey(provider, key);
        if (!validation.valid) {
            ElMessage.error(validation.message || t('settings.invalid_api_key'));
            return;
        }

        const success = storeApiKey(provider, key);
        if (success) {
            ElMessage.success(t('settings.api_key_saved'));
            apiKeys.value[provider as keyof typeof apiKeys.value] = '';
            editingProvider.value = null;
            emit('keys-updated');
        } else {
            ElMessage.error(t('settings.failed_to_save_key'));
        }
    }

    async function testKey(provider: string) {
        const key = apiKeys.value[provider as keyof typeof apiKeys.value] || getApiKey(provider);
        
        if (!key) {
            ElMessage.error(t('settings.no_key_to_test'));
            return;
        }

        testing.value[provider as keyof typeof testing.value] = true;
        
        try {
            const result = await testApiKey(provider, key);
            
            if (result.success) {
                ElMessage.success(result.message);
            } else {
                ElMessage.error(result.message);
            }
        } catch (error) {
            ElMessage.error(t('settings.test_failed'));
        } finally {
            testing.value[provider as keyof typeof testing.value] = false;
        }
    }

    function editKey(provider: string) {
        editingProvider.value = provider;
        apiKeys.value[provider as keyof typeof apiKeys.value] = '';
    }

    function cancelEdit() {
        editingProvider.value = null;
        apiKeys.value.gemini = '';
        apiKeys.value.openai = '';
        apiKeys.value.anthropic = '';
    }

    async function removeKey(provider: string) {
        try {
            await ElMessageBox.confirm(
                t('settings.remove_key_confirm'),
                t('confirm'),
                {
                    confirmButtonText: t('remove'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );

            const success = removeApiKey(provider);
            if (success) {
                ElMessage.success(t('settings.api_key_removed'));
                emit('keys-updated');
            } else {
                ElMessage.error(t('settings.failed_to_remove_key'));
            }
        } catch (error) {
            // User cancelled
        }
    }

    function exportKeys() {
        try {
            const exportData = exportApiKeys();
            
            // Create download link
            const blob = new Blob([exportData], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `kestra-api-keys-${new Date().toISOString().split('T')[0]}.json`;
            link.click();
            URL.revokeObjectURL(url);
            
            ElMessage.success(t('settings.keys_exported'));
        } catch (error) {
            ElMessage.error(t('settings.export_failed'));
        }
    }

    function performImport() {
        try {
            const success = importApiKeys(importData.value);
            if (success) {
                ElMessage.success(t('settings.keys_imported'));
                importKeysDialog.value = false;
                importData.value = '';
                emit('keys-updated');
            } else {
                ElMessage.error(t('settings.import_failed'));
            }
        } catch (error) {
            ElMessage.error(t('settings.invalid_import_data'));
        }
    }

    async function clearAllKeys() {
        try {
            await ElMessageBox.confirm(
                t('settings.clear_all_keys_confirm'),
                t('confirm'),
                {
                    confirmButtonText: t('clear'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );

            const success = clearAllApiKeys();
            if (success) {
                ElMessage.success(t('settings.all_keys_cleared'));
                emit('keys-updated');
            } else {
                ElMessage.error(t('settings.failed_to_clear_keys'));
            }
        } catch (error) {
            // User cancelled
        }
    }

    function handleClose() {
        visible.value = false;
        emit('update:modelValue', false);
        cancelEdit();
    }

    // Watchers
    watch(() => props.modelValue, (newValue) => {
        visible.value = newValue;
    });

    watch(visible, (newValue) => {
        emit('update:modelValue', newValue);
    });

    // Lifecycle
    onMounted(() => {
        // Initialize component
    });
</script>

<style lang="scss" scoped>
    .api-key-settings {
        .settings-header {
            border-bottom: 1px solid var(--ks-border-primary);
            padding-bottom: 1rem;
        }

        .provider-card {
            border: 1px solid var(--ks-border-primary);
            border-radius: 8px;
            padding: 1rem;
            background: var(--ks-background-secondary);

            .provider-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 0.75rem;
            }

            .provider-body {
                .configured-key {
                    padding: 0.5rem;
                    background: var(--ks-background-primary);
                    border-radius: 4px;
                    border: 1px solid var(--ks-border-primary);

                    .masked-key {
                        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
                        font-size: 0.875rem;
                        color: var(--ks-text-secondary);
                    }
                }

                .help-links {
                    .el-link {
                        font-size: 0.875rem;
                    }
                }
            }
        }

        .advanced-section {
            border-top: 1px solid var(--ks-border-primary);
            padding-top: 1rem;
        }
    }
</style>
