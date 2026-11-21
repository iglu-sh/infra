{
  description = "All VMs needed for the Iglu infrastructure.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    disko.url = "github:nix-community/disko";
    sops.url = "github:Mic92/sops-nix";
    iglu.url = "github:iglu-sh/iglu/chore-move-nixos-options";
  };

  outputs =
    inputs@{
      self,
      utils,
      ...
    }:

    let
      pkgs = inputs.nixpkgs;
      lib = pkgs.lib;
    in
    utils.lib.mkFlake {
      inherit self inputs;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      hostDefaults = {
        modules = with inputs; [
          iglu.nixosModules.default
          disko.nixosModules.disko
          sops.nixosModules.sops
          self.nixosModules.default
        ];
      };

      hosts =
        let
          inherit (builtins) attrNames readDir foldl';
          systems = attrNames (readDir ./hosts);
          hosts = map (
            system:
            (lib.genAttrs (attrNames (readDir (./hosts + "/${system}"))) (name: {
              inherit system;
              modules = [ (./hosts + "/${system}/${name}") ];
            }))
          ) systems;
        in
        foldl' (acc: item: acc // item) { } hosts;

      nixosModules.default = {
        imports = lib.fileset.toList (lib.fileset.fileFilter (file: file.name == "default.nix") ./.);
      };
    };

}
