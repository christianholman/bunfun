{
  description = "Template for TypeScript + Bun scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: {
    templates = {
      default = {
        path = ./template;
        description = "A template for creating TypeScript scripts with Bun and Nix";
      };
    };
  };
}
