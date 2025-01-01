<script setup lang="ts">
import { ref } from 'vue'
import { useData } from 'vitepress'

const defaultAuthor = 'Zerol Dev Notes'
const { frontmatter } = useData()
</script>

<template>
  <div class="copyright-container">
    <fa6-solid:copyright class="copyright-icon" />
    <section class="copyright-content">
      <div class="site-info">{{ frontmatter.author || defaultAuthor }}</div>
      <div class="copyright-text">
        Copyright © 2022 - 2025 by <a href="https://github.com/kisspread"><b>Zero Soul</b></a>  
      </div>
      <div class="license-text">
        This post is licensed under CC-BY-NC-SA 4.0 International
      </div>
    </section>
  </div>
</template>

<style scoped>
.copyright-container {
  position: relative;
  padding: 1.5rem;
  margin: 2rem 0;
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
}

.copyright-icon {
  position: absolute;
  top: 1.5rem;
  left: 1.5rem;
  font-size: 1.2rem;
  color: var(--vp-c-text-2);
}

.copyright-content {
  padding-left: 2.5rem;
}

.site-info {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
}

.copyright-text {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  margin-bottom: 0.3rem;
}

.license-text {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

@media (max-width: 640px) {
  .copyright-container {
    padding: 1rem;
  }
  
  .copyright-icon {
    top: 1rem;
    left: 1rem;
  }
  
  .site-info {
    font-size: 1rem;
  }
}
</style>