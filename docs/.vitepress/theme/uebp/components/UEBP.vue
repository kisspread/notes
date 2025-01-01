<!-- UEBP.vue -->
<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useData } from 'vitepress'

const props = defineProps<{
  content: string
  height: string
  isUrl?: boolean
}>()

const { isDark, site } = useData()
const containerId = `bue_container_${Math.random().toString(36).substring(2, 10)}`
const containerRef = ref<HTMLElement | null>(null)

onMounted(() => {
  // 动态加载所需的脚本和样式
  const basePath = site.value.base
  if (!document.querySelector('script[src="' + basePath + 'uebp/render.js"]')) {
    const script = document.createElement('script')
    script.src = basePath + 'uebp/render.js'
    script.defer = true
    document.head.appendChild(script)
  }

  if (!document.querySelector('script[src="' + basePath + 'uebp/copy-button.js"]')) {
    const copyScript = document.createElement('script')
    copyScript.src = basePath + 'uebp/copy-button.js'
    copyScript.defer = true
    document.head.appendChild(copyScript)
  }

  if (!document.querySelector('link[href="' + basePath + 'uebp/render.css"]')) {
    const style = document.createElement('link')
    style.rel = 'stylesheet'
    style.href = basePath + 'uebp/render.css'
    document.head.appendChild(style)
  }

  if (!document.querySelector('link[href="' + basePath + 'uebp/copy-button.css"]')) {
    const copyStyle = document.createElement('link')
    copyStyle.rel = 'stylesheet'
    copyStyle.href = basePath + 'uebp/copy-button.css'
    document.head.appendChild(copyStyle)
  }

  if (props.isUrl) return

  const initBlueprintRenderer = () => {
    if (!containerRef.value) {
      console.error('Could not find container')
      return
    }
    if (!window.blueprintUE?.render?.Main) {
      setTimeout(initBlueprintRenderer, 100)
      return
    }
    try {
      new window.blueprintUE.render.Main(props.content, containerRef.value, { height: props.height }).start()
    } catch (e) {
      console.error('Error initializing blueprint renderer:', e)
    }
  }

  if (document.readyState === 'complete') {
    initBlueprintRenderer()
  } else {
    window.addEventListener('load', initBlueprintRenderer)
  }
})

// 处理复制功能
const copied = ref(false)
async function copyCode() {
  try {
    await navigator.clipboard.writeText(props.content)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  } catch (err) {
    console.error('Failed to copy:', err)
  }
}
</script>

<template>
  <div class="bue-container" :class="{ 'is-dark': false }">
    <template v-if="!isUrl">
      <div class="copy-btn-wrapper">
        <button class="copy-button" @click="copyCode" :class="{ copied }">
          {{ copied ? 'Copied!' : 'Copy' }}
        </button>
      </div>
    </template>

    <div class="bue-render">
      <template v-if="isUrl">
        <iframe
          :src="content"
          scrolling="no"
          allowfullscreen
          :style="{ width: '100%', height: height, border: 'none' }"
        />
      </template>
      <template v-else>
        <div class="playground" :id="containerId" ref="containerRef"></div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.bue-container {
  position: relative;
  margin: 1rem 0;
  background-color: var(--vp-code-block-bg);
  border-radius: 0px;
  overflow: hidden;
}

.copy-btn-wrapper {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 3;
  opacity: 0;
  transition: opacity 0.25s;
}

.bue-container:hover .copy-btn-wrapper {
  opacity: 1;
}

.copy-button {
  border: 1px solid var(--vp-code-copy-code-border-color);
  border-radius: 4px;
  padding: 4px 10px;
  background-color: var(--vp-code-copy-code-bg);
  color: var(--vp-code-copy-code-text);
  font-size: 12px;
  cursor: pointer;
  transition: border-color 0.25s;
}

.copy-button:hover {
  border-color: var(--vp-code-copy-code-hover-border-color);
}

.copy-button.copied {
  border-color: var(--vp-c-green);
  background-color: var(--vp-c-green-dimm-2);
}

.bue-render {
  padding: 0rem;
}

.is-dark .bue-render {
  filter: invert(1) hue-rotate(180deg);
}
</style>
