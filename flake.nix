{
  description = "A lightweight, modular Nix Flakes outputs builder designed to be vendored";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { ... }@inputs:
    import ./mkflake.nix {
      inherit inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        {
          templates.default = {
            path = builtins.path {
              path = ./.;
              filter = p: _: baseNameOf p == "mkflake.nix";
            };
            description = "Use mkflake by vendoring the mkflake.nix";
          };
        }
        {
          perSystem =
            { pkgs, ... }:
            {
              # See: https://treefmt.com/latest/getting-started/configure/#config-file
              treefmt = {
                formatter = {
                  nixfmt = {
                    command = "${pkgs.nixfmt}/bin/nixfmt";
                    includes = [ "*.nix" ];
                  };
                  yamlfmt = {
                    command = "${pkgs.yamlfmt}/bin/yamlfmt";
                    includes = [
                      "*.yaml"
                      "*.yml"
                    ];
                  };
                  actionlint = {
                    command = "${pkgs.actionlint}/bin/actionlint";
                    includes = [
                      ".github/workflows/*.yaml"
                      ".github/workflows/*.yml"
                    ];
                  };
                };
              };
            };
        }
      ];
    };
}
