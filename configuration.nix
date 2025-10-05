# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs, lib,  ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{



    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

     (import "${home-manager}/nixos")
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

# --- Your existing configuration ---
# enable plasma 6 KDE



  services.desktopManager.plasma6.enable=true;

#  services.xserver.desktopManager.plasma5.enable = true;

    services.displayManager.sddm.enable = true;

    services.displayManager.sddm.wayland.enable = true;

    services.displayManager.defaultSession="plasmax11";




boot.initrd.kernelModules = [ "amdgpu" ];

services.xserver.videoDrivers = [ "amdgpu" ];


services.xserver = {
  enable = true;


};

nixpkgs.config.allowUnfree = true;
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
      #pkgs.libsForQt5.kate
   pkgs.kdePackages.kate
      thunderbird
      affine
  obsidian


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
    useOSProber = true;
  efiSupport = true;                # If you're using UEFI
  efiInstallAsRemovable = true;    # Helps on systems with restricted EFI variables
  device = "nodev";                # Required for EFI systems
  };

 # boot.loader.systemd-boot.enable = false;  # Disable systemd-boot if previously used

  boot.loader.grub.configurationLimit = 5;  # Optional: limit number of entries
  boot.loader.grub.extraConfig = ''
    set timeout=300
    set default=0
  '';

  virtualisation.docker.enable = true;
  # Docker group configuration (ensure Docker service is enabled)
  users.extraGroups.docker.members = [ "duylong" ];

 # Nextcloud service
#   services.nextcloud = {
#     enable = true;
#     home = "/home/duylong/NextCloud/";
#     hostName = "localhost"; # Change this to your domain name for external access
#
#     config = {
#       adminuser = "duylongadmin";
#       dbtype = "pgsql";
#       dbname = "duylongdb";
#       dbuser = "duylong";
#       dbpassFile = "/home/duylong/NextCloud/Password/nextcloud-db-password.txt";
#       adminpassFile = "/home/duylong/NextCloud/Password/nextcloud-admin-password.txt";
#     };
#   };
#
#   # PostgreSQL service configuration
#   services.postgresql = {
#     enable = true;
#     package = pkgs.postgresql_16;
#     ensureDatabases = [ "duylongdb" ];
#     ensureUsers = [{
#       name = "duylong";
#       ensureDBOwnership = true;
#     }];
#
#     initialScript = ''
#       CREATE ROLE duylong WITH LOGIN PASSWORD '${builtins.readFile "/home/duylong/NextCloud/Password/nextcloud-db-password.txt"}';
#       GRANT ALL PRIVILEGES ON DATABASE duylongdb TO duylong;
#     '';
#   };

  # Web server configuration (Nginx is used by Nextcloud by default)

  services.nginx={
    enable=true;
    virtualHosts = {

    "localhost" = {
      forceSSL = false;
      enableACME = false;
    };
  };
  };




  # Firewall settings
  networking.firewall = {
    enable = true;
    allowPing = true;
  };
  # Create password files and secrets (using text-based configuration)

 security.acme.defaults.email = "duylongmind432001@gmail.com"; # <--- FIX 1: Add your email here
