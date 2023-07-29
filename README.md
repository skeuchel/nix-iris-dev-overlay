# nix-iris-dev-overlay

This flake adds development versions of the `stdpp` and `iris` packages to their
respective Coq package sets in `nixpkgs`.

## Description
The flake reads the development versions from JSON files (`stdpp.json` and
`iris.json`), which contain the package hashes. It then patches the Coq package
sets, extending them with these development versions.

Note that the package sets that are patched are hardcoded and contain current
(and some future) Coq versions. The Coq package sets are defined as all those
between `coqPackages_8_5` and `coqPackages_8_20`, inclusive, plus `coqPackages`.
If you want to patch more keys in the future, you would need to add them to the
coqPackagesKeys list in the overlay function of the flake.

## Contributions
Pull Requests are welcome! If you have a better or less hacky solution, your
contribution would be greatly appreciated.
