# portfolio-pages

Static portfolio site (overview plus short write-ups per repository), generated with **Crystal** and published to **GitHub Pages** using the same deploy and pull-request preview flow as [echo-web](https://github.com/MichaelJ43/echo-web).

## Develop

Install the [Crystal compiler](https://crystal-lang.org/install/) (1.11+). This repository has **no shard dependencies**, so you do **not** need `shards` or `shards install`—only `crystal` must be on your `PATH`.

From the repository root:

```bash
mkdir -p bin
crystal build --release src/sitegen.cr -o bin/sitegen
./bin/sitegen
```

If you use a full Crystal distribution that includes [`shards`](https://crystal-lang.org/reference/the_shards_command/), `shards build --release` is equivalent here and still reads [`shard.yml`](shard.yml) for the project name and version metadata.

Optional environment variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `CONTENT_FILE` | `./content/repos.yml` | Site copy and repo list |
| `DIST_DIR` | `./dist` | Output directory |
| `PUBLIC_DIR` | `./public` | Static assets copied into `dist/` |
| `VITE_BASE_PATH` | `/` | Asset and site root path (same name as echo-web workflows) |

Serve the output locally:

```bash
python3 -m http.server --directory dist
```

To mimic a GitHub Pages **project site** locally (example repo name `portfolio-pages`):

```bash
VITE_BASE_PATH=/portfolio-pages/ ./bin/sitegen
python3 -m http.server --directory dist
```

## Deploy

Pushing to `main` runs [.github/workflows/deploy.yml](.github/workflows/deploy.yml): install Crystal with [`crystal-lang/install-crystal`](https://github.com/crystal-lang/install-crystal) (version pinned in the workflow to a real [crystal-lang/crystal release](https://github.com/crystal-lang/crystal/releases) tag), compile `sitegen`, resolve base path, build `./dist`, then publish to the `gh-pages` branch with [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages).

Pull request previews and cleanup are in [.github/workflows/preview.yml](.github/workflows/preview.yml).

## GitHub Pages settings

In the repository **Settings → Pages**, choose **Deploy from a branch**, branch **`gh-pages`**, folder **`/ (root)`**.

## Versioning

The site generator version lives in [`shard.yml`](shard.yml) (`version:`). Bump it when you ship meaningful changes to the generator or published layout.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch flow, preview URLs, and repository variables (`SITE_BASE_PATH`, `CUSTOM_PAGES_URL`).
