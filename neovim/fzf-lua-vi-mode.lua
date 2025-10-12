require("fzf-lua").setup({
	buffers = {
		keymap = {
			fzf = {
				j = "down",
				k = "up",
				l = "accept",
				f = "jump",

				-- Normal mode is on by default - calling this event will toggle it.
				-- Ideally, we would have some `toggle-input` event, but as we lack
				-- that, we use click-header (if I'm clicking in fzf, I'm doing
				-- something wrong). This lets us toggle modes without having to write
				-- out the keys in every single bind
				["click-header"] = "toggle-bind(j,k,l,f,i)",

				-- If we're in insert mode, then pressing esc should take us to normal
				-- mode. If we're NOT in insert mode, we must already be in normal mode,
				-- and esc should quit fzf.
				esc = 'transform:[[ "$FZF_INPUT_STATE" = enabled ]] && echo "hide-input+trigger(click-header)" || echo abort',

				-- We have a true normal mode, let's use it!
				start = "hide-input+unbind(alt-j,alt-k,alt-l,alt-f)",

				-- From normal mode, enter insert mode. After doing this, we want to
				-- immediately unmap it so we can actually type `i`. So we trigger
				-- `click-header` and disable all the normal mode keymaps (including
				-- this one).
				i = "show-input+trigger(click-header)",
			},
		},
	},
})
