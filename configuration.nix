# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs, lib,  ... }:
{



    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
   
  


  users.users={
    duylong={
    isNormalUser = true;
    createHome=false;
    decription="Ngô Đoàn Duy Long";
    home="/home/duylong";
    extraGroups=[
      "wheel"
      "networkmanager"
    ];
    group="admin";
    uid=1000;
    shell=pkgs.bash;
    };
     packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];

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


  boot.loader.grub = {
  enable = true;
  version = 2;
  efiSupport = true;                # If you're using UEFI
  efiInstallAsRemovable = true;    # Helps on systems with restricted EFI variables
  device = "nodev";                # Required for EFI systems
  };

  boot.loader.systemd-boot.enable = false;  # Disable systemd-boot if previously used

  boot.loader.grub.configurationLimit = 5;  # Optional: limit number of entries
  boot.loader.grub.extraConfig = ''
    set timeout=30
    set default=0
  '';

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNixOSBuilds = true;


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
   environment.shells = with pkgs; [ bashInteractive  fish ];

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
      python3Packages.pipenv
      
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



services.nextcloud = {
    enable = true;
    # ⚠️ IMPORTANT: Set a strong password here
    initialUser = "duylong";
    initialPass = "duylongpass";

    # Specify the URL where Nextcloud will be accessible
    # Replace 'cloud.example.com' with your actual domain name
    hostName = "localhost"; 


    # Link the Nextcloud service to the PostgreSQL database
    database.type = "postgresql";
    database.createLocally = true;
    database.localConfig = {
      # This tells Nextcloud where to find the local PostgreSQL service
      user = "duylongdb";
      password = "duylongpass"; # ⚠️ Use a strong, unique password
    };

    # Enable recommended apps and optimizations
    config = {
      adminuser="duylongadmin";
      enable_previews = true;
      enabled_backends = [ "imagick" "ffmpeg" ];
    };

    # Optional: Configure PHP for Nextcloud's requirements (recommended)
    phpOptions = {
      # Nextcloud requires a high memory limit
      memory_limit = "6000M"; 
    };
  };

  # ----------------------------------------------------
  # 2. Web Server and HTTPS (Caddy Example)
 

  # ----------------------------------------------------
  # 3. Enable PostgreSQL Service
  # ----------------------------------------------------
  services.postgresql.enable = true;

  # ----------------------------------------------------
  # 4. Networking and Firewall
  # ----------------------------------------------------
  networking.firewall.allowedTCPPorts = [ 80 443 ];





  # 1. Enable and configure the ISC DHCP Daemon
  services.isc-dhcpd = {
    enable = true;
    
    # ⚠️ IMPORTANT: Set the network interface the DHCP server should listen on.
    # Replace 'eth1' with the name of your server's LAN interface.
    interface = "eth1"; 

    # Configuration written to dhcpd.conf
    extraConfig = ''
      # General settings
      default-lease-time 600;
      max-lease-time 7200;
      authoritative; # Tell clients we are the authoritative server for this network
      
      # Set the subnet to manage
      subnet 192.168.22.0 netmask 255.255.255.0 {
        range 192.168.22.100 192.168.22.500; # IP address pool for dynamic allocation
        option domain-name-servers 192.168.22.1, 8.8.8.8; # gateway
        option routers 192.168.22.1; # Default gateway provided to clients
        option broadcast-address 192.168.22.255;
      }
      
      # Optional: Static IP reservation for a specific host (e.g., a printer or server)
      host my-server-host {
        hardware ethernet aa:bb:cc:dd:ee:ff; # Replace with the host's actual MAC address
        fixed-address 192.168.22.50; # The specific IP address to assign
      }
    '';
  };

  # 2. Open the necessary firewall ports
  # DHCP uses UDP ports 67 (server) and 68 (client)
  networking.firewall.allowedUDPPorts = [ 67 68 ];
  
  # 3. Ensure the DHCP server has a static IP on its interface
  # (Example, assuming 'eth1' is the LAN interface)
  networking.interfaces.eth1.ipv4.addresses = [
    { address = "192.168.22.1"; prefixLength = 24; }
  ];

}
