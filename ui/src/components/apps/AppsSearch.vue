<template>
    <div class="apps-search">
        <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Search apps..."
            class="form-control"
            @input="onSearch"
        >
    </div>
</template>

<script setup lang="ts">
    import {ref} from "vue";

    const searchQuery = ref("");

    const emit = defineEmits<{
        search: [query: string]
    }>();

    const onSearch = () => {
        emit("search", searchQuery.value);
    };
</script>

<style scoped>
.apps-search {
    margin-bottom: 1rem;
}
</style>
