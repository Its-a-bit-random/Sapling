# Sapling changelog

<!--
All changes should be done with this template:
`<package_name>`: <change>
example:
`sapling`: Added some cool feature.

If a change is done in a PR then add it before the colon:
`<package_name>` (#<pr>): <change>
example:
`sapling` (#5): Added some cool feature.
-->

## Unreleased

### BREAKING-CHANGES
- `sapling`: Service are now meant to be singleton classes.

### Additions
- New package `baseObject` [#15](https://github.com/Its-a-bit-random/Sapling/pull/15)
- New package `sweeper` [#12](https://github.com/Its-a-bit-random/Sapling/pull/12)

## v1.2.0

### Additions
- New package `QueryBuilder` [#6](https://github.com/Its-a-bit-random/Sapling/pull/6)
- New package `Registry` [#9](https://github.com/Its-a-bit-random/Sapling/pull/9)

## v1.1.0

### Additions
- New package `LifelikeCharactersService`.

### Changes
- `sapling`: new function to load other Sapling Framework packages from your Packages folder.
- `sapling`: warn if a module does't return a table when using `loadServices`.
