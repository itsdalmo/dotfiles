{
  fetchFromGitHub,
  symlinkJoin,
}:

let
  version = "1.2.3";
  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "v${version}";
    hash = "sha256-I/EXHGW92nXz6JCLp8SKGgzXrbbUTkLAfxv8bc/ThwQ=";
  };
in
symlinkJoin {
  name = "mattpocock-skills-${version}";
  paths = [ "${src}/skills" ];
  postBuild = ''
    rm -rf $out/deprecated
    rm -rf $out/misc
    rm -rf $out/personal

    rm -rf $out/engineering/setup-matt-pocock-skills
  '';
}
