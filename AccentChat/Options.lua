local addonName, addon = ...

function addon:GetOptions()
    if addon.options then
        return addon.options
    end

    local args = {
        header = {
            order = 1,
            type = "header",
            name = "AccentChat Controls",
        },
        enabled = {
            order = 2,
            type = "toggle",
            name = "Enable Accent",
            get = "GetEnabled",
            set = "SetEnabled"
        },
        strict = {
            order = 3,
            type = "toggle",
            name = "Strict Mode",
            desc = "Disables random flavor phrases for a cleaner translation.",
            get = "GetStrict",
            set = "SetStrict"
        },
        channel_header = {
            order = 4,
            type = "header",
            name = "Channel Controls"
        },
        channel_options = {
            order = 5,
            type = "group",
            name = "Apply accent to the following channels:",
            inline = true,
            args = {
                SAY = {
                    order = 1, type = "toggle", name = "Say (/s)",
                    get = function() return addon.db.char.channels.SAY end,
                    set = function(info, val) addon.db.char.channels.SAY = val end,
                },
                YELL = {
                    order = 2, type = "toggle", name = "Yell (/y)",
                    get = function() return addon.db.char.channels.YELL end,
                    set = function(info, val) addon.db.char.channels.YELL = val end,
                },
                EMOTE = {
                    order = 3, type = "toggle", name = "Emote (/e)",
                    desc = "Applies accent to the text part of custom emotes.",
                    get = function() return addon.db.char.channels.EMOTE end,
                    set = function(info, val) addon.db.char.channels.EMOTE = val end,
                },
                PARTY = {
                    order = 4, type = "toggle", name = "Party (/p)",
                    get = function() return addon.db.char.channels.PARTY end,
                    set = function(info, val) addon.db.char.channels.PARTY = val end,
                },
                RAID = {
                    order = 5, type = "toggle", name = "Raid (/raid)",
                    get = function() return addon.db.char.channels.RAID end,
                    set = function(info, val) addon.db.char.channels.RAID = val end,
                },
                GUILD = {
                    order = 6, type = "toggle", name = "Guild (/g)",
                    get = function() return addon.db.char.channels.GUILD end,
                    set = function(info, val) addon.db.char.channels.GUILD = val end,
                },
                OFFICER = {
                    order = 7, type = "toggle", name = "Officer (/o)",
                    get = function() return addon.db.char.channels.OFFICER end,
                    set = function(info, val) addon.db.char.channels.OFFICER = val end,
                },
                INSTANCE_CHAT = {
                    order = 8, type = "toggle", name = "Instance Chat",
                    get = function() return addon.db.char.channels.INSTANCE_CHAT end,
                    set = function(info, val) addon.db.char.channels.INSTANCE_CHAT = val end,
                },
            }
        },
        accent_header = {
            order = 10,
            type = "header",
            name = "Accents",
        },
    }


    local accentOptions = addon:GenerateAccentOptions()
    for k, v in pairs(accentOptions) do
        args[k] = v
    end

    local options = {
        name = "AccentChat " .. addon.version,
        handler = addon,
        type = "group",
        args = args,
    }

    addon.options = options
    return options
end