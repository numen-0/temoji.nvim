-- temoji.nvim ----------------------------------------------------------------

-- types ----------------------------------------------------------------------

---@class Temoji.Config
---@field packs         table<string, Temoji.Set|boolean>
---@field only_ascii    boolean?

---@alias Temoji.Set (Temoji|string)[]

---@class Temoji.Entry
---@field value   string
---@field tags    table<string, boolean>[] : set of the tags
---@field display string
---@field ordinal string

---@class Temoji
---@field rep   string
---@field tags  string[]?

-- modules --------------------------------------------------------------------

local utils = require("temoji.utils")
local M = {}

-- state ----------------------------------------------------------------------

---@type Temoji.Config
M.config = {
    packs = {                                               -- default packs
        ["clasic"] = {                                      -- @pack
            "ascii", "clasic",                              -- set #tags
            { rep = ":)",    tags = { "happy", "smile" } }, -- temojis
            { rep = ";)",    tags = { "happy", "smile", "wink" } },
            { rep = ":-P",   tags = { "silly", "playful", "tongue" } },
            { rep = ":-|",   tags = { "meh", "neutral" } },
            { rep = ":-[",   tags = { "sad", "meh" } },
            { rep = "xD",    tags = { "laugh", "happy" } },
            { rep = ":D",    tags = { "happy" } },
            { rep = "=_=",   tags = { "tired", "unamused", "meh" } },
            { rep = ">.<",   tags = { "pain", "shame", "stress" } },
            { rep = "^_^",   tags = { "happy", "cute" } },
            { rep = "(+_+)", tags = { "shock", "surprise" } },
            { rep = "(*_*)", tags = { "wonder", "awe" } },
            { rep = "O_o",   tags = { "confused", "weird" } },
            { rep = ":(",    tags = { "sad" } },
            { rep = ":-)",   tags = { "happy" } },
            { rep = ":'(",   tags = { "cry", "sad" } },
            { rep = ">:(",   tags = { "angry" } },
        },
        ["numen-0"] = {
            "ascii",
            { rep = "._.",           tags = { "meh", "tired" } },
            { rep = "-_-",           tags = { "tired", "unamused", "meh" } },
            { rep = ":3",            tags = { "cute", "playful" } },
            { rep = "(c-[//]-[//])", tags = { "cool", "big" } },
            { rep = "( -#-#)",       tags = { "cool" } },
            { rep = "( ._.)",        tags = { "meh", "awkward" } },
            { rep = "(._. )",        tags = { "meh", "awkward" } },
            { rep = "[ 0-0]",        tags = { "robot", "blank" } },
            { rep = "( DoD)",        tags = { "surprised", "weird" } },
            { rep = "( >_<)",        tags = { "frustrated", "pain" } },
            { rep = "( ^.^)",        tags = { "happy" } },
            { rep = "( T_T)",        tags = { "cry", "sad" } },
            { rep = "( '-')",        tags = { "neutral", "simple" } },
            { rep = "( UwU)",        tags = { "cute", "happy" } },
            { rep = "( OwO)",        tags = { "cute", "surprised" } },
            { rep = "( >_>)",        tags = { "suspicious", "shifty" } },
            { rep = "(<_< )",        tags = { "suspicious", "shifty" } },
            { rep = "( >_<)",        tags = { "pain", "frustrated" } },
            { rep = "{ 0~0}",        tags = { "pain", "frustrated" } },
        },
        ["kaomoji"] = {
            "kaomoji",
            { rep = "ʕ⌐■-■ʔ", tags = { "cool" } },
            { rep = "(⌐■-■)", tags = { "cool" } },
            { rep = "( ^_^)", tags = { "happy", "cute" } },
            { rep = "( ¬_¬)", tags = { "unamused" } },
            { rep = "( ʘ‿ʘ)", tags = { "wow", "happy" } },
            { rep = "( •‿•)", tags = { "happy" } },
            { rep = "( ◕‿◕)", tags = { "cute", "happy" } },
            { rep = "(ง •̀_•́)ง", tags = { "fight", "determined" } },
            { rep = "ʕ •ᴥ•ʔ", tags = { "cute", "bear" } },
            { rep = "ʕ —_—ʔ", tags = { "tired", "unamused", "meh" } },
        },
    }
}

