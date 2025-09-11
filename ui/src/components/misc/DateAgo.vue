<template>
    <span 
        :title="fullDate"
        class="date-ago"
    >
        {{ timeAgo }}
    </span>
</template>

<script setup lang="ts">
    import {computed} from "vue";

    interface Props {
        date: string | Date;
        showFullDate?: boolean;
    }

    const props = withDefaults(defineProps<Props>(), {
        showFullDate: false
    });

    const fullDate = computed(() => {
        const dateObj = typeof props.date === "string" ? new Date(props.date) : props.date;
        return dateObj.toLocaleString();
    });

    const timeAgo = computed(() => {
        const dateObj = typeof props.date === "string" ? new Date(props.date) : props.date;
        const now = new Date();
        const diffInSeconds = Math.floor((now.getTime() - dateObj.getTime()) / 1000);

        if (diffInSeconds < 60) {
            return "just now";
        }

        const diffInMinutes = Math.floor(diffInSeconds / 60);
        if (diffInMinutes < 60) {
            return `${diffInMinutes}m ago`;
        }

        const diffInHours = Math.floor(diffInMinutes / 60);
        if (diffInHours < 24) {
            return `${diffInHours}h ago`;
        }

        const diffInDays = Math.floor(diffInHours / 24);
        if (diffInDays < 30) {
            return `${diffInDays}d ago`;
        }

        const diffInMonths = Math.floor(diffInDays / 30);
        if (diffInMonths < 12) {
            return `${diffInMonths}mo ago`;
        }

        const diffInYears = Math.floor(diffInMonths / 12);
        return `${diffInYears}y ago`;
    });
</script>

<style scoped>
.date-ago {
    cursor: help;
}
</style>
