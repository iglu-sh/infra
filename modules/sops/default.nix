{ config, lib, ... }:

let
  cfg = config.infra.sops;

  inherit (lib) mkEnableOption mkIf;
in
{
  options.infra.sops = {
    enable = mkEnableOption "Enable sops default settings.";
  };

  config = mkIf cfg.enable {
    sops.defaultSopsFile = ../../secrets + "/${config.networking.hostName}.yaml";
  };
}
