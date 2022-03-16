# workflows

A collection of reusable workflows for GitHub Actions.

## Description

This is a collection of reusable workflows that keep clean code.

Available workflows:

- Lint and check format for YAML
- Lint and check format for Markdown
- Lint for GitHub Actions workflows

See details: [GitHub documentation](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

## Usage

### Lint YAML

```yaml
jobs:
  lint-yaml:
    uses: tmknom/workflows/.github/workflows/lint-yaml.yml@v0
```

### Lint Markdown

```yaml
jobs:
  lint-markdown:
    uses: tmknom/workflows/.github/workflows/lint-markdown.yml@v0
```

### Lint Action

```yaml
jobs:
  lint-action:
    uses: tmknom/workflows/.github/workflows/lint-action.yml@v0
```

## License

Apache 2 Licensed. See LICENSE for full details.
