{
  src, version,

  lib, stdenv,

  cmake,

  opencv
}:

stdenv.mkDerivation rec {
  pname = "hypercine";
  inherit src version;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    opencv
  ];

  cmakeFlags = [
    (lib.cmakeBool "HYPERCINE_USE_DOUBLE_STORAGE" true)
  ];
}

