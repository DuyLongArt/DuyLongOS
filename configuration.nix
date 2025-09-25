# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs, lib,  ... }:
{
# /etc/nixos/configuration.
  services.desktopManager.plasma6.enable=true;
  
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
