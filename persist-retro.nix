{ config, lib, ... }:
let
  allMounts =
    builtins.concatLists
      (builtins.attrValues
        (builtins.mapAttrs
          (mount_path: opts:
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
  scriptFor = ms:
    ''
      try_init_with_existing(){
        source=$1
        dest=$2
        # If the directory doesn't exist in persistence
        # and already exists in the target
        # initialize it by moving the existing directory
        if [ -e "$source" ] && ! [ -e "$dest" ]
        then
          # ensure parents exist
          mkdir -p "$dest"
          # rmdir fails if directory not empty so this is fairly safe
          rmdir "$dest"
          mv "$source" "$dest"
        fi
      }
    '' +
    lib.strings.concatStrings
      (builtins.map
        ({ mount_path, root_path }:
          let
            dest = mount_path + "/" + root_path;
            source = root_path;
          in
          "try_init_with_existing ${source} ${dest}\n"
        )
        ms
      );

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
