{
  description = "A better pushd interface";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-systems.url = "github:nix-systems/default";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      eachSystem = nixpkgs.lib.genAttrs (import inputs.nix-systems);
      mkPkgs = system:
        import nixpkgs {
          inherit system;
          overlays = [ inputs.rust-overlay.overlays.default ];
        };
    in {
      overlays.default =
        (final: prev: { dirStack = self.packages.${prev.system}.default; });
      packages = eachSystem (system:
        let
          pkgs = mkPkgs system;
          meta = pkgs:
            with pkgs.lib; {
              description = "A cd quicklist";
              homepage = "https://github.com/NewDawn0/dirStack";
              maintainers = with maintainers; [ NewDawn0 ];
              license = licenses.mit;
            };
          pkg = pkgs:
            pkgs.rustPlatform.buildRustPackage {
              meta = (meta pkgs);
              pname = "dirStack";
              version = "1.0.0";
              propagatedBuildInputs = with pkgs; [ fzf ];
              cargoLock.lockFile = ./Cargo.lock;
              src = pkgs.lib.cleanSource ./.;
            };
        in {
          default = pkgs.stdenv.mkDerivation {
            name = "dirStack-wrapped";
            version = "1.0.0";
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out/bin $out/lib
              cp ${pkg pkgs}/bin/dirStack $out/bin/
              echo "#!/usr/bin/env bash" > $out/lib/SOURCE_ME.sh
              $out/bin/dirStack --init >> $out/lib/SOURCE_ME.sh
              chmod +x $out/lib/SOURCE_ME.sh
            '';
            shellHook = ''
              source $out/lib/SOURCE_ME.sh
            '';
            meta = (meta pkgs);
          };
        });
    };
}
