{
  pkgs,
  ...
}@inputs:

let
  treefmt = import ./treefmt.nix {
    inherit pkgs;
    inherit (inputs) treefmt-nix;
  };
in

{
  formatter = treefmt.formatter;
}
