{
  description = "A development shell with a specific Node.js version";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/COMMIT_HASH_HERE";
  };

  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        nodejs_22
      ];
    };
  };
}
