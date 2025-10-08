{ lib }:

/*
  * DON'T USE THIS!!!!!
  * This code is unnecessarily optimized for speed. When benchmarking how long
  * it takes to list all the nix files in my nixos config, this version is
  * consistently 2 milliseconds faster than the trivial solution - but far less
  * readable. For that reason, I recommend only using this version if you have
  * tens of thousands of files in your config. If not, use
  * https://github.com/llakala/nixos/blob/5c6e729990e50610c0948c224eb231bf5848bb60/various/myLib/recursivelyImport.nix
*/

let
  inherit (lib) mapAttrsToList flatten;
  inherit (builtins) isPath filter readDir stringLength substring readFileType;

  # Don't touch any files or modules in the list. We only do this once for the
  # list passed in, since expandFolder is recursive, and shouldn't have to check
  # for non-files on every expansion
  mapElem = elem:
    if !isPath elem || readFileType elem != "directory"
    then elem
    else expandFolder elem;

  # Slightly modified version of `lib.filesystem.listFilesRecursive`. we remove
  # the `lib.flatten` call, and instead only run it once at the end
  expandFolder = folder:
    mapAttrsToList (name: type:
      let subpath = folder + "/${name}"; in
      if type == "directory" then
        expandFolder subpath
      else subpath
    ) (readDir folder);

  isNixFile = path: let
    lenContent = stringLength path;
  in
    substring (lenContent - 4) lenContent path == ".nix";

in
  paths: filter
    # Filter out any path that doesn't look like `*.nix`. Make sure to use
    # toString, otherwise we end up copying to the store!
    (elem: !isPath elem || isNixFile (toString elem))
    # Flatten at the end, since expandFolder returns a list of files for every
    # folder
    (flatten (map mapElem paths))
