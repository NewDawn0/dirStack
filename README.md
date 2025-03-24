# dirStack

The `dirStack` project provides a command-line interface (CLI) tool designed to enhance directory navigation efficiency within your shell environment. This utility offers functionalities akin to pushd and popd commands, but with added features such as directory listing, directory navigation, and initialization script generation.

<!-- vim-markdown-toc GFM -->

* [Installation](#installation)
* [Usage](#usage)
    * [Help Menu](#help-menu)
    * [Listing Directories](#listing-directories)
    * [Pushing Directories](#pushing-directories)
    * [Clearing the Stack](#clearing-the-stack)
    * [Navigating to a Saved Directory](#navigating-to-a-saved-directory)
* [Dependencies](#dependencies)

<!-- vim-markdown-toc -->

## Installation

1. Install the rust binary

   **Install using Cargo**

   ```bash
   cargo install --git https://github.com/NewDawn0/dirStack
   ```

   **Install using Nix**

   - Imperatively
     ```bash
     git clone https://github.com/NewDawn0/dirStack
     nix profile install .
     ```
   - Declaratively
     1. Add it as an input to your system flake as follows
        ```nix
        {
          inputs = {
            # Your other inputs ...
            ds = {
              url = "github:NewDawn0/dirStack";
              inputs.nixpkgs.follows = "nixpkgs";
              # Optional: If you use nix-systems or rust-overlay
              inputs.nix-systems.follows = "nix-systems";
              inputs.rust-overlay.follows = "rust-overlay";
            };
          };
        }
        ```
     2. Add the overlay to expose dirStack to your pkgs
        ```nix
        overlays = [ inputs.ds.overlays.default ];
        ```
     3. Then you can either install it in your `environment.systemPackages` using
        ```nix
        environment.systemPackages = with pkgs; [ dir-stack ];
        ```
        or install it to your `home.packages`
        ```nix
        home.packages = with pkgs; [ dir-stack ];
        ```

2. Initialize the shell extension
   Add the output of the following command to your shell's runtime configuration file (e.g., `.bashrc`, `.zshrc`). Once configured, you can begin using `dirStack` as `ds` seamlessly within your shell environment
   ```bash
   dirStack --init
   # Or the shorthand
   dirStack -i
   ```

## Usage

### Help Menu

To access the help menu, use:

```bash
ds --help
# Or the shorthand
ds -h
```

### Listing Directories

To list directories stored in the stack, use:

```bash
ds --list
# Or the shorthand
ds -l
```

### Pushing Directories

To add directories to the stack, use:

```bash
ds --push <path(s)>
# Or the shorthand
ds -p <path(s)>
```

### Clearing the Stack

To clear the stack use:

```bash
ds --clear
# Or the shorthand
ds -c
```

### Navigating to a Saved Directory

To navigate to a directory in the stack using the fzf menu, use:

```bash
ds --goto
# Or the shorthand
ds -g
```

## Dependencies

- [fzf](https://github.com/junegunn/fzf)
