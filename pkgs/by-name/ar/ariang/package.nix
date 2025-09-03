{
  lib,
  makeDesktopItem,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:
let
  ariangDesktop = makeDesktopItem {
    name = "ariang";
    desktopName = "AriaNg";
    genericName = "Modern web frontend making aria2 easier to use";
    exec = "ariang";
    icon = "ariang";
    terminal = false;
    type = "Application";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeTypes = [ "text/html" ];
  };
in
buildNpmPackage rec {
  pname = "ariang";
  version = "1.3.11";

  src = fetchFromGitHub {
    owner = "mayswind";
    repo = "AriaNg";
    rev = version;
    hash = "sha256-TisgE5VFOe/1LbDq43AHASMVhC85BglETYFcvsQpwMw=";
  };

  npmDepsHash = "sha256-wWy9XxwZvUo89kgxApHd3qZ2Bb4NgifQ96WRDsZvTGU=";

  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r dist $out/share/ariang

    mkdir -p $out/bin
    cat > $out/bin/ariang <<EOF
    #!/usr/bin/env sh
    exec xdg-open "file://$out/share/ariang/index.html"
    EOF
    chmod +x $out/bin/ariang

    cp -r ${ariangDesktop}/share/applications $out/share/

    mkdir -p $out/share/pixmaps $out/share/icons/hicolor/32x32/apps
    for file in $out/share/ariang/favicon.png;
    do
      cp $out/share/ariang/favicon.png $out/share/pixmaps/ariang.png
      cp $out/share/ariang/favicon.png $out/share/icons/hicolor/32x32/apps/ariang.png
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Modern web frontend making aria2 easier to use";
    homepage = "http://ariang.mayswind.net/";
    license = licenses.mit;
    maintainers = with maintainers; [ stunkymonkey ];
    platforms = platforms.unix;
  };
}
