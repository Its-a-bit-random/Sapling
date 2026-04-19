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

All sapling dependencies are found under the `sapling` scope on the official Pesde registry.

```toml
[dependencies]
Sapling = { name = "sapling/sapling", version = "2.0.0" }
```

