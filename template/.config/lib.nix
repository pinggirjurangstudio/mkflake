{ lib, ... }:

let
  removeEmptyAttrs = lib.filterAttrs (name: value: value != { } && value != null);
in

{
  inherit removeEmptyAttrs;
}
