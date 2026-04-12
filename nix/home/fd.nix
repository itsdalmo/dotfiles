{ config, lib, ... }:
lib.mkMerge [
  {
    programs.fd = {
      enable = true;
      ignores = [
        ".git"
        "Desktop"
        "Documents"
        "Downloads"
        "Library"
        "Movies"
        "Music"
        "Pictures"
        "Public"
      ];
    };
  }
  (lib.mkIf config.programs.fzf.enable {
    programs.fzf = {
      defaultCommand = "fd --follow --hidden";
      fileWidgetCommand = "fd --follow --hidden .";
    };
  })
]
