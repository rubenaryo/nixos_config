{ config, pkgs, ... }:

{
  home.username = "kaiyen";
  home.homeDirectory = "/home/kaiyen";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "rubenaryo";
        email = "rubeny484@gmail.com";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
    };
  };

  home.stateVersion = "25.11";
}
