{ pkgs, ... }:

{
  devShells.default = pkgs.mkShell {
    name = "minimal-smoothflake";
    packages = [ ];
  };
}
