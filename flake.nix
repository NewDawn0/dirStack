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
          version = "1.0.0";
          meta = {
            description = "A fast directory navigation tool with a quicklist";
            longDescription = ''
              This utility allows you to change directories quickly using a user defined list of frequently used paths.
              It reduces the time spent on navigation and enhances workflow efficiency.
            '';
            homepage = "https://github.com/NewDawn0/dirStack";
            license = pkgs.lib.licenses.mit;
            maintainers = with pkgs.lib.maintainers; [ NewDawn0 ];
            platforms = pkgs.lib.platforms.all;
          };
          pkg = pkgs.rustPlatform.buildRustPackage {
            inherit meta version;
            pname = "dirStack";
            src = ./.;
            cargoHash = "sha256-y3ELhG4877X6Cysg9NMaD/QC3SfPBdk2Vh1QeHF1+pU=";
            propagatedBuildInputs = with pkgs; [ fzf ];
          };
        in {
          default = pkgs.stdenv.mkDerivation {
            inherit meta version;
            pname = "dirStack-wrapped";
            src = null;
            dontUnpack = true;
            dontBuild = true;
            dontConfigure = true;
            installPhase = ''
              install -D ${pkg}/bin/dirStack -t $out/bin
              mkdir -p $out/lib
              echo "#!/${pkgs.runtimeShell}" > $out/lib/SOURCE_ME.sh
              $out/bin/dirStack --init >> $out/lib/SOURCE_ME.sh
            '';
            shellHook = ''
              source $out/lib/SOURCE_ME.sh
            '';
          };
        });
    };
}
