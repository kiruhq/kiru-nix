# kiru-nix

Nix flake for [Kiru](https://kiru.app), a transcription-driven video editor.

This flake fetches the upstream Linux release tarball from
`https://releases.kiru.app` and wraps it for Nix / NixOS, so the binary
runs cleanly on Wayland and X11 with all runtime deps resolved.

> Kiru is closed-source proprietary software. Only the packaging definition
> in this repo is open source. This flake exists so Nix users can install
> Kiru today; once the [nixpkgs PR](https://github.com/NixOS/nixpkgs/pulls?q=kiru)
> merges you can switch to plain `pkgs.kiru`.

## Quick start

One-shot run (no install):

```bash
nix run --impure github:kiruhq/kiru-nix
```

Install into your user profile:

```bash
nix profile install --impure github:kiruhq/kiru-nix
```

> The `--impure` flag lets Nix accept the unfree license. To avoid it, set
> `NIXPKGS_ALLOW_UNFREE=1` in your environment or add an
> `allowUnfreePredicate` for the `kiru` package in your config.

## Use as a flake input

```nix
{
  inputs.kiru.url = "github:kiruhq/kiru-nix";

  outputs = { self, nixpkgs, kiru, ... }: {
    # NixOS module example
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.config.allowUnfreePredicate = pkg:
            builtins.elem (pkgs.lib.getName pkg) [ "kiru" ];
          environment.systemPackages = [ kiru.packages.x86_64-linux.kiru ];
        })
      ];
    };
  };
}
```

## Platforms

- `x86_64-linux` — supported (matches upstream release artefacts)
- macOS / aarch64 — not yet; upstream ships only `x86_64-linux` tarballs

## Versioning

The version in `package.nix` tracks the latest upstream Kiru release.
`main` is updated each release; tags follow `vX.Y.Z`.

## License

The packaging code in this repo is MIT. **Kiru itself is proprietary** —
see the upstream EULA. Distributing the prebuilt binary is permitted by
the upstream end-user license; this flake does not redistribute it,
it only points at the official download URL.
