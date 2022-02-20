{
  description = "A template for Nix based C++ project setup.";

  inputs = {
    # Pointing to the current stable release of nixpkgs. You can
    # customize this to point to an older version or unstable if you
    # like everything shining.
    #
    # E.g.
    #
    # nixpkgs.url = "github:NixOS/nixpkgs/unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/21.05";
    mlx = { url = github:42Paris/minilibx-linux
; flake = false; };
    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";

  };
	

  outputs = { self, nixpkgs,mlx, ... }@inputs: inputs.utils.lib.eachSystem [
    # Add the system/architecture you would like to support here. Note that not
    # all packages in the official nixpkgs support all platforms.
    "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin"
  ] (system: let pkgs = import nixpkgs {
                   inherit system;

                   # Add overlays here if you need to override the nixpkgs
                   # official packages.
                   overlays = [  ];
                     
                   # Uncomment this if you need unfree software (e.g. cuda) for
                   # your project.
                   #
                   # config.allowUnfree = true;
                 };

		mlx = (with pkgs; stdenv.mkDerivation {
          pname = "mlx";
          src = fetchgit {
            url = "github:42Paris/minilibx-linux";
            rev = "1kicijnx05y42m50c2fi5im2gi615zl5x9kr22xd1vf2lfjhq5k9";
            sha256 = "1kicijnx05y42m50c2fi5im2gi615zl5x9kr22xd1vf2lfjhq5k9";
          };
          nativeBuildInputs = [
		  gcc
          ];
          buildPhase = "make -j  $NIX_BUILD_CORES";
          installPhase = ''
            mkdir -p $out/bin
            mv $TMP/mlx/mlx $out/bin
          '';
        }
      );

             in {
               devShell = pkgs.mkShell rec {
                 # Update the name to something that suites your project.
                 name = "my-c++-project";
			



                 packages = with pkgs; [
                   # Development Tools

                   # Development time dependencies
					mlx
					readline
					ncurses
                   # Build time and Run time dependencies
                 ];

                 # Setting up the environment variables you need during
                 # development.
                 shellHook = let
                   icon = "f121";
                 in ''
                    export PS1="$(echo -e '\u${icon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
                 '';
               };

               defaultPackage = pkgs.callPackage ./default.nix {};
             });
}
