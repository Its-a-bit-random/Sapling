# Sapling

Sapling is the successor of [Catalyst](https://github.com/Sebastian2852/Catalyst) which had some fundemental issues which would take recoding basically the whole thing to fix so I decided to make a new framework.

## Usage

To use sapling you will need to have [pesde](https://pesde.dev/) installed as well as a project setup for a Roblox environment.

Firstly all packages you use sapling need to come from the same commit or tag otherwise they may not work together. The best way is to always stick to tags as they will be created
on every release and contain the most stable code, you may sometimes want to try out a new feature which hasn't been released yet and will need to use a version based off commits.

*Please see [here](https://github.com/pesde-pkg/pesde/issues/59) why this package should be installed via git dependencies and not through a registry.*

As an example in your Pesde manifest to use the core `Sapling` package, you would add the following to the dependencies section:

```toml
[Dependencies]
Sapling = { repo = "Apple-Pear-Studios/Sapling", rev = "v1.0.0", path = "packages/sapling" }
```

Note how the path to the package has to be aded due to this repo being a mono-repo. In the future I might make a CLI tool to help with this if this project matures enough. However for the time being you will need to specify the path and tag/commit manually.

## Packages

| Package | Path | Docs |
| :-----: | :--: | :---: |
| Sapling | `packages/sapling` | [Docs](https://apple-pear-studios.github.io/Sapling/api/Sapling) |