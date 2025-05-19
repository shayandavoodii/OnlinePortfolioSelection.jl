import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/OnlinePortfolioSelection.jl/previews/PR98/',// TODO: replace this in makedocs!
  title: 'OnlinePortfolioSelection.jl',
  description: "A VitePress Site",
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../1', // This is required for MarkdownVitepress to work correctly...
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  ignoreDeadLinks: true,

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    logo: { src: '/logo.png', width: 24, height: 24},
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
{ text: 'Home', link: '/index' },
{ text: 'Fetch Financial Data', link: '/fetchdata' },
{ text: 'Use In Python', link: '/python' },
{ text: 'OPS Strategies', collapsed: false, items: [
{ text: 'Benchmark', link: '/benchmark' },
{ text: 'Follow the Loser', link: '/FL' },
{ text: 'Follow the Winner', link: '/FW' },
{ text: 'Pattern-Matching', link: '/PM' },
{ text: 'Meta-Learning', link: '/ML' },
{ text: 'Combined Strategies', link: '/Combined' }]
 },
{ text: 'Performance Evaluation', link: '/performance_eval' },
{ text: 'Functions', link: '/funcs' },
{ text: 'Types', link: '/types' },
{ text: 'References', link: '/refs' }
]
,
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Fetch Financial Data', link: '/fetchdata' },
{ text: 'Use In Python', link: '/python' },
{ text: 'OPS Strategies', collapsed: false, items: [
{ text: 'Benchmark', link: '/benchmark' },
{ text: 'Follow the Loser', link: '/FL' },
{ text: 'Follow the Winner', link: '/FW' },
{ text: 'Pattern-Matching', link: '/PM' },
{ text: 'Meta-Learning', link: '/ML' },
{ text: 'Combined Strategies', link: '/Combined' }]
 },
{ text: 'Performance Evaluation', link: '/performance_eval' },
{ text: 'Functions', link: '/funcs' },
{ text: 'Types', link: '/types' },
{ text: 'References', link: '/refs' }
]
,
    editLink: { pattern: "https://https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/edit/main/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/shayandavoodii/OnlinePortfolioSelection.jl' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/dev/" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}.`
    }
  }
})
