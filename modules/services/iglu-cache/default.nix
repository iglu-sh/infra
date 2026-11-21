{ config, lib, ... }:

let
  cfgS = config.infra.services;
  cfg = cfgS.iglu-cache;
  inherit (lib)
    mkIf
    mkEnableOption
    types
    mkOption
    ;
in
{
  options.infra.services.iglu-cache = {
    enable = mkEnableOption "Enable iglu cache on server.";
    public_key = mkOption {
      type = with types; nullOr str;
      default = "";
      description = "Public key used for the default tenant.";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      secrets = {
        "services/iglu-cache/hashing_secret" = {
          owner = "iglu";
          group = "iglu";
          restartUnits = [ "iglu-cache.service" ];
        };
        "services/iglu-cache/encryption_secret" = {
          owner = "iglu";
          group = "iglu";
          restartUnits = [ "iglu-cache.service" ];
        };
      };
    };

    infra.services.caddy.enable = true;

    services = {
      iglu-cache = {
        enable = true;
        database = {
          type = "postgres";
          createLocally = true;
        };
        settings = {
          config.reconcile.mode = "authorative";
          logger.log_level = "debug";
          server.hostname = "https://cache.${cfgS.publicDomain}";
          tenants."default" = {
            name = "default";
            preferred_compression_method = "zstd";
            priority = 1;
            ttl = "5w";
            signing_method = "server";
            github_username = "iglu-sh";
            is_public = true;
          };
          api_keys."default" = {
            generated = true;
            tenant = "default";
          };
          public_keys."default" = {
            key = cfg.public_key;
            linked_api_key = "default";
            name = "default";
          };
          keypairs."default" = {
            generated = true;
            signing_key = "default";
            tenant = "default";
          };
        };
      };

      caddy = {
        virtualHosts = {
          "cache.${cfgS.publicDomain}" = {
            extraConfig = ''
              reverse_proxy localhost:${toString config.services.iglu-cache.settings.server.port}
            '';
          };
        };
      };
    };
  };
}
