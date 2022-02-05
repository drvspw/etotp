BASEDIR = $(shell pwd)
APPNAME = $(shell basename $(BASEDIR))
REBAR = rebar3

LINTERS = check-deps lint xref eunit

.PHONY: lint
.DEFAULT_GOAL := help

compile:
	$(REBAR) compile

eunit:
	$(REBAR) eunit

xref:
	$(REBAR) xref

dialyzer:
	$(REBAR) dialyzer

check-deps: ## check dependencies
	$(REBAR) check-deps

lint:
	$(REBAR) lint

test: $(LINTERS)

console: test
	$(REBAR) shell

todo:
	$(REBAR) todo

clean:
	$(REBAR) clean
	rm -rf _build

test-coverage-report:
	$(REBAR) cover --verbose

help: ## Display help information
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
