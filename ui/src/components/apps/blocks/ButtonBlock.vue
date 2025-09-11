<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="button-block">
            <div class="button-container">
                <a 
                    :href="sanitizedUrl"
                    :target="isExternalUrl ? '_blank' : '_self'"
                    :rel="isExternalUrl ? 'noopener noreferrer' : undefined"
                    :class="[
                        'btn',
                        `btn-${buttonClass}`,
                        `btn-${buttonSize}`,
                        {'btn-disabled': disabled}
                    ]"
                    @click="handleClick"
                    :aria-disabled="disabled"
                >
                    <i v-if="icon" :class="icon" class="me-2" />
                    {{ text }}
                    <i v-if="isExternalUrl" class="fas fa-external-link-alt ms-2 small" />
                </a>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {computed} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import {isValidUrl, sanitizeUrl, isExternalUrl as checkExternalUrl} from "../../../utils/urlValidator";
    import type {ButtonBlockProps} from "../../../types/apps";

    const props = withDefaults(defineProps<ButtonBlockProps>(), {
        text: "More examples",
        url: "https://github.com/kestra-io/examples",
        style: "INFO",
        size: "MEDIUM",
        states: () => ["SUCCESS", "FAILURE"],
        className: "",
        disabled: false,
        icon: ""
    });

    const emit = defineEmits<{
        blockAction: [action: string, data: any];
        blockError: [error: string];
    }>();

    // Computed properties
    const buttonClass = computed(() => {
        switch (props.style) {
        case "SUCCESS":
            return "success";
        case "DANGER":
            return "danger";
        case "INFO":
            return "info";
        case "DEFAULT":
        default:
            return "primary";
        }
    });

    const buttonSize = computed(() => {
        switch (props.size) {
        case "SMALL":
            return "sm";
        case "LARGE":
            return "lg";
        case "MEDIUM":
        default:
            return "md";
        }
    });

    const sanitizedUrl = computed(() => {
        if (!isValidUrl(props.url)) {
            console.warn("Invalid URL provided to ButtonBlock:", props.url);
            return "#";
        }
        return sanitizeUrl(props.url);
    });

    const isExternalUrl = computed(() => {
        return checkExternalUrl(props.url);
    });

    const disabled = computed(() => {
        return props.disabled || !isValidUrl(props.url);
    });

    // Methods
    function handleClick(event: Event) {
        if (disabled.value) {
            event.preventDefault();
            return;
        }

        if (!isValidUrl(props.url)) {
            event.preventDefault();
            emit("blockError", `Invalid URL: ${props.url}`);
            return;
        }

        // Emit action for tracking
        emit("blockAction", "button_clicked", {
            url: props.url,
            text: props.text,
            style: props.style,
            external: isExternalUrl.value
        });
    }
</script>

<style scoped>
.button-block {
    text-align: center;
    padding: 1rem 0;
}

.button-container {
    display: inline-block;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.5rem 1rem;
    font-size: 1rem;
    font-weight: 500;
    line-height: 1.5;
    text-align: center;
    text-decoration: none;
    vertical-align: middle;
    cursor: pointer;
    user-select: none;
    border: 1px solid transparent;
    border-radius: 0.375rem;
    transition: all 0.15s ease-in-out;
    min-width: 120px;
}

.btn:hover {
    text-decoration: none;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn:focus {
    outline: 0;
    box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

/* Button styles */
.btn-primary {
    color: #fff;
    background-color: #007bff;
    border-color: #007bff;
}

.btn-primary:hover {
    background-color: #0056b3;
    border-color: #004085;
}

.btn-success {
    color: #fff;
    background-color: #28a745;
    border-color: #28a745;
}

.btn-success:hover {
    background-color: #1e7e34;
    border-color: #1c7430;
}

.btn-danger {
    color: #fff;
    background-color: #dc3545;
    border-color: #dc3545;
}

.btn-danger:hover {
    background-color: #c82333;
    border-color: #bd2130;
}

.btn-info {
    color: #fff;
    background-color: #17a2b8;
    border-color: #17a2b8;
}

.btn-info:hover {
    background-color: #138496;
    border-color: #117a8b;
}

/* Button sizes */
.btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
    border-radius: 0.25rem;
    min-width: 80px;
}

.btn-md {
    padding: 0.5rem 1rem;
    font-size: 1rem;
    border-radius: 0.375rem;
    min-width: 120px;
}

.btn-lg {
    padding: 0.75rem 1.5rem;
    font-size: 1.125rem;
    border-radius: 0.5rem;
    min-width: 160px;
}

/* Disabled state */
.btn-disabled {
    opacity: 0.65;
    cursor: not-allowed;
    pointer-events: none;
}

.btn-disabled:hover {
    transform: none;
    box-shadow: none;
}

/* Icon spacing */
.btn i.me-2 {
    margin-right: 0.5rem;
}

.btn i.ms-2 {
    margin-left: 0.5rem;
}

.btn i.small {
    font-size: 0.75em;
}

/* Responsive adjustments */
@media (max-width: 576px) {
    .btn {
        width: 100%;
        max-width: 300px;
    }
    
    .btn-sm {
        min-width: 100%;
    }
    
    .btn-md {
        min-width: 100%;
    }
    
    .btn-lg {
        min-width: 100%;
    }
}

/* Focus styles for accessibility */
.btn:focus-visible {
    outline: 2px solid #007bff;
    outline-offset: 2px;
}

/* Animation for loading state */
@keyframes button-pulse {
    0% {
        opacity: 1;
    }
    50% {
        opacity: 0.7;
    }
    100% {
        opacity: 1;
    }
}

.btn.loading {
    animation: button-pulse 1.5s ease-in-out infinite;
}
</style>
