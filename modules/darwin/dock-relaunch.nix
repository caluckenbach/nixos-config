{ config, lib, ... }:

let
  dockDefaults = builtins.removeAttrs config.system.defaults.dock [ "expose-group-by-app" ];
  hasDockDefaults = lib.any (value: value != null) (builtins.attrValues dockDefaults);
  user = lib.escapeShellArg config.system.primaryUser;
in
{
  system.activationScripts.launchd.text = lib.mkIf hasDockDefaults (
    lib.mkBefore ''
      # nix-darwin signals Dock to exit after applying defaults. Checking its
      # running state can race with that exit, so let launchd stop and start it.
      # Keep this recovery hook until nix-darwin manages the restart via launchd.
      primary_uid="$(id -u -- ${user})"
      dock_agent="gui/$primary_uid/com.apple.Dock.agent"

      echo >&2 "restarting Dock with launchd..."
      launchctl asuser "$primary_uid" launchctl kickstart -k "$dock_agent" ||
        echo >&2 "warning: could not restart Dock; Command-Tab may be unavailable"
    ''
  );
}
