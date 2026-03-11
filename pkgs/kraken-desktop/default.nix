{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  openssl,
  libGL,
  fontconfig,
  freetype,
  expat,
  libx11,
  libxcursor,
  libxrandr,
  libxi,
  wayland,
  libxkbcommon,
  alsa-lib,
  dbus,
  gcc,
  libdrm,
  mesa,
  libgbm,
  nss,
  nspr,
  cups,
  at-spi2-atk,
  at-spi2-core,
}:
stdenv.mkDerivation rec {
  pname = "kraken-desktop";
  version = "latest";

  src = fetchurl {
    url = "https://desktop-downloads.kraken.com/latest/kraken-x86_64-unknown-linux-gnu.zip";
    hash = "sha256-EozlqIXqi4W6vGHvVvIb4YE0tPwqtRVoEEiOqICUAMo=";
  };

  nativeBuildInputs = [autoPatchelfHook makeWrapper unzip];

  buildInputs = [
    openssl
    libGL
    fontconfig
    freetype
    expat
    libx11
    libxcursor
    libxrandr
    libxi
    wayland
    libxkbcommon
    alsa-lib
    dbus
    gcc.cc
    libdrm
    mesa
    libgbm
    nss
    nspr
    cups
    at-spi2-atk
    at-spi2-core
  ];

  unpackPhase = ''
    unzip $src -d .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    cp kraken_desktop $out/bin/.kraken-desktop-wrapped

    wrapProgram $out/bin/.kraken-desktop-wrapped \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        openssl libGL fontconfig freetype expat libx11 libxcursor
        libxrandr libxi wayland libxkbcommon alsa-lib dbus gcc.cc
        libdrm mesa libgbm nss nspr cups at-spi2-atk at-spi2-core
      ]} \
      --prefix XDG_DATA_DIRS : "/run/current-system/sw/share:/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS" \
      --prefix PATH : "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

    ln -s $out/bin/.kraken-desktop-wrapped $out/bin/kraken-desktop

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
