# portfolio-pages

[![Deploy site](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/deploy.yml/badge.svg)](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/deploy.yml)
[![PR preview workflow](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/preview.yml/badge.svg)](https://github.com/MichaelJ43/portfolio-pages/actions/workflows/preview.yml)
[![Crystal](https://img.shields.io/badge/Crystal-1.19.1-000000?logo=crystal&logoColor=white)](https://crystal-lang.org/)
[![GitHub Pages](https://img.shields.io/badge/GitHub-Pages-222?logo=githubpages&logoColor=white)](https://pages.github.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](shard.yml)

**Live site:** [https://MichaelJ43.github.io/portfolio-pages/](https://MichaelJ43.github.io/portfolio-pages/)

---

## What this repository is for

This repo is a **personal portfolio** published on **GitHub Pages**. It gives a short overview and, for each highlighted GitHub project, a **brief write-up** (about two sentences) with a link to the source repository. Content is data-driven so you can refresh copy without touching the generator logic.

## How the site is built

The published site is **static HTML and CSS**—no client-side framework.

| Piece | Role |
|--------|------|
| **[`content/repos.yml`](content/repos.yml)** | Intro, links, and one block per repository (title, URL, optional language tag, summary). |
| **[`src/sitegen.cr`](src/sitegen.cr)** | Small **Crystal** program: reads the YAML, normalizes the Pages **base path** from `VITE_BASE_PATH`, renders **[`templates/index.ecr`](templates/index.ecr)** (ECR templates), writes `dist/index.html`, copies **[`public/`](public/)** (e.g. styles and `.nojekyll`) into `dist/`. |
| **[`public/styles.css`](public/styles.css)** | Layout and light/dark-friendly styling. |

There are **no Shard dependencies**; only the `crystal` compiler is required to build the generator. [`shard.yml`](shard.yml) still holds the project **name and semver** for metadata.

## Deployment flow

Publishing follows the same **ideas** as [echo-web](https://github.com/MichaelJ43/echo-web) (base path resolution, `gh-pages`, PR previews), implemented with Crystal instead of Node/Vite.

1. **Push to `main`** triggers [.github/workflows/deploy.yml](.github/workflows/deploy.yml).
2. **Install Crystal** with [`crystal-lang/install-crystal`](https://github.com/crystal-lang/install-crystal) (version pinned in the workflow to a real [Crystal release](https://github.com/crystal-lang/crystal/releases) tag).
3. **Compile** the generator: `crystal build --release src/sitegen.cr -o bin/sitegen`.
4. **Resolve the site root** with the same shell logic as echo-web: optional repo variable `SITE_BASE_PATH`, otherwise `/` for a `username.github.io` repo or `/<repo>/` for a project Pages site (this repo → `/portfolio-pages/`).
5. **Run `./bin/sitegen`** with `VITE_BASE_PATH` set to that root so asset URLs in HTML match GitHub Pages.
6. **Publish** the `dist/` folder to the **`gh-pages`** branch using [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) (`keep_files: true` so previews and other paths are not wiped blindly).

**Pull requests:** [.github/workflows/preview.yml](.github/workflows/preview.yml) builds with base path `…/preview/pr-<N>/`, publishes under `preview/pr-<N>/` on `gh-pages`, comments the preview URL on the PR, and **removes** that folder when the PR is closed.

**Repository settings:** In GitHub **Settings → Pages**, use **Deploy from a branch** → branch **`gh-pages`**, folder **`/` (root)**. Optional variables: `SITE_BASE_PATH`, `CUSTOM_PAGES_URL` (see [CONTRIBUTING.md](CONTRIBUTING.md)).

## Run it locally

### Dependencies

| Dependency | Why |
|------------|-----|
| **[Crystal](https://crystal-lang.org/install/)** (1.11 or newer; CI uses **1.19.1**) | Compiles `sitegen`. |
| **Python 3** (stdlib only) | Optional but convenient: `http.server` to preview `dist/` in a browser. Any other static file server works. |

You do **not** need **Node**, **npm**, or **`shards install`** for this repository.

### Commands

From the repository root:

```bash
mkdir -p bin
crystal build --release src/sitegen.cr -o bin/sitegen
./bin/sitegen
python3 -m http.server --directory dist
```

Then open [http://localhost:8000](http://localhost:8000) (or the port shown in the terminal).

To match a **project site** base path (same as production for this repo name):

```bash
VITE_BASE_PATH=/portfolio-pages/ ./bin/sitegen
python3 -m http.server --directory dist
```

### Environment variables (optional)

| Variable | Default | Purpose |
|----------|---------|---------|
| `CONTENT_FILE` | `./content/repos.yml` | YAML source for copy and repo list |
| `DIST_DIR` | `./dist` | Output directory |
| `PUBLIC_DIR` | `./public` | Static assets copied into `dist/` |
| `VITE_BASE_PATH` | `/` | Root path for `href`/`src` in generated HTML (same name as echo-web workflows) |

---

## Contributing

Use feature branches and PRs into `main`. Details on preview URLs and repository variables are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

Bump the semver in [`shard.yml`](shard.yml) when you ship meaningful changes to the generator or site layout.
