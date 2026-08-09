{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.neovim ];

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        xdg.configFile."nvim".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/nvim";
      }
    )
  ];
}
