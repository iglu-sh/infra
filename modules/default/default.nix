{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.infra.default;
  inherit (lib) mkOption types mkIf;
in
{
  options.infra.default.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enabel all default options for iglu infra.";
  };

  config = mkIf cfg.enable {
    infra = {
      sops.enable = true;
    };

    boot = {
      initrd.supportedFilesystems = {
        btrfs = true;
        zfs = lib.mkForce false;
      };

      loader = {
        systemd-boot = {
          enable = true;
          editor = false;
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
    };

    console.keyMap = "de-latin1";

    programs.zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "agnoster";
      };
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
    };

    users.defaultUserShell = pkgs.zsh;

    services = {
      openssh = {
        enable = true;
        openFirewall = true;
        startWhenNeeded = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    };

    security.sudo = {
      wheelNeedsPassword = false;
      execWheelOnly = true;
    };
  };
}
