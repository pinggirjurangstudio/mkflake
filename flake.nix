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
        minimal = {
          path = ./templates/minimal;
          description = "Minimal smoothflake template";
        };
      };
    };
}
