{ lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options.infra.services = {
    publicDomain = mkOption {
      type = types.str;
      default = "example.com";
      description = "Domain used for the services.";
    };
  };
}
