{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  ffmpeg,
  fontconfig,
  freetype,
  glib,
  gst_all_1,
  gtk3,
  libGL,
  libpulseaudio,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  libxkbcommon,
  openssl,
  sqlite,
  vulkan-loader,
  wayland,
  xdg-utils,
  zenity,
}:
let
  # Single source of truth for the GStreamer derivations kiru needs at
  # runtime — referenced both as buildInputs (so autoPatchelf links) and
  # as the GST_PLUGIN_SYSTEM_PATH_1_0 wrap (so plugins are discoverable).
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
    gst-plugins-rs
    gst-vaapi
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kiru";
  version = "0.4.6";

  src = fetchurl {
    url = "https://releases.kiru.app/releases/linux/Kiru-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-QCtVdyvMVpozKRI3P6++qAsnTFI7X/BVs1mtQ89zaNI=";
  };

  sourceRoot = "Kiru-${finalAttrs.version}-linux-x86_64";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    glib
    gtk3
    libGL
    libpulseaudio
    libxkbcommon
    openssl
    sqlite
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ]
  ++ gstPlugins;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R bin share "$out/"

    wrapProgram "$out/bin/kiru" \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          xdg-utils
          zenity
        ]
      } \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
      }"

    runHook postInstall
  '';

  appendRunpaths = map (p: "${lib.getLib p}/lib") [
    libGL
    vulkan-loader
    wayland
  ];

  meta = {
    description = "Transcription-driven video editor";
    homepage = "https://kiru.app";
    license = lib.licenses.unfree;
    mainProgram = "kiru";
    maintainers = with lib.maintainers; [ elliottminns ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
