_output:
	mkdir _output

.PHONY: run
run: build
	_output/prcomment

.PHONY: build
build: _output
	crystal build --release -o _output/prcomment src/cli.cr

fmt:
	crystal tool format
