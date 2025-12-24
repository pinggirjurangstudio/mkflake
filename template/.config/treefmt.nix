{ pkgs, treefmt-nix }:

let
  cfg =
    (treefmt-nix.lib.evalModule pkgs {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        yamlfmt.enable = true;
      };
    }).config;
in

{
  formatter = cfg.build.wrapper;
  check = cfg.build.check;
}
