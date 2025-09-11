import {HighlighterCoreOptions, LanguageRegistration, RegexEngine, ThemeRegistrationRaw, HighlighterGeneric} from "shiki/core";

let highlighter: Promise<HighlighterGeneric<"yaml"| "python" | "javascript", "github-dark" | "github-light">> | null = null;

async function getHighlighter(
    createHighlighterCore: (options: HighlighterCoreOptions<false>) => Promise<HighlighterGeneric<"yaml"| "python" | "javascript", "github-dark" | "github-light">>,
    langs: LanguageRegistration[][],
    engine: Promise<RegexEngine>,
    githubDark: ThemeRegistrationRaw,
    githubLight: ThemeRegistrationRaw){
    if (!highlighter) {
        highlighter = createHighlighterCore({
            langs,
            themes: [githubDark, githubLight],
            engine
        });
    }
    return highlighter;
}

export async function render(markdown: string, options: {onlyLink?: boolean, permalink?: boolean, html?: boolean} = {}) {
    const {createHighlighterCore, githubDark, githubLight, markdownIt, mark, meta, mila, anchor, container, fromHighlighter, linkTag, langs, onigurumaEngine} = await import( "./markdownDeps")
    const highlighter = await getHighlighter(createHighlighterCore as any, Object.values(langs), onigurumaEngine, githubDark, githubLight);

    if(githubDark["colors"] && githubLight["colors"]) {
        githubDark["colors"]["editor.background"] = "var(--bs-gray-500)";
        githubLight["colors"]["editor.background"] = "var(--bs-white)";
    }

    const darkTheme = document.getElementsByTagName("html")[0].className.indexOf("dark") >= 0;

    let md;
    if (options.onlyLink) {
        md = new markdownIt("zero");
        md.enable(["link", "linkify", "entity", "html_inline"]);
    } else {
        md = new markdownIt();
    }

    md.use(mark)
        .use(meta)
        .use(mila, {matcher: (href) => href.match(/^https?:\/\//), attrs: {target: "_blank", rel: "noopener noreferrer"}})
        .use(anchor, {permalink: options.permalink ? anchor.permalink.ariaHidden({placement: "before"}) : undefined})
        .use(container, "warning")
        .use(container, "info")
        .use(fromHighlighter(highlighter, {theme: darkTheme ? "github-dark" : "github-light"}))
        .use(linkTag);

    md.set({
        html: options.html,
        xhtmlOut: true,
        breaks: true,
        linkify: true,
        typographer: true,
        langPrefix: "language-",
        quotes: "“”‘’",
    });

    md.renderer.rules.table_open = () => "<table class=\"table\">\n";

    return md.render(markdown);
}

/**
 * Simple markdown to HTML converter for Apps blocks
 * Uses the existing render function with safe defaults
 */
export async function markdownToHtml(markdown: string): Promise<string> {
    try {
        return await render(markdown, {html: false});
    } catch (error) {
        console.error("Error rendering markdown:", error);
        return `<div class="alert alert-danger">
            <strong>Markdown Error:</strong> Failed to render content
        </div>`;
    }
}

/**
 * Synchronous markdown to HTML converter (basic)
 * For cases where async rendering is not possible
 */
export function markdownToHtmlSync(markdown: string): string {
    if (!markdown || typeof markdown !== "string") {
        return "";
    }

    let html = markdown;

    // Convert headers
    html = html.replace(/^### (.*$)/gim, "<h3>$1</h3>");
    html = html.replace(/^## (.*$)/gim, "<h2>$1</h2>");
    html = html.replace(/^# (.*$)/gim, "<h1>$1</h1>");

    // Convert bold and italic
    html = html.replace(/\*\*\*(.*?)\*\*\*/gim, "<strong><em>$1</em></strong>");
    html = html.replace(/\*\*(.*?)\*\*/gim, "<strong>$1</strong>");
    html = html.replace(/\*(.*?)\*/gim, "<em>$1</em>");

    // Convert code blocks
    html = html.replace(/```([\s\S]*?)```/gim, "<pre><code>$1</code></pre>");
    html = html.replace(/`(.*?)`/gim, "<code>$1</code>");

    // Convert links
    html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/gim, "<a href=\"$2\" target=\"_blank\" rel=\"noopener noreferrer\">$1</a>");

    // Convert images
    html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/gim, "<img src=\"$2\" alt=\"$1\" />");

    // Convert blockquotes
    html = html.replace(/^> (.*$)/gim, "<blockquote>$1</blockquote>");

    // Convert unordered lists
    html = html.replace(/^\* (.*$)/gim, "<li>$1</li>");
    html = html.replace(/(<li>.*<\/li>)/s, "<ul>$1</ul>");

    // Convert horizontal rules
    html = html.replace(/^---$/gim, "<hr>");

    // Convert line breaks
    html = html.replace(/\n/gim, "<br>");

    // Convert paragraphs
    html = html.replace(/^(?!<[h|u|o|l|b|p|d])(.*$)/gim, "<p>$1</p>");

    // Clean up
    html = html.replace(/<br>\s*<br>/gim, "</p><p>");
    html = html.replace(/<p><\/p>/gim, "");

    return html.trim();
}
