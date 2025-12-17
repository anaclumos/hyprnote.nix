# hyprnote.nix

Nix flake packaging for [Hyprnote](https://hyprnote.com), an AI notepad for private meetings (local-first with on-device transcription).

This flake packages the official `.deb` release for `x86_64-linux`.

## Installation

### CLI
Install directly to your profile:
```bash
nix profile install github:anaclumos/hyprnote.nix
```

Run without installing:
```bash
nix run github:anaclumos/hyprnote.nix
```

### Flake Input
Add to your `flake.nix`:

```nix
{
  inputs = {
    hyprnote.url = "github:anaclumos/hyprnote.nix";
  };

  outputs = { self, nixpkgs, hyprnote, ... }: {
    # ...
    environment.systemPackages = [
      hyprnote.packages.x86_64-linux.default
    ];
  };
}
```

## Updating

This repository uses [nvfetcher](https://github.com/berberman/nvfetcher) to track upstream releases. To update to the latest version:

```bash
nix run nixpkgs#nvfetcher
```
