{
  self,
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
  checks.format = treefmt.check self;
}
