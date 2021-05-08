# PRCOMMENT

[![](https://img.shields.io/github/release/miry/prcomment.svg?style=flat)](https://github.com/miry/prcomment/releases)
[![](https://img.shields.io/github/license/miry/prcomment)](https://raw.githubusercontent.com/miry/prcomment/master/LICENSE)

Creates or updates single comment to Github PR or Issue.

# Usage

First step is generate a new Github token in [Github Settings](https://github.com/settings/tokens/new?description=prcomment&scopes=public_repo).

## Binaries

```shell
export GITHUB_TOKEN=<personal token>
prcomment -i 1 -r miry/prcomment Hello from console
```

## Docker

```shell
docker run -e GITHUB_TOKEN=<token> --rm -it miry/prcomment:0.1.2 -i 1 -r miry/prcomment Hello
```

## Crystal

```shell
export GITHUB_TOKEN=<personal token>
crystal run src/cli.cr -- -i 1 -r miry/prcomment Hello
```

# Options

## Match

One of the cases to have comment to show current test coverage.
By default, `prcomment` looks for first comment with same text.

```shell
crystal run src/cli.cr -- -i 1 -r miry/prcomment -m "Test coverage \d*%" Test coverage 80%  # Creates a comment with text: 'Test coverage 80%'
crystal run src/cli.cr -- -i 1 -r miry/prcomment -m "Test coverage \d*%" Test coverage 130% # Finds the comment and replaces with: 'Test coverage 130%'
```

It is also usefull to change previous answer with new one:

```shell
crystal run src/cli.cr -- -i 1 -r miry/prcomment -m ":[+-]1:" ":+1:"  # Creates a comment with icon: ':+1'
crystal run src/cli.cr -- -i 1 -r miry/prcomment -m ":[+-]1:" ":-1:"  # Replaces with ':-1:'
```

The comment is too big for single line:

```shell
echo "The big content could be piped\nSome pattern from the comment\nThird line" | \
  crystal run src/cli.cr -- -i 1 -r miry/prcomment -m "Some pattern from the comment"
```
