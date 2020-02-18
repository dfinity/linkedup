{ rev    ? "cc1ae9f21b9e0ce998e706a3de1bad0b5259f22d"
, sha256 ? "0zjafww05h50ncapw51b5qxgbv9prjyag0j22jnfc3kcs5xr4ap0"
, system ? builtins.currentSystem
, pkgs   ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256; }) {
    config.allowUnfree = true;
  }

, nodejs ? pkgs.nodejs-12_x
}:

let
  dfx = pkgs.stdenv.mkDerivation rec {
    name = "dfx-${version}";
    version = "0.5.0";

    src = pkgs.fetchurl {
      url = "https://sdk.dfinity.org/downloads/dfx/${version}/${system}/dfx-${version}.tar.gz";
      sha256 =
        if system == "x86_64-linux" then
          "1xgy2rn2pxii3axa0d9y4s25lsq7d9ykq30gvg2nzgmdkmy375rr"
        else if system == "x86_64-darwin" then
          "13h0rzy1306774lwrvpkq04x5hqmway7ii08fyngg4iz56la5lnh"
        else
          builtins.throw("unknown system");
    };

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      tar xvzCf $out/bin ${src} ./dfx
    '';
  };

  # The packages.nix imported here is the default.nix that was produced by
  # running:
  #
  #   nix-shell -p nodePackages_12_x.node2nix --pure --command "node2nix -i package.json -l package-lock.json -c packages.nix --nodejs-12 --include-peer-dependencies --supplement-input supplement.json"

  nodePackages = import ./node-composition.nix {
    inherit pkgs system nodejs;
  };

  nodeEnv = import ./node-env.nix {
    inherit (pkgs) stdenv python2 utillinux runCommand writeTextFile;
    inherit nodejs;
    libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
  };

  globalBuildInputs = pkgs.lib.attrValues (import ./supplement.nix {
    inherit nodeEnv;
    inherit (pkgs) fetchurl fetchgit;
    globalBuildInputs = [
      pkgs.darwin.apple_sdk.frameworks.CoreServices
      pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    ];
  });

  linkedup-scripts = pkgs.stdenv.mkDerivation rec {
    name = "linkedup-scripts-${version}";
    version = "0.5.0";

    src = null;

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out
    '';
  };

in pkgs.stdenv.mkDerivation rec {
  name = "linkedup-container-${version}";
  version = "0.5.0";

  src = ./.;

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildInputs = [
    dfx
    nodejs
    nodePackages.package
  ] ++ globalBuildInputs;

  buildPhase =
    let node_path = with pkgs.stdenv.lib;
      concatMapStrings(p: p.outPath + "/lib/node_modules:") globalBuildInputs;
    in ''
      HOME=$PWD ${dfx}/bin/dfx cache install
      export NODE_PATH=$NODE_PATH:${node_path}
      HOME=$PWD ${dfx}/bin/dfx build
    '';

  env = pkgs.buildEnv { name = name; paths = buildInputs; };
}
