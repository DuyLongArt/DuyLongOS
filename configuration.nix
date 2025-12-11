{ config, pkgs, lib, ... }:

let


  # 2. Define the JAR as a package
  autoCopierJar = pkgs.stdenv.mkDerivation {
    pname = "autofolder-copier-system";
    version = "1.0";
    src = /home/duylong/Desktop/Code/OSServices/AutofolderCopier.jar;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/jar
      cp $src $out/jar/AutofolderCopier.jar
    '';
  };

  # Set release version for fetching mailserver source
  release = "nixos-25.05";

in
{
  # -------------------------------------------------------------------
  # 1. IMPORTS
  # -------------------------------------------------------------------
  imports =
    [
      ./hardware-configuration.nix

    ];

  # -------------------------------------------------------------------
  # 2. SYSTEM & ENVIRONMENT
  # -------------------------------------------------------------------
  networking.hostName = "nixos";
  networking.domain = "duylong.art";
  networking.fqdn = "mail.duylong.art";
#
  networking.interfaces.enp5s0.useDHCP=true;


  networking.firewall = {
    enable = true;
    allowPing = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port 41641 ];

    # Combined mail/web ports (from the original firewall block)
    allowedTCPPorts = [ 25 465 587 143 993 80 443 4190 41641];
  };

  time.timeZone = "Asia/Ho_Chi_Minh";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN"; LC_IDENTIFICATION = "vi_VN"; LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN"; LC_NAME = "vi_VN"; LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN"; LC_TELEPHONE = "vi_VN"; LC_TIME = "vi_VN";
  };


  nixpkgs.config.allowUnfree = true;

  users.users.duylong = {
    isNormalUser = true;
    description = "Ngô Đoàn Duy Long";
    extraGroups = [ "wheel" "networkmanager" "admin" "docker" ];
    shell = pkgs.bash;
    packages = with pkgs; [
      tailscale
      pkgs.kdePackages.kate
      thunderbird
      affine
      obsidian
    ];
  };

  users.groups.admin = {};
  users.extraGroups.docker.members = [ "duylong" ]; # Ensure Docker group membership

  # Your other imports...
  programs.java.enable = true;

  environment.systemPackages = with pkgs; [
    vscode nextcloud-client nodejs_22 nodePackages.npm nodePackages.yarn
    nodePackages.pnpm nodePackages.typescript nodePackages.ts-node
    nodePackages.nodemon nodePackages.eslint nodePackages.prettier
    pkgs.noip docker python3 python3Packages.pip python3Packages.setuptools
    python3Packages.wheel python3Packages.virtualenv pipenv cmake autoconf
    automake libtool git curl wget jq tree vim
  ];





  # -------------------------------------------------------------------
  # 4. SERVICES AND DAEMONS
  # -------------------------------------------------------------------
  services = {
    # 4a. Nextcloud (Consolidated the duplicate 'services={nextcloud={...}}' block)
    nextcloud = {
      enable = true;
      hostName = "localhost"; # Using localhost since Nginx is handling the domain
      package = pkgs.nextcloud31;
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "16G";
      https = false;
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar notes tasks;
      };
      settings = {
        trusted_domains = [ "192.168.1.142" "100.64.22.2" ];
      };
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = "/home/duylong/NextClouldPass/nextcloud-admin-password.txt";
      };
    };


    nginx = {
      enable = true;
      virtualHosts = {
        "localhost" = {
          forceSSL = false;
          enableACME = false;
        };
        "duylong.art" = {
          forceSSL = false;
#           enableSSL = true
        };
      };
    };

    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    displayManager.defaultSession = "plasmax11";
    xserver.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];

    tailscale.enable = true;
    timesyncd.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
#     security.rtkit.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };


  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    configurationLimit = 5;
    extraConfig = ''
      set timeout=300
      set default=0
    '';
  };


  system.stateVersion = "25.05"; # Standardized state version
}
