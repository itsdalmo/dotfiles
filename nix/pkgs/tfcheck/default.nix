{ pkgs, ... }:

let
  inherit (pkgs) system;
  architectures = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-amd64";
    "aarch64-darwin" = "darwin-arm64";
  };
  checksums = {
    "x86_64-linux" = "17914w9cglh3d0jl7m2jzrnj8y4cil8r75bc879hf8i8940h8bx7";
    "aarch64-linux" = "0xq9vggmbvxnzbxw0xfrzmv5vzklf0c2zglbxrchsgxff2ynya6b";
    "x86_64-darwin" = "0f03yw5afda86clwp6bcdlc8d24mz1ad5rgw1qvnv4flzbk1866s";
    "aarch64-darwin" = "05wgk11c1d1y06mhdamv4dnpkpv6b30bcb60qq8sy44fz13hilys";
  };
  sys = architectures.${system} or (throw "unsupported system: ${system}");
  sha = checksums.${system} or (throw "unsupported system: ${system}");
  src = pkgs.fetchurl {
    url = "https://github.com/itsdalmo/tfcheck/releases/download/v0.1.2/tfcheck-0.1.2-${sys}.tar.gz";
    sha256 = sha;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "tfcheck";
  version = "0.1.2";
  inherit src;

  sourceRoot = ".";
  dontStrip = pkgs.lib.strings.hasSuffix "darwin" system;
  nativeBuildInputs = [ pkgs.gzip ];
  installPhase = ''
    mkdir -p $out/bin
    mv tfcheck $out/bin
  '';
}
