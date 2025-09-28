# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs, lib,  ... }:
{



    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];




  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

# enable plasma 6 KDE
 services.xserver.enable = false;

  services.desktopManager.plasma6.enable=true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

programs.firefox.enable=true;

users.users = {
  duylong = {
    isNormalUser = true;
    description = "Ngô Đoàn Duy Long";
    extraGroups = [
      "wheel"
      "networkmanager"
      "admin" # The group is usually handled this way.
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      kdePackages.kate

      # thunderbird
    ];
  };
};
  users.groups.admin={

  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

boot.loader.efi.canTouchEfiVariables=false;
  boot.loader.grub = {
  enable = true;
  efiSupport = true;                # If you're using UEFI
  efiInstallAsRemovable = true;    # Helps on systems with restricted EFI variables
  device = "nodev";                # Required for EFI systems
  };

 # boot.loader.systemd-boot.enable = false;  # Disable systemd-boot if previously used
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

boot.loader.efi.canTouchEfiVariables=false;
  boot.loader.grub = {
  enable = true;
  efiSupport = true;                # If you're using UEFI
  efiInstallAsRemovable = true;    # Helps on systems with restricted EFI variables
  device = "nodev";                # Required for EFI systems
  };

 # boot.loader.systemd-boot.enable = false;  # Disable systemd-boot if previously used

  boot.loader.grub.configurationLimit = 5;  # Optional: limit number of entries
  boot.loader.grub.extraConfig = ''
    set timeout=30
    set default=0
  '';

  virtualisation.docker.enable = true;


  users.extraGroups.docker.members = [
    "duylong"
  ];
  # This allows you to use the modern 'docker compose' command

  programs.fish.enable=true;
  programs.fish.shellInit = ''
  # Nix
  if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
  end
  # End Nix
  '';


 environment.systemPackages = with pkgs; [
      #Node
      nodejs_22
      nodePackages.npm
      nodePackages.yarn
      nodePackages.pnpm
      nodePackages.typescript
      nodePackages.ts-node
      nodePackages.nodemon
      nodePackages.eslint
      nodePackages.prettier


      # Python development
      python3
      python3Packages.pip
      python3Packages.setuptools
      python3Packages.wheel
      python3Packages.virtualenv
      pipenv

      # Build tools
      cmake
      autoconf
      automake
      libtool

      # Version control and utilities
      git
      curl
      wget
      jq
      tree
      vim
    ];



system.stateVersion="25.05";


}

  boot.loader.grub.configurationLimit = 5;  # Optional: limit number of entries
  boot.loader.grub.extraConfig = ''
    set timeout=30
    set default=0
  '';

  virtualisation.docker.enable = true;


  users.extraGroups.docker.members = [
    "duylong"
  ];
  # This allows you to use the modern 'docker compose' command

  programs.fish.enable=true;
  programs.fish.shellInit = ''
  # Nix
  if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
  end
  # End Nix
  '';


 environment.systemPackages = with pkgs; [
      #Node
      nodejs_22
      nodePackages.npm
      nodePackages.yarn
      nodePackages.pnpm
      nodePackages.typescript
      nodePackages.ts-node
      nodePackages.nodemon
      nodePackages.eslint
      nodePackages.prettier


      # Python development
      python3
      python3Packages.pip
      python3Packages.setuptools
      python3Packages.wheel
      python3Packages.virtualenv
      pipenv

      # Build tools
      cmake
      autoconf
      automake
      libtool

      # Version control and utilities
      git
      curl
      wget
      jq
      tree
      vim
    ];



system.stateVersion="25.05";


}
