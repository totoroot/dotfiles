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
      python313
      # Extremely fast Python package installer and resolver, written in Rust
      uv
      # Extremely fast Python linter
      ruff
      python313Packages.pip
      # pip update helpers
      python313Packages.pipdate
      python313Packages.virtualenv
      # python313Packages.pytest-virtualenv
      # python313Packages.virtualenv-
      python313Packages.tox
      python313Packages.ipython
      python313Packages.setuptools
      python313Packages.pylint
      python313Packages.requests
      # Python dependency management and packaging made easy
      python313Packages.poetry-core
      # Jupyter lab environment notebook server extension
      python313Packages.jupyterlab
      # # Jupyter notebooks as Markdown documents, Julia, Python or R scripts
      python313Packages.jupytext
      # Scientific tools for Python
      python313Packages.numpy
      # Python Data Analysis Library
      python313Packages.pandas
      # Python SQL toolkit and Object Relational Mapper
      python313Packages.sqlalchemy
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
      py = "python";
      po = "poetry";
      ipy = "ipython --no-banner";
      ipylab = "ipython --pylab=qt6 --no-banner";
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
