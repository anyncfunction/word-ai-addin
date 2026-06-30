import type { FeatureMode } from '../types'

interface Props {
  active: FeatureMode
  onChange: (mode: FeatureMode) => void
  hasSelection: boolean
}

const features: { key: FeatureMode; label: string; icon: string }[] = [
  { key: 'chat', label: '对话', icon: '💬' },
  { key: 'write', label: '生成', icon: '✍️' },
  { key: 'rewrite', label: '改写', icon: '🔧' },
  { key: 'translate', label: '翻译', icon: '🌐' },
]

export function FeatureBar({ active, onChange, hasSelection }: Props) {
  return (
    <div className="feature-bar">
      {features.map(f => (
        <button
          key={f.key}
          className={`feature-btn ${active === f.key ? 'active' : ''}`}
          onClick={() => onChange(f.key)}
          title={
            (f.key === 'rewrite' || f.key === 'translate') && !hasSelection
              ? '请先在文档中选中文本'
              : f.label
          }
        >
          <span className="feature-icon">{f.icon}</span>
          <span className="feature-label">{f.label}</span>
        </button>
      ))}
    </div>
  )
}
