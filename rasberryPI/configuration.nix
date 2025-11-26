{ config, pkgs, lib, ... }:

{
  # imports = [
  #   ./hardware-configuration.nix # Include if you have one generated
  # ];

  # Bootloader configuration for Raspberry Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking
  networking.hostName = "nixos-pi";
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # User configuration
  users.users.duylong = {
    isNormalUser = true;
    description = "Ngô Đoàn Duy Long";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      git
      vim
      htop
    ];
    # Initial password setup or SSH keys are recommended
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ]; 
  };

  # Enable SSH
  services.openssh.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
  ];

  # Hardware specific settings for Pi 4 (optional but recommended if using nixos-hardware)
  # hardware.enableRedistributableFirmware = true;

  system.stateVersion = "24.05";
}