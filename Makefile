VERSION=0.1.2
IMAGE=miry/prcomment:$(VERSION)
GITHUB_TOKEN=?token

_output:
	mkdir _output

.PHONY: run
run: build
	_output/prcomment

.PHONY: build
build: _output
	crystal build --release --no-debug -o _output/prcomment src/cli.cr

.PHONY: build.static
build.static: _output
	crystal build --static --release --no-debug -o _output/prcomment src/cli.cr

.PHONY: build.linux
build.linux: _output
	crystal build --cross-compile --target "x86_64-unknown-linux-gnu" --release -o _output/prcomment-$(VERSION)-x86_64-linux src/cli.cr

.PHONY: build.darwin
build.darwin: _output
	crystal build --cross-compile --target "x86_64-apple-darwin" --release -o _output/prcomment-$(VERSION)-x86_64-macos src/cli.cr

.PHONY: docker.build
docker.build:
	docker build -f Dockerfile -t $(IMAGE) .

.PHONY: docker.release
docker.release: docker.build
	docker push $(IMAGE)

.PHONY: docker.test
docker.test: docker.build
	docker run -it --rm $(IMAGE) -t $(GITHUB_TOKEN) -r miry/prcomment -i 1 Test message from Makefile

.PHONY: fmt
fmt:
	crystal tool format

.PHONY: release
release: build.linux build.darwin
	hub release create v$(VERSION)
