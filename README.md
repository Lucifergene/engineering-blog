# Systems in Practice

A Markdown-first engineering blog built with Hugo and the pinned [Hugo Blog Awesome](https://github.com/hugo-sid/hugo-blog-awesome) theme. It publishes through GitHub Pages with no Node.js, CMS, database, analytics service, or third-party host.

## Write an article

Create a page bundle so article images and diagrams stay beside the Markdown file:

```bash
hugo new content posts/my-engineering-article/index.md
```

Edit `content/posts/my-engineering-article/index.md`, then set `draft: false` when ready to publish. Set `featured: true` to show a post in the homepage's Featured section. Posts always appear in the date-sorted article list.

Put article assets in the same directory as `index.md`, and reference them with relative Markdown paths, for example `![Architecture](diagram.png)`.

## Preview and verify

Hugo Extended `v0.166.0` is required locally.

```bash
hugo server --buildDrafts
bash tests/site-contract.sh
hugo --gc --minify
```

`public/` is generated output and is intentionally not committed.

## Publishing

Pushes to `main` build and deploy to GitHub Pages. Pull requests run the same site-contract check and production build without deploying. The initial site address is:

```text
https://lucifergene.github.io/systems-in-practice/
```

The theme is a pinned Git submodule. Clone this repository with the theme present:

```bash
git clone --recurse-submodules https://github.com/Lucifergene/systems-in-practice.git
```

To intentionally update the theme, check its release notes, update the submodule, run the verification commands above, and commit the changed gitlink.

## Later: custom subdomain

When the subdomain is ready, create a root-level `CNAME` file containing only that hostname, change `baseURL` in `hugo.toml` to `https://your-subdomain/`, then configure the custom domain and DNS records in the repository's GitHub Pages settings.
