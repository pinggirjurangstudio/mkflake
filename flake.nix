{
  description = "A modular flake builder with smoothflake.lib.mkFlake";

  outputs =
    { self }:
    {
      lib.mkFlake = import ./mkflake.nix;

      templates = {
        default = {
          path = ./templates/default;
          description = "Default smoothflake template";
        };
        lib = {
          path = builtins.path {
            path = ./.;
            filter = p: _: baseNameOf p == "mkflake.nix";
          };
          description = "Use smoothflake by vendoring the mkflake.nix";
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
