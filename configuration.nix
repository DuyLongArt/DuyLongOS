# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs,.. }:
{
# /etc/nixos/configuration.
  services.desktopManager.plasma6.enable=true;
  virtualisation.docker.enable = true;

  users.extraGroups.docker.members = [ docker ];

  # This allows you to use the modern 'docker compose' command
  virtualisation.docker.enableNixOSBuilds = true;
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

}
