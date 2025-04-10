-- All credit goes to https://www.reddit.com/r/neovim/comments/1jty2vw/help_disabling_autocomplete_inside_of_comments/
-- Lets me disable completion when within comments
local is_within_comment = function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-indexed

  -- Position to check - either current position or one character back
  local check_col = col > 0 and col - 1 or col

  local success, node = pcall(vim.treesitter.get_node, {
    pos = { row, check_col },
  })

  local comment_nodes = {
    "comment",
    "comment_content",
    "line_comment",
    "block_comment",
  }

  if success and node and vim.tbl_contains(comment_nodes, node:type()) then
    return true
  end

  return true
end
