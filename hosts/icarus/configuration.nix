# edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "icarus";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Use static DNS only, ignore router/DHCP
  networking.resolvconf.enable = false;
  networking.nameservers = [
    "1.1.1.1"   # Cloudflare
    "8.8.8.8"   # Google
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-tools
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;  # see the note above
  hardware.nvidia.modesetting.enable = true;

  boot.extraModprobeConfig = ''
  options nvidia NVreg_PreserveVideoMemoryAllocations=1
'';
  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kaiyen = {
    isNormalUser = true;
    description = "kaiyen";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Core programs
  programs.firefox.enable = true;
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      # Choose a theme that supports colors, e.g., agnoster, powerlevel10k
      theme = "agnoster"; # Or "powerlevel10k"
      plugins = [ "git" ];
    };
  };

  services.emacs = 
  {
    enable = true;
    package = pkgs.emacs-pgtk;  
  };

  environment.shellAliases = {
    emacs = "emacsclient -c -n -a \"\"";
    nrs = "sudo nixos-rebuild switch --profile-name 'main' --flake .#icarus";
    nrt = "sudo nixos-rebuild test --profile-name 'main' --flake .#icarus";
    gc3 = "sudo nixos-rebuild --delete-generations +3 && sudo nix store gc";
  };

  virtualisation.docker = {
    enable = true;
    # Customize Docker daemon settings using the daemon.settings option
    daemon.settings = {
      dns = [ "1.1.1.1" "8.8.8.8" ];
      log-driver = "journald";
      registry-mirrors = [ "https://mirror.gcr.io" ];
      storage-driver = "overlay2";
    };
    # Use the rootless mode - run Docker daemon as non-root user
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    CC = "${pkgs.gcc}/bin/gcc";
    CXX = "${pkgs.gcc}/bin/g++";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zsh
    vim
    neovim
    emacs-pgtk 
    git
    gh
    wget
    discord
    steam
    mesa
    libgcc
    gnumake
    cmake
    pkgs.clang-tools
    gdb
    man-pages
    glibc.dev
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
