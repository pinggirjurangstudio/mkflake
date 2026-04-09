# mkflake [![main](https://github.com/pinggirjurangstudio/mkflake/actions/workflows/main.yaml/badge.svg)](https://github.com/pinggirjurangstudio/mkflake/actions/workflows/main.yaml)

A lightweight, [modular](https://nixos.wiki/wiki/NixOS_modules) [Nix Flakes outputs](https://wiki.nixos.org/wiki/Flakes#Output_schema) builder designed to be vendored.

## Quick start

Vendored the `mkflake.nix`.

```console
nix flake init -t github:pinggirjurangstudio/mkflake
```

Use `mkflake.nix` to build flakes outputs in a modular way.

```nix
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
```

## Features

### Modular design

If you like [NixOS modules](https://nixos.wiki/wiki/NixOS_modules), you'll love `mkflake`.

### Systems abstraction

All system-specific outputs are abstracted using `perSystem` options.

```nix
# shell.nix
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "mkflake";
        packages = [ ];
      };
    };
}

# flake.nix
# import the module
...
imports = [
  ./shell.nix
];
...
```

You can simplify them by moving `perSystem` into imports.

```nix
# shell.nix
{ pkgs, ... }:
{
  devShells.default = pkgs.mkShell {
    name = "mkflake";
    packages = [ ];
  };
}

# flake.nix
# import the module into perSystem
...
imports = [
  { perSystem = import ./shell.nix; }
];
...
```

### Treefmt integration (require no additional inputs)

Most nix project I saw are now using
[treefmt](https://github.com/numtide/treefmt) as their formatter. Its offer
flexibility because `treefmt` is a formatter multiplexer. Run `treefmt` and your
whole code base are formatted.

We also blessed by [treefmt-nix](https://github.com/numtide/treefmt-nix) which
allow us to use nix to configure them instead of using TOML. However, using
`treefmt-nix` require adding another inputs to our flake.

With `mkflake`, you can use `treefmt` without adding another inputs.
It will set `checks.<system>.treefmt` and `formatter.<system>` in your flake
outputs (overridable).

```nix
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
}
```

### Share your flake outputs

You can share your outputs via the following attribute set:
- `flakeModules.<name>` modules to be imported by other flakes (similar to `nixosModules.<name>` for NixOS)
- `lib.<name>` library
- `flake` any other arbitrary attributes goes here

### Assertions

NixOS assertions style also supported. It will set `checks.<system>.mkflake` in your flake outputs.

```nix
{
  assertions = [
    {
      assertion = false;
      message = "This shouldn't be false";
    }
  ];
}
```

```
Failed assertions:
- This shouldn't be false
```

## Similar project

### [flake-parts](https://github.com/hercules-ci/flake-parts/tree/main)

The `mkflake` are heavily inspired by `flake-parts`. You can even say its a
`flake-parts` but stripped-down all the unnecessary parts including unnecessary
dependency/inputs by vendoring the `mkflake.nix`.

### [flake-utils](https://github.com/numtide/flake-utils)

The `flake-utils` provides utility functions to make it easy to create your
flake project. But honestly, most of us only use it for abstracting the
system-specific outputs using
[flake-utils.lib.eachDefaultSystem](flake-utils.lib.eachDefaultSystem). Its also
doesn't support modules.
