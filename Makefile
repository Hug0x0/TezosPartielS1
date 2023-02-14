ifndef LIGO 
	LIGO = docker run --rm -v "${PWD}":"${PWD}" -w "${PWD}" ligolang/ligo:0.57.0
endif

compile = $(LIGO) compile contract ./src/contracts/$(1) -o ./src/compiled/$(2) $(3)
testing = $(LIGO) run test ./tests/$(1)

default: help

help: 
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  clean            - Cleans the compiled contracts"
	@echo "  compile          - Compiles contracts to Michelson"
	@echo "  deploy           - Deploys the main contract"
	@echo "  help             - Shows this help message"
	@echo "  recompile        - Cleans and compiles contracts"
	@echo "  sandbox-start    - Starts a sandbox"
	@echo "  sandbox-stop     - Stops the sandbox"
	@echo "  test             - Runs tests"
	@echo "  test-ligo        - Runs Ligo tests"
	@echo "  test-integration - Runs integration tests"

clean:
	@echo "Cleaning..."
	@rm -rf ./src/compiled/*
	@echo "Cleaned successfully"

compile: 
	@echo "Compiling Main contract..."
	@$(call compile,main.mligo,main.tz)
	@$(call compile,main.mligo,main.json,--michelson-format json)
	@echo "Compiled successfully"

deploy-contract:
	@echo "Deploying Main contract..."
	@npm run deploy

recompile: clean compile

sandbox-start: 
	@./scripts/run-sandbox.sh

sandbox-stop:
	@docker stop sandbox

test: test-ligo test-integration

test-ligo:
	@echo "Testing contracts..."
	@$(call testing,increment.test.mligo)
	@$(call testing,decrement.test.mligo)
	@echo "Tested successfully"

test-integration:
	@echo "Testing integration..."