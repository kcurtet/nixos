# ============================================================================
# Laptop Power Management Module
# ============================================================================
{ config, lib, ... }:

let
  cfg = config.laptop.powerManagement;
in
{
  options.laptop.powerManagement = {
    enable = lib.mkEnableOption "TLP power management for laptops";

    batteryThresholds = {
      startCharge = lib.mkOption {
        type = lib.types.int;
        default = 40;
        description = "Start charging when battery drops below this percentage";
      };
      stopCharge = lib.mkOption {
        type = lib.types.int;
        default = 80;
        description = "Stop charging when battery reaches this percentage";
      };
    };

    performanceProfile = lib.mkOption {
      type = lib.types.enum [ "balanced" "performance" "powersave" ];
      default = "balanced";
      description = "Default performance profile";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        # CPU scaling governors
        CPU_SCALING_GOVERNOR_ON_AC = if cfg.performanceProfile == "performance" then "performance" else "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Energy performance policies
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = if cfg.performanceProfile == "powersave" then "power" else "performance";

        # CPU performance limits
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = if cfg.performanceProfile == "performance" then 100 else 20;

        # Battery charge thresholds
        START_CHARGE_THRESH_BAT0 = cfg.batteryThresholds.startCharge;
        STOP_CHARGE_THRESH_BAT0 = cfg.batteryThresholds.stopCharge;
      };
    };
  };
}
