<!-- docs/.vitepress/theme/Layout.vue -->
<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useData, inBrowser,useRouter  } from 'vitepress'
import { watchEffect,onMounted } from 'vue'

import mediumZoom from "medium-zoom";


const router = useRouter();


// Setup medium zoom with the desired options
const setupMediumZoom = () => {
  mediumZoom("[data-zoomable]", {
    background: "transparent",
  });
};

// Apply medium zoom on load
onMounted(setupMediumZoom);
// Subscribe to route changes to re-apply medium zoom effect
router.onAfterRouteChanged = setupMediumZoom;

const { lang } = useData()
watchEffect(() => {
  if (inBrowser) {
    document.cookie = `nf_lang=${lang.value}; expires=Mon, 1 Jan 2030 00:00:00 UTC; path=/`
  }
})
</script>

<template>
  <DefaultTheme.Layout>
    <template #doc-after>
      <slot name="doc-after"/>
    </template>
    <template #doc-footer-before>
      <slot name="doc-footer-before"/>
    </template>
  </DefaultTheme.Layout>
</template>
<style>
.medium-zoom-overlay {
  backdrop-filter: blur(5rem);
}

.medium-zoom-overlay,
.medium-zoom-image--opened {
  z-index: 999;
}
</style>