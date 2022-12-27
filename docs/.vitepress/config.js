export default {
  title: "Planetarian",
  description: "shell utils made for planetarians with love",

  themeConfig: {
    siteTitle: "Planetarian",
    logo: "/hanabishi-logo-core.svg",
    socialLinks: [
      { icon: "github", link: "https://github.com/geektheripper/planetarian" },
    ],

    nav: [{ text: "Guide", link: "/guide/about-planetarian" }],

    sidebar: [
      {
        text: "Guide",
        items: [
          { text: "About Planetarian", link: "/guide/about-planetarian" },
          { text: "Getting Started", link: "/guide/getting-started" },
          { text: "Getting Started Docker", link: "/guide/getting-started-docker" },
          { text: "Auto Config", link: "/guide/auto-config" },
        ],
      },
    ],

    footer: {
      message:
        "In the world of stars, one does not long for something unattainable",
      copyright:
        'Copyright © 2022-present <a href="https://github.com/geektheripper">GeekTR</a>',
    },
  },
};
