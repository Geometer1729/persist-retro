{ config, lib, ... }:
let
  scriptFor = import ./gen-script.nix lib;
  binds =
    builtins.concatLists
      (builtins.attrValues
        (builtins.mapAttrs
          (mount_path: opts:
            builtins.filter builtins.isAttrs
            (
            (builtins.map
              (entry:
                if entry.dirPath == entry.directory && entry.persistentStoragePath == mount_path
                then
                {
                  inherit mount_path;
                  root_path = entry.dirPath;
                }
                else null
              )
              opts.directories)
            ++
            (builtins.map
              (entry:
                if entry.filePath == entry.file && entry.persistentStoragePath == mount_path
                then
                {
                  inherit mount_path;
                  root_path = entry.filePath;
                }
                else null
              )
              opts.files)
            )
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
