# smoothflake
[![builds.sr.ht status](https://builds.sr.ht/~bzm/smoothflake.svg)](https://builds.sr.ht/~bzm/smoothflake?)

A modular flake builder with `smoothflake.lib.mkFlake`.

## Templates

- Default smoothflake template with treefmt and formatter
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake
    ```
- Minimal smoothflake template
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake#minimal
    ```
- Unfree smoothflake template with treefmt and formatter
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake#unfree
    ```
- Hello smoothflake template for flakeModules demo
    ```sh
    nix flake init -t sourcehut:~bzm/smoothflake#hello
    nix run .#hello
    ```
