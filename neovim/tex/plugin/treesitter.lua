require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		disable = { "latex" }, -- Vimtex promises better highlighting
	},
})
