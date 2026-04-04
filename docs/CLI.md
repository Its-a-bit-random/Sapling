---
sidebar_position: 3
---

# CLI

## Installing

Sapling proivdes a little basic Command Line Interface for adding packages to your project. It can be downloaded using pesde like so:
```toml
SaplingCLI = { repo = "its-a-bit-random/sapling", rev = "v2.0.0", path = "tools/CLI" }
```
And it can be used in your terminal like any other CLI.

## Usage

Simply run
```sh
SaplingCLI add [packageName]
```

to add a package. There are some other small misc features which you can find by using `SaplingCLI help` command.