# This option causes make to display a warning whenever an undefined variable is expanded.
MAKEFLAGS += --warn-undefined-variables

# Disable any builtin pattern rules, then speedup a bit.
MAKEFLAGS += --no-builtin-rules

# If this variable is not set, the program /bin/sh is used as the shell.
SHELL := /bin/bash

# The arguments passed to the shell are taken from the variable .SHELLFLAGS.
#
# The -e flag causes bash with qualifications to exit immediately if a command it executes fails.
# The -u flag causes bash to exit with an error message if a variable is accessed without being defined.
# The -o pipefail option causes bash to exit if any of the commands in a pipeline fail.
# The -c flag is in the default value of .SHELLFLAGS and we must preserve it.
# Because it is how make passes the script to be executed to bash.
.SHELLFLAGS := -eu -o pipefail -c

# Disable any builtin suffix rules, then speedup a bit.
.SUFFIXES:

# Sets the default goal to be used if no targets were specified on the command line.
.DEFAULT_GOAL := help

#
# Variables for the file and directory path
#
ROOT_DIR ?= $(shell $(GIT) rev-parse --show-toplevel)
MARKDOWN_FILES ?= $(shell find . -name '*.md')
YAML_FILES ?= $(shell find . -name '*.y*ml')

#
# Variables to be used by Git and GitHub CLI
#
GIT ?= $(shell \command -v git 2>/dev/null)
GH ?= $(shell \command -v gh 2>/dev/null)
GIT_EXCLUDE_FILES ?= ':!*.md' ':!Makefile' ':!VERSION' ':!.github/fixtures/*' ':!.github/workflows/internal-*'

#
# Variables to be used by Docker
#
DOCKER ?= $(shell \command -v docker 2>/dev/null)
DOCKER_WORK_DIR ?= /work
DOCKER_RUN_OPTIONS ?=
DOCKER_RUN_OPTIONS += -it
DOCKER_RUN_OPTIONS += --rm
DOCKER_RUN_OPTIONS += -v $(ROOT_DIR):$(DOCKER_WORK_DIR)
DOCKER_RUN_OPTIONS += -w $(DOCKER_WORK_DIR)
DOCKER_RUN_SECURE_OPTIONS ?=
DOCKER_RUN_SECURE_OPTIONS += --user 1111:1111
DOCKER_RUN_SECURE_OPTIONS += --read-only
DOCKER_RUN_SECURE_OPTIONS += --security-opt no-new-privileges
DOCKER_RUN_SECURE_OPTIONS += --cap-drop all
DOCKER_RUN_SECURE_OPTIONS += --network none
DOCKER_RUN ?= $(DOCKER) run $(DOCKER_RUN_OPTIONS)
SECURE_DOCKER_RUN ?= $(DOCKER_RUN) $(DOCKER_RUN_SECURE_OPTIONS)
DOCKER_PULL ?= $(DOCKER) pull

#
# Variables for the image name
#
REGISTRY ?= ghcr.io/tmknom/dockerfiles
PRETTIER ?= $(REGISTRY)/prettier:latest
MARKDOWNLINT ?= $(REGISTRY)/markdownlint:latest
YAMLLINT ?= $(REGISTRY)/yamllint:latest
ACTIONLINT ?= rhysd/actionlint:latest

#
# Variables for the version
#
VERSION ?= $(shell \cat VERSION)
SEMVER ?= "v$(VERSION)"
MAJOR_VERSION ?= $(shell version=$(SEMVER) && echo "$${version%%.*}")

#
# All
#
.PHONY: all
all: install lint ## all

#
# Install dependencies
#
.PHONY: install
install: ## install docker images
	$(DOCKER_PULL) $(PRETTIER)
	$(DOCKER_PULL) $(MARKDOWNLINT)
	$(DOCKER_PULL) $(YAMLLINT)
	$(DOCKER_PULL) $(ACTIONLINT)

#
# Lint
#
.PHONY: lint
lint: lint-markdown lint-yaml lint-action ## lint all

.PHONY: lint-markdown
lint-markdown: ## lint markdown by markdownlint and prettier
	$(SECURE_DOCKER_RUN) $(MARKDOWNLINT) --dot --config .markdownlint.yml $(MARKDOWN_FILES)
	$(SECURE_DOCKER_RUN) $(PRETTIER) --check --parser=markdown $(MARKDOWN_FILES)

.PHONY: lint-yaml
lint-yaml: ## lint yaml by yamllint and prettier
	$(SECURE_DOCKER_RUN) $(YAMLLINT) --strict --config-file .yamllint.yml .
	$(SECURE_DOCKER_RUN) $(PRETTIER) --check --parser=yaml $(YAML_FILES)

.PHONY: lint-action
lint-action: ## lint action by actionlint
	$(SECURE_DOCKER_RUN) $(ACTIONLINT) -color -ignore '"permissions" section should not be empty.'

#
# Format code
#
.PHONY: format
format: format-markdown format-yaml ## format all

.PHONY: format-markdown
format-markdown: ## format markdown by prettier
	$(SECURE_DOCKER_RUN) $(PRETTIER) --write --parser=markdown $(MARKDOWN_FILES)

.PHONY: format-yaml
format-yaml: ## format yaml by prettier
	$(SECURE_DOCKER_RUN) $(PRETTIER) --write --parser=yaml $(YAML_FILES)

#
# Release management
#
release: ## release
	$(GIT) tag --force --message "$(SEMVER)" "$(SEMVER)" && \
	$(GIT) tag --force --message "$(SEMVER)" "$(MAJOR_VERSION)" && \
	$(GIT) push --force origin "$(SEMVER)" && \
	$(GIT) push --force origin "$(MAJOR_VERSION)"

bump: input-version commit create-pr ## bump version

input-version:
	@echo "Current version: $(VERSION)" && \
	read -rp "Input next version: " version && \
	echo "$${version}" > VERSION

commit:
	$(GIT) switch -c "bump-$(SEMVER)" && \
	$(GIT) add VERSION && \
	$(GIT) commit -m "Bump up to $(SEMVER)"

create-pr:
	$(GIT) push origin $$($(GIT) rev-parse --abbrev-ref HEAD) && \
	$(GH) pr create --title "Bump up to $(SEMVER)" --body "" --web

#
# Git shortcut
#
.PHONY: diff
diff: ## git diff only features
	@$(GIT) diff $(SEMVER)... -- $(GIT_EXCLUDE_FILES)

.PHONY: log
log: ## git log only features
	@$(GIT) log $(SEMVER)... -- $(GIT_EXCLUDE_FILES)

#
# Help
#
.PHONY: help
help: ## show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
