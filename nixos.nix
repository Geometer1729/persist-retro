{ config, lib, ... }:
let
  scriptFor = import ./gen-script.nix lib;
  concatMapFlatten = func: attrs:
    builtins.concatLists (builtins.attrValues (builtins.mapAttrs func attrs));
  getUserBinds =
    mount_path: user:
    (builtins.map
      (entry:
      if entry.filePath == entry.home + "/" + entry.file
      && entry.persistentStoragePath == mount_path
      then
        {
          inherit mount_path;
          root_path = entry.filePath;
        }
      else null
      )
      user.files
    )
    ++
    (builtins.map
      (entry:
      if entry.dirPath == entry.home + "/" + entry.directory
      && entry.persistentStoragePath == mount_path
      then
        {
          inherit mount_path;
          root_path = entry.dirPath;
        }
      else null
      )
      user.directories
    );
  binds =
    concatMapFlatten
      (mount_path: opts:
        builtins.filter builtins.isAttrs
          (
            (builtins.map
              (entry:
                if entry.dirPath == entry.directory
                && entry.persistentStoragePath == mount_path
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
                if entry.filePath == entry.file
                && entry.persistentStoragePath == mount_path
                then
                  {
                    inherit mount_path;
                    root_path = entry.filePath;
                  }
                else null
              )
              opts.files)
            ++
            (concatMapFlatten
              (_name: user: getUserBinds mount_path user)
              opts.users
            )
          )
      )
      config.environment.persistence
  ;
in
{
  system.activationScripts.createPersistentStorageDirs.deps = [ "persist-retro" ];
  system.activationScripts.persist-retro = {
    text = scriptFor binds;
  };
}
