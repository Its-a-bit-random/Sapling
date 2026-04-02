rm -rf build
mkdir build

rojo build packages/sapling -o build/sapling.rbxm
rojo build packages/lifelikeCharactersService -o build/lifelikeCharactersService.rbxm
rojo build packages/queryBuilder -o build/queryBuilder.rbxm
rojo build packages/registry -o build/registry.rbxm
rojo build packages/sweeper -o build/sweeper.rbxm
rojo build packages/baseObject -o build/baseObject.rbxm
