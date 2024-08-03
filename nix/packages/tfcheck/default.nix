{ pkgs }:

let
  inherit (pkgs) system;
  architectures = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-amd64";
    "aarch64-darwin" = "darwin-arm64";
  };
  checksums = {
    "x86_64-linux" = "2cd27c3a5dd8aca891e92f31a4d89fecb9a9deddc061208ef581f15cb6dd9fae";
    "aarch64-linux" = "6e503c9ca5f4cffeea3655eadf3bf1840c784b3c5356e5417e0dc190311fa979";
    "x86_64-darwin" = "59a78d407be2dac9a6919512be663fb9fbaf146924dfc2132d01a05404066bc5";
    "aarch64-darwin" = "f97a1551984705abf02d7d1a84713202ee21667ce20eb86a9abcce5573bc5c1e";
  };
  sys = architectures.${system} or (throw "unsupported system: ${system}");
  sha = checksums.${system} or (throw "unsupported system: ${system}");
  src = pkgs.fetchurl {
    url = "https://github.com/itsdalmo/tfcheck/releases/download/v0.1.1/tfcheck-0.1.1-${sys}.tar.gz";
    sha256 = sha;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "tfcheck";
  version = "0.1.1";
  inherit src;

  sourceRoot = ".";
  dontStrip = pkgs.lib.strings.hasSuffix "darwin" system;
  nativeBuildInputs = [ pkgs.gzip ];
  installPhase = ''
    mkdir -p $out/bin
    mv tfcheck $out/bin
  '';
}
