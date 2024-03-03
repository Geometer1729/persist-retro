{ config, lib, ... }:
let
  scriptFor = import ./gen-script.nix lib;
  allMounts =
    builtins.concatLists
      (builtins.attrValues
        (builtins.mapAttrs
          (mount_path: opts:
            if opts.removePrefixDirectory
            then [ ]
            else
              (builtins.map
                (entry:
                  {
                    inherit mount_path entry;
                    type = "dir";
                  }
                )
                opts.directories)
              ++
              (builtins.map
                (entry:
                  {
                    inherit mount_path entry;
                    type = "file";
                  }
                )
                opts.files)
          )
          config.home.persistence
        ));
  binds = builtins.filter builtins.isAttrs # remove nulls
    (
      builtins.map
        ({ mount_path, type, entry }:
          if type == "dir"
          then
            (if builtins.isString entry
            then { inherit mount_path; root_path = entry; }
            else
              (if entry.method == "bindfs"
              then { inherit mount_path; root_path = entry.directory; }
              else null))
          else null
        )
        allMounts);
  links = builtins.filter builtins.isAttrs # remove nulls
    (builtins.map
      ({ mount_path, type, entry }:
        if type == "dir"
        then
          (if builtins.isAttrs entry && entry.method == "symlink"
          then { inherit mount_path; root_path = entry.directory; }
          else null)
        else
          {
            inherit mount_path;
            root_path =
              if builtins.isString entry
              then entry
              else entry.file;
          }
      )
      allMounts);
in
{
  home.activation = {
    persist-retro =
      lib.hm.dag.entryBetween
        # before
        [
          "createAndMountPersistentStoragePaths"
          "createTargetFileDirectories"
          "linkGeneration"
        ]
        # after
        [
          "unmountPersistentStoragePaths"
          "runUnmountPersistentStoragePaths"
        ]
        (scriptFor binds)
    ;
    persist-retro-link-phase =
      lib.hm.dag.entryBefore
        [
          "checkLinkTargets"
        ]
        (scriptFor links)
    ;
  };
}
