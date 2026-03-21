@echo off
mkdir build

rojo build packages/sapling -o build/sapling.rbxm
rojo build packages/canopy -o build/leaf.rbxm