<template>
    <div class="ai-copilot" :class="{ 'expanded': isExpanded, 'minimized': isMinimized }">
        <!-- Copilot Toggle Button -->
        <el-button 
            v-if="isMinimized"
            @click="toggleCopilot"
            type="primary"
            class="copilot-toggle"
            :loading="isLoading"
        >
            <Robot class="me-2" />
            {{ $t('ai.copilot') }}
        </el-button>

        <!-- Main Copilot Interface -->
        <div v-else class="copilot-interface">
            <div class="copilot-header">
                <div class="d-flex align-items-center">
                    <Robot class="me-2 text-primary" />
                    <h6 class="mb-0">{{ $t('ai.copilot') }}</h6>
                    <el-tag v-if="aiStatus.provider" size="small" class="ms-2">
                        {{ aiStatus.provider }}
                    </el-tag>
                </div>
                <div class="header-actions">
                    <el-button 
                        size="small" 
                        text 
                        @click="isExpanded = !isExpanded"
                        :icon="isExpanded ? ChevronDown : ChevronUp"
                    />
                    <el-button 
                        size="small" 
                        text 
                        @click="toggleCopilot"
                        :icon="Close"
                    />
                </div>
            </div>

            <div v-if="isExpanded" class="copilot-body">
                <!-- Quick Actions -->
                <div class="quick-actions mb-3">
                    <el-button-group size="small">
                        <el-button @click="setMode('generate')" :type="mode === 'generate' ? 'primary' : ''">
                            {{ $t('ai.generate') }}
                        </el-button>
                        <el-button @click="setMode('refine')" :type="mode === 'refine' ? 'primary' : ''">
                            {{ $t('ai.refine') }}
                        </el-button>
                        <el-button @click="setMode('explain')" :type="mode === 'explain' ? 'primary' : ''">
                            {{ $t('ai.explain') }}
                        </el-button>
                        <el-button @click="setMode('chat')" :type="mode === 'chat' ? 'primary' : ''">
                            {{ $t('ai.chat') }}
                        </el-button>
                    </el-button-group>
                </div>

                <!-- Input Area -->
                <div class="input-area mb-3">
                    <el-input
                        v-model="userInput"
                        type="textarea"
                        :placeholder="getPlaceholder()"
                        :rows="3"
                        @keydown.ctrl.enter="handleSubmit"
                        @keydown.meta.enter="handleSubmit"
                    />
                    <div class="input-actions mt-2">
                        <el-button 
                            type="primary" 
                            size="small"
                            @click="handleSubmit"
                            :loading="isLoading"
                            :disabled="!userInput.trim()"
                        >
                            <Send class="me-1" />
                            {{ getSubmitText() }}
                        </el-button>
                        <el-button 
                            size="small"
                            @click="clearInput"
                            :disabled="!userInput.trim()"
                        >
                            {{ $t('clear') }}
                        </el-button>
                    </div>
                </div>

                <!-- Conversation History -->
                <div v-if="conversationHistory.length > 0" class="conversation-history">
                    <div 
                        v-for="(message, index) in conversationHistory" 
                        :key="index"
                        class="message"
                        :class="message.role"
                    >
                        <div class="message-header">
                            <component :is="message.role === 'user' ? Account : Robot" class="message-icon" />
                            <span class="message-role">{{ message.role === 'user' ? $t('you') : $t('ai.copilot') }}</span>
                            <span class="message-time">{{ formatTime(message.timestamp) }}</span>
                        </div>
                        <div class="message-content">
                            <div v-if="message.type === 'yaml'" class="yaml-response">
                                <div class="response-header">
                                    <span>{{ $t('ai.generated_yaml') }}</span>
                                    <div class="response-actions">
                                        <el-button size="small" @click="acceptSuggestion(message.content)">
                                            {{ $t('ai.accept') }}
                                        </el-button>
                                        <el-button size="small" @click="copySuggestion(message.content)">
                                            {{ $t('copy') }}
                                        </el-button>
                                    </div>
                                </div>
                                <pre class="yaml-content">{{ message.content }}</pre>
                                <div v-if="message.explanation" class="explanation">
                                    <strong>{{ $t('ai.explanation') }}:</strong>
                                    <p>{{ message.explanation }}</p>
                                </div>
                            </div>
                            <div v-else class="text-content">
                                {{ message.content }}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Suggestions -->
                <div v-if="suggestions.length > 0" class="suggestions">
                    <h6>{{ $t('ai.suggestions') }}</h6>
                    <div class="suggestion-chips">
                        <el-tag 
                            v-for="(suggestion, index) in suggestions"
                            :key="index"
                            @click="applySuggestion(suggestion)"
                            class="suggestion-chip"
                            :type="getSuggestionType(suggestion.severity)"
                        >
                            {{ suggestion.message }}
                        </el-tag>
                    </div>
                </div>

                <!-- Loading State -->
                <div v-if="isLoading" class="loading-state">
                    <el-skeleton :rows="2" animated />
                    <p class="text-muted small">{{ $t('ai.thinking') }}</p>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
    import {ref, computed, onMounted, watch} from "vue";
    import {useI18n} from "vue-i18n";
    import {ElMessage} from "element-plus";
    import {AiService} from "../../services/aiService";
    import Robot from "vue-material-design-icons/Robot.vue";
    import Account from "vue-material-design-icons/Account.vue";
    import Send from "vue-material-design-icons/Send.vue";
    import Close from "vue-material-design-icons/Close.vue";
    import ChevronUp from "vue-material-design-icons/ChevronUp.vue";
    import ChevronDown from "vue-material-design-icons/ChevronDown.vue";

    interface Props {
        flowYaml?: string;
        namespace?: string;
        visible?: boolean;
    }

    const props = withDefaults(defineProps<Props>(), {
        flowYaml: "",
        namespace: "",
        visible: false
    });

    const emit = defineEmits<{
        'update:flowYaml': [value: string];
        'yaml-accepted': [yaml: string];
        'visibility-changed': [visible: boolean];
    }>();

    const {t} = useI18n();
    const aiService = new AiService();

    // State
    const isMinimized = ref(!props.visible);
    const isExpanded = ref(true);
    const isLoading = ref(false);
    const mode = ref<'generate' | 'refine' | 'explain' | 'chat'>('generate');
    const userInput = ref('');
    const conversationHistory = ref<Array<{
        role: 'user' | 'assistant';
        content: string;
        type?: 'text' | 'yaml';
        explanation?: string;
        timestamp: Date;
    }>>([]);
    const suggestions = ref<Array<{ type: string, message: string, severity: 'info' | 'warning' | 'error' }>>([]);
    const aiStatus = ref<{ available: boolean, provider?: string, model?: string, features?: string[] }>({ available: false });

    // Computed
    const getPlaceholder = () => {
        switch (mode.value) {
            case 'generate':
                return t('ai.placeholder.generate');
            case 'refine':
                return t('ai.placeholder.refine');
            case 'explain':
                return t('ai.placeholder.explain');
            case 'chat':
                return t('ai.placeholder.chat');
            default:
                return t('ai.placeholder.default');
        }
    };

    const getSubmitText = () => {
        switch (mode.value) {
            case 'generate':
                return t('ai.generate');
            case 'refine':
                return t('ai.refine');
            case 'explain':
                return t('ai.explain');
            case 'chat':
                return t('ai.send');
            default:
                return t('ai.send');
        }
    };

    // Methods
    function toggleCopilot() {
        isMinimized.value = !isMinimized.value;
        emit('visibility-changed', !isMinimized.value);
    }

    function setMode(newMode: typeof mode.value) {
        mode.value = newMode;
        clearInput();
    }

    function clearInput() {
        userInput.value = '';
    }

    async function handleSubmit() {
        if (!userInput.value.trim() || isLoading.value) return;

        const input = userInput.value.trim();
        addMessage('user', input);
        clearInput();
        isLoading.value = true;

        try {
            let response;
            
            switch (mode.value) {
                case 'generate':
                    response = await aiService.generateFlow({
                        description: input,
                        existingFlow: props.flowYaml,
                        namespace: props.namespace
                    });
                    addMessage('assistant', response.yaml, 'yaml', response.explanation);
                    break;

                case 'refine':
                    response = await aiService.refineFlow(props.flowYaml, input);
                    addMessage('assistant', response.yaml, 'yaml', response.explanation);
                    break;

                case 'explain':
                    response = await aiService.explainFlow(props.flowYaml, input);
                    addMessage('assistant', response.explanation);
                    break;

                case 'chat':
                    response = await aiService.chat(input, {
                        flowYaml: props.flowYaml,
                        conversationHistory: conversationHistory.value.map(msg => ({
                            role: msg.role,
                            content: msg.content
                        }))
                    });
                    addMessage('assistant', response.response);
                    break;
            }

            // Load suggestions if available
            if (props.flowYaml && (mode.value === 'generate' || mode.value === 'refine')) {
                loadSuggestions();
            }

        } catch (error) {
            console.error('AI Copilot error:', error);
            addMessage('assistant', t('ai.error.general'));
        } finally {
            isLoading.value = false;
        }
    }

    function addMessage(role: 'user' | 'assistant', content: string, type: 'text' | 'yaml' = 'text', explanation?: string) {
        conversationHistory.value.push({
            role,
            content,
            type,
            explanation,
            timestamp: new Date()
        });
    }

    function acceptSuggestion(yaml: string) {
        emit('update:flowYaml', yaml);
        emit('yaml-accepted', yaml);
        ElMessage.success(t('ai.suggestion_accepted'));
    }

    function copySuggestion(yaml: string) {
        navigator.clipboard.writeText(yaml);
        ElMessage.success(t('ai.copied_to_clipboard'));
    }

    function applySuggestion(suggestion: any) {
        userInput.value = suggestion.message;
    }

    function getSuggestionType(severity: string) {
        switch (severity) {
            case 'error': return 'danger';
            case 'warning': return 'warning';
            default: return 'info';
        }
    }

    function formatTime(date: Date) {
        return new Intl.DateTimeFormat('en-US', {
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    }

    async function loadSuggestions() {
        if (!props.flowYaml) return;
        
        try {
            const response = await aiService.getSuggestions(props.flowYaml);
            suggestions.value = response.suggestions;
        } catch (error) {
            console.error('Error loading suggestions:', error);
        }
    }

    async function checkAiStatus() {
        try {
            aiStatus.value = await aiService.checkAvailability();
        } catch (error) {
            console.error('Error checking AI status:', error);
            aiStatus.value = { available: false };
        }
    }

    // Lifecycle
    onMounted(async () => {
        await checkAiStatus();
        if (props.flowYaml) {
            await loadSuggestions();
        }
    });

    // Watchers
    watch(() => props.visible, (newValue) => {
        isMinimized.value = !newValue;
    });

    watch(() => props.flowYaml, async (newValue) => {
        if (newValue) {
            await loadSuggestions();
        }
    });
</script>

<style lang="scss" scoped>
    .ai-copilot {
        position: fixed;
        bottom: 20px;
        right: 20px;
        z-index: 1000;
        max-width: 400px;
        min-width: 300px;

        &.minimized {
            .copilot-toggle {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            }
        }

        .copilot-interface {
            background: var(--ks-background-primary);
            border: 1px solid var(--ks-border-primary);
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
            overflow: hidden;
        }

        .copilot-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            background: var(--ks-background-secondary);
            border-bottom: 1px solid var(--ks-border-primary);

            .header-actions {
                display: flex;
                gap: 4px;
            }
        }

        .copilot-body {
            padding: 16px;
            max-height: 500px;
            overflow-y: auto;
        }

        .quick-actions {
            .el-button-group {
                width: 100%;
                
                .el-button {
                    flex: 1;
                }
            }
        }

        .input-area {
            .input-actions {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
        }

        .conversation-history {
            max-height: 300px;
            overflow-y: auto;
            margin-bottom: 16px;

            .message {
                margin-bottom: 16px;
                
                &.user {
                    .message-content {
                        background: var(--el-color-primary-light-9);
                        margin-left: 24px;
                    }
                }

                &.assistant {
                    .message-content {
                        background: var(--ks-background-secondary);
                    }
                }

                .message-header {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    margin-bottom: 8px;
                    font-size: 12px;
                    color: var(--ks-text-secondary);

                    .message-icon {
                        width: 16px;
                        height: 16px;
                    }

                    .message-role {
                        font-weight: 500;
                    }

                    .message-time {
                        margin-left: auto;
                    }
                }

                .message-content {
                    padding: 12px;
                    border-radius: 8px;
                    font-size: 14px;
                    line-height: 1.5;

                    .yaml-response {
                        .response-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 8px;
                            font-weight: 500;

                            .response-actions {
                                display: flex;
                                gap: 8px;
                            }
                        }

                        .yaml-content {
                            background: var(--ks-background-primary);
                            border: 1px solid var(--ks-border-primary);
                            border-radius: 4px;
                            padding: 12px;
                            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
                            font-size: 12px;
                            overflow-x: auto;
                            margin-bottom: 8px;
                        }

                        .explanation {
                            font-size: 13px;
                            color: var(--ks-text-secondary);

                            p {
                                margin: 4px 0 0 0;
                            }
                        }
                    }
                }
            }
        }

        .suggestions {
            margin-bottom: 16px;

            h6 {
                margin-bottom: 8px;
                font-size: 13px;
                color: var(--ks-text-secondary);
            }

            .suggestion-chips {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;

                .suggestion-chip {
                    cursor: pointer;
                    font-size: 12px;
                    
                    &:hover {
                        opacity: 0.8;
                    }
                }
            }
        }

        .loading-state {
            text-align: center;
            padding: 16px;

            p {
                margin-top: 8px;
            }
        }
    }

    @media (max-width: 768px) {
        .ai-copilot {
            right: 10px;
            bottom: 10px;
            max-width: calc(100vw - 20px);
            min-width: 280px;
        }
    }
</style>
