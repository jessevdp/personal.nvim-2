{}: let
  createWritableSource =
    # lua
    ''
      local real_lockfile = os.getenv("packLockfileSourcePath")
      local writable_source = os.getenv("HOME") .. "/source-lock.json"
      local content = vim.fn.readfile(real_lockfile)
      vim.fn.writefile(content, writable_source)
    '';
in {
  # ============================================================================
  # Copy mode tests
  # ============================================================================

  nvim-pack-lock-install_copy-clean = {
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Copied lockfile to .+", level = vim.log.levels.INFO },
        })

        local source = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(source), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)
      '';
  };

  nvim-pack-lock-install_copy-matching = {
    setup =
      # lua
      ''
        -- Pre-install a copy of the source lockfile
        local source = os.getenv("packLockfileSourcePath")
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local content = vim.fn.readfile(source)
        vim.fn.writefile(content, config_dir .. "/nvim-pack-lock.json")
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotConfirmed()
        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        local source = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(source), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)
      '';
  };

  nvim-pack-lock-install_copy-replace-file-confirm = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 1,  -- Accept
          },
        })

        -- Pre-install a different file
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        vim.fn.writefile({ '{"preexisting": true}' }, config_dir .. "/nvim-pack-lock.json")
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Backed up to .+", level = vim.log.levels.INFO },
          { message = "%[nvim%-pack%-install%] Copied lockfile to .+", level = vim.log.levels.INFO },
        })

        local source = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(source), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 1, "Expected exactly 1 backup, got " .. #backups)
        test_helpers.assertFileHasContents(backups[1], '{"preexisting": true}')
      '';
  };

  nvim-pack-lock-install_copy-replace-file-deny = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 2,  -- Deny
          },
        })

        -- Pre-install the real lockfile
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local content = vim.fn.readfile(real_lockfile)
        vim.fn.writefile(content, config_dir .. "/nvim-pack-lock.json")

        -- Point source to a different file
        local different_source = os.getenv("HOME") .. "/different-lock.json"
        vim.fn.writefile({ '{"different": true}' }, different_source)
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = different_source
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        -- Should still have the original (real) lockfile contents
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(real_lockfile), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 0, "Expected no backups, got " .. #backups)
      '';
  };

  nvim-pack-lock-install_copy-replace-symlink-confirm = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 1,
          },
        })

        -- Pre-install a symlink to a different file
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local old_target = os.getenv("HOME") .. "/old-lock.json"
        vim.fn.writefile({ '{"old": true}' }, old_target)
        vim.uv.fs_symlink(old_target, config_dir .. "/nvim-pack-lock.json")
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Backed up to .+", level = vim.log.levels.INFO },
          { message = "%[nvim%-pack%-install%] Copied lockfile to .+", level = vim.log.levels.INFO },
        })

        local source = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(source), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 1, "Expected exactly 1 backup, got " .. #backups)
        local old_target = os.getenv("HOME") .. "/old-lock.json"
        test_helpers.assertIsSymlinkTo(backups[1], old_target)
      '';
  };

  nvim-pack-lock-install_copy-replace-symlink-deny = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 2,
          },
        })

        -- Pre-install a symlink to the real lockfile
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local target = os.getenv("HOME") .. "/original-lock.json"
        local content = vim.fn.readfile(real_lockfile)
        vim.fn.writefile(content, target)
        vim.uv.fs_symlink(target, config_dir .. "/nvim-pack-lock.json")

        -- Point source to a different file
        local different_source = os.getenv("HOME") .. "/different-lock.json"
        vim.fn.writefile({ '{"different": true}' }, different_source)
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = different_source
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        local original_target = os.getenv("HOME") .. "/original-lock.json"
        test_helpers.assertIsSymlinkTo(lockfile, original_target)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 0, "Expected no backups, got " .. #backups)
      '';
  };

  # ============================================================================
  # Symlink mode tests
  # ============================================================================

  nvim-pack-lock-install_symlink-clean = {
    setup =
      # lua
      ''
        ${createWritableSource}
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = writable_source
        vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK = "1"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Created symlink at .+", level = vim.log.levels.INFO },
        })

        local expected_target = os.getenv("HOME") .. "/source-lock.json"
        test_helpers.assertIsSymlinkTo(lockfile, expected_target)
      '';
  };

  nvim-pack-lock-install_symlink-matching = {
    setup =
      # lua
      ''
        ${createWritableSource}

        -- Pre-install symlink to writable source
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        vim.uv.fs_symlink(writable_source, config_dir .. "/nvim-pack-lock.json")

        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = writable_source
        vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK = "1"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotConfirmed()
        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        local expected_target = os.getenv("HOME") .. "/source-lock.json"
        test_helpers.assertIsSymlinkTo(lockfile, expected_target)
      '';
  };

  nvim-pack-lock-install_symlink-replace-file-confirm = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 1,  -- Accept
          },
        })

        -- Pre-install a different file
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        vim.fn.writefile({ '{"preexisting": true}' }, config_dir .. "/nvim-pack-lock.json")

        ${createWritableSource}
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = writable_source
        vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK = "1"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Backed up to .+", level = vim.log.levels.INFO },
          { message = "%[nvim%-pack%-install%] Created symlink at .+", level = vim.log.levels.INFO },
        })

        local expected_target = os.getenv("HOME") .. "/source-lock.json"
        test_helpers.assertIsSymlinkTo(lockfile, expected_target)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 1, "Expected exactly 1 backup, got " .. #backups)
        test_helpers.assertFileHasContents(backups[1], '{"preexisting": true}')
      '';
  };

  nvim-pack-lock-install_symlink-replace-file-deny = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 2,  -- Deny
          },
        })

        -- Pre-install a valid lockfile
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local content = vim.fn.readfile(real_lockfile)
        vim.fn.writefile(content, config_dir .. "/nvim-pack-lock.json")

        -- Point source to a different file (symlink mode)
        local source = os.getenv("HOME") .. "/source-lock.json"
        vim.fn.writefile({ '{"source": true}' }, source)
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = source
        vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK = "1"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        local real_lockfile = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(real_lockfile), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)

        local stat = vim.uv.fs_lstat(lockfile)
        assert(stat.type == "file", "Expected file, got " .. stat.type)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 0, "Expected no backups, got " .. #backups)
      '';
  };

  nvim-pack-lock-install_symlink-replace-symlink-confirm = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 1,
          },
        })

        -- Pre-install a symlink to a different file
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local old_target = os.getenv("HOME") .. "/old-lock.json"
        vim.fn.writefile({ '{"old": true}' }, old_target)
        vim.uv.fs_symlink(old_target, config_dir .. "/nvim-pack-lock.json")

        ${createWritableSource}
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = writable_source
        vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK = "1"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Backed up to .+", level = vim.log.levels.INFO },
          { message = "%[nvim%-pack%-install%] Created symlink at .+", level = vim.log.levels.INFO },
        })

        local expected_target = os.getenv("HOME") .. "/source-lock.json"
        test_helpers.assertIsSymlinkTo(lockfile, expected_target)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 1, "Expected exactly 1 backup, got " .. #backups)
        local old_target = os.getenv("HOME") .. "/old-lock.json"
        test_helpers.assertIsSymlinkTo(backups[1], old_target)
      '';
  };

  nvim-pack-lock-install_symlink-replace-symlink-deny = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 2,
          },
        })

        ${createWritableSource}

        -- Pre-install a symlink to the writable source
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        vim.uv.fs_symlink(writable_source, config_dir .. "/nvim-pack-lock.json")

        -- Point source to a different file (symlink mode)
        local different_source = os.getenv("HOME") .. "/different-lock.json"
        vim.fn.writefile({ '{"different": true}' }, different_source)
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = different_source
        vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK = "1"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        local original_target = os.getenv("HOME") .. "/source-lock.json"
        test_helpers.assertIsSymlinkTo(lockfile, original_target)

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 0, "Expected no backups, got " .. #backups)
      '';
  };

  # ============================================================================
  # Errors
  # ============================================================================

  nvim-pack-lock-install_source-does-not-exist = {
    setup =
      # lua
      ''
        -- Pre-install a valid lockfile
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local content = vim.fn.readfile(real_lockfile)
        vim.fn.writefile(content, config_dir .. "/nvim-pack-lock.json")

        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = "/nonexistent/path/to/lockfile.json"
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotConfirmed()
        test_helpers.assertNotified({
          {
            message = "%[nvim%-pack%-install%] Source lockfile not found: /nonexistent/path/to/lockfile.json",
            level = vim.log.levels.ERROR,
          },
        })

        -- Should still have the original lockfile (unchanged)
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(real_lockfile), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)
      '';
  };

  nvim-pack-lock-install_env-source-path-empty = {
    setup =
      # lua
      ''
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = ""
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        -- Should fall back to opts.source_path (packLockfileSourcePath)
        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Copied lockfile to .+", level = vim.log.levels.INFO },
        })

        local source = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(source), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)
      '';
  };

  nvim-pack-lock-install_backup-error = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 1,
          },
        })

        -- Pre-install a valid lockfile
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local content = vim.fn.readfile(real_lockfile)
        vim.fn.writefile(content, config_dir .. "/nvim-pack-lock.json")

        -- Point source to a different file
        local source = os.getenv("HOME") .. "/source-lock.json"
        vim.fn.writefile({ '{"source": true}' }, source)
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = source

        -- Mock fs_rename to fail for backup
        local original_rename = vim.uv.fs_rename
        vim.uv.fs_rename = function(from, to)
          if to:match("%.backup%.") then
            return nil, "mocked backup error"
          end
          return original_rename(from, to)
        end
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Failed to backup to .+: mocked backup error", level = vim.log.levels.ERROR },
        })

        -- No backups should have been created (backup failed)
        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 0, "Expected no backups, got " .. #backups)
      '';
  };

  nvim-pack-lock-install_install-error-clean = {
    setup =
      # lua
      ''
        -- Mock writefile to fail
        local original_writefile = vim.fn.writefile
        vim.fn.writefile = function(lines, fname, flags)
          if fname:match("nvim%-pack%-lock%.json$") then
            return -1
          end
          return original_writefile(lines, fname, flags)
        end
      '';
    test =
      # lua
      ''
        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Failed to copy lockfile to .+", level = vim.log.levels.ERROR },
        })
      '';
  };

  nvim-pack-lock-install_install-error-replace = {
    setup =
      # lua
      ''
        test_helpers.mockConfirm({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
            response = 1,
          },
        })

        -- Pre-install a valid lockfile
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local content = vim.fn.readfile(real_lockfile)
        vim.fn.writefile(content, config_dir .. "/nvim-pack-lock.json")

        -- Point source to a different file
        local source = os.getenv("HOME") .. "/source-lock.json"
        vim.fn.writefile({ '{"source": true}' }, source)
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = source

        -- Mock writefile to fail (but only after backup succeeds)
        local original_writefile = vim.fn.writefile
        vim.fn.writefile = function(lines, fname, flags)
          if fname:match("nvim%-pack%-lock%.json$") then
            return -1
          end
          return original_writefile(lines, fname, flags)
        end
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")

        test_helpers.assertConfirmed({
          {
            message = "%[nvim%-pack%-install%] Lockfile at .+ differs from source%. Replace it%? %(backup will be created%)",
            choices = "&Yes\n&No",
          },
        })

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Backed up to .+", level = vim.log.levels.INFO },
          { message = "%[nvim%-pack%-install%] Failed to copy lockfile to .+", level = vim.log.levels.ERROR },
        })

        local backups = vim.fn.glob(config_dir .. "/nvim-pack-lock.json.backup.*", false, true)
        assert(#backups == 1, "Expected exactly 1 backup, got " .. #backups)
      '';
  };

  # ============================================================================
  # Other
  # ============================================================================

  nvim-pack-lock-install_parent-dir-does-not-exist = {
    setup =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        vim.fn.delete(config_dir, "rf")
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotified({
          { message = "%[nvim%-pack%-install%] Copied lockfile to .+", level = vim.log.levels.INFO },
        })

        local source = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(source), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)
      '';
  };

  nvim-pack-lock-install_source-is-target = {
    setup =
      # lua
      ''
        -- Pre-install the lockfile at the target location
        local config_dir = vim.fn.stdpath("config")
        vim.fn.mkdir(config_dir, "p")
        local real_lockfile = os.getenv("packLockfileSourcePath")
        local content = vim.fn.readfile(real_lockfile)
        local target = config_dir .. "/nvim-pack-lock.json"
        vim.fn.writefile(content, target)

        -- Point source to the target itself
        vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH = target
      '';
    test =
      # lua
      ''
        local config_dir = vim.fn.stdpath("config")
        local lockfile = config_dir .. "/nvim-pack-lock.json"

        test_helpers.assertNotConfirmed()
        test_helpers.assertNotNotifiedMatching("%[nvim%-pack%-install%]")

        local real_lockfile = os.getenv("packLockfileSourcePath")
        local expected = table.concat(vim.fn.readfile(real_lockfile), "\n")
        test_helpers.assertFileHasContents(lockfile, expected)
      '';
  };
}
