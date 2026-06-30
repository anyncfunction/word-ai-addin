export interface AISettings {
  apiKey: string
  endpoint: string
  model: string
}

export interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: number
}

export interface Template {
  id: string
  name: string
  icon: string
  prompt: string
  description: string
}

export interface PresetPrompt {
  id: string
  name: string
  content: string
  createdAt: number
}

export type FeatureMode = 'chat' | 'write' | 'rewrite' | 'translate'

export type RewriteStyle = 'polish' | 'expand' | 'shorten' | 'professional' | 'casual'
