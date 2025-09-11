/**
 * Secure API Key Storage Utility
 * Handles storing and retrieving API keys in the browser with encryption
 */

interface ApiKeyConfig {
    gemini?: string;
    openai?: string;
    anthropic?: string;
    [key: string]: string | undefined;
}

interface StoredApiKey {
    value: string;
    timestamp: number;
    encrypted: boolean;
}

const STORAGE_KEY = 'kestra_api_keys';
const ENCRYPTION_KEY = 'kestra_encryption_key';

/**
 * Simple encryption/decryption using base64 encoding
 * Note: This is basic obfuscation, not cryptographically secure
 * For production, consider using Web Crypto API
 */
class SimpleEncryption {
    private key: string;

    constructor(key: string) {
        this.key = key;
    }

    encrypt(text: string): string {
        try {
            // Simple XOR encryption with base64 encoding
            const encrypted = text.split('').map((char, i) => 
                String.fromCharCode(char.charCodeAt(0) ^ this.key.charCodeAt(i % this.key.length))
            ).join('');
            return btoa(encrypted);
        } catch (error) {
            console.error('Encryption failed:', error);
            return text; // Fallback to plain text
        }
    }

    decrypt(encryptedText: string): string {
        try {
            const decoded = atob(encryptedText);
            const decrypted = decoded.split('').map((char, i) => 
                String.fromCharCode(char.charCodeAt(0) ^ this.key.charCodeAt(i % this.key.length))
            ).join('');
            return decrypted;
        } catch (error) {
            console.error('Decryption failed:', error);
            return encryptedText; // Fallback to encrypted text
        }
    }
}

/**
 * Generate or retrieve encryption key
 */
function getEncryptionKey(): string {
    let key = localStorage.getItem(ENCRYPTION_KEY);
    if (!key) {
        // Generate a random key
        key = Math.random().toString(36).substring(2, 15) + 
              Math.random().toString(36).substring(2, 15);
        localStorage.setItem(ENCRYPTION_KEY, key);
    }
    return key;
}

const encryption = new SimpleEncryption(getEncryptionKey());

/**
 * Validate API key format
 */
export function validateApiKey(provider: string, apiKey: string): { valid: boolean; message?: string } {
    if (!apiKey || apiKey.trim().length === 0) {
        return { valid: false, message: 'API key cannot be empty' };
    }

    switch (provider.toLowerCase()) {
        case 'gemini':
            if (!apiKey.startsWith('AIza') && !apiKey.startsWith('AI')) {
                return { valid: false, message: 'Gemini API key should start with "AIza" or "AI"' };
            }
            if (apiKey.length < 20) {
                return { valid: false, message: 'Gemini API key appears to be too short' };
            }
            break;
        
        case 'openai':
            if (!apiKey.startsWith('sk-')) {
                return { valid: false, message: 'OpenAI API key should start with "sk-"' };
            }
            if (apiKey.length < 40) {
                return { valid: false, message: 'OpenAI API key appears to be too short' };
            }
            break;
        
        case 'anthropic':
            if (!apiKey.startsWith('sk-ant-')) {
                return { valid: false, message: 'Anthropic API key should start with "sk-ant-"' };
            }
            if (apiKey.length < 50) {
                return { valid: false, message: 'Anthropic API key appears to be too short' };
            }
            break;
    }

    return { valid: true };
}

/**
 * Store API key securely
 */
export function storeApiKey(provider: string, apiKey: string): boolean {
    try {
        const validation = validateApiKey(provider, apiKey);
        if (!validation.valid) {
            throw new Error(validation.message);
        }

        const storedKeys = getStoredApiKeys();
        const encryptedKey = encryption.encrypt(apiKey);
        
        storedKeys[provider] = {
            value: encryptedKey,
            timestamp: Date.now(),
            encrypted: true
        };

        localStorage.setItem(STORAGE_KEY, JSON.stringify(storedKeys));
        return true;
    } catch (error) {
        console.error('Failed to store API key:', error);
        return false;
    }
}

/**
 * Retrieve API key
 */
export function getApiKey(provider: string): string | null {
    try {
        const storedKeys = getStoredApiKeys();
        const storedKey = storedKeys[provider];
        
        if (!storedKey) {
            return null;
        }

        if (storedKey.encrypted) {
            return encryption.decrypt(storedKey.value);
        } else {
            // Legacy unencrypted key
            return storedKey.value;
        }
    } catch (error) {
        console.error('Failed to retrieve API key:', error);
        return null;
    }
}

/**
 * Remove API key
 */
export function removeApiKey(provider: string): boolean {
    try {
        const storedKeys = getStoredApiKeys();
        delete storedKeys[provider];
        localStorage.setItem(STORAGE_KEY, JSON.stringify(storedKeys));
        return true;
    } catch (error) {
        console.error('Failed to remove API key:', error);
        return false;
    }
}

