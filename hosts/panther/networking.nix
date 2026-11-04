# ============================================================================
# Panther Network Configuration
# ============================================================================
_:

{
  networking.hostName = "panther";
  networking.networkmanager.enable = true;

  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # Firewall
  networking.firewall.enable = true;
}
