local function sanitize_portage()
  local file = vim.fn.expand '%:p'
  local script_path = vim.fn.expand '~/.local/bin/portage-cleaner.py'

  if vim.fn.executable 'python3' == 1 and vim.fn.filereadable(script_path) == 1 then
    vim.fn.jobstart({ 'python3', script_path, file }, {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.schedule(function()
            vim.cmd 'checktime'
            vim.notify('Portage config sanitized.', vim.log.levels.INFO)
          end)
        else
          vim.notify('Cleaner failed (Code ' .. exit_code .. ')', vim.log.levels.ERROR)
        end
      end,
    })
  end
end

-- 1. Create a manual command: :SanitizePortage
vim.api.nvim_create_user_command('SanitizePortage', sanitize_portage, {})

-- 2. The Autocmd with a broader pattern
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  -- Broaden the pattern to match exactly what Neovim sees
  pattern = { '*/etc/portage/package.use', 'package.use' },
  callback = sanitize_portage,
})
