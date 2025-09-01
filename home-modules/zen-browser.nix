{ pkgs, inputs, ...}:
let
  # Workaround for zen-twilight and zen-desktop not working
  # zen-desktop = pkgs.makeDesktopItem {
  #   name = "zen";
  #   desktopName = "Zen Browser";
  #   exec = "zen";
  # };
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight-official
  ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      OfferToSaveLogins = false;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      Preferences = {
        "browser.tabs.warnOnClose" = {
          "Value" = false;
          "Status" = "locked";
        };
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = {
        #   "Value" = true;
        #   "Status" = "locked";
        # };
      };
    };


    nativeMessagingHosts = [ pkgs.firefoxpwa ];
  };

  # home.packages = [ zen-desktop ];
}
