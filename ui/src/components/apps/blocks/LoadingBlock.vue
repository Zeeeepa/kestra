<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="loading-block">
            <div class="loading-content">
                <div class="loading-spinner">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
                <div class="loading-text">
                    <h5 class="mb-2">
                        Processing your request...
                    </h5>
                    <p class="text-muted mb-0">
                        Please wait while we execute your workflow.
                    </p>
                </div>
            </div>
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import BaseBlock from "./BaseBlock.vue";
    import type {LoadingBlockProps} from "../../../types/apps";

    withDefaults(defineProps<LoadingBlockProps>(), {
        states: () => ["RUNNING"],
        className: ""
    });
</script>

<style scoped>
.loading-block {
    padding: 3rem 2rem;
    text-align: center;
    background-color: #f8f9fa;
    border-radius: 0.5rem;
    border: 1px solid #e9ecef;
}

.loading-content {
    max-width: 300px;
    margin: 0 auto;
}

.loading-spinner {
    margin-bottom: 1.5rem;
}

.spinner-border {
    width: 3rem;
    height: 3rem;
    border-width: 0.3em;
}

.spinner-border.text-primary {
    color: #007bff !important;
}

.loading-text h5 {
    color: #495057;
    font-weight: 600;
}

.loading-text p {
    color: #6c757d;
    font-size: 0.9rem;
}

.visually-hidden {
    position: absolute !important;
    width: 1px !important;
    height: 1px !important;
    padding: 0 !important;
    margin: -1px !important;
    overflow: hidden !important;
    clip: rect(0, 0, 0, 0) !important;
    white-space: nowrap !important;
    border: 0 !important;
}

/* Animation for spinner */
@keyframes spinner-border {
    to {
        transform: rotate(360deg);
    }
}

.spinner-border {
    display: inline-block;
    vertical-align: -0.125em;
    border: 0.25em solid currentcolor;
    border-right-color: transparent;
    border-radius: 50%;
    animation: 0.75s linear infinite spinner-border;
}

/* Responsive adjustments */
@media (max-width: 576px) {
    .loading-block {
        padding: 2rem 1rem;
    }
    
    .spinner-border {
        width: 2.5rem;
        height: 2.5rem;
    }
}
</style>
