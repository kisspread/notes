// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import UEBP from './uebp/components/UEBP.vue'
import { useRouter } from 'vitepress'
import { useData } from 'vitepress'
import './style.css'
import GiscusComment from './components/GiscusComment.vue';


export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
      'doc-after': () => h(GiscusComment),
    })
  },
  enhanceApp({ app, router, siteData }) {
    // ...
    app.component('UEBP', UEBP)
  },
  setup() {
    const route = useRouter()
    route.onBeforePageLoad = (to) => {
      
    }
     
}
} satisfies Theme
