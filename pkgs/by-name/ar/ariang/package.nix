{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  imagemagick,
  runtimeShell,
  xdg-utils,
  makeDesktopItem,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "ariang";
  version = "1.3.11";

  src = fetchFromGitHub {
    owner = "mayswind";
    repo = "AriaNg";
    tag = finalAttrs.version;
    hash = "sha256-TisgE5VFOe/1LbDq43AHASMVhC85BglETYFcvsQpwMw=";
  };

  npmDepsHash = "sha256-wWy9XxwZvUo89kgxApHd3qZ2Bb4NgifQ96WRDsZvTGU=";

  makeCacheWritable = true;

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
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
    cat > $out/bin/ariang << 'EOF'
    #!${runtimeShell}
    set -eu
    persistent_dir="\$HOME/.local/share/ariang"
    version_file="\$persistent_dir/.version"
    current_version="${finalAttrs.version}"

    mkdir -p "\$user_dir"
    if [ ! -f "\$version_file" ] || [ "$(cat "\$version_file")" != "\$current_version" ]; then
        cp -r ${placeholder "out"}/share/ariang/* "\$user_dir/"
        echo "\$current_version" > "\$version_file"
    fi

    exec ${xdg-utils}/bin/xdg-open "file://\$user_dir/index.html"
    EOF

    chmod +x $out/bin/ariang

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern web frontend making aria2 easier to use";
    homepage = "https://ariang.mayswind.net";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.unix;
  };
})
