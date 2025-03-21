import { defineConfig, UserConfig } from 'vitepress'
import { generateSidebar } from 'vitepress-sidebar';
import { VitePressSidebarOptions } from 'vitepress-sidebar/types';
import { markdownItUEBP } from './theme/uebp/markdown-it-uebp';
import lightbox from "vitepress-plugin-lightbox"
import { withMermaid } from "vitepress-plugin-mermaid";


// import { withI18n } from 'vitepress-i18n';

// import { withI18n } from 'vitepress-i18n';
const vitePressSidebarOptions: VitePressSidebarOptions = {
  documentRootPath: '/docs',
  useTitleFromFrontmatter: true,
  excludePattern: ['*.zh.md'],
};



const srcExclude = ['assets', 'public', 'canvas', 'javascript', 'stylesheets', 'task', 'Excalidraw']

const staticNavItems = [
  {
    text: 'Dropdown Menu',
    items: [
      { text: 'Item A', link: '/item-1' },
      { text: 'Item B', link: '/item-2' },
      { text: 'Item C', link: '/item-3' }
    ]
  }
];

// Attention!!! items[0].link is important, make sure the first item must have a link!
const dynamicNavItems = () => generateSidebar(vitePressSidebarOptions)
  .filter(item => item.items &&
    item.items.length > 0 &&
    !srcExclude.includes(item.text))
  .map(item => ({
    text: item.text,
    link: item.items[0].link
  }));

const dynamicSidebarConfigFunction = (NavItems) => {
  return NavItems.map(item => ({
    ...vitePressSidebarOptions,
    scanStartPath: item.text,
    // basePath: `/${item.text}/`,
    resolvePath: `/${item.text}/`,
  }));
}

const nav = [
  ...dynamicNavItems(),
  // ...staticNavItems,
];

const sidebar = generateSidebar(dynamicSidebarConfigFunction(dynamicNavItems()));

// const vitePressI18nOptions = {
//   // VitePress I18n config
//   locales: [
//     { locale: 'en', path: "/" },
//     { locale: 'zhHans', path: "zh" }], // first locale 'en' is root locale
//   searchProvider: 'local', // enable search with auto translation
//   debugPrint: true 
// }; 
const base = '/notes/';

const vitePressOptions: UserConfig = {
  base,
  sitemap: {
    hostname: `https://kisspread.github.io${base}`,
  },
  title: "Zerol Dev Notes",
  description: "My Dev Notes is a personal knowledge base documenting my programming journey across game development, web, and utility tools. ",
  srcExclude,
  head: [
    ["link", { rel: "icon", href: `${base}/logo.png` }],
    ['script', { async: true, src: 'https://www.googletagmanager.com/gtag/js?id=G-1C4YPESY1M',} ],
    ['script', {},"window.dataLayer = window.dataLayer || [];\nfunction gtag(){dataLayer.push(arguments);}\ngtag('js', new Date());\ngtag('config', 'G-1C4YPESY1M');"],
  ],
  ignoreDeadLinks: true,
  // locales: {
  //   root: {
  //     label: 'English',
  //     lang: 'en'
  //   },
  //   zh: {
  //     label: '简体中文',
  //     lang: 'zh',
  //     link: '/zh/'
  //   },
  // },
  rewrites: {
    ':path(.+).zh.md': 'zh/:path.md',
  },


  markdown: {
    math: true,
    lineNumbers: true,
    config: (md) => {
      md.use(markdownItUEBP)
      md.use(lightbox, {});
    }
  },
  
  themeConfig: {
    logo: "/logo.png",
    search: {
      provider: "local",
    },
    outline: [2, 5],
    footer: {
      message: "Zerol Dev Notes.",
      copyright: `Copyright &copy; 2022 - 2025 by <a href="https://github.com/kisspread"><b>Zero Soul</b></a> </br>This post is licensed under <a href="https://creativecommons.org/licenses/by/4.0/deed.en"> <i>CC-BY-NC-SA 4.0 </i></a> International.`,
    },
    lastUpdated: {
      text: "Updated At",
      formatOptions: {
        dateStyle: "full",
        timeStyle: "medium",
      },
    },

    nav,
    sidebar,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/kisspread' },
      { icon: 'discord', link: 'https://discord.gg/unrealsource' }
    ],

  }
}



export default defineConfig(withMermaid(vitePressOptions));
// export default defineConfig(withI18n(vitePressOptions, vitePressI18nOptions));
