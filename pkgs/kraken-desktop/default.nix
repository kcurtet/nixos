{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  openssl,
  libGL,
  fontconfig,
  freetype,
  expat,
  xorg,
  wayland,
  libxkbcommon,
}:
stdenv.mkDerivation rec {
  pname = "kraken-desktop";
  version = "latest";

  src = fetchurl {
    url = "https://desktop-downloads.kraken.com/latest/kraken-x86_64-unknown-linux-gnu.zip";
    hash = "sha256-EozlqIXqi4W6vGHvVvIb4YE0tPwqtRVoEEiOqICUAMo=";
  };

  nativeBuildInputs = [autoPatchelfHook makeWrapper];

  buildInputs = [
    openssl
    libGL
    fontconfig
    freetype
    expat
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    wayland
    libxkbcommon
  ];

  unpackPhase = ''
    unzip $src -d .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    cp kraken $out/bin/kraken-desktop

    cat > $out/share/applications/kraken-desktop.desktop << EOF
    [Desktop Entry]
    Name=Kraken Desktop
    Exec=$out/bin/kraken-desktop
    Icon=kraken
    Type=Application
    Categories=Finance;
    EOF
  '';

  meta = {
    description = "Kraken crypto exchange desktop app";
    homepage = "https://www.kraken.com/desktop";
    platforms = ["x86_64-linux"];
  };
}