---@type Temoji.Entry[]
M.temojis = {}

-- helpers --------------------------------------------------------------------

---@param  packs table<string, Temoji.Set>
---@return table<string, Temoji[]>
local function collapse_packs(packs)
    local collapsed = {}

    for name, set in pairs(packs) do
        local glob_tags = {}
        local out = {}

        for _, val in pairs(set) do -- Split string tags & temoji objects
            if type(val) == "string" then
                table.insert(glob_tags, val)
            elseif type(val) == "table" then
                val.tags = val.tags or {}
                table.insert(out, val)
            else
                error("temoji: invalid temoji set value at '" .. name .. "'")
            end
        end

        for _, temoji in pairs(out) do -- Apply merged tags to each temoji
            local tag_set = {}

            -- ascii auto-tag
            if utils.is_ascii(temoji.rep) then
                tag_set["ascii"] = true
            end

            -- group all tags
            for _, t in ipairs(glob_tags) do tag_set[t] = true end
            for _, t in ipairs(temoji.tags) do tag_set[t] = true end

            -- sort
            local list = {}
            for v, _ in pairs(tag_set) do table.insert(list, v) end
            table.sort(list)

            temoji.tags = list
        end

        collapsed[name] = out
    end

    return collapsed
end

---@param  t string[]
---@return table<string, boolean>
local function array_to_set(t)
    local set = {}
    for _, k in pairs(t) do set[k] = true end
    return set
end

---@param  temojis table<string, Temoji[]>
---@return table<string, Temoji.Entry[]>
local function build_entries(temojis)
    local entries = {}

    for name, set in pairs(temojis) do
        local t = {}

        for _, item in ipairs(set) do
            local rep     = item.rep
            local meta    = table.concat(item.tags, " ")

            -- display format: "@name rep meta"
            local display = string.format("@%-12s %s | %s", name .. ":",
                utils.pad_utf8(rep, 16), meta)
            ---@type Temoji.Entry
            table.insert(t, {
                value   = rep,
                tags    = array_to_set(item.tags),
                display = display,
                ordinal = display, -- text only
            })
        end

        entries[name] = t
    end

    return entries
end

-- api ------------------------------------------------------------------------

---@param  tags string|string[]?
---@return Temoji.Entry[]
M.filter_temojis = function (tags)
    if tags == nil or (type(tags) == "table" and #tags == 0) then
        return M.temojis
    elseif type(tags) == "string" then
        tags = { tags }
    elseif type(tags) ~= "table" then
        error("temoji: invalid input '" .. vim.inspect(tags) .. "'")
    end

    local entries = {}
    for _, e in ipairs(M.temojis) do
        for _, tag in ipairs(tags) do
            if not e.tags[tag] then
                goto next
            end
        end
        table.insert(entries, e)
        :: next ::
    end

    return entries
end

---@param tags string[]?
M.pick = function(tags)
    require("telescope").extensions.temoji.temoji({ tags = tags })
end

---@param tags string|string[]?
M.random = function(tags)
    local entries = M.filter_temojis(tags)

    if #entries == 0 then
        vim.notify("temoji: no matching emojis found for tags '" .. vim.inspect(tags) .. "'",
            vim.log.levels.ERROR)
        return
    end

    local item = entries[math.random(#entries)]
    vim.api.nvim_put({ item.value }, "", true, true)
end

-- setup ----------------------------------------------------------------------

---@param opts Temoji.Config?
M.setup = function(opts)
    opts = opts or {}

    for k, v in pairs(opts) do
        if type(v) ~= "table" then
            M.config[k] = v
        else
            M.config[k] = vim.tbl_extend("force", M.config[k], v)
        end
    end

    local packs = {}
    for name, pack in pairs(M.config.packs) do
        if type(pack) ~= "boolean" then -- disabled packs (["pack"] = false)
            packs[name] = pack
        end
    end

    M.config.packs = collapse_packs(packs)
    ---@diagnostic disable-next-line: param-type-mismatch
    M.temojis = utils.flatten(build_entries(M.config.packs))

    require("telescope").load_extension("temoji")
end

return M
