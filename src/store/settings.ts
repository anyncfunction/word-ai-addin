import type { AISettings } from '../types'

const STORAGE_KEY = 'word-ai-addin-settings'

const defaults: AISettings = {
  apiKey: '',
  endpoint: 'https://api.openai.com',
  model: 'gpt-3.5-turbo',
}

export function loadSettings(): AISettings {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) {
      return { ...defaults, ...JSON.parse(raw) }
    }
  } catch { /* ignore */ }
  return { ...defaults }
}

export function saveSettings(settings: AISettings): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(settings))
}

export function clearSettings(): void {
  localStorage.removeItem(STORAGE_KEY)
}
