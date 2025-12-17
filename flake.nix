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
        inherit (pkgs) lib stdenv;
        sources = pkgs.callPackage ./_sources/generated.nix { };

        pname = "hyprnote";
        inherit (sources.hyprnote) version src;

        # Extract .deb contents
        extracted = stdenv.mkDerivation {
          name = "${pname}-extracted-${version}";
          inherit src;
          nativeBuildInputs = [ pkgs.dpkg ];
          unpackPhase = "dpkg-deb -x $src .";
          installPhase = "cp -r . $out";
        };

        hyprnote = stdenv.mkDerivation {
          inherit pname version;

          src = extracted;

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            makeWrapper
            copyDesktopItems
          ];

          buildInputs = with pkgs; [
            glib
            gtk3
            webkitgtk_4_1
            openssl
            libsoup_3
            alsa-lib
            libayatana-appindicator
            librsvg
            gdk-pixbuf
          ];

          runtimeDependencies = with pkgs; [
            systemd
            libayatana-appindicator
          ];

          desktopItems = [
            (pkgs.makeDesktopItem {
              name = "hyprnote-nightly";
              desktopName = "Hyprnote Nightly";
              exec = "hyprnote-nightly %U";
              icon = "hyprnote-nightly";
              terminal = false;
              categories = [ "Office" "Utility" ];
              mimeTypes = [ "x-scheme-handler/hyprnote" ];
            })
          ];

          dontConfigure = true;
          dontBuild = true;

          installPhase =
            let
              icons = {
                "32x32" = "32x32";
                "128x128" = "128x128";
                "256x256@2" = "256x256";
              };
              installIcon = srcSize: destSize: ''
                install -Dm644 \
                  "$src/usr/share/icons/hicolor/${srcSize}/apps/Hyprnote Nightly.png" \
                  "$out/share/icons/hicolor/${destSize}/apps/hyprnote-nightly.png"
              '';
            in ''
              runHook preInstall
              install -Dm755 "$src/usr/bin/Hyprnote Nightly" "$out/bin/.hyprnote-nightly-unwrapped"
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList installIcon icons)}
              runHook postInstall
            '';

          postFixup = ''
            makeWrapper "$out/bin/.hyprnote-nightly-unwrapped" "$out/bin/hyprnote-nightly" \
              --prefix PATH : ${lib.makeBinPath [ pkgs.desktop-file-utils ]}
          '';

          meta = {
            description = "AI notepad for private meetings - local-first with on-device transcription";
            homepage = "https://hyprnote.com";
            license = lib.licenses.gpl3Only;
            platforms = [ "x86_64-linux" ];
            mainProgram = "hyprnote-nightly";
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
      }
    ) // {
      overlays.default = final: prev: {
        hyprnote = self.packages.${prev.system}.default or null;
      };
    };
}
