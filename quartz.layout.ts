import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

// components shared across all pages
export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [],
  afterBody: [],
  footer: Component.Footer({
    links: {
      Portfolio: "https://athan-dial.github.io/",
      GitHub: "https://github.com/athan-dial",
    },
  }),
}

// components for pages that display a single page (e.g. a single note)
export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.Breadcrumbs(),
    Component.ArticleTitle(),
    Component.ContentMeta(),
    Component.TagList(),
  ],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
    Component.DesktopOnly(Component.Explorer({
      title: "Content",
      folderClickBehavior: "link",
      folderDefaultState: "collapsed",
      useSavedState: true,
      filterFn: (node) => {
        const hiddenFolders = ["inbox", "drafts", "publish_queue", ".templates", ".obsidian", "attachments"]
        return !hiddenFolders.some(folder => node.file?.slug?.includes(folder))
      },
      sortFn: (a, b) => {
        // Folders first, then alphabetical
        if ((!a.file && b.file) || (a.file?.slug === "index" && b.file?.slug !== "index")) {
          return -1
        }
        if ((a.file && !b.file) || (a.file?.slug !== "index" && b.file?.slug === "index")) {
          return 1
        }
        return a.displayName.localeCompare(b.displayName)
      }
    })),
  ],
  right: [
    Component.Graph(),
    Component.DesktopOnly(Component.TableOfContents()),
    Component.Backlinks(),
  ],
}

// components for pages that display lists of pages  (e.g. tags or folders)
export const defaultListPageLayout: PageLayout = {
  beforeBody: [Component.Breadcrumbs(), Component.ArticleTitle(), Component.ContentMeta()],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
    Component.DesktopOnly(Component.Explorer({
      title: "Content",
      folderClickBehavior: "link",
      folderDefaultState: "collapsed",
      useSavedState: true,
      filterFn: (node) => {
        const hiddenFolders = ["inbox", "drafts", "publish_queue", ".templates", ".obsidian", "attachments"]
        return !hiddenFolders.some(folder => node.file?.slug?.includes(folder))
      },
      sortFn: (a, b) => {
        // Folders first, then alphabetical
        if ((!a.file && b.file) || (a.file?.slug === "index" && b.file?.slug !== "index")) {
          return -1
        }
        if ((a.file && !b.file) || (a.file?.slug !== "index" && b.file?.slug === "index")) {
          return 1
        }
        return a.displayName.localeCompare(b.displayName)
      }
    })),
  ],
  right: [],
}
