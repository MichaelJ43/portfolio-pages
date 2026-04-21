# portfolio-pages

[![Deploy site](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/deploy.yml/badge.svg)](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/deploy.yml)
[![PR preview workflow](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/preview.yml/badge.svg)](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/preview.yml)
[![Crystal](https://img.shields.io/badge/Crystal-1.19.1-000000?logo=crystal&logoColor=white)](https://crystal-lang.org/)
[![GitHub Pages](https://img.shields.io/badge/GitHub-Pages-222?logo=githubpages&logoColor=white)](https://pages.github.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](shard.yml)

**Live site:** [michaelj43.dev](https://michaelj43.dev) · [GitHub Pages default URL](https://MichaelJ43.github.io/portfolio-pages/) (project path)

---

## What this repository is for

This repo is a **personal portfolio** published on **GitHub Pages**. It gives a short overview and, for each highlighted GitHub project, a **brief write-up** (about two sentences) with a link to the source repository. Content is data-driven so you can refresh copy without touching the generator logic.

## How the site is built

The published site is **static HTML and CSS**.

| Piece | Role |
|--------|------|
| **[`content/repos.yml`](content/repos.yml)** | Intro, links, and one block per repository (title, URL, optional language tag, summary). |
| **[`src/sitegen.cr`](src/sitegen.cr)** | Small **Crystal** program: reads the YAML, renders **[`templates/index.ecr`](templates/index.ecr)** (ECR templates), writes `dist/index.html`, copies **[`public/`](public/)** (e.g. styles and `.nojekyll`) into `dist/`. Stylesheet uses a **relative** `styles.css` URL so the same build works for a [custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site) at the site root, the default `*.github.io` project URL, and PR preview subpaths. |
| **[`public/styles.css`](public/styles.css)** | Layout and light/dark-friendly styling. |

Building the generator takes the **Crystal** compiler (stdlib only for this code). [`shard.yml`](shard.yml) holds the project **name and semver** for metadata.

## Deployment flow

1. **Push to `main`** triggers [.github/workflows/deploy.yml](.github/workflows/deploy.yml).
2. **Install Crystal** with [`crystal-lang/install-crystal`](https://github.com/crystal-lang/install-crystal) (version pinned in the workflow to a real [Crystal release](https://github.com/crystal-lang/crystal/releases) tag).
3. **Compile** the generator: `crystal build --release src/sitegen.cr -o bin/sitegen`.
4. **Run `./bin/sitegen`** to write `dist/` (no base-path env: CSS is linked with a relative `href` so it resolves correctly for custom domains, project Pages URLs, and previews).
5. **Publish** the `dist/` folder to the **`gh-pages`** branch using [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) (`keep_files: true` merges with existing branch content, e.g. PR preview folders).

**Pull requests:** [.github/workflows/preview.yml](.github/workflows/preview.yml) publishes the same build under `preview/pr-<N>/` on `gh-pages`, comments the preview URL on the PR, and **removes** that folder when the PR is closed.

**Repository settings:** In GitHub **Settings → Pages**, use **Deploy from a branch** → branch **`gh-pages`**, folder **`/` (root)**. Optional variable: `CUSTOM_PAGES_URL` (see [CONTRIBUTING.md](CONTRIBUTING.md)) so PR preview links use your custom origin when set.

## Run it locally

### Dependencies

| Dependency | Why |
|------------|-----|
| **[Crystal](https://crystal-lang.org/install/)** (1.11 or newer; CI uses **1.19.1**) | Compiles `sitegen`. |
| **Python 3** (stdlib only) | Optional but convenient: `http.server` to preview `dist/` in a browser. Any other static file server works. |

### Commands

From the repository root:

```bash
mkdir -p bin
crystal build --release src/sitegen.cr -o bin/sitegen
./bin/sitegen
python3 -m http.server --directory dist
```

Then open [http://localhost:8000](http://localhost:8000) (or the port shown in the terminal).

### Environment variables (optional)

| Variable | Default | Purpose |
|----------|---------|---------|
| `CONTENT_FILE` | `./content/repos.yml` | YAML source for copy and repo list |
| `DIST_DIR` | `./dist` | Output directory |
| `PUBLIC_DIR` | `./public` | Static assets copied into `dist/` |

---

## Contributing

Use feature branches and PRs into `main`. Details on preview URLs and repository variables are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

Bump the semver in [`shard.yml`](shard.yml) when you ship meaningful changes to the generator or site layout.
