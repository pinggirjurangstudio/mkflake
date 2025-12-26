{
  description = "Minimal smoothflake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    smoothflake.url = "sourcehut:~bzm/smoothflake";
  };

  outputs =
    { nixpkgs, smoothflake, ... }@inputs:
    smoothflake.lib.mkFlake {
      inherit nixpkgs;
      specialArgs = inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        { perSystem = import ./.config/shell.nix; }
      ];
    };
}
