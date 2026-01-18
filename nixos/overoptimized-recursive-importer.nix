/*
  * DON'T USE THIS!!!!!
  * This code is unnecessarily optimized for speed. When benchmarking how long
  * it takes to list all the nix files in my nixos config, this version is
  * consistently 2 milliseconds faster than the trivial solution - but far less
  * readable. For that reason, I recommend only using this version if you have
  * tens of thousands of files in your config. If not, use
  * https://github.com/llakala/synaptic-standard/blob/6a63d53763c3eea5ca6590b10b5bb2d57119af0d/demo/recursivelyImport.nix
*/

let
  inherit (builtins) isPath readDir stringLength substring readFileType attrNames concatMap;

  # Modified version of `lib.filesystem.listFilesRecursive`, that's more
  # optimized and filters for nix files on every recursive call
  expandFolder =
    folder:
    let
      contents = readDir folder;
    in
    concatMap (
      name:
      let
        subpath = folder + "/${name}";
        type = contents.${name};
      in
      if type == "regular" && isNixFile name then
        [ subpath ]
      else if type == "directory" then
        expandFolder subpath
      else
        []
    ) (attrNames contents);

  isNixFile =
    path:
    let
      len = stringLength path;
    in
    if len < 4 then false else substring (len - 4) len path == ".nix";

in
# Given the original list of modules:
# 1. don't change any non-paths
# 3. expand any folders into the nix files within them
# 2. filter out any non-nix regular files
paths:
concatMap (
  elem:
  let
    type = readFileType elem;
  in
  if !isPath elem then
    [ elem ]
  else if type == "directory" then
    expandFolder elem
  else if type == "regular" && isNixFile (toString elem) then
    [ elem ]
  else
    []
) paths
