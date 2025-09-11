<template>
    <div 
        class="markdown-tooltip-wrapper"
        :title="plainText"
        @mouseenter="showTooltip = true"
        @mouseleave="showTooltip = false"
    >
        <slot />
        
        <!-- Tooltip -->
        <div 
            v-if="showTooltip && content" 
            class="tooltip-content"
            :class="{'tooltip-visible': showTooltip}"
        >
            <div v-if="isMarkdown" v-html="renderedMarkdown" class="markdown-content" />
            <div v-else class="plain-content">
                {{ content }}
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
    import {ref, computed} from "vue";

    interface Props {
        content?: string;
        markdown?: boolean;
        maxWidth?: string;
        placement?: "top" | "bottom" | "left" | "right";
    }

    const props = withDefaults(defineProps<Props>(), {
        content: "",
        markdown: true,
        maxWidth: "300px",
        placement: "top"
    });

    const showTooltip = ref(false);

    const isMarkdown = computed(() => {
        return props.markdown && props.content && (
            props.content.includes("**") || 
            props.content.includes("*") || 
            props.content.includes("`") ||
            props.content.includes("#") ||
            props.content.includes("[") ||
            props.content.includes("\n")
        );
    });

    const plainText = computed(() => {
        if (!props.content) return "";
        // Simple markdown to plain text conversion
        return props.content
            .replace(/\*\*(.*?)\*\*/g, "$1")  // Bold
            .replace(/\*(.*?)\*/g, "$1")      // Italic
            .replace(/`(.*?)`/g, "$1")        // Code
            .replace(/#{1,6}\s*(.*)/g, "$1")  // Headers
            .replace(/\[(.*?)\]\(.*?\)/g, "$1") // Links
            .replace(/\n/g, " ")              // Newlines
            .trim();
    });

    const renderedMarkdown = computed(() => {
        if (!props.content || !isMarkdown.value) return "";
    
        // Simple markdown rendering
        let html = props.content
            .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")  // Bold
            .replace(/\*(.*?)\*/g, "<em>$1</em>")              // Italic
            .replace(/`(.*?)`/g, "<code>$1</code>")            // Inline code
            .replace(/#{6}\s*(.*)/g, "<h6>$1</h6>")            // H6
            .replace(/#{5}\s*(.*)/g, "<h5>$1</h5>")            // H5
            .replace(/#{4}\s*(.*)/g, "<h4>$1</h4>")            // H4
            .replace(/#{3}\s*(.*)/g, "<h3>$1</h3>")            // H3
            .replace(/#{2}\s*(.*)/g, "<h2>$1</h2>")            // H2
            .replace(/#{1}\s*(.*)/g, "<h1>$1</h1>")            // H1
            .replace(/\[(.*?)\]\((.*?)\)/g, "<a href=\"$2\" target=\"_blank\">$1</a>") // Links
            .replace(/\n/g, "<br>");                           // Line breaks
    
        return html;
    });
</script>

<style scoped>
.markdown-tooltip-wrapper {
    position: relative;
    display: inline-block;
}

.tooltip-content {
    position: absolute;
    z-index: 1000;
    background: #333;
    color: white;
    padding: 8px 12px;
    border-radius: 4px;
    font-size: 0.875rem;
    line-height: 1.4;
    max-width: v-bind(maxWidth);
    word-wrap: break-word;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.2s, visibility 0.2s;
    
    /* Default placement: top */
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-bottom: 5px;
}

.tooltip-content.tooltip-visible {
    opacity: 1;
    visibility: visible;
}

.tooltip-content::after {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    border: 5px solid transparent;
    border-top-color: #333;
}

/* Placement variations */
.tooltip-content.placement-bottom {
    top: 100%;
    bottom: auto;
    margin-top: 5px;
    margin-bottom: 0;
}

.tooltip-content.placement-bottom::after {
    top: -10px;
    border-top-color: transparent;
    border-bottom-color: #333;
}

.tooltip-content.placement-left {
    right: 100%;
    left: auto;
    top: 50%;
    bottom: auto;
    transform: translateY(-50%);
    margin-right: 5px;
    margin-bottom: 0;
}

.tooltip-content.placement-left::after {
    left: 100%;
    top: 50%;
    transform: translateY(-50%);
    border-left-color: #333;
    border-top-color: transparent;
}

.tooltip-content.placement-right {
    left: 100%;
    right: auto;
    top: 50%;
    bottom: auto;
    transform: translateY(-50%);
    margin-left: 5px;
    margin-bottom: 0;
}

.tooltip-content.placement-right::after {
    right: 100%;
    top: 50%;
    transform: translateY(-50%);
    border-right-color: #333;
    border-top-color: transparent;
}

.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3),
.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) {
    margin: 0.5em 0 0.25em 0;
    font-weight: bold;
}

.markdown-content :deep(h1) { font-size: 1.2em; }
.markdown-content :deep(h2) { font-size: 1.1em; }
.markdown-content :deep(h3) { font-size: 1.05em; }
.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) { font-size: 1em; }

.markdown-content :deep(code) {
    background: rgba(255, 255, 255, 0.1);
    padding: 2px 4px;
    border-radius: 2px;
    font-family: monospace;
    font-size: 0.9em;
}

.markdown-content :deep(a) {
    color: #66b3ff;
    text-decoration: underline;
}

.markdown-content :deep(a:hover) {
    color: #99ccff;
}

.plain-content {
    white-space: pre-wrap;
}
</style>
