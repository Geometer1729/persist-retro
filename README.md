# persist-retro
Retroactively persist directories with home-manager + impermanence


persist-retro works by adding a step during activation of home-manager
in which missing directories configured to be persisted by impermanence
are initialized by the existing directory from the root filesystem if it exists.

Usage is similar to impermanence
```nix
{
  imports =
    [ inputs.persist-retro.nixosModules.home-manager.persist-retro
    ];
}
```

# Missing features
- [ ] work with non-string etries in the directories list
- [ ] Support files with home-manager
- [ ] Work with the impermanence nixosModule
