{
  lib,
  buildGoModule,
  fetchFromGitHub,
  testers,
  leaps,
  nixosTests,
}:

buildGoModule rec {
  pname = "leaps";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Jeffail";
    repo = "leaps";
    rev = "v${version}";
    sha256 = "sha256-9AYE8+K6B6/odwNR+UhTTqmJ1RD6HhKvtC3WibWUZic=";
  };

  proxyVendor = true; # darwin/linux hash mismatch
  vendorHash = "sha256-0dwUOoV2bxPB+B6CKxJPImPIDlBMPcm0AwEMrVUkALc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  passthru.tests = {
    version = testers.testVersion { package = leaps; };
    inherit (nixosTests) leaps;
  };

  meta = with lib; {
    description = "Pair programming tool and library written in Golang";
    mainProgram = "leaps";
    homepage = "https://github.com/jeffail/leaps/";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ qknight ];
  };
}
