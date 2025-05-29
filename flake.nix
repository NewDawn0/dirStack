{
  description = "A better pushd interface";

  inputs.utils.url = "github:NewDawn0/nixUtils";

  outputs = { self, utils, ... }: {
    overlays.default = final: prev: {
      dir-stack = self.packages.${prev.system}.default;
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
          name = "dirStack";
          src = null;
          dontUnpack = true;
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            install -D ${basePkg}/bin/dirStack $out/bin/dirStack
            echo "#!${pkgs.runtimeShell}" > SOURCE_ME.sh
            $out/bin/dirStack --init >> SOURCE_ME.sh
            install -Dm644 SOURCE_ME.sh $out/share/dirStack/SOURCE_ME.sh
          '';
          shellHook = ''
            source $out/share/dirStack/SOURCE_ME.sh
          '';
        };
      });
  };
}
