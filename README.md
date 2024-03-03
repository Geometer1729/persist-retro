# persist-retro
Retroactively persist directories with impermanence

Persist-retro works by adding a step during activations of home-manager and nixos
in which directories, which have been configured to be persisted by impermanence
but do not yet exist in the persistant directory,
are initialized by moving the coresponding directory from the root filesystem, if it exists,
into the persistant filesystem.
This is usefull to allow you to easily save files which already exist
without manually moving.

Usage is similar to impermanence
In your home-manager
```nix
{
  imports =
    [ inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.persist-retro.nixosModules.home-manager.persist-retro
    ];
}
```
and in your nixos-configuration
```nix
{
  imports =
    [ inputs.impermanence.nixosModules.impermanence
      inputs.persist-retro.nixosModules.persist-retro
    ];
}
```

# Missing features
- [X] Work with non-string etries in the directories list
- [X] Work with symlinks
- [X] Support files with home-manager
- [X] Work with the impermanence nixosModule
- [X] disable when `persistentStoragePath` or `removePrefixDirectory` are set
- [ ] add option to disable persist-retro for individual persistennce entries
- [ ] corectly support `persistentStoragePath`
- [ ] corectly support `removePrefixDirectory`
