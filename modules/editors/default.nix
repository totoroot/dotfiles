{ config, options, lib, pkgs, ... }:

let
  editor = config.modules.editors.default;
  editorPackages = {
    micro = pkgs.micro;
    hx = pkgs.helix;
  };
  packages = lib.optional (builtins.hasAttr editor editorPackages) editorPackages.${editor};
  editorVariables = {
    EDITOR = editor;
    VISUAL = editor;
    GIT_EDITOR = editor;
  };
in
{
  options.modules.editors.default = lib.mkOption {
    type = lib.types.str;
    default = "micro";
    example = "hx";
    description = "Default editor command for shell sessions and Git. Use hx for Helix.";
  };

  config = if options ? home.sessionVariables then {
    home.sessionVariables = editorVariables;
    home.packages = packages;
  } else {
    env = editorVariables;
    environment.systemPackages = packages;
  };
}
