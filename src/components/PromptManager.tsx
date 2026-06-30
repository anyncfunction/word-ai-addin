import { useState, useEffect } from 'react'
import type { PresetPrompt } from '../types'
import { loadPresetPrompts, savePresetPrompts } from '../store/prompts'

interface Props {
  onUsePrompt: (content: string) => void
}

export function PromptManager({ onUsePrompt }: Props) {
  const [open, setOpen] = useState(false)
  const [prompts, setPrompts] = useState<PresetPrompt[]>([])
  const [editing, setEditing] = useState(false)
  const [name, setName] = useState('')
  const [content, setContent] = useState('')
  const [editId, setEditId] = useState<string | null>(null)

  useEffect(() => {
    if (open) setPrompts(loadPresetPrompts())
  }, [open])

  const handleSave = () => {
    if (!name.trim() || !content.trim()) return
    let updated: PresetPrompt[]
    if (editId) {
      updated = prompts.map(p =>
        p.id === editId ? { ...p, name: name.trim(), content: content.trim() } : p,
      )
    } else {
      updated = [...prompts, { id: crypto.randomUUID(), name: name.trim(), content: content.trim(), createdAt: Date.now() }]
    }
    setPrompts(updated)
    savePresetPrompts(updated)
    setEditing(false)
    setName('')
    setContent('')
    setEditId(null)
  }

  const handleEdit = (p: PresetPrompt) => {
    setEditId(p.id)
    setName(p.name)
    setContent(p.content)
    setEditing(true)
  }

  const handleDelete = (id: string) => {
    const updated = prompts.filter(p => p.id !== id)
    setPrompts(updated)
    savePresetPrompts(updated)
  }

  return (
    <div className="prompt-manager">
      <button className="btn-ghost" onClick={() => setOpen(!open)}>
        📌 快捷 Prompt {open ? '▲' : '▼'}
      </button>
      {open && (
        <div className="prompt-panel">
          {prompts.map(p => (
            <div key={p.id} className="prompt-item">
              <button className="prompt-btn" onClick={() => onUsePrompt(p.content)}>
                {p.name}
              </button>
              <button className="btn-icon-sm" onClick={() => handleEdit(p)} title="编辑">✏️</button>
              <button className="btn-icon-sm" onClick={() => handleDelete(p.id)} title="删除">🗑️</button>
            </div>
          ))}
          {editing && (
            <div className="prompt-edit">
              <input placeholder="名称" value={name} onChange={e => setName(e.target.value)} />
              <textarea placeholder="Prompt 内容..." rows={3} value={content} onChange={e => setContent(e.target.value)} />
              <div className="prompt-edit-actions">
                <button className="btn-primary" onClick={handleSave}>保存</button>
                <button className="btn-secondary" onClick={() => { setEditing(false); setName(''); setContent(''); setEditId(null) }}>取消</button>
              </div>
            </div>
          )}
          {!editing && (
            <button className="btn-add-prompt" onClick={() => setEditing(true)}>+ 添加 Prompt</button>
          )}
        </div>
      )}
    </div>
  )
}
