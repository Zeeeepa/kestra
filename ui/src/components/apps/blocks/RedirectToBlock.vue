<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="redirect-block">
            <div class="redirect-content">
                <div class="redirect-info">
                    <i class="fas fa-external-link-alt me-2" />
                    <span>Redirecting to: <strong>{{ displayUrl }}</strong></span>
                </div>
                
                <div v-if="delaySeconds > 0" class="redirect-countdown">
                    <div class="progress mb-2">
                        <div 
                            class="progress-bar progress-bar-striped progress-bar-animated"
                            :style="{width: progressPercentage + '%'}"
                        />
                    </div>
                    <small class="text-muted">
                        Redirecting in {{ remainingSeconds }} second{{ remainingSeconds !== 1 ? 's' : '' }}...
                    </small>
                </div>

                <div class="redirect-actions mt-3">
                    <button 
                        class="btn btn-primary me-2"
                        @click="redirectNow"
                        :disabled="redirecting"
                    >
                        <i class="fas fa-arrow-right me-1" />
                        Go Now
                    </button>
                    <button 
                        class="btn btn-outline-secondary"
                        @click="cancelRedirect"
                        v-if="delaySeconds > 0 && !redirectComplete"
                    >
                        <i class="fas fa-times me-1" />
                        Cancel
                    </button>
                </div>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {computed, ref, onMounted, onUnmounted} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import {parseISO8601Duration, isValidUrl} from "../../../utils/urlValidator";
    import type {RedirectToBlockProps} from "../../../types/apps";

    const props = withDefaults(defineProps<RedirectToBlockProps>(), {
        url: "https://kestra.io/docs",
        delay: "PT60S",
        states: () => [],
        className: ""
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    // Reactive state
    const remainingSeconds = ref(0);
    const redirecting = ref(false);
    const redirectComplete = ref(false);
    const intervalId = ref<number | null>(null);

    // Computed properties
    const delaySeconds = computed(() => {
        try {
            return parseISO8601Duration(props.delay || "PT0S");
        } catch {
            console.warn("Invalid delay format, using 0 seconds:", props.delay);
            return 0;
        }
    });

    const displayUrl = computed(() => {
        return props.url.length > 50 ? props.url.substring(0, 47) + "..." : props.url;
    });

    const progressPercentage = computed(() => {
        if (delaySeconds.value === 0) return 100;
        return ((delaySeconds.value - remainingSeconds.value) / delaySeconds.value) * 100;
    });

    // Methods
    function validateUrl(): boolean {
        if (!isValidUrl(props.url)) {
            emit("blockError", `Invalid URL: ${props.url}`);
            return false;
        }
        return true;
    }

    function startCountdown() {
        if (delaySeconds.value <= 0) {
            redirectNow();
            return;
        }

        remainingSeconds.value = delaySeconds.value;
    
        intervalId.value = window.setInterval(() => {
            remainingSeconds.value--;
        
            if (remainingSeconds.value <= 0) {
                redirectNow();
            }
        }, 1000);
    }

    function redirectNow() {
        if (redirecting.value || redirectComplete.value) return;
    
        if (!validateUrl()) return;

        redirecting.value = true;
    
        // Clear countdown
        if (intervalId.value) {
            clearInterval(intervalId.value);
            intervalId.value = null;
        }

        // Emit action for tracking
        emit("blockAction", "redirect", {url: props.url, delay: props.delay});

        // Perform redirect
        try {
            window.open(props.url, "_blank", "noopener,noreferrer");
            redirectComplete.value = true;
        } catch (error) {
            emit("blockError", `Failed to redirect: ${error}`);
            redirecting.value = false;
        }
    }

    function cancelRedirect() {
        if (intervalId.value) {
            clearInterval(intervalId.value);
            intervalId.value = null;
        }
    
        remainingSeconds.value = 0;
        emit("blockAction", "redirect_cancelled", {url: props.url});
    }

    // Lifecycle
    onMounted(() => {
        if (validateUrl()) {
            startCountdown();
        }
    });

    onUnmounted(() => {
        if (intervalId.value) {
            clearInterval(intervalId.value);
        }
    });
</script>

<style scoped>
.redirect-block {
    padding: 1.5rem;
    border: 2px dashed #007bff;
    border-radius: 0.5rem;
    background-color: #f8f9fa;
    text-align: center;
}

.redirect-content {
    max-width: 400px;
    margin: 0 auto;
}

.redirect-info {
    font-size: 1.1rem;
    margin-bottom: 1rem;
    color: #495057;
}

.redirect-info i {
    color: #007bff;
}

.redirect-countdown {
    margin: 1rem 0;
}

.progress {
    height: 8px;
    background-color: #e9ecef;
    border-radius: 4px;
    overflow: hidden;
}

.progress-bar {
    background-color: #007bff;
    transition: width 1s linear;
}

.progress-bar-striped {
    background-image: linear-gradient(45deg, rgba(255, 255, 255, 0.15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, 0.15) 50%, rgba(255, 255, 255, 0.15) 75%, transparent 75%, transparent);
    background-size: 1rem 1rem;
}

.progress-bar-animated {
    animation: progress-bar-stripes 1s linear infinite;
}

@keyframes progress-bar-stripes {
    0% {
        background-position: 1rem 0;
    }
    100% {
        background-position: 0 0;
    }
}

.redirect-actions {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    flex-wrap: wrap;
}

.btn {
    padding: 0.5rem 1rem;
    border: 1px solid transparent;
    border-radius: 0.375rem;
    font-size: 0.875rem;
    font-weight: 500;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.15s ease-in-out;
}

.btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}

.btn-primary {
    color: #fff;
    background-color: #007bff;
    border-color: #007bff;
}

.btn-primary:hover:not(:disabled) {
    background-color: #0056b3;
    border-color: #004085;
}

.btn-outline-secondary {
    color: #6c757d;
    border-color: #6c757d;
    background-color: transparent;
}

.btn-outline-secondary:hover:not(:disabled) {
    color: #fff;
    background-color: #6c757d;
    border-color: #6c757d;
}

/* Responsive adjustments */
@media (max-width: 576px) {
    .redirect-block {
        padding: 1rem;
    }
    
    .redirect-actions {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
    }
}
</style>
