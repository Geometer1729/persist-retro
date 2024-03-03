{ config, lib, ... }:
let
  scriptFor = import ./gen-script.nix lib;
  binds =
    builtins.concatLists
      (builtins.attrValues
        (builtins.mapAttrs
          (mount_path: opts:
            (builtins.map
              (entry:
                {
                  inherit mount_path;
                  root_path = entry.dirPath;
                }
              )
              opts.directories)
            ++
            (builtins.map
              (entry:
                {
                  inherit mount_path;
                  root_path = entry.filePath;
                }
              )
              opts.files)
          )
          config.environment.persistence
        ));
in
{
  system.activationScripts.createPersistentStorageDirs.deps = [ "persist-retro" ];
  system.activationScripts.persist-retro = {
    text = scriptFor binds;
  };
}
