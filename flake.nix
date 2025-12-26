{
  description = "A modular flake builder with smoothflake.lib.mkFlake";

  outputs =
    { self }:
    {
      lib.mkFlake = import ./mkflake.nix;
    };
}
