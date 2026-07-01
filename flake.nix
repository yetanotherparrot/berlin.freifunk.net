{
  description = "berlin.freifunk.net development environment.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        # To find the rev attribute of a specific package version, use:
        # https://www.nixhub.io/packages/nodejs
        
        # To find the sha256 of that commit to nixpkgs, use:
        # nix-prefetch-url --unpack https://codeload.github.com/NixOS/nixpkgs/zip/{COMMIT_ID}

        pkgs_hugo_152 = import (pkgs.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "ee09932cedcef15aaf476f9343d1dea2cb77e261";
          sha256 = "1xz5pa6la2fyj5b1cfigmg3nmml11fyf9ah0rnr4zfgmnwimn2gn";
        }) {
          inherit (pkgs) system;
        };

        pkgs_nodejs_22 = import (pkgs.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "3d46470bb3030020f7e1361f33514854f5bfa86d";
          sha256 = "0hn1wvpn79ma083nf53kp4wbs27bwzbzwfr5kipdnz38zsc4yh1y";
        }) {
          inherit (pkgs) system;
        };

        # Define packages needed for both devShell and build
        commonPackages = with pkgs; [
          pkgs_hugo_152.hugo
          pkgs_nodejs_22.nodejs
          go
        ];

        nixTools = with pkgs; [
          alejandra
          nixpkgs-fmt
        ];
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = commonPackages ++ nixTools;

          shellHook = ''
            git submodule init
            git submodule update
            npm install
          '';
        };
      }
    );
}
