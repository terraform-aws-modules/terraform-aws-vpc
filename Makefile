SHELL = /usr/bin/env bash

.PHONY: help
.DEFAULT_GOAL := help

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: test
test: ## Execute tests - NOTE: this will create actual resources in AWS and incur charges!
	@for TEST_CASE in $$(find test -mindepth 1 -maxdepth 1 -type d); do \
		pushd $$TEST_CASE ; go test -count=1 -timeout 5m ; popd ; \
	done

##@ Release

.PHONY: changelog
changelog: ## Update changelog to include changes since last release
	@git-chglog -o CHANGELOG.md --next-tag `semtag final -s minor -o`

.PHONY: release
release: ## Create new release version
	@semtag final -s minor
