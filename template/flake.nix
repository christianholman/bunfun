{
  description = "[script-name] - A purpose-built TypeScript script with Bun";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pname = "[script-name]";
      version = "0.0.1";
      src = ./.;

      # Build node_modules as a separate derivation
      node_modules = pkgs.stdenv.mkDerivation {
        pname = "${pname}-node_modules";
        inherit src version;
        impureEnvVars =
          pkgs.lib.fetchers.proxyImpureEnvVars
          ++ [
            "GIT_PROXY_COMMAND"
            "SOCKS_SERVER"
          ];
        nativeBuildInputs = [pkgs.bun];
        dontConfigure = true;
        buildPhase = ''
          bun install --no-progress --frozen-lockfile
        '';
        installPhase = ''
          mkdir -p $out/node_modules
          cp -R ./node_modules $out
        '';
        outputHash = "";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      };
    in {
      packages.${pname} = pkgs.stdenv.mkDerivation {
        inherit pname version src;
        nativeBuildInputs = [pkgs.makeBinaryWrapper pkgs.bun];
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin

          # Link node_modules and copy source
          ln -s ${node_modules}/node_modules $out
          cp -R ./* $out

          # Create the binary wrapper
          makeBinaryWrapper ${pkgs.bun}/bin/bun $out/bin/${pname} \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.bun]} \
            --add-flags "run --prefer-offline --no-install --cwd $out ./src/index.ts"

          runHook postInstall
        '';
      };

      packages.default = self.packages.${system}.${pname};

      apps.${pname} = {
        type = "app";
        program = "${self.packages.${system}.${pname}}/bin/${pname}";
      };
      apps.default = self.apps.${system}.${pname};

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [bun typescript direnv];
        shellHook = ''
          echo "Welcome to the ${pname} dev shell!"
          echo "Bun version: $(bun --version)"

          # Set up .envrc if it doesn't exist
          if [ ! -e .envrc ]; then
            echo "use flake" > .envrc
            direnv allow
          fi
        '';
      };
    });
}
