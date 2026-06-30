import type { RewriteStyle } from '../types'

export async function insertAtCursor(text: string): Promise<void> {
  try {
    await Word.run(async (context) => {
      const selection = context.document.getSelection()
      selection.insertText(text, Word.InsertLocation.replace)
      await context.sync()
    })
  } catch (err) {
    console.error('插入文本失败:', err)
    throw new Error('插入文档失败，请确保已打开 Word 文档')
  }
}

export async function insertAtEnd(text: string): Promise<void> {
  try {
    await Word.run(async (context) => {
      const body = context.document.body
      body.insertText(text, Word.InsertLocation.end)
      await context.sync()
    })
  } catch (err) {
    console.error('追加文本失败:', err)
    throw new Error('插入文档失败，请确保已打开 Word 文档')
  }
}

export async function replaceSelection(text: string): Promise<void> {
  try {
    await Word.run(async (context) => {
      const selection = context.document.getSelection()
      selection.insertText(text, Word.InsertLocation.replace)
      await context.sync()
    })
  } catch (err) {
    console.error('替换选中内容失败:', err)
    throw new Error('替换失败，请确保已选中文本')
  }
}

export async function getSelectedText(): Promise<string> {
  try {
    return await Word.run(async (context) => {
      const selection = context.document.getSelection()
      selection.load('text')
      await context.sync()
      return selection.text || ''
    })
  } catch {
    return ''
  }
}

export async function insertMarkdown(markdown: string): Promise<void> {
  const html = markdownToSimpleHtml(markdown)
  try {
    await Word.run(async (context) => {
      const selection = context.document.getSelection()
      selection.insertHtml(html, Word.InsertLocation.replace)
      await context.sync()
    })
  } catch {
    await insertAtCursor(markdown)
  }
}

function markdownToSimpleHtml(md: string): string {
  let html = md
    .replace(/^### (.+)$/gm, '<h3>$1</h3>')
    .replace(/^## (.+)$/gm, '<h2>$1</h2>')
    .replace(/^# (.+)$/gm, '<h1>$1</h1>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/^(\d+)\. (.+)$/gm, '<p>$1. $2</p>')
    .replace(/^- (.+)$/gm, '<p>• $1</p>')
    .replace(/\n\n/g, '</p><p>')
    .replace(/\n/g, '<br/>')
  return `<p>${html}</p>`
}

export async function applyRewrite(text: string, _style: RewriteStyle): Promise<void> {
  await replaceSelection(text)
}
