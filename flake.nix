{
  description = "A better pushd interface";

  inputs.utils.url = "github:NewDawn0/nixUtils";

  outputs = { self, utils, ... }@inputs: {
    overlays.default = final: prev: {
      dirStack = self.packages.${prev.system}.default;
    };
    packages = utils.lib.eachSystem { } (pkgs:
      let
        version = "1.0.0";
        meta = {
          description = "Fast directory navigation tool with a quicklist";
          longDescription = ''
            This utility allows you to change directories quickly using a user defined list of frequently used paths.
            It reduces the time spent on navigation and enhances workflow efficiency.
          '';
          homepage = "https://github.com/NewDawn0/dirStack";
          license = pkgs.lib.licenses.mit;
          maintainers = with pkgs.lib.maintainers; [ NewDawn0 ];
          platforms = pkgs.lib.platforms.all;
        };
        basePkg = pkgs.rustPlatform.buildRustPackage {
          inherit meta version;
          pname = "dirStack";
          src = ./.;
          useFetchCargoVendor = true;
          cargoHash = "sha256-Q0PqPWT31k8n4YboELd/OgX4FsdSUtWnSyofuEoADnU=";
          propagatedBuildInputs = with pkgs; [ fzf ];
        };
      in {
        default = pkgs.stdenvNoCC.mkDerivation {
          inherit meta version;
          pname = "dirStack-wrapped";
          src = null;
          dontUnpack = true;
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            install -D ${basePkg}/bin/dirStack -t $out/bin
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
