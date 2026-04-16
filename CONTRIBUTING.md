# Contributing to portfolio-pages

## Workflow

Use feature branches and open a **pull request** into `main`. Merging to `main` deploys the production site to the `gh-pages` branch.

## Pull request previews

When you open or update a PR, GitHub Actions builds the site with base path `…/preview/pr-<N>/` and pushes it to `gh-pages`. A bot comment on the PR links to the live preview.

- **GitHub Pages (default):** `https://<owner>.github.io/<repo>/preview/pr-<N>/` for project sites (for example `portfolio-pages`), or `https://<owner>.github.io/preview/pr-<N>/` for a `<owner>.github.io` repository.
- **Custom domain:** set repository variable `CUSTOM_PAGES_URL` to your site origin (no trailing slash), for example `https://example.com`. Previews use `${CUSTOM_PAGES_URL}` plus the same path suffix as the default host.

Override the automatic site root with repository variable `SITE_BASE_PATH` (for example `/portfolio-pages/`) if your publish path should not follow the `/<repo>/` default for project sites.

When a PR is **closed** or **merged**, the workflow removes `preview/pr-<N>` from `gh-pages`.

## Local build

This project does not pull any libraries from Shards; building only needs the `crystal` compiler:

```bash
mkdir -p bin
crystal build --release src/sitegen.cr -o bin/sitegen
./bin/sitegen
```

To mimic a PR preview locally:

```bash
export VITE_BASE_PATH=/preview/pr-1/
./bin/sitegen
```

(PowerShell: `$env:VITE_BASE_PATH='/preview/pr-1/'; ./bin/sitegen`)

## Editing content

Repository blurbs and the intro live in [`content/repos.yml`](content/repos.yml). After edits, run `./bin/sitegen` and refresh the served `dist/` output.
