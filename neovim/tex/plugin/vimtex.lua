-- Only add these binds when in a tex buffer
g.vimtex_view_method = "zathura"
g.maplocalleader = " "

g.vimtex_mappings_disable = {
	x = { "tsf", "tsc", "tse", "tsd", "tsD" },
	n = { "tsf", "tsc", "tse", "tsd", "tsD" },
}

g.vimtex_compiler_latexmk = {
	aux_dir = ".build",

	-- aux_dir is compilation artifacts, this is for the pdf and `synctex.gz` files
	out_dir = ".build",
}
