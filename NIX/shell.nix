{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs;
    [
      nodejs_22
      openjdk21
    ] ;

  shellHook = ''
    echo "Node.js 22 environment ready!"
    node NodeApp/app.js
  '';
}
