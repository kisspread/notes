import MarkdownIt from 'markdown-it'

function renderBlueprint(text: string, height: string = '643px'): string {
  // 检查是否是URL
  const isUrl = text.trim().startsWith('http')

  // 处理高度单位
  if (!height.endsWith('px') && !height.endsWith('em') && !height.endsWith('vh')) {
    height = `${height}px`
  }

  // 对非URL内容进行HTML转义，并保留换行符
  const content = isUrl ? text.trim() : text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')

  // 使用 Vue 组件语法
  return `<UEBP content="${content}" height="${height}" ${isUrl ? 'is-url="true"' : ''}></UEBP>`
}

export function markdownItUEBP(md: MarkdownIt) {
  const defaultFence = md.renderer.rules.fence?.bind(md.renderer.rules)
  if (!defaultFence) return

  // 处理代码块
  md.renderer.rules.fence = (tokens, idx, options, env, slf) => {
    const token = tokens[idx]
    const info = token.info ? token.info.trim() : ''

    if (info.startsWith('uebp')) {
      const content = token.content
      
      // 解析可能的高度参数，例如 ```uebp height=500px
      const heightMatch = info.match(/height=(\d+(?:px|em|vh)?)/)
      const height = heightMatch ? heightMatch[1] : undefined
      
      return renderBlueprint(content, height)
    }

    return defaultFence(tokens, idx, options, env, slf)
  }

  // 处理图片语法 ![uebp](url)
  const defaultImage = md.renderer.rules.image?.bind(md.renderer.rules)
  if (!defaultImage) return

  md.renderer.rules.image = (tokens, idx, options, env, slf) => {
    const token = tokens[idx]
    
    if (token.content === 'uebp') {
      const srcAttr = token.attrs?.find(([key]) => key === 'src')
      if (srcAttr && srcAttr[1]) {
        return renderBlueprint(srcAttr[1])
      }
    }

    return defaultImage(tokens, idx, options, env, slf)
  }
}
