import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

/**
 * Quartz 4.0 Configuration
 *
 * See https://quartz.jzhao.xyz/configuration for more information.
 */
const config: QuartzConfig = {
  configuration: {
    pageTitle: "Model Citizen",
    pageTitleSuffix: " | Athan Dial",
    enableSPA: true,
    enablePopovers: true,
    analytics: {
      provider: "plausible",
    },
    locale: "en-US",
    baseUrl: "athan-dial.github.io/model-citizen",
    ignorePatterns: ["private", "templates", ".obsidian", "inbox", "drafts", "publish_queue"],
    defaultDateType: "created",
    generateSocialImages: false,
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Inter",
        body: "Inter",
        code: "JetBrains Mono",
      },
      colors: {
        lightMode: {
          light: "#FFFFFF",
          lightgray: "#E5E5EA",
          gray: "#AEAEB2",
          darkgray: "#4e4e4e",
          dark: "#1D1D1F",
          secondary: "#1E3A5F",
          tertiary: "#2A4A75",
          highlight: "rgba(30, 58, 95, 0.1)",
          textHighlight: "#1E3A5F22",
        },
        darkMode: {
          light: "#1D1D1F",
          lightgray: "#48484A",
          gray: "#86868B",
          darkgray: "#AEAEB2",
          dark: "#F5F5F7",
          secondary: "#4A90E2",
          tertiary: "#5BA3F5",
          highlight: "rgba(74, 144, 226, 0.15)",
          textHighlight: "#4A90E244",
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "filesystem"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
