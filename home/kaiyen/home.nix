{ config, pkgs, ... }:

{
  home.username = "kaiyen";
  home.homeDirectory = "/home/kaiyen";

  programs.git = {
    enable = true;
    userName = "rubenaryo";
    userEmail = "rubeny484@gmail.com";
  };

  home.stateVersion = "25.11";
}
