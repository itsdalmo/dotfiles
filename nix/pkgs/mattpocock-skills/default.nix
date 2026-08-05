{
  fetchFromGitHub,
  symlinkJoin,
}:

let
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "v${version}";
    hash = "sha256-XqF709Y9GMKINzZITlbCTyatG9AxRZh0qn2vcv1Z8yo=";
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
