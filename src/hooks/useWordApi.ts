import { useState, useCallback } from 'react'
import * as wordWriter from '../services/wordWriter'
import type { RewriteStyle } from '../types'

export function useWordApi() {
  const [selectedText, setSelectedText] = useState('')
  const [isOfficeReady, setIsOfficeReady] = useState(false)

  const init = useCallback(async () => {
    try {
      await Office.onReady()
      setIsOfficeReady(true)
    } catch {
      setIsOfficeReady(false)
    }
  }, [])

  const refreshSelectedText = useCallback(async () => {
    const text = await wordWriter.getSelectedText()
    setSelectedText(text)
    return text
  }, [])

  const insertText = useCallback(async (text: string, mode: 'cursor' | 'end' | 'replace' = 'cursor') => {
    switch (mode) {
      case 'cursor':
        await wordWriter.insertAtCursor(text)
        break
      case 'end':
        await wordWriter.insertAtEnd(text)
        break
      case 'replace':
        await wordWriter.replaceSelection(text)
        break
    }
  }, [])

  const insertMarkdown = useCallback(async (markdown: string) => {
    await wordWriter.insertMarkdown(markdown)
  }, [])

  const applyRewrite = useCallback(async (text: string, style: RewriteStyle) => {
    await wordWriter.applyRewrite(text, style)
  }, [])

  return {
    selectedText,
    isOfficeReady,
    init,
    refreshSelectedText,
    insertText,
    insertMarkdown,
    applyRewrite,
  }
}
