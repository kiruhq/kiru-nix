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
stdenv.mkDerivation (finalAttrs: {
  pname = "kiru";
  version = "0.4.4";

  src = fetchurl {
    url = "https://releases.kiru.app/releases/linux/Kiru-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-OTZ9hdSFl+1TPt2SAKeqVjwSHnuzgzhhWXo/3/Du+DY=";
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
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
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
  ];

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
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
        ]
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
