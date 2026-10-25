{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostName = "dalmobook";
  user = "dalmo";
  certs = "/etc/ssl/certs/ca-certificates.crt";
in
{
  imports = [
    ../../nix.nix
    ../../darwin.nix
    ./hardware-configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${user}" = {
      imports = [ ../../home.nix ];

      home.sessionVariables = {
        NODE_EXTRA_CA_CERTS = certs;
        REQUESTS_CA_BUNDLE = certs;
        SSL_CERT_FILE = certs;
      };

      xdg.configFile = {
        "colima/_templates/default.yaml".text = ''
          cpu: 6
          disk: 100
          memory: 8

          arch: host
          runtime: docker
          rootDisk: 20
          vmType: vz
          mountType: virtiofs
          mountInotify: true
          portForwarder: ssh

          provision:
            - mode: system
              script: |
                cat <<EOF > /usr/local/share/ca-certificates/zscaler.crt
                ${builtins.replaceStrings [ "\n" ] [ "\n      " ] (builtins.readFile ./zscaler.crt)}
                EOF
                update-ca-certificates
                service docker restart
        '';
      };
    };
    extraSpecialArgs = {
      user = user;
    };
  };

  nix.buildMachines = [
    {
      hostName = "dalmobox.wombat-woodpecker.ts.net";
      sshKey = "/var/root/.ssh/id_nixremote";
      sshUser = "nix-ssh";
      protocol = "ssh-ng";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUxEN2lBeWwyVE1Ld2ZUcEZFcU4yeS9zQ2lGWmUrSDZDWWJuaThVa2NwRSsgcm9vdEBkYWxtb2JveAo=";
      maxJobs = 4;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
      supportedFeatures = [ "kvm" ];
    }
  ];
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  system.primaryUser = user;

  users.users."${user}" = {
    shell = pkgs.zsh;

    # nix-darwin requires these to be set even if the user already exists
    uid = 501;
    home = "/Users/${user}";
  };

  # nix-darwin will not touch the user unless its specified here
  users.knownUsers = [ user ];

  networking = {
    hostName = hostName;
    computerName = hostName;
    localHostName = hostName;

    dns = [
      "8.8.8.8"
      "8.8.4.4"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];

    knownNetworkServices = [ "Wi-Fi" ];
  };

  security.pki.certificates = [ (builtins.readFile ./zscaler.crt) ];

  # Roots with compromised eMudhra intermediates (CVE-2026-111943). Mirrors
  # NixOS/nixpkgs#576390, which only patched the NixOS module, not nix-darwin.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];

  nix.settings.ssl-cert-file = certs;

  homebrew.masApps = {
    # "1Password for Safari" = 1569813296;
    # "AdGuard for Safari" = 1440147259;
    # "Azure VPN Client" = 1553936137;
  };
}
