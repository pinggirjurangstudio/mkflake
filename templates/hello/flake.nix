{
  description = "Hello smoothflake template for flakeModules demo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    smoothflake.url = "sourcehut:~bzm/smoothflake";
  };

  outputs =
    { nixpkgs, smoothflake, ... }@inputs:
    smoothflake.lib.mkFlake {
      inherit nixpkgs inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        # This modules are exposing packages.<system>.hello and can be run with:
        # nix run .#hello
        smoothflake.flakeModules.hello
      ];
    };
}
