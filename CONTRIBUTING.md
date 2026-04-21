# Contributing to portfolio-pages

## Workflow

Use feature branches and open a **pull request** into `main`. Merging to `main` deploys the production site to the `gh-pages` branch.

## Pull request previews

When you open or update a PR, GitHub Actions builds the same static output as `main` and publishes it to `gh-pages` under `preview/pr-<N>/` (so the preview URL is `…/preview/pr-<N>/` on the default host, or the same path on your `CUSTOM_PAGES_URL` if set). A bot comment on the PR links to the live preview.

- **GitHub Pages (default):** `https://<owner>.github.io/<repo>/preview/pr-<N>/` for project sites (for example `portfolio-pages`), or `https://<owner>.github.io/preview/pr-<N>/` for a `<owner>.github.io` repository.
- **Custom domain:** set repository variable `CUSTOM_PAGES_URL` to your site origin (no trailing slash), for example `https://example.com`. Previews use `${CUSTOM_PAGES_URL}` plus the same path suffix as the default host.

When a PR is **closed** or **merged**, the workflow removes `preview/pr-<N>` from `gh-pages`.

## Local build

This project does not pull any libraries from Shards; building only needs the `crystal` compiler:

```bash
mkdir -p bin
crystal build --release src/sitegen.cr -o bin/sitegen
./bin/sitegen
```

## Editing content

Repository blurbs and the intro live in [`content/repos.yml`](content/repos.yml). After edits, run `./bin/sitegen` and refresh the served `dist/` output.
