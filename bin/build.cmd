@echo off
mkdir build

rojo build packages/sapling -o build/sapling.rbxm
rojo build packages/lifelikeCharactersService -o build/lifelikeCharactersService.rbxm