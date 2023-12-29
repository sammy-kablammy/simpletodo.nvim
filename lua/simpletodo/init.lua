-- custom TODO finder
-- inspired from https://www.youtube.com/watch?v=PdaObkGazoU
-- learn ya' some treesitter, nvim api, all sorts of fun stuff
-- you can use :InspectTree to play with treesitter

local M = {}

local function simple_todo()
    -- see https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax
    local query = '((comment) @thecomment (#match? @thecomment "TODO"))'
    --                  1          2          3        4        5
    -- 1: the type of node we're looking for
    -- 2: a label given to each found node (this label will be used in 4.)
    -- 3: a predicate specifying an extra condition that must be met for each
    --    node we want to use #match?
    -- 4: LHS of comparison is the comment we just found and labeled from 2.
    -- 5: RHS of comparison is the string literal "TODO"

    local parser = require('nvim-treesitter.parsers').get_parser()
    local result = vim.treesitter.query.parse(parser:lang(), query)
    local root = parser:parse()[1]:root() -- pure sorcery

    -- recall that in vim, buffers start at 1.
    -- buffer 0 is a special case that refers to the current buffer
    local current_buffer = 0
    local current_window_number = 0

    local all_matches = {}
    for _, node, _ in result:iter_captures(root, current_buffer) do
        local starting_line_number, starting_col_number = node:range()
        local text = vim.treesitter.get_node_text(node, current_buffer)
        table.insert(all_matches, {
            bufnr = current_buffer,
            text = text,
            -- vim line numbers are 1-based; treesitter is 0-based
            lnum = starting_line_number + 1,
        })
    end
    vim.fn.setloclist(current_window_number, all_matches)
    vim.cmd.lopen()
end

local function setup(options)
    vim.api.nvim_create_user_command("SimpleTodo", simple_todo, {})
end

M.simple_todo = simple_todo
M.setup = setup

return M
