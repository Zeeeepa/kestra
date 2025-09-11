// URL validation and ISO 8601 duration parsing utilities

/**
 * Validate if a string is a valid URL
 */
export function isValidUrl(url: string): boolean {
    if (!url || typeof url !== "string") {
        return false;
    }

    try {
        const urlObj = new URL(url);
        return ["http:", "https:"].includes(urlObj.protocol);
    } catch {
        return false;
    }
}

/**
 * Parse ISO 8601 duration string to seconds
 * Examples: PT60S = 60 seconds, PT5M = 300 seconds, PT1H = 3600 seconds
 */
export function parseISO8601Duration(duration: string): number {
    if (!duration || typeof duration !== "string") {
        return 0;
    }

    // Remove 'PT' prefix if present
    const cleanDuration = duration.replace(/^PT?/i, "");
    
    // Regular expression to match duration components
    const regex = /(?:(\d+(?:\.\d+)?)H)?(?:(\d+(?:\.\d+)?)M)?(?:(\d+(?:\.\d+)?)S)?/i;
    const matches = cleanDuration.match(regex);

    if (!matches) {
        throw new Error(`Invalid ISO 8601 duration format: ${duration}`);
    }

    const hours = parseFloat(matches[1] || "0");
    const minutes = parseFloat(matches[2] || "0");
    const seconds = parseFloat(matches[3] || "0");

    return Math.floor(hours * 3600 + minutes * 60 + seconds);
}

/**
 * Convert seconds to ISO 8601 duration string
 */
export function secondsToISO8601Duration(seconds: number): string {
    if (seconds < 0) {
        throw new Error("Duration cannot be negative");
    }

    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    let duration = "PT";
    
    if (hours > 0) {
        duration += `${hours}H`;
    }
    if (minutes > 0) {
        duration += `${minutes}M`;
    }
    if (remainingSeconds > 0 || duration === "PT") {
        duration += `${remainingSeconds}S`;
    }

    return duration;
}

/**
 * Validate URL for security (prevent XSS and other attacks)
 */
export function isSecureUrl(url: string): boolean {
    if (!isValidUrl(url)) {
        return false;
    }

    const urlObj = new URL(url);
    
    // Block javascript: and data: protocols
    if (["javascript:", "data:", "vbscript:", "file:"].includes(urlObj.protocol)) {
        return false;
    }

    // Block localhost and private IP ranges in production
    if (process.env.NODE_ENV === "production") {
        const hostname = urlObj.hostname.toLowerCase();
        
        // Block localhost
        if (hostname === "localhost" || hostname === "127.0.0.1" || hostname === "::1") {
            return false;
        }
        
        // Block private IP ranges
        const privateIPRegex = /^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)/;
        if (privateIPRegex.test(hostname)) {
            return false;
        }
    }

    return true;
}

/**
 * Sanitize URL by removing potentially dangerous parameters
 */
export function sanitizeUrl(url: string): string {
    if (!isValidUrl(url)) {
        return "";
    }

    try {
        const urlObj = new URL(url);
        
        // Remove potentially dangerous query parameters
        const dangerousParams = ["javascript", "script", "eval", "onload", "onerror"];
        dangerousParams.forEach(param => {
            urlObj.searchParams.delete(param);
        });

        return urlObj.toString();
    } catch {
        return "";
    }
}

/**
 * Get domain from URL
 */
export function getDomainFromUrl(url: string): string {
    if (!isValidUrl(url)) {
        return "";
    }

    try {
        const urlObj = new URL(url);
        return urlObj.hostname;
    } catch {
        return "";
    }
}

/**
 * Check if URL is external (different domain)
 */
export function isExternalUrl(url: string): boolean {
    if (!isValidUrl(url)) {
        return false;
    }

    try {
        const urlObj = new URL(url);
        const currentDomain = window.location.hostname;
        return urlObj.hostname !== currentDomain;
    } catch {
        return false;
    }
}

/**
 * Format duration in human-readable format
 */
export function formatDuration(seconds: number): string {
    if (seconds < 60) {
        return `${seconds} second${seconds !== 1 ? "s" : ""}`;
    }
    
    if (seconds < 3600) {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        
        if (remainingSeconds === 0) {
            return `${minutes} minute${minutes !== 1 ? "s" : ""}`;
        }
        
        return `${minutes} minute${minutes !== 1 ? "s" : ""} and ${remainingSeconds} second${remainingSeconds !== 1 ? "s" : ""}`;
    }
    
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;
    
    let result = `${hours} hour${hours !== 1 ? "s" : ""}`;
    
    if (minutes > 0) {
        result += ` and ${minutes} minute${minutes !== 1 ? "s" : ""}`;
    }
    
    if (remainingSeconds > 0 && minutes === 0) {
        result += ` and ${remainingSeconds} second${remainingSeconds !== 1 ? "s" : ""}`;
    }
    
    return result;
}
