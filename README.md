# PRCOMMENT

Creates or updates single comment to Github PR or Issue.

# Usage

## Binaries

```shell
export GITHUB_TOKEN=<personal token>
prcomment -i 1 -r miry/prcomment Hello from console
```

## Docker

```shell
docker run -e GITHUB_TOKEN=<token> --rm -it miry/prcomment:0.1.0 -i 1 -r miry/prcomment Hello
```
