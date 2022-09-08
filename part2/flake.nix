{
  # Like any flake, we define a set of inputs that should be accessible to our
  # project.

  # This includes the `std` flake which provides the functions we need for
  # standardizing our project.
  inputs.std.url = "github:divnix/std";

  # The latest version of nixpkgs for us to consume.
  inputs.nixpkgs.url = "nixpkgs";

  # The rust-overlay flake allows us to fetch the most recent stable versions
  # of the Rust toolchain to use in our development shell.
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  # As per the flake schema, we define an attribute for holding the outputs of
  # our flake. In this case, `std` will be responsible for managing the outputs.
  outputs = { std, ... } @ inputs:
    # The `growOn` function can be seen as the main entrypoint into `std`. It is
    # responsible for growing our "organism" through cells into the final
    # product. It will produce an output schema that is specific to `std` and
    # can be further explored through the `std` CLI/TUI.
    #
    # The `growOn` function is similar to `grow` but allows us to expand our
    # flake outputs to include more than just what `std` generates by default.
    # It takes a variable number of attribute sets after the first one which
    # defines how it behaves and will recursively update them into one final
    # set. Without this, we would only be able to use the `std` CLI/TUI, as by
    # default `std` places outputs under the `__std` attribute which the nix CLI
    # knows nothing about.
    std.growOn
      {
        # Necessary for `std` to perform its magic.
        inherit inputs;

        # This is one of the most important arguments for the `grow` function.
        # It defines the path where `std` will search for our cells. In this
        # case, we're specifying the `nix` subdirectory. A cell, in this case,
        # would be defined in a subdirectory under `nix` (i.e. ./nix/cell).
        cellsFrom = ./nix;

        # This is the second most important argument for the `grow` function. It
        # informs `std` of the block types that exist within our cells and where
        # they can be found. In this case, we're specifying that we have
        # "runnable" block types that can be found in an `apps.nix` file under
        # the cell directory.
        #
        # The `std` framework has many different block types, and they primarily
        # dictate how the `std` CLI/TUI will behave.
        cellBlocks = [
          # The `runnable` type will allow us to run our cell block as an
          # executable using:
          #
          # > std //std-example/apps/default:run
          #
          # The `run` action is available because we've specified the `runnable`
          # cell block type. In this case, we're running the `default` target
          # which is defined as a derivation in ./nix/std-example/apps.nix that
          # builds our binary.
          (std.blockTypes.runnables "apps")

          # The `devshell` type will allow us to have "development shells"
          # available. These are managed by `numtide/devshell`.
          # See: https://github.com/numtide/devshell
          (std.clades.devshells "devshells")

          # The `function` type is a generic block type that allows us to define
          # some common Nix code that can be used in other cells. In this case,
          # we're defining a toolchain cell block that will contain derivations
          # for the Rust toolchain.
          (std.clades.functions "toolchain")
        ];
      }
      # This second argument, as described above, allows us to expand what gets
      # included in our flake output.
      {
        # In this case, we're using the built-in `harvest` function to "harvest"
        # the derivations from our apps cell block into the `packages` attribute
        # of our flake output. This allows us to interact with our flake using
        # the nix CLI. For example, we can run
        #
        # > nix run .#default
        #
        # Which will build and run our binary.
        packages = std.harvest inputs.self [ [ "std-example" "apps" ] ];

        # Likewise, we want to export our development shells so that the
        # following works as expected:
        #
        # > nix develop
        #
        # Or, we can put the following in a .envrc:
        #
        # use flake
        devShells = std.harvest inputs.self [ "std-example" "devshells" ];
      };
}
