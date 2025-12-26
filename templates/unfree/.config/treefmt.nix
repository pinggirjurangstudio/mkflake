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
    }).config;
in

{
  formatter = treefmt.build.wrapper;
  checks.format = treefmt.build.check self;
}
