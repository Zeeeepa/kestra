<template>
    <div class="labels">
        <span 
            v-for="label in labels" 
            :key="label.key || label"
            class="badge bg-secondary me-1"
            :title="typeof label === 'object' ? `${label.key}: ${label.value}` : label"
        >
            <template v-if="typeof label === 'object'">
                {{ label.key }}: {{ label.value }}
            </template>
            <template v-else>
                {{ label }}
            </template>
        </span>
        <span v-if="!labels || labels.length === 0" class="text-muted">
            No labels
        </span>
    </div>
</template>

<script setup lang="ts">
    interface Label {
        key: string;
        value: string;
    }

    interface Props {
        labels?: (Label | string)[];
    }

    defineProps<Props>();
</script>

<style scoped>
.labels .badge {
    font-size: 0.75em;
}
</style>
