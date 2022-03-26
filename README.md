# workflows

A collection of reusable workflows for GitHub Actions.

## Description

This is a collection of reusable workflows that keep clean code.

Available workflows:

- Lint and check format for YAML
- Lint and check format for Markdown
- Lint and check format for Shell
- Lint for GitHub Actions workflows
- Scan secret for all code

For more information, see [GitHub documentation](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

## Usage

### Lint YAML

```yaml
jobs:
  lint-yaml:
    uses: tmknom/workflows/.github/workflows/lint-yaml.yml@v1
```

For more information, see [lint-yaml.yml](/.github/workflows/lint-yaml.yml).

### Lint Markdown

```yaml
jobs:
  lint-markdown:
    uses: tmknom/workflows/.github/workflows/lint-markdown.yml@v1
```

For more information, see [lint-markdown.yml](/.github/workflows/lint-markdown.yml).

### Lint Shell

```yaml
jobs:
  lint-shell:
    uses: tmknom/workflows/.github/workflows/lint-shell.yml@v1
```

For more information, see [lint-shell.yml](/.github/workflows/lint-shell.yml).

### Lint Action

```yaml
jobs:
  lint-action:
    uses: tmknom/workflows/.github/workflows/lint-action.yml@v1
```

For more information, see [lint-action.yml](/.github/workflows/lint-action.yml).

### Scan Secret

```yaml
jobs:
  scan-secret:
    uses: tmknom/workflows/.github/workflows/scan-secret.yml@v1
```

For more information, see [scan-secret.yml](/.github/workflows/scan-secret.yml).

## Developer Guide

<!-- markdownlint-disable no-inline-html -->
<details>
<summary>Click to see details</summary>

### Requirements

- [GNU Make](https://www.gnu.org/software/make/)
- [Docker](https://docs.docker.com/get-docker/)
- [GitHub CLI](https://cli.github.com/)

### CI

When create a pull request, the following workflows are executed automatically at GitHub Actions.

- Test workflows, see [internal-test.yml](.github/workflows/internal-test.yml).
- Lint YAML, Markdown, Shell, and GitHub Action, see [internal-lint.yml](.github/workflows/internal-lint.yml).

**NOTE:** Files with `internal-` prefix are not reusable workflows, and used only this repository.

### Dependency management

Use Dependabot version updates.
For more information, see [dependabot.yml](/.github/dependabot.yml).

### Release management

#### 1. Bump up to a new version

Run the following command to bump up.

```shell
make bump
```

This command will execute the following steps:

1. Update [VERSION](/VERSION)
2. Commit, push, and create a pull request
3. Open the web browser automatically for reviewing pull request

Then review and merge, so the release is ready to go.

#### 2. Publish the new version

Run the following command to publish a new tag at GitHub.

```shell
make release
```

Finally, we can use the new version! :tada:

</details>
<!-- markdownlint-enable no-inline-html -->

## Changelog

See [CHANGELOG.md](/CHANGELOG.md).

## License

Apache 2 Licensed. See [LICENSE](/LICENSE) for full details.
