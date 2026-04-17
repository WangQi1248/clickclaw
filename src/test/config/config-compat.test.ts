import { describe, expect, it } from 'vitest'
import { normalizeConfigCompat, normalizeProviderConfig } from '../../main/config'

describe('config compat normalization', () => {
  it('补齐 provider models 缺失的 name 字段', () => {
    const normalized = normalizeProviderConfig({
      api: 'openai-completions',
      models: [{ id: 'deepseek-chat' }, { id: 'deepseek-reasoner', name: '' }],
    })

    expect(normalized.models).toEqual([
      { id: 'deepseek-chat', name: 'deepseek-chat' },
      { id: 'deepseek-reasoner', name: 'deepseek-reasoner' },
    ])
  })

  it('仅在需要时返回新的配置对象', () => {
    const original = {
      models: {
        providers: {
          deepseek: {
            api: 'openai-completions' as const,
            models: [{ id: 'deepseek-chat' }],
          },
        },
      },
    }

    const normalized = normalizeConfigCompat(original)

    expect(normalized).not.toBe(original)
    expect(normalized.models?.providers?.deepseek.models).toEqual([
      { id: 'deepseek-chat', name: 'deepseek-chat' },
    ])
  })

  it('配置已兼容时保持原对象引用', () => {
    const original = {
      models: {
        providers: {
          deepseek: {
            api: 'openai-completions' as const,
            models: [{ id: 'deepseek-chat', name: 'DeepSeek Chat' }],
          },
        },
      },
    }

    expect(normalizeConfigCompat(original)).toBe(original)
  })
})
