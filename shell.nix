{ pkgs }:
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      shfmt
      shellcheck
      stylua
    ];
  };
}
