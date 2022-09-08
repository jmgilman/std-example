{
  # Like any flake, we define a set of inputs that should be accessible to our
  # project. Here, we include the `std` library and the latest version of
  # nixpkgs.
  inputs.std.url = "github:divnix/std";
  inputs.nixpkgs.url = "nixpkgs";

  # As per the flake schema, we define an attribute for holding the outputs of
  # our flake. In this case, `std` will be responsible for managing the outputs.
  outputs = { std, ... } @ inputs:
    # The grow function can be seen as the main entrypoint into `std`. It is
    # responsible for growing our "organism" through cells into the final
    # product. It will produce an output schema that is specific to `std` and
    # can be further explored through the `std` CLI/TUI.
    std.grow
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
        # dictate how the `std` CLI/TUI will behave. For example, the `runnable`
        # type will allow us to run our cell block as an executable using:
        #
        # > std //std-example/apps/default:run
        #
        # The `run` action is available because we've specified the `runnable`
        # cell block type. In this case, we're running the `default` target
        # which is defined as a derivation in ./nix/std-example/apps.nix that
        # builds our binary.
        cellBlocks = [
          (std.blockTypes.runnables "apps")
        ];
      };
}
