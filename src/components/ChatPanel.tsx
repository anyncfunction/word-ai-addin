import { useEffect, useRef } from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import type { Message } from '../types'

interface Props {
  messages: Message[]
  isStreaming: boolean
  onInsert: (content: string) => void
}

export function ChatPanel({ messages, isStreaming, onInsert }: Props) {
  const bottomRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  if (messages.length === 0) {
    return (
      <div className="chat-empty">
        <div className="empty-icon">🤖</div>
        <p>选择上方功能开始写作</p>
        <p className="hint">可选模板快速开始，或在输入框直接输入</p>
      </div>
    )
  }

  return (
    <div className="chat-panel">
      {messages.map(m => {
        if (m.role === 'system') return null
        return (
          <div key={m.id} className={`message ${m.role}`}>
            <div className="message-avatar">
              {m.role === 'user' ? '👤' : '🤖'}
            </div>
            <div className="message-content">
              <div className="message-bubble">
                <ReactMarkdown remarkPlugins={[remarkGfm]}>
                  {m.content || (isStreaming ? '...' : '')}
                </ReactMarkdown>
              </div>
              {m.role === 'assistant' && m.content && !isStreaming && (
                <div className="message-actions">
                  <button className="btn-action" onClick={() => onInsert(m.content)}>
                    📄 插入文档
                  </button>
                  <button className="btn-action" onClick={() => navigator.clipboard.writeText(m.content)}>
                    📋 复制
                  </button>
                </div>
              )}
            </div>
          </div>
        )
      })}
      {isStreaming && (
        <div className="streaming-indicator">
          <span className="dot-pulse" />
        </div>
      )}
      <div ref={bottomRef} />
    </div>
  )
}
