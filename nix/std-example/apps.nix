# A common `std` idiom is to place all buildables for a cell in a `apps.nix`
# cell block. This is not required, and you can name this cell block anything
# that makes sense for your project.
#
# This cell block is used to define how our example application is built.
# Ultimately, this means it produces a nix derivation that, when evalulated,
# produces our binary.

{ inputs
, cell
}:
let
  # The `inputs` attribute allows us to access all of our flake inputs.
  inherit (inputs) nixpkgs std;

  # This is a common idiom for combining lib with builtins.
  l = nixpkgs.lib // builtins;
in
{
  # We can think of this attribute set as what would normally be contained under
  # `outputs.packages` in our flake.nix. In this case, we're defining a default
  # package which contains a derivation for building our binary.
  default = with inputs.nixpkgs; rustPlatform.buildRustPackage {
    pname = "std-example";
    version = "0.1.0";

    src = inputs.self;
    cargoLock = {
      lockFile = inputs.self + "/Cargo.lock";
    };

    meta = {
      description = "An example repository showcasing the Nix std framework";
    };
  };
}
