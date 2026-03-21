# Installing the Sapling Framework

Firstly we should mentally note that the Sapling Framework is a collection of pacakges while the `sapling` package is the main core package.

The Sapling Framework expects to be installed via Pesde using git dependencies and versioned using Git tags. This is done so that it is easy
to have the git repo as the single source of truth for the pacakge but more importantly follow the new proposed changes to Pesde to use git
mainly rather than registires.

When installing a package from the Sapling Framework you need to specify the tag/commit and the path to the pacakges. All packages are located
under the `packages/` folder in the root of the repo.

:::warning
It is VITAL that you use the same commit or tag for ALL Sapling Framework packages as otherwise the packages may not be able to work togheter 
properly.
:::