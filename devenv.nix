{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = [
    pkgs.texlive.combined.scheme-full
    pkgs.typst
    pkgs.gnumake
  ];

  # https://devenv.sh/scripts/
  scripts.build.exec = "make";
  scripts.clean.exec = "make clean";

  enterShell = ''
    echo "latex/typst environment ready — pdflatex, typst and make are on PATH"
  '';

  # See full reference at https://devenv.sh/reference/options/
}
