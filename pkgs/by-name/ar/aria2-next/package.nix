{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  perl,
  sphinx,
  makeWrapper,
  installShellFiles,
  cacert,
  boost189,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aria2-next";
  version = "2.8.3";
  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "AnInsomniacy";
    repo = "aria2-next";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SIeheE9aVcHV2z9ysptvmo3IGKqReIWzXDTsftoMA5k=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
    sphinx
    makeWrapper
    installShellFiles
    cacert
  ];


  postPatch = ''
    # Force lib/ install dir for vendored deps
    substituteInPlace cmake/superbuild/Dependencies.cmake \
      --replace-fail \
        '-DCMAKE_POSITION_INDEPENDENT_CODE=ON)' \
        '-DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DCMAKE_INSTALL_LIBDIR=lib)'

    rm -rf third_party/boost
    cp -rL ${boost189.dev}/include third_party/boost
  '';

  postBuild = ''
    # Manually generate man page
    cp -r --no-preserve=mode $src/docs/manual/en sphinx_src
    mv sphinx_src/conf.py.in sphinx_src/conf.py
    substituteInPlace sphinx_src/conf.py \
      --replace-fail "@PACKAGE_VERSION@" "${finalAttrs.version}"
    sphinx-build -b man sphinx_src man_build
  '';

  installPhase = ''
    runHook preInstall

    installBin ./aria2-next
    installManPage man_build/aria2-next.1

    runHook postInstall
  '';

  postInstall = ''
    # Set CA cert paths for HTTPS
    wrapProgram $out/bin/aria2-next \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set SSL_CERT_DIR "${cacert}/etc/ssl/certs"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/AnInsomniacy/aria2-next";
    changelog = "https://github.com/AnInsomniacy/aria2-next/releases/tag/v${finalAttrs.version}";
    description = "Aria2 fork with extensive bug fixes and modernized architecture";
    longDescription = ''
      Aria2 Next is an actively maintained download engine and the embedded engine used by Rayburst.
      HTTP, HTTPS, SFTP, Metalink, ED2K, RPC, and libaria2 remain supported.
      HTTP, HTTPS, SFTP, and Metalink payload transfers use libcurl 8.21 with nghttp2.
      BitTorrent uses libtorrent-rasterbar 2.1.
      FTP and the former custom stream protocol stacks have been removed.
    '';
    mainProgram = "aria2-next";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ProxyVT ];
  };
})
