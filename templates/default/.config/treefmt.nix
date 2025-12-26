{ pkgs, treefmt-nix, ... }@inputs:

let
  inherit (inputs) self;

  treefmt =
    (treefmt-nix.lib.evalModule pkgs {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        yamlfmt.enable = true;
      };
    }).config.build;
in

{
  formatter = treefmt.wrapper;
  checks.format = treefmt.check self;
}
