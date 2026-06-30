import { useState } from 'react'
import { DEFAULT_TEMPLATES } from '../store/prompts'

interface Props {
  onSelect: (prompt: string) => void
}

export function TemplatePicker({ onSelect }: Props) {
  const [open, setOpen] = useState(false)

  return (
    <div className="template-picker">
      <button className="btn-ghost" onClick={() => setOpen(!open)}>
        📋 模板 {open ? '▲' : '▼'}
      </button>
      {open && (
        <div className="template-grid">
          {DEFAULT_TEMPLATES.map(t => (
            <button
              key={t.id}
              className="template-card"
              onClick={() => {
                onSelect(t.prompt)
                setOpen(false)
              }}
              title={t.description}
            >
              <span className="template-icon">{t.icon}</span>
              <span className="template-name">{t.name}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
