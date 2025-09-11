<template>
    <span 
        class="badge"
        :class="getBadgeClass(status)"
        :title="title || status"
    >
        <i v-if="showIcon" :class="getIconClass(status)" class="me-1" />
        {{ displayText || status }}
    </span>
</template>

<script setup lang="ts">
    interface Props {
        status: string;
        displayText?: string;
        title?: string;
        showIcon?: boolean;
    }

    const _props = withDefaults(defineProps<Props>(), {
        displayText: "",
        title: "",
        showIcon: false
    });

    const getBadgeClass = (status: string) => {
        switch (status?.toLowerCase()) {
        case "success":
        case "completed":
        case "active":
        case "running":
            return "bg-success";
        case "failed":
        case "error":
        case "cancelled":
            return "bg-danger";
        case "warning":
        case "paused":
            return "bg-warning";
        case "pending":
        case "queued":
        case "waiting":
            return "bg-info";
        case "draft":
        case "inactive":
        case "disabled":
            return "bg-secondary";
        default:
            return "bg-primary";
        }
    };

    const getIconClass = (status: string) => {
        switch (status?.toLowerCase()) {
        case "success":
        case "completed":
            return "fas fa-check-circle";
        case "failed":
        case "error":
            return "fas fa-times-circle";
        case "warning":
            return "fas fa-exclamation-triangle";
        case "running":
        case "active":
            return "fas fa-play-circle";
        case "paused":
            return "fas fa-pause-circle";
        case "pending":
        case "queued":
        case "waiting":
            return "fas fa-clock";
        case "cancelled":
            return "fas fa-ban";
        default:
            return "fas fa-circle";
        }
    };
</script>

<style scoped>
.badge {
    font-size: 0.8em;
}
</style>
