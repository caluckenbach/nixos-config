{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.username = "morpheus";
  home.homeDirectory = "/home/morpheus";
  home.stateVersion = "25.11";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    stow
    ghostty
    ripgrep
    eza
    fd
    gh
    htop
    yazi
    lazygit
    bun
    uv
    amp-cli
    claude-code
    rustup
    bacon
    gcc
    fastfetch

    # lsp and formatters
    nil
    nixfmt-rfc-style
    lua-language-server
    stylua
    ruff
    ty
  ];

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      config = {
        bars = [
          {
            position = "bottom";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-bottom.toml";
            colors = {
              background = "#282828";
              statusline = "#ebdbb2";
              focusedWorkspace = {
                border = "#458588";
                background = "#458588";
                text = "#ebdbb2";
              };
              inactiveWorkspace = {
                border = "#282828";
                background = "#282828";
                text = "#928374";
              };
            };
            fonts = {
              names = [ "TX-02" ];
              size = 12.0;
            };
          }
        ];
        window.border = 0;
        defaultWorkspace = "1";

        startup = [
          {
            command = "vmware-user-suid-wrapper";
            notification = false;
          }
          {
            command = "ghostty";
            notification = false;
          }
        ];

        keybindings = lib.mkOptionDefault {
          "Mod1+Shift+e" = "exec i3-msg exit";
        };
      };

    };
  };

  xdg.configFile."ghostty/config".text = ''
    font-family = TX-02
    font-size = 15
    theme = Gruvbox Dark

    # Hide window decorations and tab bar
    window-decoration = none
    gtk-titlebar = false

    # Visual polish
    window-padding-x = 8
    window-padding-y = 6
    cursor-style = bar
    cursor-style-blink = false

    background-opacity = 0.95
    background-blur-radius = 20
    macos-non-native-fullscreen = visible-menu
    macos-option-as-alt = left

    mouse-hide-while-typing = true
    mouse-scroll-multiplier = 2

    # Prevent app from quitting when last window closes (like macOS)
    quit-after-last-window-closed = false

    # Keybinds to match macOS since this is a VM
    keybind = super+c=copy_to_clipboard
    keybind = super+v=paste_from_clipboard
    keybind = super+shift+c=copy_to_clipboard
    keybind = super+shift+v=paste_from_clipboard
    keybind = super+equal=increase_font_size:1
    keybind = super+minus=decrease_font_size:1
    keybind = super+zero=reset_font_size
    keybind = super+q=unbind
    keybind = super+shift+comma=reload_config
    keybind = super+k=clear_screen
    keybind = super+n=new_window
    keybind = super+w=close_surface
    keybind = super+shift+w=unbind
    keybind = super+alt+w=close_tab:this
    keybind = super+alt+shift+w=unbind
    confirm-close-surface = true
    keybind = super+t=new_tab
    keybind = super+shift+left_bracket=previous_tab
    keybind = super+shift+right_bracket=next_tab
    keybind = super+d=new_split:right
    keybind = super+shift+d=new_split:down
    keybind = super+right_bracket=goto_split:next
    keybind = super+left_bracket=goto_split:previous
    keybind = shift+enter=text:\n
  '';

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

  programs.jujutsu = {
    enable = true;
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
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

  programs.i3status-rust = {
    enable = true;
    bars.bottom = {
      theme = "gruvbox-dark";
      icons = "awesome6";
      blocks = [
        {
          block = "memory";
          format = " $mem_used/$mem_total ";
        }
        {
          block = "cpu";
          format = " $utilization ";
        }
        {
          block = "disk_space";
          path = "/";
          format = " $available ";
        }
      ];
    };
  };
}
