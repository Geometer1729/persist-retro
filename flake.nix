{
  description = "Retroactively persist directories with home-manager + impermanence";

  outputs = {...}: {
    nixosModules.home-manager.persist-retro =
      import ./persist-retro.nix;

  };
}
