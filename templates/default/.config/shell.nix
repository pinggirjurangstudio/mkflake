{ pkgs, ... }:

{
  devShells.default = pkgs.mkShell {
    name = "default-smoothflake";
    packages = [ ];
  };
}
