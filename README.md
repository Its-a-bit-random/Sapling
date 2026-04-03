<div align="center">
    <h1>Sapling Framework</h1>
    <a href="https://sapling.itsabitrandom.com">View Docs →</a> | <a href="https://sapling.itsabitrandom.com/docs/installing">Installing Guide →</a>
</div>

Sapling Framework is an ecosystem of packages which aim to speed up and improvde DX when developing games on Roblox. Sapling is the successor of [Catalyst](https://github.com/Sebastian2852/Catalyst) which had fundemental issues which would take recoding the whole thing to fix so I decided to make a new framework.

## Usage

To use sapling you will need to have [pesde](https://pesde.dev/) installed and a project setup for a Roblox environment.

Sapling is versioned using Git tags. All packages you install that are a part of the ecosystem need to be from the same git tag or commit. While not striclty necessary in most cases, in some cases it may be required as a package could depend on anotther.

*Please see [here](https://github.com/pesde-pkg/pesde/issues/59) why this package should be installed via git dependencies and not through a registry.*

Installing pacakges is as simple as adding a dependencies into your `pesde.toml` manifest. You will need to specify a path due to this repo being a mono-repo. In the future we may decide to create a CLI tool to assist with doing so but for now you need to manually add each package, and its peer dependencies.

As an example in your Pesde manifest to use the core `Sapling` package, you would add the following to the dependencies section:

```toml
[Dependencies]
Sapling = { repo = "its-a-bit-random/Sapling", rev = "v1.0.0", path = "packages/sapling" }
```

More info about installing and consuming packages can be found [here](https://sapling.itsabitrandom.com/docs/installing)

## Packages

Below is a list of every pacakge and its path and docs link.

<!--moonwave-hide-before-this-line-->

| Package | Path | Docs |
| ------- | :--: | :---: |
| Sapling | `packages/sapling` | [Docs](https://sapling.itsabitrandom.com/api/Sapling) |
| Lifelike Characters Service | `packages/lifelikeCharactersService` | [Docs](https://sapling.itsabitrandom.com/api/LifelikeCharactersService) |
| QueryBuilder | `packages/queryBuilder` | [Docs](https://sapling.itsabitrandom.com/api/QueryBuilder) |
| Registry | `packages/registry` | [Docs](https://sapling.itsabitrandom.com/api/Registry) |
| Sweeper | `packages/sweeper` | [Docs](https://sapling.itsabitrandom.com/api/Sweeper) |
| BaseObject | `packages/baseObject` | [Docs](https://sapling.itsabitrandom.com/api/BaseObject) |
