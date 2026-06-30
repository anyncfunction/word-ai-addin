import { useState, useRef, useCallback } from 'react'
import type { Message, AISettings } from '../types'
import { streamChat } from '../services/aiClient'

export function useStreamAI(settings: AISettings) {
  const [messages, setMessages] = useState<Message[]>([])
  const [isStreaming, setIsStreaming] = useState(false)
  const [streamingContent, setStreamingContent] = useState('')
  const abortRef = useRef<AbortController | null>(null)

  const sendMessage = useCallback(async (
    userContent: string,
    systemMessage?: string,
  ) => {
    const userMsg: Message = {
      id: crypto.randomUUID(),
      role: 'user',
      content: userContent,
      timestamp: Date.now(),
    }

    const assistantId = crypto.randomUUID()
    const assistantMsg: Message = {
      id: assistantId,
      role: 'assistant',
      content: '',
      timestamp: Date.now(),
    }

    setMessages(prev => [...prev, userMsg, assistantMsg])
    setStreamingContent('')
    setIsStreaming(true)

    const abort = new AbortController()
    abortRef.current = abort

    const msgs = systemMessage
      ? [{ id: 'system', role: 'system' as const, content: systemMessage, timestamp: 0 }, ...messages, userMsg]
      : [...messages, userMsg]

    await streamChat(settings, msgs, {
      onToken: (token) => {
        setStreamingContent(prev => prev + token)
        setMessages(prev =>
          prev.map(m => m.id === assistantId ? { ...m, content: m.content + token } : m),
        )
      },
      onDone: () => {
        setIsStreaming(false)
        abortRef.current = null
      },
      onError: (error) => {
        setIsStreaming(false)
        setMessages(prev =>
          prev.map(m => m.id === assistantId
            ? { ...m, content: `\n\n**错误**: ${error.message}` }
            : m,
          ),
        )
        abortRef.current = null
      },
    }, abort.signal)

    return assistantId
  }, [settings, messages])

  const stopGeneration = useCallback(() => {
    abortRef.current?.abort()
    abortRef.current = null
    setIsStreaming(false)
  }, [])

  const clearMessages = useCallback(() => {
    setMessages([])
    setStreamingContent('')
  }, [])

  const removeMessage = useCallback((id: string) => {
    setMessages(prev => prev.filter(m => m.id !== id))
  }, [])

  return {
    messages,
    isStreaming,
    streamingContent,
    sendMessage,
    stopGeneration,
    clearMessages,
    removeMessage,
  }
}
