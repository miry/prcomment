VERSION=0.1.0
IMAGE=miry/prcomment:$(VERSION)

_output:
	mkdir _output

.PHONY: run
run: build
	_output/prcomment

.PHONY: build
build: _output
	crystal build --release -o _output/prcomment src/cli.cr

.PHONY: build.linux
build.linux: _output
	crystal build --cross-compile --target "x86_64-unknown-linux-gnu" --release -o _output/prcomment-$(VERSION)-x86_64-linux src/cli.cr

.PHONY: build.darwin
build.darwin: _output
	crystal build --cross-compile --target "x86_64-apple-darwin" --release -o _output/prcomment-$(VERSION)-x86_64-macos src/cli.cr

build.docker:
	docker build -f Dockerfile -t $(IMAGE) .
	docker push $(IMAGE)

fmt:
	crystal tool format

release: build.linux build.darwin
	hub release create -a _output/prcomment-$(VERSION)-x86_64-linux _output/prcomment-$(VERSION)-x86_64-macos v$(VERSION)
