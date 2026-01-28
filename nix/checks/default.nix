{
  pkgs,
  nvimWrapped,
  src,
}:
{
  lint = import ./lint.nix {inherit pkgs src;};
}
// (import ./tests.nix {inherit pkgs nvimWrapped;})
