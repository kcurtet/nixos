{...}: {
  # ============================================================================
  # Power Management
  # ============================================================================
  # TLP is currently disabled. Configuration is preserved for future use.
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling governors
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Energy performance policies
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      # CPU performance limits
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      # Battery charge thresholds (helps preserve long-term battery health)
      START_CHARGE_THRESH_BAT0 = 40; # Start charging at 40%
      STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging at 80%
    };
  };
}
