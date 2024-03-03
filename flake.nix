{
  description = "Retroactively persist directories with home-manager + impermanence";

  outputs = { ... }: {
    nixosModules.persist-retro =
      import ./nixos.nix;
    nixosModules.home-manager.persist-retro =
      import ./home-manager.nix;
  };
}
