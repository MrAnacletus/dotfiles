return {
	{
		"johnpena/badwolf-neovim",
		lazy = false, -- cargar al inicio
		priority = 1000, -- antes que otros plugins
		config = function()
			vim.cmd.colorscheme("badwolf")
		end,
	},
}
