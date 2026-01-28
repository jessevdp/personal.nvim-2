{
  pkgs,
  src,
}:
pkgs.runCommand "lint" {
  nativeBuildInputs = with pkgs; [stylua alejandra];
  inherit src;
} ''
  cd $src
  echo "Checking Lua formatting..."
  stylua --check .
  echo "Checking Nix formatting..."
  alejandra --check .
  touch $out
''
