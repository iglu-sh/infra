{ pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  infra = {
    services = {
      publicDomain = "iglu.sh";
      iglu-cache = {
        enable = true;
        public_key = "Z6AmDHNNlfVqV3IUDmhAKQL5wF7cADPROuLYUam+5Nk=";
      };
    };
  };

  users.users = {
    sudouser = {
      initialPassword = "sudouser";
      createHome = true;
      isNormalUser = true;
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A== Svenum"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  boot = {
    initrd.kernelModules = [ "virtio_gpu" ];
    kernelParams = [ "console=tty" ];
  };

  environment.systemPackages = [ pkgs.git ];

  system.stateVersion = "26.11";
}
