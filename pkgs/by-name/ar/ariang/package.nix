{
  lib,
  fetchFromGitHub,
  nodejs_22,
  buildNpmPackage,
  copyDesktopItems,
  imagemagick,
  makeWrapper,
  xdg-utils,
  makeDesktopItem,
}:

buildNpmPackage (finalAttrs: {
  pname = "ariang";
  version = "1.3.14";

  src = fetchFromGitHub {
    owner = "mayswind";
    repo = "AriaNg";
    tag = finalAttrs.version;
    hash = "sha256-wPFZGNqVveDj9Dh0QSxyy93K7G91CACD4RzmgjaRxjI=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-D+yqIDeJki0h6bT8eia8W8Xbokjgl4nlBXLApfhMwVc=";

  makeCacheWritable = true;

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r dist $out/share/ariang

    for size in 16 24 32 36 48 64 72 128; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      magick $out/share/ariang/tileicon.png -filter Lanczos -resize ''${size}x''${size} \
        $out/share/icons/hicolor/''${size}x''${size}/apps/ariang.png
    done

    mkdir -p $out/bin

    makeWrapper ${xdg-utils}/bin/xdg-open $out/bin/ariang \
      --add-flags "file://$out/share/ariang/index.html"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ariang";
      desktopName = "AriaNg";
      genericName = finalAttrs.meta.description;
      comment = finalAttrs.meta.description;
      exec = "ariang";
      icon = "ariang";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "WebBrowser"
      ];
    })
  ];

  meta = {
    description = "Modern web frontend making aria2 easier to use";
    homepage = "https://ariang.mayswind.net";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.unix;
  };
})
