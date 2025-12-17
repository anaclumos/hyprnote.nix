{
  description = "Hyprnote - AI notepad for private meetings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        sources = pkgs.callPackage ./_sources/generated.nix { };

        hyprnote = pkgs.stdenv.mkDerivation {
          inherit (sources.hyprnote) pname version src;

          nativeBuildInputs = with pkgs; [
            dpkg
            autoPatchelfHook
            makeWrapper
            wrapGAppsHook3
          ];

          buildInputs = with pkgs; [
            glib
            gtk3
            webkitgtk_4_1
            openssl
            libsoup_3
            alsa-lib
            libappindicator-gtk3
            librsvg
            gdk-pixbuf
          ];

          runtimeDependencies = with pkgs; [
            systemd
            pulseaudio
            pipewire
          ];

          unpackPhase = ''
            runHook preUnpack
            dpkg-deb -x $src .
            runHook postUnpack
          '';

          installPhase = ''
            runHook preInstall
            
            mkdir -p $out
            cp -r usr/* $out/
            
            substituteInPlace $out/share/applications/hyprnote.desktop \
              --replace '/usr/bin/hyprnote' 'hyprnote'
            
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "AI notepad for private meetings - local-first with on-device transcription";
            homepage = "https://hyprnote.com";
            license = licenses.agpl3Only;
            platforms = [ "x86_64-linux" ];
            mainProgram = "hyprnote";
            maintainers = [ ];
          };
        };

      in {
        packages = {
          default = hyprnote;
          inherit hyprnote;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = hyprnote;
        };

        overlays.default = final: prev: {
          inherit hyprnote;
        };
      }
    ) // {
      overlays.default = final: prev: {
        hyprnote = self.packages.${prev.system}.default or null;
      };
    };
}
