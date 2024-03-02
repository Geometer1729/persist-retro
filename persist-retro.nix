{config,lib,...}:
let
  mounts =
    builtins.concatLists
    (builtins.attrValues
     (builtins.mapAttrs
      (mount: opts:
       builtins.map
       (entry :
        let dirPath =
          if builtins.isString entry
            then entry
            else entry.directory;
        in {inherit mount dirPath;}
       )
       (builtins.filter
        (entry: builtins.isString entry || entry.method == "bindfs")
        opts.directories)
       ) config.home.persistence
      ));
in
{
  home.activation.persist-retro =
    lib.hm.dag.entryBetween
    # before
    [ "createAndMountPersistentStoragePaths"
      "createTargetFileDirectories"
      "linkGeneration"
    ]
    # after
    [ "unmountPersistentStoragePaths"
      "runUnmountPersistentStoragePaths"
    ]
    (
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
    ''+
    lib.strings.concatStrings
      (builtins.map
        ({mount,dirPath} :
          let dest = mount + "/" + dirPath;
              source = dirPath;
            in
         "try_init_with_existing ${source} ${dest}\n"
         )
        mounts
      )
    );
}
