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

### Additions
- New package `QueryBuilder`

## v1.1.0

### Additions
- New package `LifelikeCharactersService`.

### Changes
- `sapling`: new function to load other Sapling Framework packages from your Packages folder.
- `sapling`: warn if a module does't return a table when using `loadServices`.