local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")

npairs.add_rules({
  -- TODO REWRITE
  -- Homerolled logic to auto-add semicolons. I didn't think most nodes even had
  -- children, but it turns out there are anonymous nodes that don't show up in
  -- `:InspectTree` until you type `a` - and these anonymous children seem to
  -- contain the wrapping syntax elements for your current node. All the
  -- existing setups for auto-semicolons had edge cases - but I haven't been
  -- able to find a place where this fails.
  Rule("=", ";", "nix"):with_pair(function(_)
    local node = vim.treesitter.get_node()
    if node == nil then
      vim.print("node nil")
      return false
    end

    local first_child = node:child(0)
    local third_child = node:child(2)
    if
      first_child ~= nil
      and vim.tbl_contains({ "{", "let" }, first_child:type())
      and (third_child == nil or third_child:type() ~= ",")
    then
      return true
    end

    local sibling = node:prev_sibling()
    if sibling ~= nil and vim.tbl_contains({ "{", "let" }, sibling:type()) then
      vim.print("Sibling " .. sibling:type())
      return true
    end

    local parent = node:parent()
    if parent ~= nil and parent:type() == "ERROR" then
      local uncle = parent:prev_sibling()
      return uncle ~= nil and vim.tbl_contains({ "{", "let" }, uncle:type())
    end
    if parent == nil then
      vim.print("Parent nil")
    else
      vim.print("Parent " .. parent:type())
    end

    return false
  end),

  Autopairs_utils.replacePunctuation("nix", ";"),
})
