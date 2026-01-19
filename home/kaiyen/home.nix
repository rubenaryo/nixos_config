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

  programs.home-manager.enable = true;

  # Install JetBrains Mono font
  home.packages = with pkgs; [
    jetbrains-mono
  ];

  # Enable fontconfig for user fonts
  fonts.fontconfig.enable = true;

  # Configure Alacritty terminal
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrains Mono";
          style = "Bold Italic";
        };
        size = 12.0;
      };
      
      window = {
        opacity = 1.0;
        padding = {
          x = 10;
          y = 10;
        };
      };
      
      colors = {
        primary = {
          background = "#1e1e1e";
          foreground = "#d4d4d4";
        };
      };
    };
  };

  home.stateVersion = "25.11";
}
