// // .vitepress/i18n.ts
// import fs from 'fs/promises'
// import path from 'path'
// import type { Plugin } from 'vite'

// export function createI18nFallbackPlugin(): Plugin {
//   const fileCache = new Map<string, string>()
  
//   return {
//     name: 'vitepress-i18n-fallback',
//     configResolved(config) {
//       // 确保在 VitePress 环境中运行
//       if (!config.plugins.find(p => p.name === 'vitepress')) {
//         console.warn('VitePress plugin not found')
//       }
//     },
//     async resolveId(id, importer) {
//       if (!id.includes('.zh.md')) return null
      
//       const resolved = await this.resolve(id, importer, { skipSelf: true })
//       if (!resolved) return null
      
//       const zhPath = resolved.id
//       const enPath = zhPath.replace('.zh.md', '.md')
      
//       try {
//         await fs.access(zhPath)
//         return resolved.id
//       } catch {
//         try {
//           await fs.access(enPath)
//           return enPath
//         } catch {
//           return resolved.id
//         }
//       }
//     },
    
//     async load(id) {
//       if (!id.includes('.md')) return null
      
//       // 如果是中文路径
//       if (id.includes('.zh.md')) {
//         const enPath = id.replace('.zh.md', '.md')
        
//         try {
//           await fs.access(id)
//           // 如果中文文件存在，返回null让 VitePress 正常处理
//           return null
//         } catch {
//           try {
//             // 如果中文文件不存在，尝试读取英文文件
//             if (fileCache.has(enPath)) {
//               return fileCache.get(enPath)
//             }
//             const content = await fs.readFile(enPath, 'utf-8')
//             fileCache.set(enPath, content)
//             return content
//           } catch {
//             return null
//           }
//         }
//       }
      
//       return null
//     }
//   }
// }

