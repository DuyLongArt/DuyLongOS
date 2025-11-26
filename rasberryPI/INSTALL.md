# Installing NixOS on Raspberry Pi 4

## Prerequisites
- A Raspberry Pi 4
- A microSD card (at least 8GB)
- A computer with Nix installed (to build the image)

## 1. Build the SD Card Image

You can build a complete SD card image using your configuration.

Create a `flake.nix` in the `rasberryPI` directory if you want to use flakes, or use a standard `default.nix` wrapper.

### Option A: Using `nix-build` (Simpler)

Create a file named `default.nix` in the `rasberryPI` directory with the following content:

```nix
{ pkgs ? import <nixpkgs> { } }:

let
  nixos = import <nixpkgs/nixos> {
    configuration = {
      imports = [
        ./configuration.nix
        <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
      ];
      # Compress the image to save space
      sdImage.compressImage = false;
    };
  };
in
nixos.config.system.build.sdImage
```

Then run:
```bash
nix-build default.nix
```

This will produce a result symlink (e.g., `result/sd-image/nixos-sd-image-....img`).

## 2. Flash the Image

Identify your SD card device (e.g., `/dev/sdX` or `/dev/diskN`). **Be very careful!**

```bash
# On Linux
sudo dd if=result/sd-image/nixos-sd-image-*-aarch64-linux.img of=/dev/sdX bs=4M status=progress conv=fsync

# On macOS
sudo dd if=result/sd-image/nixos-sd-image-*-aarch64-linux.img of=/dev/rdiskN bs=4m
```

## 3. First Boot
1. Insert the SD card into the Raspberry Pi.
2. Power it on.
3. It should connect to Ethernet if plugged in, or you can configure Wi-Fi via `nmcli` if you have a keyboard/monitor attached.
4. Login with user `duylong` (you may need to set a password via root first if not configured, default root password is empty or `nixos` depending on the image, but usually it's best to set SSH keys in config).

> **Note:** If you didn't set a password or SSH key in `configuration.nix`, you might need physical access (keyboard/monitor) to log in as root and set a password for `duylong`.
