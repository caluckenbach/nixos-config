{ config, pkgs, lib, ... }:

{
  home.username = "morpheus";
  home.homeDirectory = "/home/morpheus";
  home.stateVersion = "25.11";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    eza
    ghostty
    stow
    amp-cli
    claude-code
    ripgrep
    lazygit
    yazi
  ];

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      package= pkgs.i3;
      config = {
        bars = [];
        window.border = 0;
        defaultWorkspace = "1";

        startup = [
          { command = "vmware-user-suid-wrapper"; notification = false; }
          { command = "ghostty"; notification = false; }
        ];

        keybindings = lib.mkOptionDefault {
          "Mod1+Shift+e" = "exec i3-msg exit";
        };
      };

      extraConfig = ''
        for_window [class="^Ghostty$"] fullscreen enable
      '';
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    sessionVariables = {
      LANG = "en_US.UTF-8";
    };

    shellAliases = {
      # File operations (eza with icons)
      ls = "eza -F --group-directories-first --color=always --icons";
      la = "eza -alF --group-directories-first --color=always --icons";
      ll = "eza -lF --group-directories-first";
      lt = "eza -aTF --level=2 --group-directories-first --icons --color=always";
      tree = "eza --tree";
      cat = "bat";
      grep = "rg";

      # Safe file operations
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

      # Neovim
      vim = "nvim";

      # Git
      g = "git";
      gp = "git push";
      gpf = "git push --force";
      gpl = "git pull";
      gpls = "git pull --recurse-submodules";
      gst = "git stash";
      gstp = "git stash pop";
      gs = "git switch";
      gsc = "git switch -c";
      gco = "git checkout";
      grb = "git rebase";
      gcan = "git commit --amend --no-edit";
      gsh = "git show --ext-diff";
      gl = "git log -p --ext-diff";

      # Tools
      lg = "lazygit";
    };

    initContent = ''
      # ldot function (list dotfiles)
      ldot() { eza -a | rg "^\." }

      # gprn - prune gone branches
      gprn() {
        git fetch --all --prune
        git branch -v | awk '/\[gone\]/ {print $1}' | while read branch; do
          git branch -D "$branch"
        done
      }

      # y - yazi with cd on exit
      y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d "" cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }

      # PATH additions
      typeset -U path
      [[ -d "$HOME/.local/bin" ]] && path+=("$HOME/.local/bin")
      [[ -d "$HOME/.cargo/bin" ]] && path+=("$HOME/.cargo/bin")
      export PATH
    '';

    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Constantin Luckenbach";
      user.email = "cluckenbach@protonmail.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
