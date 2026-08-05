{
  coreutils,
  gh,
  jq,
  writeShellApplication,
}:

writeShellApplication {
  name = "github-work";

  runtimeInputs = [
    coreutils
    gh
    jq
  ];

  text = builtins.readFile ./github-work.sh;
}
