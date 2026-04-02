---
sidebar_position: 2
---

# Installing

This is a more in-depth guide on how to consume sapling pacakges.

## Packages

Firstly, there are 2 types of sapling packages:

- **Services**: A singleton which works as a normal service however is handled fully by Sapling, including lifecycle.
- **Standalone**: A standalone module that works by itself and exports all its functionality with a class or a module.

It doesn't really matter too much if you understand the differences between these. However what you do need to know is that for Sapling provided services to work you **must** call `loadPackages` pointing it to your packages folder **before** you load your services.

As an example here is a typical main server script:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sapling = required(ReplicatedStorage.Packages.Sapling)

Sapling.loadPackages(ReplicatedStorage.Packages)
Sapling.loadServices(script.Parent.Services)
Sapling.fireLifecycle("OnStart")
```

## Specifing Dependencies

:::info
In the future I might make a little CLI tool to aid with dependencies.
:::

First you need to decide which version of Sapling you want to use, you shouldn't really update Major version of Sapling as they will bring breaking changes. Furthermoer all packages must be on the same version to work fully.

Here is an example of consuming the core `sapling` package:
```toml
[dependencies]
Sapling = { repo = "its-a-bit-random/Sapling", rev = "v1.0.0", path = "packages/sapling" }
```
