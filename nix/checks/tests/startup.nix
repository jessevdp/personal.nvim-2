{}: {
  startup = {
    test =
      # lua
      ''
        -- If we get here, nvim started and init ran successfully
        assert(vim.fn.stdpath("config") ~= nil, "stdpath should work")
      '';
  };
}
