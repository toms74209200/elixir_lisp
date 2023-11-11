DIALYXIR_DIR =			deps/dialyxir
CREDO_DIR =				deps/credo
DIALYXIR_CACHE_DIR =	priv/plts

.PHONY: help

help: ## display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

%:
	@echo 'command "$@" is not found.'
	@$(MAKE) help
	@exit 2

all: check

.PHONY: setup

setup: ## install dependencies
	mix deps.get
	mix deps.compile

.PHONY: check dialyzer format lint test

check: format lint dialyzer test

$(DIALYXIR_DIR):
	mix deps.get
	mix deps.compile

$(DIALYXIR_CACHE_DIR):
	mix dialyzer --plt

dialyzer: $(DIALYXIR_DIR) $(DIALYXIR_CACHE_DIR) ## run dialyzer
	mix dialyzer --no-check

format: ## run formatter
	mix format --check-formatted

$(CREDO_DIR):
	mix deps.get
	mix deps.compile

lint: $(CREDO_DIR) ## run linter
	mix credo

test: ## run tests
	mix test