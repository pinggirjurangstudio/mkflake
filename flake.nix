{
  description = "A modular flake builder with smoothflake.lib.mkFlake";

  outputs =
    { self }:
    {
      lib.mkFlake = import ./mkflake.nix;

      templates = {
        default = {
          path = ./templates/default;
          description = "Default smoothflake template with treefmt checks and formatter";
        };
        minimal = {
          path = ./templates/minimal;
          description = "Minimal smoothflake template";
        };
        unfree = {
          path = ./templates/unfree;
          description = "Unfree smoothflake template with treefmt checks and formatter";
        };
        hello = {
          path = ./templates/hello;
          description = "Hello smoothflake template for flakeModules demo";
        };
      };

      flakeModules.hello = {
        perSystem =
          { pkgs, ... }:
          {
            packages.hello = pkgs.writeShellApplication {
              name = "hello";
              runtimeInputs = [ pkgs.neo-cowsay ];
              text = ''
                cowsay -f sage "Hello from smoothflake!"
              '';
            };
          };
      };
    };
}
