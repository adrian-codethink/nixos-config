{
  description = "Adrian's Nix(OS) Config";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    };

    
  outputs =
    { nixpkgs, home-manager, ... }@inputs:

    let
      inherit (nixpkgs.lib) nixosSystem mapAttrs;
      inherit (home-manager.lib) homeManagerConfiguration;
    in

    {
      homeConfigurations = mapAttrs (
        target: cfg:
        homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${cfg.system};
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            { home.stateVersion = cfg.stateVersion; }
            ./hm-modules/all.nix
            { inherit (cfg) my-nixos-hm; }
          ];
        }
      ) (import ./hm-hosts.nix);

      nixosConfigurations = mapAttrs (
        hostname: host:
        nixosSystem {
          specialArgs = {
            inherit inputs host;
          };
          modules = [
            ./configurations/${hostname}-hardware.nix
            ./modules/all.nix
            ./configurations/${hostname}.nix
          ];
        }
      ) (import ./hosts.nix);

      packages."x86_64-linux".options-doc =
        let
          pkgs' = import ./packages/all.nix { pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
        in
        pkgs'.options-doc;
    };
}