#   security.acme.acceptTerms = true;
# This assumes the code snippet is within the main options block
services=
{
  nextcloud = {
    enable = true;
    hostName = "localhost";
    package = pkgs.nextcloud31;
    database.createLocally = true;
    configureRedis = true;
    maxUploadSize = "16G";
    https = false;

    autoUpdateApps.enable = true;
    extraAppsEnable = true;

    # --- Start of extraApps block ---
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar  notes  tasks;
    };
    # --- End of extraApps block ---

    # --- Start of config block (MUST be here, at the same level as extraApps) ---
    settings={
      trusted_domains=[
      "192.168.1.142"];
    };
    config = {
#       overwriteProtocol = "https";
#       defaultPhoneRegion = "PT";

      dbtype = "pgsql";
      adminuser = "admin";
      # Note: The adminpassFile should point to a file containing only the password.
      adminpassFile = "/home/duylong/NextClouldPass/nextcloud-admin-password.txt";
    };
    # --- End of config block ---
  };
};


  # Enable Fish shell and Nix initialization
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # Nix-specific Fish shell configuration
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
  '';

  # Add Fish and Bash to environment shells
  environment.shells = with pkgs; [ bashInteractive fish ];


 environment.systemPackages = with pkgs; [

    pkgs.vscode

   pkgs.nextcloud-client
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


  # Enable IPv4 packet forwarding
#   boot.kernel.sysctl = {
#     "net.ipv4.conf.all.forwarding" = true;
#   };
#
#   networking = {
#     interfaces = {
#       "eth0" = {
#         # DHCP needed to acquire IP for WAN
#         useDHCP = true;
#       };
#       "eth1" = {
#         # Static IP needed for LAN gateway
#         useDHCP = false;
#         ipv4.addresses = [{
#           address = "192.168.0.1";
#           prefixLength = 24;
#         }];
#       };
#     };
#   };
/*
  networking = {
    # Disable firewall (this will be handled by nftables)
    firewall.enable = false;

    nftables = {
      enable = true;
      tables = {
        # Allow select IPv4 traffic
        filterV4 = {
          family = "ip";
          content = ''
            chain input {
              type filter hook input priority 0; policy drop;
              iifname "lo" accept comment "allow loopback traffic"
              iifname "eth1" accept comment "allow traffic from LAN"
              iifname "eth0" ct state established, related accept comment "allow established traffic from WAN"
              iifname "eth0" ip protocol icmp counter accept comment "allow ICMP traffic from WAN"
              iifname "eth0" tcp dport 22 counter accept comment "allow SSH traffic from WAN"
              iifname "eth0" counter drop comment "drop all other traffic from WAN"
            }
            chain forward {
              type filter hook forward priority 0; policy drop;
              iifname "eth1" oifname "eth0" accept comment "allow LAN connections to forward to WAN"
              iifname "eth0" oifname "eth1" ct state established, related accept comment "allow established WAN connections to forward to LAN"
            }
          '';
        };
        # Allow forwarded traffic out through WAN, masquerades IP
        natV4 = {
          family = "ip";
          content = ''
            chain postrouting {
              type nat hook postrouting priority 100; policy accept;
              oifname "eth0" masquerade comment "replace source address with WAN IP address"
            }
          '';
        };
        # Drops all IPv6 traffic
        filterV6 = {
          family = "ip6";
          content = ''
            chain input {
              type filter hook input priority 0; policy drop;
            }
            chain forward {
              type filter hook forward priority 0; policy drop;
            }
          '';
        };
      };
    };
  };
 # DHCP server for LAN
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ "eth1" ];

      lease-database = {
        name = "/var/lib/kea/dhcp4-leases.csv";
        type = "memfile";
        persist = true;
        lfc-interval = 3600;
      };

      valid-lifetime = 4000;
      renew-timer = 1000;
      rebind-timer = 2000;

      subnet4 = [{
        id = 1;
        subnet = "192.168.0.0/24";
        pools = [{
          pool = "192.168.0.16 - 192.168.0.128";
        }];

        option-data = [{
          name = "routers";
          data = "192.168.0.1";
        }{
          name = "domain-name-servers";
          data = "1.1.1.1"; # Cloudflare DNS
        }];
      }];
    };
  };*/

 home-manager.users.duylong = { pkgs, ... }: {

    programs.bash.enable = true;
  programs.home-manager.enable = true;
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
     home.packages = with pkgs; [
    neofetch
    htop
    git
    firefox
  ];

  # You can also use specific Home Manager modules for more advanced configuration
  # For example, to configure Git:
  programs.git = {
    enable = true;
    userName = "DuyLongArt";
    userEmail = "duylongmind432001l@gmail.com";
  };

   programs.alacritty = {
    enable = true;
    settings = {
      # Here's where you put your Alacritty configuration
      font = {
        size = 11.0;
        normal = {
        family = "Fira Code";
        };
      };
      colors = {
        primary = {
          background = "#1f1d2e";
          foreground = "#e0def4";
        };
      };
      window = {
        opacity = 0.8;
      };
    };
  };

  };

  # A list of packages you want to install.
networking.firewall.allowedTCPPorts = [ 80 443 ];
system.stateVersion="25.05";
}
