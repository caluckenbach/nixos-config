{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    orbstack
    pinentry_mac
    (pulumi.withPackages (p: [ p.pulumi-nodejs ]))
    twilio-cli
  ];
}
