lib:
ms:
''
  try_init_with_existing(){
    src=$1
    dest=$2
    # If the directory doesn't exist in persistence
    # and already exists in the target
    # initialize it by moving the existing directory
    if [ -e "$src" ] && ! [ -e "$dest" ]
    then
      # ensure parents exist
      mkdir -p "$dest"
      # rmdir fails if directory not empty so this is fairly safe
      rmdir "$dest"
      echo moved "$src" to "$dest" at $(date) >> /var/log/persist-retro
      mv "$src" "$dest"
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
  )
