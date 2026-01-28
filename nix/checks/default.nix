{
  pkgs,
  src,
}: {
  lint = import ./lint.nix {inherit pkgs src;};
}
