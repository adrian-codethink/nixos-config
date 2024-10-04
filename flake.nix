{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, disko, ... }:
    let
      # TODO: Adjust these values to your needs
      system = "x86_64-linux";
      hostName = "nixos-vm";
      rootAuthorizedKeys = [
        # This user can ssh using `ssh root@<ip>`
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6OgrgddyY05gzVggok2riToZffOqEqIouS39WoI4Jt"
      ];
    in
    {
      nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./disko.nix
          disko.nixosModules.disko
          ({ pkgs, ... }: {
            boot.loader = {
              systemd-boot.enable = true;
              efi.canTouchEfiVariables = true;
            };
            networking = { inherit hostName; };
            services.openssh.enable = true;
            environment.systemPackages = with pkgs; [
              git
              neovim
            ];

            users.users.root.openssh.authorizedKeys.keys = rootAuthorizedKeys;
            users.users.root.initialPassword = "root";

            system.stateVersion = "24.05";
          })
        ];
      };
    };
}
