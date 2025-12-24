{ pkgs, ... }:

{
  devShells.default = pkgs.mkShell {
    name = "smoothflake";
    packages = [ ];
  };
}
