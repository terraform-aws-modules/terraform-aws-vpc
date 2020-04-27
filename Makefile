SHELL = /usr/bin/env bash
JOB_NAME ?= local
BUILD_NUMBER ?= 0

.PHONY: help
.DEFAULT_GOAL := help

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY:

.PHONY: test
test: ## Execute tests
	@docker-compose -p ${JOB_NAME}_${BUILD_NUMBER} up --exit-code-from go

.PHONY: clean
clean:
	@docker-compose -p ${JOB_NAME}_${BUILD_NUMBER} down

.PHONY: tf-init
tf-init:
	@find . -type f -name "*.tf" -exec dirname {} \;|sort -u | while read m; do (cd "$m" && terraform init -input=false -backend=false) || exit 1; done

.PHONY: tf-validate
tf-validate:
	@find . -name ".terraform" -prune -o -type f -name "*.tf" -exec dirname {} \;|sort -u | while read m; do (cd "$m" && terraform validate && echo "√ $m") || exit 1 ; done

.PHONY: tf-fmt
tf-fmt:
	@if [[ -n "$(terraform fmt -write=false)" ]]; then echo "Some terraform files need be formatted, run terraform fmt to fix"; exit 1; fi

.PHONY: tf-lint
tf-lint:
	@tflint -v

##@ Release

.PHONY: changelog
changelog: ## Update changelog to include changes since last release
	@git-chglog -o CHANGELOG.md --next-tag `semtag final -s minor -o`

.PHONY: release
release: ## Create new release version
	@semtag final -s minor
