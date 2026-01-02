# smoothflake
[![builds.sr.ht status](https://builds.sr.ht/~bzm/smoothflake.svg)](https://builds.sr.ht/~bzm/smoothflake?)

A [modular](https://nixos.wiki/wiki/NixOS_modules) flake builder with `smoothflake.lib.mkFlake`.

```nix
{
  description = "Default smoothflake template";

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
        # # Uncomment this to modify the pkgs, e.g. to set allowUnfree.
        # {
        #   perSystem =
        #     { pkgs, system, ... }:
        #     {
        #       _module.args.pkgs = import nixpkgs {
        #         inherit system;
        #         config.allowUnfree = true;
        #       };
        #     };
        # }
        { perSystem = import ./.config/shell.nix; }
        { perSystem = import ./.config/treefmt.nix; }
      ];
    };
}
```

## Features

### Modular design

If you like [modules](https://nixos.wiki/wiki/NixOS_modules) in NixOS, you'll love `smoothflake`.

### Systems abstraction

All system-specific outputs are abstracted using `perSystem` options.

```nix
# ./.config/shell.nix
{
  perSystem =
    { pkgs, ... }:

    {
      devShells.default = pkgs.mkShell {
        name = "smoothflake";
        packages = [ ];
      };
    };
}

# import the module using path
...
imports = [
  ./.config/shell.nix
];
...
```

You can simplify them by moving `perSystem` into imports.

```nix
# ./.config/shell.nix
{ pkgs, ... }:

{
  devShells.default = pkgs.mkShell {
    name = "smoothflake";
    packages = [ ];
  };
}

# import the module using module that import them into perSystem
...
imports = [
  { perSystem = import ./.config/shell.nix; }
];
...
```

### Minimal to no dependency

The [flake.nix](https://git.sr.ht/~bzm/smoothflake/tree/main/item/flake.nix)
doesn't have any dependency/inputs. So when using `smoothflake`, the only
dependency is `nixpkgs` and the `smoothflake` itself.

You can further eliminate the `smoothflake` dependency by vendoring the
[mkflake.nix](https://git.sr.ht/~bzm/smoothflake/tree/main/item/mkflake.nix)
(its only around 200LOC) into your existing/new project using the following template:

```sh
nix flake init -t sourcehut:~bzm/smoothflake#lib
```

Then modify your `flake.nix`:

```diff
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
-    smoothflake.url = "sourcehut:~bzm/smoothflake";
   };
 
   outputs =
-    { nixpkgs, smoothflake, ... }@inputs:
-    smoothflake.lib.mkFlake {
+    { nixpkgs, ... }@inputs:
+    import ./mkflake.nix {
       inherit nixpkgs inputs;
       systems = [
         "x86_64-linux"
```

### Treefmt integration (require no additional inputs)

Most nix project I saw are now using
[treefmt](https://github.com/numtide/treefmt) as their formatter. Its offer
flexibility because `treefmt` is a formatter multiplexer. Run `treefmt` and your
whole code base are formatted.

We also blessed by [treefmt-nix](https://github.com/numtide/treefmt-nix) which
allow us to use nix to configure them instead of using TOML. However, using
`treefmt-nix` require adding another inputs to our flake.

With `smoothflake`, you can use `treefmt` without adding yet another inputs.
See the [example](https://git.sr.ht/~bzm/smoothflake/tree/main/item/templates/default/.config/treefmt.nix).
It will set `checks.<system>.default` and `formatter.<system>` in your flake
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
    };
  };
}
```

### Share your flake outputs

You can share your outputs via the following attribute set:
- `flakeModules.<name>` modules to be imported by other flakes
- `lib.<name>` library
- `flake` any other arbitrary attributes goes here

See [hello template](https://git.sr.ht/~bzm/smoothflake/tree/main/item/templates/hello/flake.nix)
on how to imports modules from other flake.

## Templates

- Default smoothflake template
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake
    ```
- Use smoothflake by vendoring the mkflake.nix
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake#lib
    ```
- Hello smoothflake template for flakeModules demo
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake#hello
    nix run .#hello
    ```

## Similar project

### [flake-parts](https://github.com/hercules-ci/flake-parts/tree/main)

The `smoothflake` are heavily inspired by `flake-parts`. You can even say its a
`flake-parts` but stripped-down all the unnecessary parts including unnecessary
dependency/inputs. You can even remove `smoothflake` dependency by vendoring
the `mkflake.nix`.

### [flake-utils](https://github.com/numtide/flake-utils)

The `flake-utils` provides utility functions to make it easy to create your
flake project. But honestly, most of us only use it for abstracting the
system-specific outputs using
[flake-utils.lib.eachDefaultSystem](flake-utils.lib.eachDefaultSystem). Its also
doesn't support modules.
