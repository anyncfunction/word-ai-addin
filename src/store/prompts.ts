import type { PresetPrompt, Template } from '../types'

const PROMPTS_KEY = 'word-ai-addin-prompts'

export const DEFAULT_TEMPLATES: Template[] = [
  {
    id: 'weekly-report',
    name: '周报',
    icon: '📋',
    description: '生成周报',
    prompt: '请帮我写一份周报，包含本周工作内容、遇到的问题和下周计划。',
  },
  {
    id: 'meeting-summary',
    name: '会议纪要',
    icon: '📝',
    description: '生成会议纪要',
    prompt: '请帮我整理一份会议纪要，包含会议主题、讨论内容、决议和待办事项。',
  },
  {
    id: 'project-proposal',
    name: '方案',
    icon: '📄',
    description: '生成项目方案',
    prompt: '请帮我写一份项目方案，包含项目背景、目标、实施计划和预期成果。',
  },
  {
    id: 'email',
    name: '邮件',
    icon: '✉️',
    description: '生成邮件',
    prompt: '请帮我写一封专业的商务邮件。',
  },
  {
    id: 'todo',
    name: '待办清单',
    icon: '✅',
    description: '生成待办清单',
    prompt: '请帮我生成一份待办事项清单，包含优先级和截止时间。',
  },
  {
    id: 'analysis',
    name: '分析报告',
    icon: '📊',
    description: '生成分析报告',
    prompt: '请帮我写一份分析报告，包含数据分析和结论建议。',
  },
]

export function loadPresetPrompts(): PresetPrompt[] {
  try {
    const raw = localStorage.getItem(PROMPTS_KEY)
    if (raw) return JSON.parse(raw)
  } catch { /* ignore */ }
  return []
}

export function savePresetPrompts(prompts: PresetPrompt[]): void {
  localStorage.setItem(PROMPTS_KEY, JSON.stringify(prompts))
}
