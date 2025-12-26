{ pkgs, ... }:

{
  devShells.default = pkgs.mkShell {
    name = "unfree-smoothflake";
    packages = [ ];
  };
}
