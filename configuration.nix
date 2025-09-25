# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs, lib,  ... }:
{
# /etc/nixos/configuration.
  services.desktopManager.plasma6.enable=true;
   services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
   
  users.users={
    duylong={
    createHome=false;
    decription="";
    home="/home/duylong";
    extraGroups=[
      "wheel"
      "networkmanager"
    ];
    group="admin";
    uid=1000;
    shell=pkgs.bash;
    }

  };
  users.groups.admin={

  };
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
