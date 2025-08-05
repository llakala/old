local feedkeys = function(keys, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, false)
end

-- From https://github.com/echasnovski/mini.nvim/issues/1837
local function handle_non_eol_comments()
	-- Try selecting comment block as "whole lines"
	require("mini.comment").textobject()

	if vim.fn.mode() ~= "V" then
		return
	end

	-- Adjust selection to be charwise and not include edge comment parts
	local comment_left, comment_right = vim.bo.commentstring:match("^(.*)%%s(.*)$")
	if comment_left == nil then
		return
	end

	-- NOTE: this depends on implementation detail that `textobject` puts
	-- cursor on last line of comment block
	local from_line, to_line = vim.fn.line("v"), vim.fn.line(".")

	vim.fn.feedkeys("v", "nx")
	local to_col = vim.fn.getline(to_line):find(vim.pesc(comment_right) .. "%s*$")
	vim.api.nvim_win_set_cursor(0, { to_line, to_col - 2 })

	vim.fn.feedkeys("o", "nx")
	local _, from_col = vim.fn.getline(from_line):find("^%s*" .. vim.pesc(comment_left))
	vim.api.nvim_win_set_cursor(0, { from_line, from_col })
	vim.fn.feedkeys("o", "nx")
end

-- Will change inline comments with custom regex logic, or multiline comments
-- via `mini.comment`.
local function inner_comment()
	local line = vim.api.nvim_get_current_line()

	-- Take the commenstring until we see whitespace. I tried matching on the
	-- literal %s, but it was being weird and buggy.
	local commentstr, _ = vim.fn.matchstr(vim.bo.commentstring, [[^\(.*\)\s]])

	-- If the line has a comment that's only following whitespace, we can
	-- defer to mini.comment. We only have custom logic for EOL comments, since
	-- mini.comment doesn't implement logic for them
	if vim.fn.match(line, [[^\s*]] .. commentstr) ~= -1 then
		handle_non_eol_comments()
		return
	end

	-- Captures everything on a line until the commentstring is found. There's
	-- probably a better way to do this - but it does work!
	--
	-- To accomplish the above behavior, we match for optional whitespace at the
	-- beginning of the line, then at least one character of non-whitespace, then
	-- any more text until we reach the commentstring. This is to ensure that the
	-- comment is ACTUALLY an EOL comment, and has some non-whitespace preceding
	-- it. This probably isn't necessary since non-eol comments get filtered out
	-- above, but it makes the regex work better on its own.
	--
	-- Next, we add the commentstring to the capturing group, followed by a space.
	-- We now end the group. This will mean that when we sub in the line,
	-- everything after that commentstring will be deleted.
	local regex = [[\(^\s*\S\+.*]] .. commentstr .. [[\).*$]]

	if vim.fn.match(line, regex) == -1 then
		return
	end

	local new_line = vim.fn.substitute(line, regex, [[\=submatch(1)]], "")
	vim.api.nvim_set_current_line(new_line)

	-- TODO: actually enter insert mode when using `cic`. This probably needs to
	-- be done via `mini.ai` to accomplish that - something to look into.
	feedkeys("<Esc>$", "n")
end

vim.keymap.set({ "x", "o" }, "ic", inner_comment)
