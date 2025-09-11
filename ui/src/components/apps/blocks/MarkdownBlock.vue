<template>
    <BaseBlock :type="type" :states="states" :id="id" :className="className">
        <div class="markdown-block">
            <div 
                class="markdown-content"
                v-html="renderedContent"
            />
        </div>
    </BaseBlock>
</template>

<script setup lang="ts">
    import {computed} from "vue";
    import BaseBlock from "./BaseBlock.vue";
    import {markdownToHtmlSync} from "../../../utils/markdown";
    import type {MarkdownBlockProps} from "../../../types/apps";

    const props = withDefaults(defineProps<MarkdownBlockProps>(), {
        content: "# Welcome\n\nThis is a markdown block.",
        states: () => [],
        className: ""
    });

    // Computed properties
    const renderedContent = computed(() => {
        try {
            return markdownToHtmlSync(props.content);
        } catch (error) {
            console.error("Error rendering markdown:", error);
            return `<div class="alert alert-danger">
            <strong>Markdown Error:</strong> Failed to render content
        </div>`;
        }
    });
</script>

<style scoped>
.markdown-block {
    padding: 0;
}

.markdown-content {
    line-height: 1.6;
    color: #333;
}

/* Markdown content styles */
.markdown-content :deep(h1) {
    font-size: 2rem;
    font-weight: 600;
    margin-bottom: 1rem;
    color: #1a1a1a;
    border-bottom: 2px solid #e9ecef;
    padding-bottom: 0.5rem;
}

.markdown-content :deep(h2) {
    font-size: 1.5rem;
    font-weight: 600;
    margin-top: 2rem;
    margin-bottom: 1rem;
    color: #1a1a1a;
}

.markdown-content :deep(h3) {
    font-size: 1.25rem;
    font-weight: 600;
    margin-top: 1.5rem;
    margin-bottom: 0.75rem;
    color: #1a1a1a;
}

.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) {
    font-size: 1rem;
    font-weight: 600;
    margin-top: 1rem;
    margin-bottom: 0.5rem;
    color: #1a1a1a;
}

.markdown-content :deep(p) {
    margin-bottom: 1rem;
    color: #333;
}

.markdown-content :deep(ul),
.markdown-content :deep(ol) {
    margin-bottom: 1rem;
    padding-left: 2rem;
}

.markdown-content :deep(li) {
    margin-bottom: 0.25rem;
}

.markdown-content :deep(blockquote) {
    border-left: 4px solid #007bff;
    padding-left: 1rem;
    margin: 1rem 0;
    font-style: italic;
    color: #6c757d;
    background-color: #f8f9fa;
    padding: 1rem;
    border-radius: 0.375rem;
}

.markdown-content :deep(code) {
    background-color: #f8f9fa;
    padding: 0.125rem 0.25rem;
    border-radius: 0.25rem;
    font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
    font-size: 0.875rem;
    color: #e83e8c;
}

.markdown-content :deep(pre) {
    background-color: #f8f9fa;
    padding: 1rem;
    border-radius: 0.375rem;
    overflow-x: auto;
    margin-bottom: 1rem;
    border: 1px solid #e9ecef;
}

.markdown-content :deep(pre code) {
    background-color: transparent;
    padding: 0;
    color: #333;
}

.markdown-content :deep(table) {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1rem;
    border: 1px solid #dee2e6;
}

.markdown-content :deep(th),
.markdown-content :deep(td) {
    padding: 0.75rem;
    border: 1px solid #dee2e6;
    text-align: left;
}

.markdown-content :deep(th) {
    background-color: #f8f9fa;
    font-weight: 600;
}

.markdown-content :deep(tr:nth-child(even)) {
    background-color: #f8f9fa;
}

.markdown-content :deep(a) {
    color: #007bff;
    text-decoration: none;
}

.markdown-content :deep(a:hover) {
    color: #0056b3;
    text-decoration: underline;
}

.markdown-content :deep(img) {
    max-width: 100%;
    height: auto;
    border-radius: 0.375rem;
    margin: 1rem 0;
}

.markdown-content :deep(hr) {
    border: none;
    border-top: 1px solid #dee2e6;
    margin: 2rem 0;
}

/* Alert styles for error messages */
.markdown-content :deep(.alert) {
    padding: 0.75rem 1rem;
    margin-bottom: 1rem;
    border: 1px solid transparent;
    border-radius: 0.375rem;
}

.markdown-content :deep(.alert-danger) {
    color: #721c24;
    background-color: #f8d7da;
    border-color: #f5c6cb;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .markdown-content :deep(h1) {
        font-size: 1.5rem;
    }
    
    .markdown-content :deep(h2) {
        font-size: 1.25rem;
    }
    
    .markdown-content :deep(table) {
        font-size: 0.875rem;
    }
    
    .markdown-content :deep(th),
    .markdown-content :deep(td) {
        padding: 0.5rem;
    }
}
</style>
