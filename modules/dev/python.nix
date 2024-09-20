# modules/dev/python.nix

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.python;
in {
  options.modules.dev.python = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      python312
      python313
      python312Packages.pip
      # pip update helpers
      python312Packages.pipdate
      python312Packages.virtualenv
      python312Packages.pytest-virtualenv
      python312Packages.virtualenv-clone
      python312Packages.tox
      python312Packages.ipython
      python312Packages.setuptools
      python312Packages.pylint
      python312Packages.requests
      # Python dependency management and packaging made easy
      python312Packages.poetry-core
      # Jupyter lab environment notebook server extension
      # python312Packages.jupyterlab
      # # Jupyter notebooks as Markdown documents, Julia, Python or R scripts
      # python312Packages.jupytext
      # Scientific tools for Python
      python312Packages.numpy
      # Python Data Analysis Library
      python312Packages.pandas
      # Uncompromising Python code formatter
      black
      # Linter for yaml files
      yamllint
    ];

    env.IPYTHONDIR = "$XDG_CONFIG_HOME/ipython";
    env.PIP_CONFIG_FILE = "$XDG_CONFIG_HOME/pip/pip.conf";
    env.PIP_LOG_FILE = "$XDG_DATA_HOME/pip/log";
    env.PYLINTHOME = "$XDG_DATA_HOME/pylint";
    env.PYLINTRC = "$XDG_CONFIG_HOME/pylint/pylintrc";
    # env.PYTHONSTARTUP = "$XDG_CONFIG_HOME/python/pythonrc";
    env.PYTHON_EGG_CACHE = "$XDG_CACHE_HOME/python-eggs";
    env.JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";

    environment.shellAliases = {
      python = "python3.13";
      py = "python";
      po = "poetry";
      ipy = "ipython --no-banner";
      ipylab = "ipython --pylab=qt5 --no-banner";
    };

    home.configFile = {
      "yamllint/yamllint.yml".source = "${configDir}/yamllint/yamllint.yml";
    };

    environment.shellAliases = {
      yamllint = "yamllint -c $XDG_CONFIG_HOME/yamllint/yamllint.yml";
      yl = "yamllint -c $XDG_CONFIG_HOME/yamllint/yamllint.yml";
    };
  };
}
