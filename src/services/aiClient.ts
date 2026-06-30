import type { AISettings, Message } from '../types'

export interface StreamCallbacks {
  onToken: (token: string) => void
  onDone: () => void
  onError: (error: Error) => void
}

export function buildSystemPrompt(feature: string, selectedText?: string): string {
  switch (feature) {
    case 'write':
      return '你是一个专业的文档写作助手。请根据用户的要求生成完整的文档内容，使用 Markdown 格式输出。'
    case 'rewrite':
      return `你是一个专业的文字润色助手。请对以下文本进行润色改进。\n\n原文：\n${selectedText || ''}`
    case 'translate':
      return `你是一个专业翻译助手。请将以下文本翻译成中文（如果是中文则翻译成英文）。\n\n原文：\n${selectedText || ''}`
    default:
      return '你是一个专业的文档写作助手。请帮助用户完成文档相关任务。'
  }
}

export function buildRewritePrompt(style: string, selectedText: string): string {
  const styleMap: Record<string, string> = {
    polish: '润色以下文本，改进表达但保持原意：',
    expand: '扩写以下文本，增加更多细节和内容：',
    shorten: '缩写以下文本，保留要点但更加简洁：',
    professional: '将以下文本改写为正式、专业的风格：',
    casual: '将以下文本改写为口语化、轻松的风格：',
  }
  return `${styleMap[style] || styleMap.polish}\n\n${selectedText}`
}

export async function streamChat(
  settings: AISettings,
  messages: Message[],
  callbacks: StreamCallbacks,
  signal?: AbortSignal,
): Promise<void> {
  const { apiKey, endpoint, model } = settings

  if (!apiKey || !endpoint || !model) {
    callbacks.onError(new Error('请先配置 API Key、接口地址和模型名称'))
    return
  }

  const url = `${endpoint.replace(/\/+$/, '')}/v1/chat/completions`

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: messages.map(({ role, content }) => ({ role, content })),
        stream: true,
      }),
      signal,
    })

    if (!response.ok) {
      const errText = await response.text().catch(() => '')
      callbacks.onError(new Error(`API 请求失败 (${response.status}): ${errText}`))
      return
    }

    const reader = response.body?.getReader()
    if (!reader) {
      callbacks.onError(new Error('响应体不可读'))
      return
    }

    const decoder = new TextDecoder()
    let buffer = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split('\n')
      buffer = lines.pop() || ''

      for (const line of lines) {
        const trimmed = line.trim()
        if (!trimmed || !trimmed.startsWith('data: ')) continue

        const data = trimmed.slice(6)
        if (data === '[DONE]') {
          callbacks.onDone()
          return
        }

        try {
          const parsed = JSON.parse(data)
          const delta = parsed.choices?.[0]?.delta?.content
          if (delta) {
            callbacks.onToken(delta)
          }
        } catch {
          // skip malformed lines
        }
      }
    }

    callbacks.onDone()
  } catch (err) {
    if (err instanceof DOMException && err.name === 'AbortError') {
      callbacks.onDone()
      return
    }
    callbacks.onError(err instanceof Error ? err : new Error(String(err)))
  }
}

export async function testConnection(settings: AISettings): Promise<boolean> {
  const { apiKey, endpoint, model } = settings
  const url = `${endpoint.replace(/\/+$/, '')}/v1/models`

  try {
    const response = await fetch(url, {
      headers: { 'Authorization': `Bearer ${apiKey}` },
    })
    return response.ok
  } catch {
    return false
  }
}
