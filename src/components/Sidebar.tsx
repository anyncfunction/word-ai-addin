import { useState, useEffect, useCallback } from 'react'
import type { AISettings, FeatureMode, RewriteStyle } from '../types'
import { loadSettings } from '../store/settings'
import { useStreamAI } from '../hooks/useStreamAI'
import { useWordApi } from '../hooks/useWordApi'
import { buildSystemPrompt, buildRewritePrompt } from '../services/aiClient'
import { FeatureBar } from './FeatureBar'
import { ChatPanel } from './ChatPanel'
import { TemplatePicker } from './TemplatePicker'
import { PromptManager } from './PromptManager'
import { SettingsDialog } from './SettingsDialog'
import { RewriteDialog } from './RewriteDialog'

export function Sidebar() {
  const [settings, setSettings] = useState<AISettings>(loadSettings)
  const [showSettings, setShowSettings] = useState(false)
  const [feature, setFeature] = useState<FeatureMode>('chat')
  const [input, setInput] = useState('')
  const [showRewrite, setShowRewrite] = useState(false)
  const [insertMode, setInsertMode] = useState<'cursor' | 'end'>('cursor')

  const wordApi = useWordApi()
  const ai = useStreamAI(settings)

  useEffect(() => {
    wordApi.init()
  }, [wordApi.init])

  useEffect(() => {
    if (wordApi.isOfficeReady && (feature === 'rewrite' || feature === 'translate')) {
      wordApi.refreshSelectedText()
    }
  }, [feature, wordApi.isOfficeReady, wordApi.refreshSelectedText])

  const handleSend = useCallback(async (text?: string) => {
    const content = text || input
    if (!content.trim() || ai.isStreaming) return

    let systemPrompt: string | undefined

    if (feature === 'rewrite') {
      const selected = await wordApi.refreshSelectedText()
      if (!selected) {
        alert('请先在 Word 文档中选中要改写的文本')
        return
      }
      systemPrompt = buildRewritePrompt('polish', selected)
      setShowRewrite(false)
    } else if (feature === 'translate') {
      const selected = await wordApi.refreshSelectedText()
      if (!selected) {
        alert('请先在 Word 文档中选中要翻译的文本')
        return
      }
      systemPrompt = buildSystemPrompt('translate', selected)
    } else if (feature === 'write') {
      systemPrompt = buildSystemPrompt('write')
    }

    await ai.sendMessage(content, systemPrompt)
    setInput('')
  }, [input, ai, feature, wordApi])

  const handleRewrite = useCallback(async (style: RewriteStyle) => {
    const selected = await wordApi.refreshSelectedText()
    if (!selected) {
      alert('请先在 Word 文档中选中文本')
      return
    }
    const systemPrompt = buildRewritePrompt(style, selected)
    await ai.sendMessage('请按上述要求改写', systemPrompt)
    setShowRewrite(false)
  }, [ai, wordApi])

  const handleInsert = useCallback(async (content: string) => {
    try {
      await wordApi.insertMarkdown(content)
    } catch (err: any) {
      alert(err.message)
    }
  }, [wordApi])

  const handleTemplateSelect = useCallback((prompt: string) => {
    if (feature !== 'chat' && feature !== 'write') {
      setFeature('write')
    }
    setInput(prompt)
  }, [feature])

  const needsSelection = feature === 'rewrite' || feature === 'translate'

  return (
    <div className="sidebar">
      <div className="sidebar-top">
        <span className="logo">🤖 AI 写作助手</span>
        <button className="btn-icon" onClick={() => setShowSettings(true)} title="设置">
          ⚙️
        </button>
      </div>

      <FeatureBar
        active={feature}
        onChange={setFeature}
        hasSelection={!!wordApi.selectedText}
      />

      {needsSelection && !wordApi.selectedText && (
        <div className="selection-hint">
          ⚠️ 请在 Word 文档中选中文本后再使用此功能
        </div>
      )}

      <ChatPanel
        messages={ai.messages}
        isStreaming={ai.isStreaming}
        onInsert={handleInsert}
      />

      <div className="sidebar-bottom">
        <div className="input-tools">
          <TemplatePicker onSelect={handleTemplateSelect} />
          <PromptManager onUsePrompt={(p) => setInput(p)} />
          {needsSelection && (
            <button className="btn-ghost" onClick={() => wordApi.refreshSelectedText()} title="刷新选中">
              🔄 刷新选中
            </button>
          )}
          <div className="insert-mode-toggle">
            <button
              className={`btn-sm ${insertMode === 'cursor' ? 'active' : ''}`}
              onClick={() => setInsertMode('cursor')}
              title="插入到光标位置"
            >
              📍
            </button>
            <button
              className={`btn-sm ${insertMode === 'end' ? 'active' : ''}`}
              onClick={() => setInsertMode('end')}
              title="追加到文档末尾"
            >
              📄
            </button>
          </div>
        </div>

        <div className="input-row">
          <textarea
            className="input-box"
            placeholder={
              needsSelection
                ? '输入改写要求或直接发送...'
                : feature === 'write'
                  ? '输入文档主题或要求...'
                  : '输入消息...'
            }
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={e => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault()
                handleSend()
              }
            }}
            rows={2}
            disabled={ai.isStreaming}
          />
          <div className="input-actions">
            {feature === 'rewrite' && (
              <button
                className="btn-secondary"
                onClick={() => setShowRewrite(true)}
                disabled={ai.isStreaming || !wordApi.selectedText}
              >
                🔧 选择风格
              </button>
            )}
            {ai.isStreaming ? (
              <button className="btn-stop" onClick={ai.stopGeneration}>
                ⏹ 停止
              </button>
            ) : (
              <button className="btn-send" onClick={() => handleSend()} disabled={!input.trim()}>
                ➤
              </button>
            )}
            {ai.messages.length > 0 && !ai.isStreaming && (
              <button className="btn-icon" onClick={ai.clearMessages} title="清空对话">
                🗑️
              </button>
            )}
          </div>
        </div>
      </div>

      <SettingsDialog
        open={showSettings}
        onClose={() => setShowSettings(false)}
        onSaved={setSettings}
      />

      <RewriteDialog
        selectedText={wordApi.selectedText}
        open={showRewrite}
        onClose={() => setShowRewrite(false)}
        onApply={handleRewrite}
        isGenerating={ai.isStreaming}
      />
    </div>
  )
}
