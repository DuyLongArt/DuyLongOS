{ pkgs ? import <nixpkgs> { } }:

let
  nixos = import <nixpkgs/nixos> {
    configuration = {
      imports = [
        ./configuration.nix
        <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
      ];
      # Compress the image to save space (optional, takes longer to build)
      sdImage.compressImage = false;
      
      # Allow unfree packages if needed
      nixpkgs.config.allowUnfree = true;
    };
  };
in
nixos.config.system.build.sdImage
