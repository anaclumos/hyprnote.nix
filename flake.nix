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

        pname = "hyprnote";
        inherit (sources.hyprnote) version src;

        appimageContents = pkgs.appimageTools.extractType2 {
          inherit pname version src;
        };

        wrappedApp = pkgs.appimageTools.wrapType2 {
          inherit pname version src;

          extraPkgs = pkgs: with pkgs; [
            libayatana-appindicator
            mesa
            libGL
          ];
        };

        desktopItem = pkgs.makeDesktopItem {
          name = pname;
          desktopName = "Hyprnote";
          exec = pname;
          icon = "hyprnote-nightly";
          comment = "AI notepad for private meetings";
          categories = [ "Office" "AudioVideo" ];
          terminal = false;
          mimeTypes = [ "x-scheme-handler/hyprnote-nightly" ];
        };

        icons = pkgs.linkFarm "${pname}-icons" [
          {
            name = "share/icons/hicolor/32x32/apps/hyprnote-nightly.png";
            path = "${appimageContents}/usr/share/icons/hicolor/32x32/apps/hyprnote-nightly.png";
          }
          {
            name = "share/icons/hicolor/128x128/apps/hyprnote-nightly.png";
            path = "${appimageContents}/usr/share/icons/hicolor/128x128/apps/hyprnote-nightly.png";
          }
          {
            name = "share/icons/hicolor/256x256/apps/hyprnote-nightly.png";
            path = "${appimageContents}/usr/share/icons/hicolor/256x256@2/apps/hyprnote-nightly.png";
          }
        ];

        hyprnote = pkgs.symlinkJoin {
          name = "${pname}-${version}";
          paths = [ wrappedApp desktopItem icons ];

          meta = with pkgs.lib; {
            description = "AI notepad for private meetings - local-first with on-device transcription";
            homepage = "https://hyprnote.com";
            license = licenses.gpl3Only;
            platforms = [ "x86_64-linux" ];
            mainProgram = pname;
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
