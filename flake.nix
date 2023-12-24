{
  description = "Flake for universe family of packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/haskell-updates";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hpkgs = pkgs.haskellPackages.override (old: {
          overrides = pkgs.lib.composeExtensions (old.overrides or (_: _: { }))
            (self: super: {
              universe = self.callCabal2nix "universe" ./universe { };
              universe-base =
                self.callCabal2nix "universe-base" ./universe-base { };
              universe-dependent-sum =
                self.callCabal2nix "universe-dependent-sum"
                ./universe-dependent-sum { };
              universe-instances-extended =
                self.callCabal2nix "universe-instances-extended"
                ./universe-instances-extended { };
              universe-reverse-instances =
                self.callCabal2nix "universe-reverse-instances"
                ./universe-reverse-instances { };
              universe-some =
                self.callCabal2nix "universe-some" ./universe-some { };
            });
        });
      in {
        packages = {
          inherit (hpkgs)
            universe universe-base universe-dependent-sum
            universe-instances-extended universe-reverse-instances
            universe-some;
        };

        defaultPackage = self.packages.${system}.universe;
        devShell = hpkgs.shellFor {
          packages = h:
            with h; [
              universe
              universe-base
              universe-dependent-sum
              universe-instances-extended
              universe-reverse-instances
              universe-some
            ];
          buildInputs = with hpkgs; [
            cabal-install
            ghcid
            haskell-language-server
            nixfmt
            ormolu
          ];
          withHoogle = false;
          withHaddocks = false;
        };
      });
}
