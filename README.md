# temoji.nvim

Text-emoji picker for Neovim.
Because sometimes `._.` says more than text ever could.

```
 ####                     ####
#   ##                   ##   #
#                             #
 ##        # ###      # ### ##
  # ###### ##### #### ##### #
  # #      #####      ##### #
  #                         #
```

## Features

- **Fuzzy picker**
    - [telescope](https://github.com/nvim-telescope/telescope.nvim)

## Install

```lua
{
    "numen-0/temoji.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim" ,
    },
    config = function()
        local temoji = require("temoji")
        temoji.setup({})

        vim.keymap.set("n", "<leader>te", function()
            temoji.pick()
        end, { desc = "Pick a text emoji" })

        vim.keymap.set("n", "<leader>tr", function()
            temoji.random()
        end, { desc = "Pick random text emoji" })

        vim.keymap.set("n", "<leader>ts", function()
            temoji.random({"serious"})
        end, { desc = "Pick random text emoji with tag 'serious'" })
    end,
}
```

## Configuaration

```lua
{
    ---@type table<string, (Temoji|string)[]>
    temojis = {
        ["core"] = {                           -- @pack
            "ascii",                           -- pack-wide #tags
            { rep = "._.", tags = { "meh" } }, -- temojis
            { rep = "UwU", tags = { "cute" } },
            { rep = ">:(" },
            { rep = "^_^", tags = { "happy" } },
        },
    },

    ---@type boolean?
    only_ascii = false,     -- ignore non-ASCII emojis
}
```

## Create your own pack

```lua
---@class Temoji
---@field rep   string
---@field tags  string[]?


temoji.setup({
    temojis = {
        ["my_temojis"] = { -- @set
            -- pack global tags (added to all)
            "my_temojis",
            "ascii",

            -- entries
            { rep = ">-<" },
            { rep = "('._.)", tags = { "nervous", "big" } },
            { rep = ">:(",    tags = { "angly" } },
            { rep = "^_^",    tags = { "happy" } },
        },

        ["core"] = false, -- disable default pack if desired
    },
})
```

## API

| function         | desc                                         |
|:----------------:|:---------------------------------------------|
| `pick(tags?)`    | Open emoji picker filtered by tags           |
| `random(tags?)`  | Insert random emoji with tag filter          |

### example

```lua
temoji.pick({ "cute", "angry" })
temoji.random("happy")
```

## License

All the repo falls under the [MIT License](/LICENSE).
