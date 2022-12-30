{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Monospace font with programming ligatures
    fira-code
    # Monospace font for Firefox OS
    fira-mono
    # A typeface designed for source code
    hack-font
    # A typeface made for developers
    jetbrains-mono
    # A monospaced font for scientific and technical computing
    julia-mono
    # Sans-serif typeface family designed in Summer 2010 by Łukasz Dziedzic
    lato
    # A font for programming and code review
    mononoki
    # Free programming font with cursive italics and ligatures
    victor-mono
  ];
}
