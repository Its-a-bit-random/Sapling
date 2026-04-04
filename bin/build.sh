#!/usr/bin/env bash
set -euo pipefail

rm -rf build
mkdir build

rojo build packages/baseobject -o build/baseobject.rbxm
rojo build packages/binder -o build/binder.rbxm
rojo build packages/instanceutils -o build/instanceutils.rbxm
rojo build packages/lifelikecharactersservice -o build/lifelikecharactersservice.rbxm
rojo build packages/querybuilder -o build/querybuilder.rbxm
rojo build packages/registry -o build/registry.rbxm
rojo build packages/sapling -o build/sapling.rbxm
rojo build packages/sweeper -o build/sweeper.rbxm
rojo build packages/typeutils -o build/typeutils.rbxm
