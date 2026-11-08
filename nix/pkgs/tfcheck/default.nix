{ pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  architectures = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "aarch64-darwin" = "darwin-arm64";
  };
  checksums = {
    "x86_64-linux" = "0il4k8xsh9k1m59nyi476immaav5ms6r23sfzxzvpbq1pmsdwhqp";
    "aarch64-linux" = "1ksyljpjkgqmlci3z1d6ihxgwvzxy5w4x6l09pdj2g99q161s723";
    "aarch64-darwin" = "1568ryynw9klvkmyrjxmyg0425w0gqnb8y4dhz80m5n6q7c10kky";
  };
  sys = architectures.${system} or (throw "unsupported system: ${system}");
  sha = checksums.${system} or (throw "unsupported system: ${system}");
  src = pkgs.fetchurl {
    url = "https://github.com/itsdalmo/tfcheck/releases/download/v0.2.1/tfcheck-0.2.1-${sys}.tar.gz";
    sha256 = sha;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "tfcheck";
  version = "0.2.1";
  inherit src;

  sourceRoot = ".";
  dontStrip = pkgs.lib.strings.hasSuffix "darwin" system;
  nativeBuildInputs = [ pkgs.gzip ];
  installPhase = ''
    install -Dm755 tfcheck $out/bin/tfcheck
  '';
}
