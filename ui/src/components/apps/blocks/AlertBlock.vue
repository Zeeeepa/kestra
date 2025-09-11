<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="alert-block">
            <div 
                :class="[
                    'alert',
                    `alert-${alertClass}`,
                    {'alert-dismissible': dismissible}
                ]"
                role="alert"
            >
                <div class="alert-content">
                    <div v-if="showIcon" class="alert-icon">
                        <i :class="iconClass" />
                    </div>
                    <div class="alert-text">
                        <div 
                            class="alert-message"
                            v-html="renderedContent"
                        />
                    </div>
                </div>
                <button 
                    v-if="dismissible"
                    type="button" 
                    class="btn-close" 
                    @click="dismiss"
                    aria-label="Close"
                />
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {computed, ref} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import {markdownToHtmlSync} from "../../../utils/markdown";
    import type {AlertBlockProps} from "../../../types/apps";

    const props = withDefaults(defineProps<AlertBlockProps>(), {
        style: "ERROR",
        showIcon: true,
        content: "An error occurred!",
        states: () => ["FAILURE"],
        className: "",
        dismissible: false
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
    }>();

    // Reactive state
    const dismissed = ref(false);

    // Computed properties
    const alertClass = computed(() => {
        switch (props.style) {
        case "SUCCESS":
            return "success";
        case "WARNING":
            return "warning";
        case "ERROR":
            return "danger";
        case "INFO":
        default:
            return "info";
        }
    });

    const iconClass = computed(() => {
        switch (props.style) {
        case "SUCCESS":
            return "fas fa-check-circle";
        case "WARNING":
            return "fas fa-exclamation-triangle";
        case "ERROR":
            return "fas fa-times-circle";
        case "INFO":
        default:
            return "fas fa-info-circle";
        }
    });

    const renderedContent = computed(() => {
        try {
            return markdownToHtmlSync(props.content);
        } catch (error) {
            console.error("Error rendering alert content:", error);
            return props.content;
        }
    });

    const dismissible = computed(() => {
        return props.dismissible !== undefined ? props.dismissible : false;
    });

    // Methods
    function dismiss() {
        dismissed.value = true;
        emit("blockAction", "alert_dismissed", {style: props.style, content: props.content});
    }
</script>

<style scoped>
.alert-block {
    margin: 1rem 0;
}

.alert {
    position: relative;
    padding: 0.75rem 1rem;
    margin-bottom: 1rem;
    border: 1px solid transparent;
    border-radius: 0.375rem;
    display: flex;
    align-items: flex-start;
}

.alert-content {
    display: flex;
    align-items: flex-start;
    flex: 1;
}

.alert-icon {
    margin-right: 0.75rem;
    font-size: 1.25rem;
    line-height: 1;
    margin-top: 0.125rem;
}

.alert-text {
    flex: 1;
}

.alert-message {
    margin: 0;
    line-height: 1.5;
}

/* Alert styles */
.alert-success {
    color: #0f5132;
    background-color: #d1e7dd;
    border-color: #badbcc;
}

.alert-success .alert-icon {
    color: #198754;
}

.alert-info {
    color: #055160;
    background-color: #cff4fc;
    border-color: #b6effb;
}

.alert-info .alert-icon {
    color: #0dcaf0;
}

.alert-warning {
    color: #664d03;
    background-color: #fff3cd;
    border-color: #ffecb5;
}

.alert-warning .alert-icon {
    color: #ffc107;
}

.alert-danger {
    color: #842029;
    background-color: #f8d7da;
    border-color: #f5c2c7;
}

.alert-danger .alert-icon {
    color: #dc3545;
}

/* Close button */
.btn-close {
    position: absolute;
    top: 0.75rem;
    right: 1rem;
    z-index: 2;
    padding: 0.25rem;
    background: transparent url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='%23000'%3e%3cpath d='m.235 1.027 4.61-4.61c.317-.317.832-.317 1.149 0l4.61 4.61c.317.317.317.832 0 1.149l-4.61 4.61c-.317.317-.832.317-1.149 0l-4.61-4.61c-.317-.317-.317-.832 0-1.149z'/%3e%3c/svg%3e") center/1em auto no-repeat;
    border: 0;
    border-radius: 0.375rem;
    opacity: 0.5;
    cursor: pointer;
    width: 1em;
    height: 1em;
}

.btn-close:hover {
    opacity: 0.75;
}

.btn-close:focus {
    outline: 0;
    box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
    opacity: 1;
}

/* Alert content styles */
.alert-message :deep(h1),
.alert-message :deep(h2),
.alert-message :deep(h3),
.alert-message :deep(h4),
.alert-message :deep(h5),
.alert-message :deep(h6) {
    margin-top: 0;
    margin-bottom: 0.5rem;
    font-weight: 600;
}

.alert-message :deep(p) {
    margin-bottom: 0.5rem;
}

.alert-message :deep(p:last-child) {
    margin-bottom: 0;
}

.alert-message :deep(ul),
.alert-message :deep(ol) {
    margin-bottom: 0.5rem;
    padding-left: 1.5rem;
}

.alert-message :deep(code) {
    background-color: rgba(0, 0, 0, 0.1);
    padding: 0.125rem 0.25rem;
    border-radius: 0.25rem;
    font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
    font-size: 0.875em;
}

.alert-message :deep(a) {
    color: inherit;
    text-decoration: underline;
}

.alert-message :deep(a:hover) {
    text-decoration: none;
}

/* Responsive adjustments */
@media (max-width: 576px) {
    .alert {
        padding: 0.5rem 0.75rem;
    }
    
    .alert-icon {
        margin-right: 0.5rem;
        font-size: 1rem;
    }
    
    .btn-close {
        top: 0.5rem;
        right: 0.75rem;
    }
}

/* Animation for dismissible alerts */
.alert-dismissible {
    padding-right: 3rem;
}

/* Hide dismissed alerts */
.alert-block:has(.alert[style*="display: none"]) {
    display: none;
}
</style>
