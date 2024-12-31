import { defineConfig, UserConfig } from 'vitepress'
import { generateSidebar } from 'vitepress-sidebar';
import { VitePressSidebarOptions } from 'vitepress-sidebar/types';
import { markdownItUEBP } from './theme/uebp/markdown-it-uebp';

const vitePressSidebarOptions: VitePressSidebarOptions = {
  documentRootPath: '/docs',
  useTitleFromFrontmatter: true
};

const srcExclude = ['assets', 'public','canvas','javascript','stylesheets','task','Excalidraw'];

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
    resolvePath:`/${item.text}/`,
  }));
}

const nav = [...dynamicNavItems(),...staticNavItems, ];
 
const sidebar = generateSidebar(dynamicSidebarConfigFunction(dynamicNavItems()));

// https://vitepress.dev/reference/site-config
const vitePressOptions: UserConfig = {
  title: "Zerol Dev Notes",
  description: "My Dev Notes is a personal knowledge base documenting my programming journey across game development, web, and utility tools. ",
  srcExclude,
  head: [["link", { rel: "icon", href: "/assets/logo.png" }]],  
  markdown: {
    math: true,
    config: (md) => {
      md.use(markdownItUEBP)
    }
  },
  themeConfig: {
    // 网站的logo
    logo: "/assets/logo.png",
    search: {
      provider: "local",
    },
    footer: {
      message: "Zerol Dev Notes.",
      copyright: `Copyright &copy; 2022 - 2025 by <a href="https://github.com/kisspread"><b>Zero Soul</b></a> </br>This post is licensed under <a href="https://creativecommons.org/licenses/by/4.0/deed.en"> <i>CC-BY-NC-SA 4.0 </i></a> International.`,
    },
    // 文档的最后更新时间
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
      { icon: 'github', link: 'https://github.com/vuejs/vitepress' },
      { icon: 'zhihu', link: 'https://github.com/vuejs/vitepress' }
    ],
    
  }
}



export default defineConfig(vitePressOptions);
