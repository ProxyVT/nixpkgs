{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatch-vcs,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "protobug";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "protobug";
    tag = finalAttrs.version;
    hash = "sha256-TPI9C7NGvzX3NuzFn7hpBjiX6AkUIs0GewI20ba8a7s=";
  };

  build-system = [ hatchling ];

  dependencies = [ hatch-vcs ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "A pythonic protobuf library using dataclasses and enums";
    homepage = "https://github.com/yt-dlp/protobug";
    changelog = "https://github.com/yt-dlp/protobug/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ ProxyVT ];
  };
})
