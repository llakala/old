{
  framework = mkHost {
    hostname = "framework";
    configDirectory = "/etc/nixos";
    stateVersion = "24.05";
    scalingFactor = 2;
  };
  iso = mkHost {
    hostname = "iso";
    configDirectory = "/etc/nixos";
    stateVersion = "24.11";
    scalingFactor = 1;
  };
}