/**
 * Get all stored API key providers (without the actual keys)
 */
export function getStoredProviders(): string[] {
    try {
        const storedKeys = getStoredApiKeys();
        return Object.keys(storedKeys);
    } catch (error) {
        console.error('Failed to get stored providers:', error);
        return [];
    }
}

/**
 * Check if API key exists for provider
 */
export function hasApiKey(provider: string): boolean {
    const storedKeys = getStoredApiKeys();
    return !!storedKeys[provider];
}

/**
 * Get masked API key for display (shows only first and last few characters)
 */
export function getMaskedApiKey(provider: string): string | null {
    const apiKey = getApiKey(provider);
    if (!apiKey) {
        return null;
    }

    if (apiKey.length <= 8) {
        return '*'.repeat(apiKey.length);
    }

    const start = apiKey.substring(0, 4);
    const end = apiKey.substring(apiKey.length - 4);
    const middle = '*'.repeat(Math.max(4, apiKey.length - 8));
    
    return `${start}${middle}${end}`;
}

/**
 * Clear all API keys
 */
export function clearAllApiKeys(): boolean {
    try {
        localStorage.removeItem(STORAGE_KEY);
        return true;
    } catch (error) {
        console.error('Failed to clear API keys:', error);
        return false;
    }
}

/**
 * Export API keys configuration (encrypted)
 */
export function exportApiKeys(): string {
    const storedKeys = getStoredApiKeys();
    return JSON.stringify(storedKeys, null, 2);
}

/**
 * Import API keys configuration
 */
export function importApiKeys(configJson: string): boolean {
    try {
        const config = JSON.parse(configJson);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(config));
        return true;
    } catch (error) {
        console.error('Failed to import API keys:', error);
        return false;
    }
}

/**
 * Get stored API keys from localStorage
 */
function getStoredApiKeys(): Record<string, StoredApiKey> {
    try {
        const stored = localStorage.getItem(STORAGE_KEY);
        return stored ? JSON.parse(stored) : {};
    } catch (error) {
        console.error('Failed to parse stored API keys:', error);
        return {};
    }
}

/**
 * Test API key by making a simple request
 */
export async function testApiKey(provider: string, apiKey?: string): Promise<{ success: boolean; message: string }> {
    const keyToTest = apiKey || getApiKey(provider);
    
    if (!keyToTest) {
        return { success: false, message: 'No API key provided' };
    }

    try {
        switch (provider.toLowerCase()) {
            case 'gemini':
                // Test Gemini API key with a simple request
                const geminiResponse = await fetch('https://generativelanguage.googleapis.com/v1/models?key=' + keyToTest);
                if (geminiResponse.ok) {
                    return { success: true, message: 'Gemini API key is valid' };
                } else {
                    return { success: false, message: 'Gemini API key is invalid or expired' };
                }
            
            case 'openai':
                // Test OpenAI API key
                const openaiResponse = await fetch('https://api.openai.com/v1/models', {
                    headers: {
                        'Authorization': `Bearer ${keyToTest}`
                    }
                });
                if (openaiResponse.ok) {
                    return { success: true, message: 'OpenAI API key is valid' };
                } else {
                    return { success: false, message: 'OpenAI API key is invalid or expired' };
                }
            
            case 'anthropic':
                // Test Anthropic API key
                const anthropicResponse = await fetch('https://api.anthropic.com/v1/messages', {
                    method: 'POST',
                    headers: {
                        'x-api-key': keyToTest,
                        'anthropic-version': '2023-06-01',
                        'content-type': 'application/json'
                    },
                    body: JSON.stringify({
                        model: 'claude-3-haiku-20240307',
                        max_tokens: 1,
                        messages: [{ role: 'user', content: 'test' }]
                    })
                });
                
                if (anthropicResponse.status === 200 || anthropicResponse.status === 400) {
                    // 400 is expected for this minimal test, but means the key is valid
                    return { success: true, message: 'Anthropic API key is valid' };
                } else {
                    return { success: false, message: 'Anthropic API key is invalid or expired' };
                }
            
            default:
                return { success: false, message: 'Unknown provider' };
        }
    } catch (error) {
        console.error('API key test failed:', error);
        return { success: false, message: 'Failed to test API key: ' + (error as Error).message };
    }
}

/**
 * Get API key configuration for AI service
 */
export function getApiKeyConfig(): ApiKeyConfig {
    return {
        gemini: getApiKey('gemini') || undefined,
        openai: getApiKey('openai') || undefined,
        anthropic: getApiKey('anthropic') || undefined
    };
}
