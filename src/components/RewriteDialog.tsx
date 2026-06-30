import type { RewriteStyle } from '../types'

interface Props {
  selectedText: string
  open: boolean
  onClose: () => void
  onApply: (style: RewriteStyle) => void
  isGenerating: boolean
}

const styles: { key: RewriteStyle; label: string; icon: string }[] = [
  { key: 'polish', label: '润色', icon: '✨' },
  { key: 'expand', label: '扩写', icon: '📖' },
  { key: 'shorten', label: '缩写', icon: '📐' },
  { key: 'professional', label: '正式', icon: '👔' },
  { key: 'casual', label: '口语化', icon: '💬' },
]

export function RewriteDialog({ open, onClose, onApply, isGenerating }: Props) {
  if (!open) return null

  return (
    <div className="overlay">
      <div className="dialog dialog-sm">
        <div className="dialog-header">
          <h3>🔧 改写</h3>
          <button className="btn-icon" onClick={onClose}>✕</button>
        </div>
        <div className="dialog-body">
          <p className="hint" style={{ marginBottom: 12 }}>选择改写风格：</p>
          <div className="rewrite-grid">
            {styles.map(s => (
              <button
                key={s.key}
                className="rewrite-btn"
                onClick={() => onApply(s.key)}
                disabled={isGenerating}
              >
                <span>{s.icon}</span>
                <span>{s.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
