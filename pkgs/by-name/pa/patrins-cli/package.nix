{
  lib,
  stdenv,
  fetchurl,
  nodejs,
}:

stdenv.mkDerivation {
  name = "patrins-cli";

  src = fetchurl {
    url = "https://patrins.com/cli.js";
    hash = "sha256-Q+ExSJOcc2UAinlbNXp73vLIpZUuUQ1gLYKsuWC3WVA=";
  };

  buildInputs = [ nodejs ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/patrins
    chmod +x $out/bin/patrins

    substituteInPlace $out/bin/patrins \
      --replace-fail "/usr/bin/env node" "${lib.getExe nodejs}"

    runHook postInstall
  '';

  meta = {
    description = "Patrins file hosting CLI (wrapper around official bundle)";
    homepage = "https://patrins.com";
    mainProgram = "patrins";
  };
}
