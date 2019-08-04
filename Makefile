_output:
	mkdir _output

.PHONY: run
run:
	crystal src/prcomment.cr

.PHONY: build
build: _output
	crystal build --release -s -o _output/prcomment src/prcomment.cr
