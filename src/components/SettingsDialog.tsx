import { useState, useEffect } from 'react'
import type { AISettings } from '../types'
import { loadSettings, saveSettings } from '../store/settings'
import { testConnection } from '../services/aiClient'

interface Props {
  open: boolean
  onClose: () => void
  onSaved: (settings: AISettings) => void
}

export function SettingsDialog({ open, onClose, onSaved }: Props) {
  const [settings, setSettings] = useState<AISettings>(loadSettings())
  const [testing, setTesting] = useState(false)
  const [testResult, setTestResult] = useState<'idle' | 'success' | 'fail'>('idle')

  useEffect(() => {
    if (open) setSettings(loadSettings())
  }, [open])

  if (!open) return null

  const handleSave = () => {
    saveSettings(settings)
    onSaved(settings)
    onClose()
  }

  const handleTest = async () => {
    setTesting(true)
    setTestResult('idle')
    const ok = await testConnection(settings)
    setTestResult(ok ? 'success' : 'fail')
    setTesting(false)
  }

  return (
    <div className="overlay">
      <div className="dialog">
        <div className="dialog-header">
          <h3>⚙️ API 设置</h3>
          <button className="btn-icon" onClick={onClose}>✕</button>
        </div>
        <div className="dialog-body">
          <label>API Key</label>
          <input
            type="password"
            placeholder="sk-..."
            value={settings.apiKey}
            onChange={e => setSettings(s => ({ ...s, apiKey: e.target.value }))}
          />
          <label>API 接口地址</label>
          <input
            type="url"
            placeholder="https://api.openai.com"
            value={settings.endpoint}
            onChange={e => setSettings(s => ({ ...s, endpoint: e.target.value }))}
          />
          <label>模型名称</label>
          <input
            type="text"
            placeholder="gpt-3.5-turbo"
            value={settings.model}
            onChange={e => setSettings(s => ({ ...s, model: e.target.value }))}
          />
          {testResult === 'success' && <p className="success">✅ 连接成功</p>}
          {testResult === 'fail' && <p className="error">❌ 连接失败，请检查配置</p>}
        </div>
        <div className="dialog-footer">
          <button className="btn-secondary" onClick={handleTest} disabled={testing}>
            {testing ? '测试中...' : '测试连接'}
          </button>
          <button className="btn-primary" onClick={handleSave}>保存</button>
        </div>
      </div>
    </div>
  )
}
