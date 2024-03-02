# persist-retro
Retroactively persist directories with home-manager + impermanence


persist-retro works by adding a step during activation of home-manager
in which directories, which have been configured to be persisted by impermanence
but do not yet exist in the persistant directory,
are initialized by moving the coresponding directory from the root filesystem, if it exists,
into the persistant filesystem.

Usage is similar to impermanence
```nix
{
  imports =
    [ inputs.persist-retro.nixosModules.home-manager.persist-retro
    ];
}
```

# Missing features
- [X] Work with non-string etries in the directories list
- [X] Work with symlinks
- [X] Support files with home-manager
- [ ] Work with the impermanence nixosModule
