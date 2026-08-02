{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  perl,
  makeWrapper,
  cacert,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aria2-next";
  version = "2.6.8";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "AnInsomniacy";
    repo = "aria2-next";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WDNwqKyXL1yu9YdRMVK9NFf6XSiUvIL+4Mjr65b8vGE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
    makeWrapper
    cacert
  ];

  postPatch = ''
    substituteInPlace cmake/superbuild/Dependencies.cmake \
      --replace-fail \
        '-DCMAKE_POSITION_INDEPENDENT_CODE=ON)' \
        '-DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DCMAKE_INSTALL_LIBDIR=lib)'
  '';

  dontUseCmakeInstall = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ./aria2-next $out/bin/aria2-next

    wrapProgram $out/bin/aria2-next \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set SSL_CERT_DIR "${cacert}/etc/ssl/certs"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/AnInsomniacy/aria2-next";
    changelog = "https://github.com/AnInsomniacy/aria2-next/releases/tag/v${finalAttrs.version}";
    description = "Maintained aria2 fork with extensive bug fixes and modernized architecture";
    longDescription = ''
      Aria2 Next is an actively maintained aria2-compatible engine for everyone, and it is also the embedded engine used by Motrix Next.
      Original interfaces, including options, configuration, sessions, JSON-RPC, and libaria2, remain intact so downstream projects get a seamless upgrade.
      The focus is straightforward: release reliability, current dependency baselines, and ongoing compatibility fixes. Same engine, renewed foundation.
    '';
    mainProgram = "aria2-next";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ProxyVT ];
  };
})
