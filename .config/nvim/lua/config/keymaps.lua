print("KEYMAPS CARGADOS")

local map = vim.keymap.set
map("n", "<leader>xx", function()
	print("Keymap funciona")
end, { desc = "Test keymap" })
