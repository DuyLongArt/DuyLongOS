# To use this, import it into your configuration.nix:
# imports = [ ./postgres.nix ];
#
# This is a good default choice, very powerful and well-supported.

{ config, pkgs, ... }:

{


      # 1. Hostname Configuration
  # This sets the local name of your machine on the network.
  networking.hostName = "nixos-database";

  # 2. Static IP Address Configuration
  # This section configures a specific network interface (replace 'enp3s0' 
  # with the name of your actual wired or wireless interface).
  
  
  networking.firewall.enable = true; # Always good practice!
networking.enable = true;
  networking.useDHCP = true; # Needed for Wi-Fi too



  # Enable wpa_supplicant
  networking.wireless.enable = true;
  networking.wireless.interfaces = [ "wlan0" ]; # Your Wi-Fi interface name

  networking.interfaces.enp3s0 = {
    # Set this interface to NOT use DHCP.
    useDHCP = false;
    
    # Define the IP address and subnet mask (in CIDR notation).
    # Replace the IP with the desired address for your machine.
    # The /24 is common for home networks (subnet 255.255.255.0).
    ipv4.addresses = [
      {
        address = "192.168.22.5555"; # <-- YOUR DESIRED STATIC IP
        prefixLength = 24;
      }
    ];
  };


  networking.interfaces.wlan0 = {
    # Set this interface to NOT use DHCP.
    useDHCP = false;
    
    # Define the IP address and subnet mask (in CIDR notation).
    # Replace the IP with the desired address for your machine.
    # The /24 is common for home networks (subnet 255.255.255.0).
    ipv4.addresses = [
      {
        address = "192.168.22.5555";  # <-- YOUR DESIRED STATIC IP
        prefixLength = 24;
      }
    ];
  };

  # 3. Router/Gateway and DNS Configuration
  # These are essential for connecting to the internet.
  
  # Specify the IP address of your router/gateway
  networking.defaultGateway = "192.168.22.1"; 

  # Specify DNS servers for resolving domain names (e.g., Google's public DNS)
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  # Configure your network
  networking.wireless.networks = {
    "DuyLongNetwork" = {
      psk = "my-secret-password";
      # For a hidden network, add:
      # scan_ssid = 1;
    };
  };
    
  services.postgresql = {
    enable = true;

    # You can specify the version. 16 is the latest default.
    package = pkgs.postgresql_16;

    # By default, NixOS uses 'ident' auth, which can be tricky.
    # Using 'md5' (or 'scram-sha-256' on newer versions) allows
    # normal username/password logins.
    authentication = ''
      # TYPE  DATABASE        USER            ADDRESS_SPEC    METHOD
      local   all             all                             md5
      host    all             all             127.0.0.1/32    md5
      host    all             all             ::1/128         md5
    '';

    # This script runs *only* if the database cluster is initialized
    # for the first time. It's the declarative Nix way to create
    # your initial users and databases.

     authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser auth-method
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';

    initialScript = pkgs.writeText "postgresql-init" ''
      CREATE ROLE duylong WITH LOGIN PASSWORD 'duylongpass';
      CREATE DATABASE backend OWNER duylong;
    '';

    # By default, PostgreSQL only listens on localhost.
    # To allow network connections, change this to:
    listenAddresses = "*";
    #
    # If you do that, you MUST also open the firewall port:
    networking.firewall.allowedTCPPorts = [ 5432 ];
  };
}
