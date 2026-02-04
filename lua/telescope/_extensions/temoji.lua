-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md

local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
    error("Telescope is required for temoji picker")
end

local pickers      = require("telescope.pickers")
local finders      = require("telescope.finders")
local config       = require("telescope.config").values
local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters      = require("telescope.sorters")

local temoji       = require("temoji")

local function temoji_picker(opts)
    opts = opts or {}
    local entries = opts.tags and temoji.filter_temojis(opts.tags) or temoji.temojis

    if #entries == 0 then
        vim.notify("temoji: no matching emojis found for tags '" .. vim.inspect(opts.tags) .. "'",
            vim.log.levels.ERROR)
        return
    end

    pickers.new(opts, {
        prompt_title = "Temoji",
        finder = finders.new_table({
            results = entries,
            entry_maker = function(e)
                return {
                    value   = e.value,
                    display = e.display,
                    ordinal = e.ordinal or e.display,
                    score   = e.score or 0,
                }
            end,
        }),
        -- sorter = config.generic_sorter(opts),
        sorter = config.generic_sorter(opts, {
            scoring_function = function(_, prompt, line, entry)
                return sorters.get_fzy_score(prompt, line) + entry.score
            end,
        }),

        attach_mappings = function(prompt_bufnr, map)
            local function insert_temoji()
                local rep = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                vim.api.nvim_put({ rep }, "", false, true)
            end

            map("i", "<CR>", insert_temoji)
            map("n", "<CR>", insert_temoji)

            return true
        end,
    }):find()
end


return telescope.register_extension({
    exports = { temoji = temoji_picker },
})
