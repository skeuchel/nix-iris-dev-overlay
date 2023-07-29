{
  description = "A flake that adds development versions
    of stdpp and iris to their respective coqPackages";

  outputs = inputs: let
    # Load the dev releases from the stdpp and iris json files.
    stdppDevReleases = builtins.fromJSON (builtins.readFile ./stdpp.json);
    irisDevReleases = builtins.fromJSON (builtins.readFile ./stdpp.json);

    # Ideally we would simply patch mkCoqPackages, but that seems impossible.
    # Instead, we take the existing coqPackages and add the dev versions
    # there. This is a bit hacky, but it works.

    # Patch a single coqPackages attribute set.
    patchCoqPackages = coqPackages:
      coqPackages.overrideScope' (_self: super: {
        stdpp = super.stdpp.override ({mkCoqDerivation, ...}: {
          mkCoqDerivation = drv_:
            (mkCoqDerivation drv_).override (old: {
              release = old.release // stdppDevReleases;
            });
        });
        iris = super.iris.override ({mkCoqDerivation, ...}: {
          mkCoqDerivation = drv_:
            (mkCoqDerivation drv_).override (old: {
              release = old.release // irisDevReleases;
            });
        });
      });
  in {
    overlay = self: super: let
      # The keys we want to patch. We cannot simply use builtins.attrNames. Instead
      # we specify the keys we want to patch and test that they are really there.
      # This should be fine for now, but if we want to patch more keys in the future,
      # we should probably find a better way to do this.
      coqPackagesKeys = builtins.filter (key: builtins.hasAttr key super) (
        ["coqPackages"] ++ map (n: "coqPackages_8_${toString n}") (super.lib.range 5 20)
      );
    in
      # Build a new attribute set with each coqPackages* replaced by a patched version
      builtins.listToAttrs (map (key: {
          name = key;
          value = patchCoqPackages (builtins.getAttr key super);
        })
        coqPackagesKeys);
  };
}
