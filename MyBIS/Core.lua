local addonName = "BiSDisplayer"
local addon = CreateFrame("Frame", addonName)

local playerSpecName = nil

-- DATA SECTION: MAPPING
local specIDMap = {
    -- Death Knight
    [250] = "Blood Death Knight", [251] = "Frost Death Knight", [252] = "Unholy Death Knight",
    -- Demon Hunter
    [577] = "Havoc Demon Hunter", [581] = "Vengeance Demon Hunter",
    -- Druid
    [102] = "Balance Druid", [103] = "Feral Druid", [104] = "Guardian Druid", [105] = "Restoration Druid",
    -- Evoker
    [1467] = "Devastation Evoker", [1468] = "Preservation Evoker", [1473] = "Augmentation Evoker",
    -- Hunter
    [253] = "Beast Mastery Hunter", [254] = "Marksmanship Hunter", [255] = "Survival Hunter",
    -- Mage
    [62] = "Arcane Mage", [63] = "Fire Mage", [64] = "Frost Mage",
    -- Monk
    [268] = "Brewmaster Monk", [270] = "Mistweaver Monk", [269] = "Windwalker Monk",
    -- Paladin
    [65] = "Holy Paladin", [66] = "Protection Paladin", [70] = "Retribution Paladin",
    -- Priest
    [256] = "Discipline Priest", [257] = "Holy Priest", [258] = "Shadow Priest",
    -- Rogue
    [259] = "Assassination Rogue", [260] = "Outlaw Rogue", [261] = "Subtlety Rogue",
    -- Shaman
    [262] = "Elemental Shaman", [263] = "Enhancement Shaman", [264] = "Restoration Shaman",
    -- Warlock
    [265] = "Affliction Warlock", [266] = "Demonology Warlock", [267] = "Destruction Warlock",
    -- Warrior
    [71] = "Arms Warrior", [72] = "Fury Warrior", [73] = "Protection Warrior",
}

-- BIS DATA LIST (Kept your Patch 11.2 Future Data)
local BiS_Lists = {
    ["Beast Mastery Hunter"] = {
        source = "Wowhead by Tarlo",
        classSlug = "hunter",
        specSlug = "beast-mastery",
        items = {
            {slot = "Head",     itemName = "Midnight Herald's Cowl",                  itemID = 224675, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",     itemName = "Chrysalis of Sundered Souls",             itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Shoulder", itemName = "Midnight Herald's Shadowguards",          itemID = 224678, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",    itemName = "Reshii Wraps",                            itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",    itemName = "Midnight Herald's Hauberk",               itemID = 224674, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",    itemName = "Glyph-Etched Vambraces",                  itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Hands",    itemName = "Midnight Herald's Gloves",                itemID = 224679, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Waist",    itemName = "Durable Information Securing Container",    itemID = 224421, sourceInfo = "Overcharged Delves"},
            {slot = "Legs",     itemName = "Glyph-Etched Cuisses",                    itemID = 224391, sourceInfo = "Profession: Leatherworking"},
            {slot = "Feet",     itemName = "Interloper's Chain Boots",                itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",   itemName = "Band of the Shattered Soul",              itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",   itemName = "Ring of the Panoply",                     itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1",itemName = "Unyielding Netherprism",                  itemID = 224200, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2",itemName = "Astral Antenna",                          itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",   itemName = "Yasahm the Riftbreaker",                  itemID = 193737, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
        }
    },
    
    ["Survival Hunter"] = {
        source = "Wowhead by DoolB",
        classSlug = "hunter",
        specSlug = "survival",
        items = {
            {slot = "Head",     itemName = "Midnight Herald's Cowl",         itemID = 224675, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",     itemName = "Duskblaze's Desperation",        itemID = 224383, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Shoulder", itemName = "Midnight Herald's Shadowguards", itemID = 224678, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",    itemName = "Reshii Wraps",                   itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",    itemName = "Midnight Herald's Hauberk",      itemID = 224674, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",    itemName = "Glyph-Etched Vambraces",         itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Hands",    itemName = "Glyph-Etched Gauntlets",         itemID = 224390, sourceInfo = "Profession: Leatherworking"},
            {slot = "Waist",    itemName = "Clasp of Furious Freedom",       itemID = 224382, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Legs",     itemName = "Midnight Herald's Petticoat",    itemID = 224676, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Feet",     itemName = "Interloper's Chain Boots",       itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",   itemName = "Signet of the False Accuser",    itemID = 184717, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Ring 2",   itemName = "Logic Gate: Omega",              itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 1",itemName = "Araz's Ritual Forge",            itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2",itemName = "Improvised Seaforium Pacemaker", itemID = 186430, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Weapon",   itemName = "Spellstrike Warplance",          itemID = 224368, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
        }
    },

    ["Marksmanship Hunter"] = { 
        source = "Wowhead by TheAzortharion", 
        classSlug = "hunter",
        specSlug = "marksmanship",
        items = {
            {slot = "Head",     itemName = "Midnight Herald's Cowl",                  itemID = 224675, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",     itemName = "Ornately Engraved Amplifier",             itemID = 193741, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Shoulder", itemName = "Midnight Herald's Shadowguards",          itemID = 224678, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",    itemName = "Reshii Wraps",                            itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",    itemName = "Midnight Herald's Hauberk",               itemID = 224674, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",    itemName = "Glyph-Etched Vambraces",                  itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Hands",    itemName = "Glyph-Etched Gauntlets",                  itemID = 224390, sourceInfo = "Profession: Leatherworking"},
            {slot = "Waist",    itemName = "Durable Information Securing Container",    itemID = 224421, sourceInfo = "Overcharged Delves"},
            {slot = "Legs",     itemName = "Midnight Herald's Petticoat",             itemID = 224676, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Feet",     itemName = "Interloper's Chain Boots",                itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",   itemName = "Logic Gate: Alpha",                       itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",   itemName = "Radiant Necromancer's Band",              itemID = 224209, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Trinket 1",itemName = "Unyielding Netherprism",                  itemID = 224200, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2",itemName = "Astral Antenna",                          itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",   itemName = "Yasahm the Riftbreaker",                  itemID = 193737, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
        } 
    },

    ["Assassination Rogue"] = { 
        source = "Wowhead by Whispyr", 
        classSlug = "rogue",
        specSlug = "assassination",
        items = {
            {slot = "Head",     itemName = "Hood of the Sudden Eclipse",         itemID = 224667, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",     itemName = "Ornately Engraved Amplifier",        itemID = 193741, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Shoulder", itemName = "Smokemantle of the Sudden Eclipse",  itemID = 224670, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",    itemName = "Pure Energizing Fiber",              itemID = 224425, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",    itemName = "Tactical Vest of the Sudden Eclipse",itemID = 224666, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",    itemName = "Rune-Branded Armbands",              itemID = 224398, sourceInfo = "Profession: Crafting"},
            {slot = "Hands",    itemName = "Deathgrips of the Sudden Eclipse",   itemID = 224671, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Waist",    itemName = "Atomic Phasebelt",                   itemID = 224219, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Legs",     itemName = "Pants of the Sudden Eclipse",        itemID = 224668, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Feet",     itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",   itemName = "Logic Gate: Alpha",                  itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",   itemName = "Radiant Necromancer's Band",         itemID = 224209, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Trinket 1",itemName = "Araz's Ritual Forge",                itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2",itemName = "Astral Antenna",                     itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Main Hand",itemName = "Vengeful Netherspike",               itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand", itemName = "Everforged Stabber",                 itemID = 224400, sourceInfo = "Profession: Crafting"},
        }
    },

    ["Outlaw Rogue"] = { 
        source = "Wowhead by JustGuy", 
        classSlug = "rogue",
        specSlug = "outlaw",
        items = {
            {slot = "Head",     itemName = "Hood of the Sudden Eclipse",          itemID = 224667, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",     itemName = "Chrysalis of Sundered Souls",         itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Shoulder", itemName = "Smokemantle of the Sudden Eclipse",   itemID = 224670, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",    itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",    itemName = "Tactical Vest of the Sudden Eclipse", itemID = 224666, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",    itemName = "Armbands of the Sudden Eclipse",      itemID = 224669, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Hands",    itemName = "Gloves of Haunting Fixation",         itemID = 184725, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Waist",    itemName = "Rune-Branded Waistband",              itemID = 224397, sourceInfo = "Profession: Leatherworking"},
            {slot = "Legs",     itemName = "Pants of the Sudden Eclipse",         itemID = 224668, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Feet",     itemName = "Interloper's Reinforced Sandals",     itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",   itemName = "Ring of Earthen Craftsmanship",       itemID = 224410, sourceInfo = "Profession: Jewelcrafting"},
            {slot = "Ring 2",   itemName = "Ring of Earthen Craftsmanship",       itemID = 224410, sourceInfo = "Profession: Jewelcrafting"},
            {slot = "Trinket 1",itemName = "Sigil of the Cosmic Hunt",            itemID = 224385, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Trinket 2",itemName = "Astral Antenna",                      itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Main Hand",itemName = "Ergospheric Cudgel",                  itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Off Hand", itemName = "Geezle's Coercive Volt-ohmmeter",     itemID = 186429, sourceInfo = "Dungeon: Operation: Floodgate"},
        }
    },

    ["Elemental Shaman"] = {
        source = "Wowhead by HawkCorrigan",
        classSlug = "shaman",
        specSlug = "elemental",
        items = {
            {slot = "Head",      itemName = "Nathrian Usurper's Mask",        itemID = 184725, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Neck",      itemName = "Momma's Mega Medallion",         itemID = 186430, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Shoulder",  itemName = "Fangs of Channeled Fury",         itemID = 224720, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Furs of Channeled Fury",          itemID = 224716, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Glyph-Etched Vambraces",          itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Claws of Channeled Fury",         itemID = 224721, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Clasp of Furious Freedom",        itemID = 224382, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Legs",      itemName = "Tassets of Channeled Fury",       itemID = 224718, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Chain Boots",        itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Signet of Collapsing Stars",      itemID = 193744, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Ring 2",    itemName = "Seal of the Panoply",             itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",             itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Diamantine Voidcore",             itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Alt (Passive)", itemName = "Azhiccran Parapodia",         itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Alt (On Use)", itemName = "Lily of the Eternal Weave",    itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                  itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                itemID = 224401, sourceInfo = "Profession: Inscription"},
            {slot = "Alternative", itemName = "Voidglass Spire",               itemID = 224198, sourceInfo = "Raid: Soulbinder Naazindhri"},
        }
    },
    ["Enhancement Shaman"] = {
        source = "Wowhead by Wordup",
        classSlug = "shaman",
        specSlug = "enhancement",
        items = {
            {slot = "Head",      itemName = "Aspect of Channeled Fury",        itemID = 224717, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Cabochon of the Infinite Flight", itemID = 193745, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Shoulder",  itemName = "Fangs of Channeled Fury",         itemID = 224720, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "11.2 Campaign"},
            {slot = "Chest",     itemName = "Harvested Attendant's Uniform",   itemID = 224214, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Wrist",     itemName = "Glyph-Etched Vambraces",          itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Claws of Channeled Fury",         itemID = 224721, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Clasp of Furious Freedom",        itemID = 224382, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Legs",      itemName = "Tassets of Channeled Fury",       itemID = 224718, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Chain Boots",        itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Omega",               itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Ring 2",    itemName = "Whispers of K'aresh",             itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",             itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                  itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Alt (Passive)", itemName = "Improvised Seaforium Pacemaker", itemID = 186430, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Alt (On Use)", itemName = "Signet of the Priory",         itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Main Hand", itemName = "Fatebreaker, Destroyer of Futures", itemID = 193742, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Off Hand",  itemName = "Charged Facesmasher",             itemID = 224415, sourceInfo = "Profession: Blacksmithing"},
            {slot = "Alternative", itemName = "Unbound Training Claws",        itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
        }
    },
    ["Restoration Shaman"] = {
        source = "Wowhead by Theun",
        classSlug = "shaman",
        specSlug = "restoration",
        items = {
            {slot = "Head",      itemName = "Aspect of Channeled Fury",          itemID = 224717, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Ornately Engraved Amplifier",       itemID = 193741, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Shoulder",  itemName = "Claws of Failed Resistance",        itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Furs of Channeled Fury",            itemID = 224716, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Glyph-Etched Vambraces",            itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Claws of Channeled Fury",           itemID = 224721, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Colossal Lifetether",               itemID = 224203, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Legs",      itemName = "Tassets of Channeled Fury",         itemID = 224718, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Chain Boots",          itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Ring of the Panoply",               itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                    itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "So'leah's Secret Technique",        itemID = 193739, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Alt (Passive)", itemName = "Empowering Crystal of Anub'ikkaj", itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Alt (On Use)", itemName = "Signet of the Priory",           itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                    itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Everforged Defender",               itemID = 224417, sourceInfo = "Profession: Blacksmithing"},
            {slot = "Alternative", itemName = "Vagabond's Torch",                itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Havoc Demon Hunter"] = {
        source = "Wowhead by Shadarek",
        classSlug = "demon-hunter",
        specSlug = "havoc",
        items = {
            {slot = "Head",      itemName = "Charhound's Vicious Scalp",      itemID = 224690, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",               itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Charhound's Vicious Hornguards", itemID = 224693, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                   itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Charhound's Vicious Bindings",   itemID = 224689, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",          itemID = 224398, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Charhound's Vicious Feldaws",    itemID = 224694, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Atomic Phasebelt",               itemID = 224219, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Legs",      itemName = "Charhound's Vicious Hidecoat",   itemID = 224691, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Reinforced Sandals",itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Devout Zealot's Ring",           itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Ring 2",    itemName = "Logic Gate: Alpha",              itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                 itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Screams of a Forgotten Sky",     itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Alt (Passive)", itemName = "Sigil of the Cosmic Hunt",   itemID = 224385, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Alt (Passive) 2", itemName = "So'leah's Secret Technique", itemID = 193739, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Main Hand", itemName = "Collapsing Phaseblades",         itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Off Hand",  itemName = "Everforged Warglaive",           itemID = 224416, sourceInfo = "Profession: Blacksmithing"},
            {slot = "Alternative", itemName = "Interrogator's Flensing Blade",  itemID = 193742, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
        }
    },
    ["Vengeance Demon Hunter"] = {
        source = "Wowhead by Itamae",
        classSlug = "demon-hunter",
        specSlug = "vengeance",
        items = {
            {slot = "Head",      itemName = "Irradiated Impurity Filter",         itemID = 224218, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Neck",      itemName = "Ornately Engraved Amplifier",        itemID = 193741, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Shoulder",  itemName = "Charhound's Vicious Hornguards",     itemID = 224693, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps with Pure Chronomantic Fiber", itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Charhound's Vicious Bindings",       itemID = 224689, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",              itemID = 224398, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Charhound's Vicious Feldaws",        itemID = 224694, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Venza's Powderbelt",                 itemID = 193739, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Legs",      itemName = "Charhound's Vicious Hidecoat",       itemID = 224691, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",         itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Ring of the Panoply",                itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1", itemName = "So'leah's Secret Technique",         itemID = 193739, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Trinket 2", itemName = "Tome of Light's Devotion",           itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Trinket (Def 1)", itemName = "Ringing Ritual Mud",           itemID = 186429, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Trinket (Def 2)", itemName = "Soulbinder's Embrace",         itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Trinket (Group)", itemName = "Loom'ithar's Living Silk",     itemID = 224203, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",    itemName = "Sonic Ka-BOOM!-erang",               itemID = 186429, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Weapon (Alt)", itemName = "Everforged Longsword",            itemID = 224413, sourceInfo = "Profession: Blacksmithing"},
        }
    },

    ["Subtlety Rogue"] = { 
        source = "Wowhead by fuu1", 
        classSlug = "rogue",
        specSlug = "subtlety",
        items = {
            {slot = "Head",      itemName = "Hood of the Sudden Eclipse",         itemID = 224667, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Amulet of Earthen Craftsmanship",    itemID = 224408, sourceInfo = "Profession: Jewelcrafting"},
            {slot = "Shoulder",  itemName = "Deathbound Shoulderpads",            itemID = 224203, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                       itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Tactical Vest of the Sudden Eclipse",itemID = 224666, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",              itemID = 224398, sourceInfo = "Profession: Leatherworking"},
            {slot = "Hands",     itemName = "Deathgrips of the Sudden Eclipse",   itemID = 224671, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Waist",     itemName = "Reaper's Dreadbelt",                 itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Legs",      itemName = "Pants of the Sudden Eclipse",        itemID = 224668, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Feet",      itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Alpha",                  itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",    itemName = "High Nerubian Signet",               itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Trinket 1", itemName = "Unyielding Netherprism",             itemID = 224200, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                     itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Main Hand", itemName = "Vengeful Netherspike",               itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Prodigious Gene Splicer",            itemID = 224202, sourceInfo = "Raid: Loom'ithar"},
        }
    },

    ["Balance Druid"] = { 
        source = "Wowhead by Tettles", 
        classSlug = "druid",
        specSlug = "balance",
        items = {
            {slot = "Head",      itemName = "Skymane of the Mother Eagle",      itemID = 224697, sourceInfo = "Catalyst / Raid: Forgeweaver Araz"},
            {slot = "Neck",      itemName = "Sin Stained Pendant",              itemID = 184719, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Shoulder",  itemName = "Ritual Pauldrons of the Mother Eagle", itemID = 224700, sourceInfo = "Catalyst / Raid: The Soul Hunters"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                       itemID = 224424, sourceInfo = "Artifact Cloak"},
            {slot = "Chest",     itemName = "Vest of the Mother Eagle",         itemID = 224696, sourceInfo = "Catalyst / Raid: Fractillus"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",              itemID = 224398, sourceInfo = "Profession: Crafting"},
            {slot = "Hands",     itemName = "Wings of the Mother Eagle",        itemID = 224703, sourceInfo = "Catalyst / Raid: Soulbinder Naazindhri"},
            {slot = "Waist",     itemName = "Atomic Phasebelt",                   itemID = 224219, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Legs",      itemName = "Spittle-Stained Trousers",         itemID = 224369, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Feet",      itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Omega",                  itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Ring 2",    itemName = "Signet of the False Accuser",        itemID = 184717, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",                itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                     itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                     itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                   itemID = 224401, sourceInfo = "Profession: Crafting"},
        }
    },

    ["Feral Druid"] = { 
        source = "Wowhead by Guiltyas", 
        classSlug = "druid",
        specSlug = "feral",
        items = {
            {slot = "Head",      itemName = "Skymane of the Mother Eagle",      itemID = 224697, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                 itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Ritual Pauldrons of the Mother Eagle", itemID = 224700, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                       itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "So'azmi's Fractal Vest",           itemID = 193738, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",              itemID = 224398, sourceInfo = "Profession: Leatherworking"},
            {slot = "Hands",     itemName = "Wings of the Mother Eagle",        itemID = 224703, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Waist",     itemName = "Rune-Branded Waistband",           itemID = 224397, sourceInfo = "Profession: Leatherworking"},
            {slot = "Legs",      itemName = "Breeches of the Mother Eagle",     itemID = 224698, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Feet",      itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Radiant Necromancer's Band",         itemID = 224209, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Ring 2",    itemName = "Ring of the Panoply",                itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",                itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                     itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",    itemName = "Harvester's Interdiction",           itemID = 185100, sourceInfo = "Dungeon: Ara-Kara, City of Echoes"},
        }
    },
    ["Guardian Druid"] = { 
        source = "Wowhead by Pumps", 
        classSlug = "druid",
        specSlug = "guardian",
        items = {
            {slot = "Head",      itemName = "Skymane of the Mother Eagle",      itemID = 224697, sourceInfo = "Raid: Forgeweaver Araz / Catalyst"},
            {slot = "Neck",      itemName = "Duskblaze's Desperation",          itemID = 224383, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Shoulder",  itemName = "Ritual Pauldrons of the Mother Eagle", itemID = 224700, sourceInfo = "Raid: The Soul Hunters / Catalyst"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                       itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Vest of the Mother Eagle",         itemID = 224696, sourceInfo = "Raid: Fractillus / Catalyst"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",              itemID = 224398, sourceInfo = "Profession: Crafting"},
            {slot = "Hands",     itemName = "Winged Gamma Handlers",            itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Waist",     itemName = "Adrenal Surge Clasp",                itemID = 224404, sourceInfo = "Profession: Crafting"},
            {slot = "Legs",      itemName = "Breeches of the Mother Eagle",     itemID = 224698, sourceInfo = "Raid: Loom'ithar / Catalyst"},
            {slot = "Feet",      itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",         itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Ring of the Panoply",                itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1", itemName = "Tome of Light's Devotion",           itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Trinket 2", itemName = "Improvised Seaforium Pacemaker",     itemID = 186430, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Weapon",    itemName = "Harvester's Interdiction",           itemID = 185100, sourceInfo = "Dungeon: Ara-Kara, City of Echoes"},
        }
    },
    ["Restoration Druid"] = { 
        source = "Wowhead by Voulk", 
        classSlug = "druid",
        specSlug = "restoration",
        items = {
            {slot = "Head",      itemName = "Skymane of the Mother Eagle",      itemID = 224697, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Sin Stained Pendant",              itemID = 184719, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Shoulder",  itemName = "Ritual Pauldrons of the Mother Eagle", itemID = 224700, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                       itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Vest of the Mother Eagle",         itemID = 224696, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Time-Compressed Wristguards",      itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Hands",     itemName = "Wings of the Mother Eagle",        itemID = 224703, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Waist",     itemName = "Dreamsash of the Mother Eagle",    itemID = 224699, sourceInfo = "Catalyst"},
            {slot = "Legs",      itemName = "Spittle-Stained Trousers",         itemID = 224369, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Feet",      itemName = "Interloper's Reinforced Sandals",    itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Whispers of K'aresh",                itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Ring 2",    itemName = "Band of the Shattered Soul",         itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Trinket 1", itemName = "So'leah's Secret Technique",         itemID = 193739, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Trinket 2", itemName = "Diamantine Voidcore",                itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Weapon",    itemName = "Voidglass Spire",                    itemID = 224198, sourceInfo = "Raid: Soulbinder Naazindhri"},
        }
    },

    ["Blood Death Knight"] = {
        source = "Wowhead by Mandi",
        classSlug = "death-knight",
        specSlug = "blood",
        items = {
            {slot = "Head",      itemName = "Hollow Sentinel's Stonemask",       itemID = 224683, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Neck",      itemName = "Duskblaze's Desperation",           itemID = 224383, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Shoulder",  itemName = "Hollow Sentinel's Perches",         itemID = 224686, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Hollow Sentinel's Breastplate",     itemID = 224682, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",              itemID = 224419, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Hollow Sentinel's Gauntlets",       itemID = 224687, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Belt",      itemName = "Everforged Greatbelt",              itemID = 224418, sourceInfo = "Profession: Crafting"},
            {slot = "Legs",      itemName = "Halkias's Towering Pillars",        itemID = 184728, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",      itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Signet of Collapsing Stars",        itemID = 193744, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Trinket 1", itemName = "Brand of Ceaseless Ire",            itemID = 224385, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Trinket 2", itemName = "Tome of Light's Devotion",          itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Trinket (Alt)", itemName = "Unyielding Netherprism",        itemID = 224200, sourceInfo = "Raid: Fractillus"},
            {slot = "Weapon",    itemName = "Maw of the Void",                   itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
        }
    },
    ["Frost Death Knight"] = {
        source = "Wowhead by KhazakDK",
        classSlug = "death-knight",
        specSlug = "frost",
        items = {
            {slot = "Head",      itemName = "Hollow Sentinel's Stonemask",       itemID = 224683, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Sin Stained Pendant",               itemID = 184719, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Shoulder",  itemName = "Hollow Sentinel's Perches",         itemID = 224686, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Hollow Sentinel's Breastplate",     itemID = 224682, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",              itemID = 224419, sourceInfo = "Profession: Blacksmithing"},
            {slot = "Gloves",    itemName = "Jumpstarter's Scaffold-Scrapers",   itemID = 186431, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Belt",      itemName = "Girdle of Somber Ploys",            itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Legs",      itemName = "Hollow Sentinel's Stonekilt",       itemID = 224684, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",      itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",    itemName = "Logic Gate: Omega",                 itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",               itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                    itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "2H Weapon", itemName = "Charged Claymore",                  itemID = 224414, sourceInfo = "Profession: Blacksmithing"},
            {slot = "1H Weapon", itemName = "Oath-Breaker's Recompense",         itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
        }
    },
    ["Unholy Death Knight"] = {
        source = "Wowhead by Taeznak",
        classSlug = "death-knight",
        specSlug = "unholy",
        items = {
            {slot = "Head",      itemName = "Hollow Sentinel's Stonemask",       itemID = 224683, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                  itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Hollow Sentinel's Perches",         itemID = 224686, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Hollow Sentinel's Breastplate",     itemID = 224682, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",              itemID = 224419, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Breached Containment Guards",       itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Belt",      itemName = "Everforged Greatbelt",              itemID = 224418, sourceInfo = "Profession: Crafting"},
            {slot = "Legs",      itemName = "Hollow Sentinel's Stonekilt",       itemID = 224684, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",      itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Ring of the Panoply",               itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Ring 2",    itemName = "Whispers of K'aresh",               itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Trinket 1", itemName = "Cursed Stone Idol",                 itemID = 184721, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                    itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",    itemName = "Fatebound Crusader",                itemID = 224368, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
        }
    },
    ["Devastation Evoker"] = {
        source = "Wowhead by Preheat",
        classSlug = "evoker",
        specSlug = "devastation",
        items = {
            {slot = "Head",      itemName = "Spellweaver's Immaculate Focus",      itemID = 224660, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Duskblaze's Desperation",             itemID = 224383, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Shoulder",  itemName = "Spellweaver's Immaculate Pauldrons",  itemID = 224663, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Spellweaver's Immaculate Crestward",   itemID = 224659, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Glyph-Etched Vambraces",              itemID = 224392, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Spellweaver's Immaculate Scaleguards",itemID = 224664, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Durable Information Securing Container", itemID = 224421, sourceInfo = "Overcharged Delves"},
            {slot = "Legs",      itemName = "Spellweaver's Immaculate Runeslacks", itemID = 224661, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Chain Boots",            itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",          itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Band of the Panoply",                 itemID = 193740, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",                 itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Azhiccran Parapodia",                 itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Main Hand", itemName = "Voidglass Sovereign's Blade",         itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                    itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Preservation Evoker"] = {
        source = "Wowhead by Voulk",
        classSlug = "evoker",
        specSlug = "preservation",
        items = {
            {slot = "Head",      itemName = "Spellweaver's Immaculate Focus",      itemID = 224660, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                    itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Spellweaver's Immaculate Pauldrons",  itemID = 224663, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Soaring Decimator's Hauberk",         itemID = 193738, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Wrist",     itemName = "Arcanotech Wrist-Matrix",             itemID = 224218, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Gloves",    itemName = "Spellweaver's Immaculate Scaleguards",itemID = 224664, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Clasp of Furious Freedom",            itemID = 224382, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Legs",      itemName = "Spellweaver's Immaculate Runeslacks", itemID = 224661, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Chain Boots",            itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",          itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Logic Gate: Omega",                   itemID = 224217, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                      itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Nexus-King's Command",                itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Trinket 3", itemName = "Diamantine Voidcore",                 itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Weapon",    itemName = "Voidglass Spire",                     itemID = 224198, sourceInfo = "Raid: Soulbinder Naazindhri"},
        }
    },
    ["Augmentation Evoker"] = {
        source = "Wowhead by Jereico",
        classSlug = "evoker",
        specSlug = "augmentation",
        items = {
            {slot = "Head",      itemName = "Cryptbound Headpiece",                itemID = 185100, sourceInfo = "Dungeon: Ara-Kara, City of Echoes"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                    itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Spellweaver's Immaculate Pauldrons",  itemID = 224663, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Spellweaver's Immaculate Crestward",   itemID = 224659, sourceInfo = "Raid: Fractillus"},
            {slot = "Wrist",     itemName = "Glyph-Etched Vambraces",              itemID = 224392, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Spellweaver's Immaculate Scaleguards",itemID = 224664, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Waist",     itemName = "Discount Mail-Order Belt",            itemID = 193739, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Legs",      itemName = "Spellweaver's Immaculate Runeslacks", itemID = 224661, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Boots",     itemName = "Interloper's Chain Boots",            itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Omega",                   itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Ring 2",    itemName = "Signet of the False Accuser",         itemID = 184717, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Trinket 1", itemName = "Lily of the Eternal Weave",          itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Trinket 2", itemName = "Screams of a Forgotten Sky",          itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                      itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                    itemID = 224401, sourceInfo = "Profession: Crafting"},
            {slot = "Weapon",    itemName = "Voidglass Spire",                     itemID = 224198, sourceInfo = "Raid: Soulbinder Naazindhri"},
        }
    },
    ["Arcane Mage"] = {
        source = "Wowhead by Porom",
        classSlug = "mage",
        specSlug = "arcane",
        items = {
            {slot = "Head",      itemName = "Augur's Ephemeral Wide-Brim",         itemID = 224710, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Neck",      itemName = "Chrysalis of Sundered Souls",         itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Shoulder",  itemName = "Augur's Ephemeral Orbs of Power",     itemID = 224713, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Augur's Ephemeral Habiliments",       itemID = 224709, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                   itemID = 224405, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Codebreaker's Cunning Handwraps",     itemID = 193745, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Belt",      itemName = "Singularity Cincture",                itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Legs",      itemName = "Augur's Ephemeral Trousers",          itemID = 224711, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",        itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",          itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "High Nerubian Signet",                itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Trinket 1", itemName = "Loom'ithar",                          itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Diamantine Voidcore",                 itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Weapon",    itemName = "Voidglass Sovereign's Blade",         itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                    itemID = 224401, sourceInfo = "Profession: Crafting"},
        }
    },
    ["Fire Mage"] = {
        source = "Wowhead by Preheat",
        classSlug = "mage",
        specSlug = "fire",
        items = {
            {slot = "Head",      itemName = "Zadus's Liturgical Hat",              itemID = 224213, sourceInfo = "Trash Drop (Raid)"},
            {slot = "Neck",      itemName = "Duskblaze's Desperation",             itemID = 224383, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Shoulder",  itemName = "Augur's Ephemeral Orbs of Power",     itemID = 224713, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Augur's Ephemeral Habiliments",       itemID = 224709, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                   itemID = 224405, sourceInfo = "Profession: Tailoring"},
            {slot = "Gloves",    itemName = "Augur's Ephemeral Mitts",             itemID = 224714, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Belt",      itemName = "Forgeweaver's Journal Holster",       itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Legs",      itemName = "Augur's Ephemeral Trousers",          itemID = 224711, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",        itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",          itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Signet of Collapsing Stars",          itemID = 193744, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Trinket 1", itemName = "Diamantine Voidcore",                 itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                      itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Main Hand", itemName = "Voidglass Sovereign's Blade",         itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                    itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Frost Mage"] = {
        source = "Wowhead by Dorovon",
        classSlug = "mage",
        specSlug = "frost",
        items = {
            {slot = "Head",      itemName = "Augur's Ephemeral Wide-Brim",         itemID = 224710, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Ornately Engraved Amplifier",         itemID = 193741, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Shoulder",  itemName = "Augur's Ephemeral Orbs of Power",     itemID = 224713, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                        itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Zealous Warden's Raiment",            itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                   itemID = 224405, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Augur's Ephemeral Mitts",             itemID = 224714, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Cord of the Dark Word",               itemID = 184720, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Legs",      itemName = "Augur's Ephemeral Trousers",          itemID = 224711, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",        itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Signet of Collapsing Stars",          itemID = 193744, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Ring 2",    itemName = "High Nerubian Signet",                itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",                 itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Trinket 2", itemName = "Azhiccran Parapodia",                 itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                      itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                    itemID = 224401, sourceInfo = "Profession: Crafting"},
        }
    },

        ["Brewmaster Monk"] = {
        source = "Wowhead by Sinzhu",
        classSlug = "monk",
        specSlug = "brewmaster",
        items = {
            {slot = "Head",      itemName = "Half-Mask of Fallen Storms",      itemID = 224698, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Bloodstained Memento",            itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Shoulder",  itemName = "Glyphs of Fallen Storms",         itemID = 224701, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Gi of Fallen Storms",             itemID = 224697, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",           itemID = 224398, sourceInfo = "Leatherworking (See note)"},
            {slot = "Gloves",    itemName = "Grasp of Fallen Storms",          itemID = 224702, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Adrenal Surge Clasp",             itemID = 224397, sourceInfo = "Leatherworking (See note)"},
            {slot = "Legs",      itemName = "Anomalous Starlit Breeches",      itemID = 193743, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Boots",     itemName = "Interloper's Reinforced Sandals", itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Alpha",               itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",    itemName = "High Nerubian Signet",            itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Trinket (Hyb 1)", itemName = "Brand of Ceaseless Ire",    itemID = 224385, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Trinket (Hyb 2)", itemName = "Tome of Light's Devotion",  itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Trinket (Dmg 1)", itemName = "Unyielding Netherprism",    itemID = 224200, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket (Dmg 2)", itemName = "Perfidious Projector",      itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Trinket (Def 1)", itemName = "Ringing Ritual Mud",        itemID = 186429, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Trinket (Def 2)", itemName = "Soulbinder's Embrace",      itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Weapon (2H)", itemName = "Harvester's Interdiction",      itemID = 185100, sourceInfo = "Dungeon: Ara-Kara, City of Echoes"},
            {slot = "Weapon (1H)", itemName = "Zephyrous Sail Carver",         itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Weapon (1H) 2", itemName = "Starforged Seraph's Mace",    itemID = 224210, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
        }
    },
    ["Mistweaver Monk"] = {
        source = "Wowhead by JuneHW",
        classSlug = "monk",
        specSlug = "mistweaver",
        items = {
            {slot = "Head",      itemName = "Half-Mask of Fallen Storms",      itemID = 224698, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Chrysalis of Sundered Souls",     itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Shoulder",  itemName = "Glyphs of Fallen Storms",         itemID = 224701, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Darksorrow's Corrupted Carapace", itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",           itemID = 224398, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Grasp of Fallen Storms",          itemID = 224702, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Thunderbund of Fallen Storms",    itemID = 224699, sourceInfo = "The Catalyst"},
            {slot = "Legs",      itemName = "Legwraps of Fallen Storms",       itemID = 224700, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Reinforced Sandals", itemID = 224386, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Devout Zealot's Ring",            itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Ring 2",    itemName = "Ring of the Panoply",             itemID = 193740, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Trinket 1", itemName = "Diamantine Voidcore",             itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                  itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",    itemName = "Voidglass Sovereign's Blade",     itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Windwalker Monk"] = {
        source = "Wowhead by Babylonius",
        classSlug = "monk",
        specSlug = "windwalker",
        items = {
            {slot = "Head",      itemName = "Half-Mask of Fallen Storms",      itemID = 224698, sourceInfo = "Raid: Forgeweaver Araz - Manaforge Omega"},
            {slot = "Neck",      itemName = "Sin Stained Pendant",             itemID = 184719, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Shoulder",  itemName = "Glyphs of Fallen Storms",         itemID = 224701, sourceInfo = "Raid: The Soul Hunters - Manaforge Omega"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Gi of Fallen Storms",             itemID = 224697, sourceInfo = "Raid: Fractillus - Manaforge Omega"},
            {slot = "Wrist",     itemName = "Rune-Branded Armbands",           itemID = 224398, sourceInfo = "Profession: Leatherworking"},
            {slot = "Gloves",    itemName = "Grasp of Fallen Storms",          itemID = 224702, sourceInfo = "Raid: Soulbinder Naazindhri - Manaforge Omega"},
            {slot = "Belt",      itemName = "Rune-Branded Waistband",          itemID = 224397, sourceInfo = "Profession: Leatherworking"},
            {slot = "Legs",      itemName = "Legwraps of Fallen Storms",       itemID = 224700, sourceInfo = "Raid: Loom'ithar - Manaforge Omega"},
            {slot = "Boots",     itemName = "Interloper's Reinforced Sandals", itemID = 224386, sourceInfo = "Raid: The Soul Hunters - Manaforge Omega"},
            {slot = "Ring 1",    itemName = "Signet of the False Accuser",     itemID = 184717, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Ring 2",    itemName = "Whispers of K'aresh",             itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Weapon",    itemName = "Harvester's Interdiction",        itemID = 185100, sourceInfo = "Dungeon: Ara-Kara, City of Echoes"},
            {slot = "Trinket 1", itemName = "Araz's Ritual Forge",             itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz - Manaforge Omega"},
            {slot = "Trinket 2", itemName = "Astral Antenna",                  itemID = 224204, sourceInfo = "Raid: Loom'ithar - Manaforge Omega"},
        }
    },
    ["Holy Paladin"] = {
        source = "Wowhead by HolyClarius",
        classSlug = "paladin",
        specSlug = "holy",
        items = {
            {slot = "Head",      itemName = "Lightmane of the Lucent Battalion", itemID = 224732, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Neck",      itemName = "Duskblaze's Desperation",           itemID = 224383, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Shoulder",  itemName = "Chargers of the Lucent Battalion",  itemID = 224735, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Cuirass of the Lucent Battalion",   itemID = 224731, sourceInfo = "Raid: Fractillus"},
            {slot = "Wrist",     itemName = "Yoke of Enveloping Hatred",         itemID = 224382, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Gloves",    itemName = "Jumpstarter's Scaffold-Scrapers",   itemID = 186431, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Belt",      itemName = "Fresh Ethereal Fetters",            itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Legs",      itemName = "Cuisses of the Lucent Battalion",   itemID = 224733, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",      itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Omega",                 itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Ring 2",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Trinket 1", itemName = "Diamantine Voidcore",               itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2", itemName = "Nexus-King's Command",              itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Weapon",    itemName = "Voidglass Sovereign's Blade",       itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shield",    itemName = "Ward of the Weaving-Beast",         itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
        }
    },
    ["Protection Paladin"] = {
        source = "Wowhead by AndyBrew",
        classSlug = "paladin",
        specSlug = "protection",
        items = {
            {slot = "Head",      itemName = "Crown of Absolute Command",         itemID = 193744, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Neck",      itemName = "Cabochon of the Infinite Flight",   itemID = 193745, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Shoulder",  itemName = "Chargers of the Lucent Battalion",  itemID = 224735, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Cuirass of the Lucent Battalion",   itemID = 224731, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",              itemID = 224419, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Protectors of the Lucent Battalion",itemID = 224736, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Everforged Greatbelt",              itemID = 224418, sourceInfo = "Profession: Crafting"},
            {slot = "Legs",      itemName = "Cuisses of the Lucent Battalion",   itemID = 224733, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",      itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",    itemName = "Devout Zealot's Ring",              itemID = 224220, sourceInfo = "Dungeon: Dawnbreaker"},
            {slot = "Weapon",    itemName = "Oath-Breaker's Recompense",         itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shield",    itemName = "Ward of the Weaving-Beast",         itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
        }
    },
    ["Retribution Paladin"] = {
        source = "Wowhead by Bolas",
        classSlug = "paladin",
        specSlug = "retribution",
        items = {
            {slot = "Head",      itemName = "Lightmane of the Lucent Battalion", itemID = 224732, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                  itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Chargers of the Lucent Battalion",  itemID = 224735, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Cuirass of the Lucent Battalion",   itemID = 224731, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",              itemID = 224419, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Protectors of the Lucent Battalion",itemID = 224736, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Belt",      itemName = "Everforged Greatbelt",              itemID = 224418, sourceInfo = "Profession: Crafting"},
            {slot = "Legs",      itemName = "Cuisses of the Lucent Battalion",   itemID = 224733, sourceInfo = "Catalyst / Raid / Vault"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",      itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Omega",                 itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Ring 2",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 1", itemName = "Screams of a Forgotten Sky",        itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Trinket 2", itemName = "Loom'ithar",                          itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Weapon",    itemName = "Photon Sabre Prime",                itemID = 224216, sourceInfo = "Raid: Forgeweaver Araz"},
        }
    },
    ["Discipline Priest"] = {
        source = "Wowhead by AutomaticJak",
        classSlug = "priest",
        specSlug = "discipline",
        items = {
            {slot = "Head",      itemName = "Dying Star's Veil",                 itemID = 224724, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                  itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Dying Star's Pyrelights",           itemID = 224727, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Dying Star's Cassock",              itemID = 224723, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                 itemID = 224405, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Bloodwrath's Gnarled Claws",        itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Belt",      itemName = "Pan-Dimensional Packing Cord",      itemID = 193739, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Legs",      itemName = "Dying Star's Leggings",             itemID = 224725, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",      itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Trinket 1", itemName = "Lily of the Eternal Weave",          itemID = 224370, sourceInfo = "Dungeon: Eco-Dome Al'dani"},
            {slot = "Trinket 2", itemName = "Diamantine Voidcore",               itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                    itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                  itemID = 224401, sourceInfo = "Profession: Crafted"},
        }
    },
    ["Holy Priest"] = {
        source = "Wowhead by AutomaticJak",
        classSlug = "priest",
        specSlug = "holy",
        items = {
            {slot = "Head",      itemName = "Dying Star's Veil",                 itemID = 224724, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadar's Folly",                  itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Dying Star's Pyrelights",           itemID = 224727, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Dying Star's Cassock",              itemID = 224723, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                 itemID = 224405, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Bloodwrath's Gnarled Claws",        itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Belt",      itemName = "Pan-Dimensional Packing Cord",      itemID = 193739, sourceInfo = "Dungeon: Tazavesh, Streets of Wonder"},
            {slot = "Legs",      itemName = "Dying Star's Leggings",             itemID = 224725, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",      itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Ring 2",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                      itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Diamantine Voidcore",               itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                    itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                  itemID = 224401, sourceInfo = "Profession: Crafted"},
        }
    },
    ["Shadow Priest"] = {
        source = "Wowhead by EllipsisPriest",
        classSlug = "priest",
        specSlug = "shadow",
        items = {
            {slot = "Head",      itemName = "Dying Star's Veil",                 itemID = 224724, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Sin Stained Pendant",               itemID = 184719, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Shoulder",  itemName = "Sinlight Shoulderpads",             itemID = 184725, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Dying Star's Cassock",              itemID = 224723, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                 itemID = 224405, sourceInfo = "Profession: Tailoring"},
            {slot = "Gloves",    itemName = "Dying Star's Caress",               itemID = 224728, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Singularity Cincture",              itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Legs",      itemName = "Dying Star's Leggings",             itemID = 224725, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",      itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Logic Gate: Omega",                 itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Ring 2",    itemName = "Signet of the False Accuser",       itemID = 184717, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                      itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Araz's Ritual Forge",               itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Main Hand", itemName = "Voidglass Kris",                    itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                  itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },


    ["Affliction Warlock"] = {
        source = "Wowhead by Kalamazi",
        classSlug = "warlock",
        specSlug = "affliction",
        items = {
            {slot = "Head",      itemName = "Inquisitor's Portal to Madness",    itemID = 224741, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadaar's Folly",                 itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Inquisitor's Gaze of Madness",      itemID = 224744, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Inquisitor's Robes of Madness",     itemID = 224740, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                 itemID = 224405, sourceInfo = "Profession: Tailoring"},
            {slot = "Gloves",    itemName = "Inquisitor's Clutches of Madness",  itemID = 224745, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Forgeweaver's Journal Holster",     itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Legs",      itemName = "Inquisitor's Leggings of Madness",  itemID = 224742, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",      itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                    itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Araz's Ritual Forge",               itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Weapon",    itemName = "Voidglass Sovereign's Blade",       itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                  itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Demonology Warlock"] = {
        source = "Wowhead by NotWarlock",
        classSlug = "warlock",
        specSlug = "demonology",
        items = {
            {slot = "Head",      itemName = "Inquisitor's Portal to Madness",    itemID = 224741, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadaar's Folly",                 itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Inquisitor's Gaze of Madness",      itemID = 224744, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Inquisitor's Robes of Madness",     itemID = 224740, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                 itemID = 224405, sourceInfo = "Profession: Tailoring"},
            {slot = "Gloves",    itemName = "Bloodwrath's Gnarled Claws",        itemID = 224381, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Belt",      itemName = "Forgeweaver's Journal Holster",     itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Legs",      itemName = "Inquisitor's Leggings of Madness",  itemID = 224742, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",      itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 1", itemName = "Loom'ithar",                          itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Araz's Ritual Forge",               itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Weapon",    itemName = "Voidglass Sovereign's Blade",       itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                  itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Destruction Warlock"] = {
        source = "Wowhead by Loozy",
        classSlug = "warlock",
        specSlug = "destruction",
        items = {
            {slot = "Head",      itemName = "Inquisitor's Portal to Madness",    itemID = 224741, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Salhadaar's Folly",                 itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Inquisitor's Gaze of Madness",      itemID = 224744, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                      itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Inquisitor's Robes of Madness",     itemID = 224740, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Wrist",     itemName = "Consecrated Cuffs",                 itemID = 224405, sourceInfo = "Profession: Tailoring"},
            {slot = "Gloves",    itemName = "Inquisitor's Clutches of Madness",  itemID = 224745, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Forgeweaver's Journal Holster",     itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Legs",      itemName = "Inquisitor's Leggings of Madness",  itemID = 224742, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Silken Striders",      itemID = 224380, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",        itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Logic Gate: Alpha",                 itemID = 224216, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 1", itemName = "Diamantine Voidcore",               itemID = 224199, sourceInfo = "Raid: Fractillus"},
            {slot = "Trinket 2", itemName = "Araz's Ritual Forge",               itemID = 224215, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Weapon",    itemName = "Voidglass Sovereign's Blade",       itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Off Hand",  itemName = "Vagabond's Torch",                  itemID = 224401, sourceInfo = "Profession: Inscription"},
        }
    },
    ["Arms Warrior"] = {
        source = "Wowhead by Archimtiros",
        classSlug = "warrior",
        specSlug = "arms",
        items = {
            {slot = "Head",      itemName = "Living Weapon's Faceshield",      itemID = 224750, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Neck",      itemName = "Salhadaar's Folly",               itemID = 224208, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shoulder",  itemName = "Living Weapon's Ramparts",        itemID = 224753, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Living Weapon's Bulwark",         itemID = 224749, sourceInfo = "Raid: Fractillus"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",            itemID = 224419, sourceInfo = "Profession: Crafted"},
            {slot = "Gloves",    itemName = "Living Weapon's Crushers",        itemID = 224754, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Belt",      itemName = "Everforged Greatbelt",            itemID = 224418, sourceInfo = "Profession: Crafted"},
            {slot = "Legs",      itemName = "Living Weapon's Legguards",       itemID = 224751, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",    itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",      itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Signet of Collapsing Stars",      itemID = 193744, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Trinket 1", itemName = "Astral Antenna",                  itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Trinket 2", itemName = "Screams of a Forgotten Sky",      itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Weapon",    itemName = "Maw of the Void",                 itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
        }
    },
    ["Fury Warrior"] = {
        source = "Wowhead by Archimtiros",
        classSlug = "warrior",
        specSlug = "fury",
        items = {
            {slot = "Head",      itemName = "Bone-Melted Faceplate",           itemID = 224214, sourceInfo = "Manaforge Omega BoE Drop"},
            {slot = "Neck",      itemName = "Chrysalis of Sundered Souls",     itemID = 224197, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Shoulder",  itemName = "Living Weapon's Ramparts",        itemID = 224753, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Living Weapon's Bulwark",         itemID = 224749, sourceInfo = "Raid: Fractillus"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",            itemID = 224419, sourceInfo = "Profession: Crafted"},
            {slot = "Gloves",    itemName = "Living Weapon's Crushers",        itemID = 224754, sourceInfo = "Raid: Soulbinder Naazindhri"},
            {slot = "Belt",      itemName = "Living Weapon's Chain",           itemID = 224752, sourceInfo = "Catalyst"},
            {slot = "Legs",      itemName = "Living Weapon's Legguards",       itemID = 224751, sourceInfo = "Raid: Loom'ithar"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",    itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Radiant Necromancer's Band",      itemID = 224209, sourceInfo = "Dungeon: Priory of the Sacred Flame"},
            {slot = "Ring 2",    itemName = "Signet of the False Accuser",     itemID = 184717, sourceInfo = "Dungeon: Halls of Atonement"},
            {slot = "Trinket 1", itemName = "Eradicating Arcanocore",          itemID = 224219, sourceInfo = "Raid: Plexus Sentinel"},
            {slot = "Trinket 2", itemName = "Screams of a Forgotten Sky",      itemID = 224205, sourceInfo = "Raid: Dimensius"},
            {slot = "Main Hand", itemName = "Circuit Breaker",                 itemID = 186429, sourceInfo = "Dungeon: Operation: Floodgate"},
            {slot = "Off Hand",  itemName = "Everforged Greataxe",             itemID = 224413, sourceInfo = "Profession: Crafted"},
        }
    },
    ["Protection Warrior"] = {
        source = "Wowhead by Nomeratur",
        classSlug = "warrior",
        specSlug = "protection",
        items = {
            {slot = "Head",      itemName = "Living Weapon's Faceshield",      itemID = 224750, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Neck",      itemName = "Cabochon of the Infinite Flight", itemID = 193745, sourceInfo = "Dungeon: Tazavesh, So'leah's Gambit"},
            {slot = "Shoulder",  itemName = "Living Weapon's Ramparts",        itemID = 224753, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Cloak",     itemName = "Reshii Wraps",                    itemID = 224424, sourceInfo = "Patch 11.2 Questline"},
            {slot = "Chest",     itemName = "Experimental Goresilk Chestguard",itemID = 185100, sourceInfo = "Dungeon: Ara-Kara, City of Echoes"},
            {slot = "Wrist",     itemName = "Everforged Vambraces",            itemID = 224419, sourceInfo = "Profession: Crafting"},
            {slot = "Gloves",    itemName = "Living Weapon's Crushers",        itemID = 224754, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Belt",      itemName = "Everforged Greatbelt",            itemID = 224418, sourceInfo = "Profession: Crafting"},
            {slot = "Legs",      itemName = "Living Weapon's Legguards",       itemID = 224751, sourceInfo = "Catalyst | Raid | Vault"},
            {slot = "Boots",     itemName = "Interloper's Plated Sabatons",    itemID = 224384, sourceInfo = "Raid: The Soul Hunters"},
            {slot = "Ring 1",    itemName = "Band of the Shattered Soul",      itemID = 224206, sourceInfo = "Raid: Dimensius"},
            {slot = "Ring 2",    itemName = "Logic Gate: Omega",               itemID = 224217, sourceInfo = "Raid: Forgeweaver Araz"},
            {slot = "Weapon",    itemName = "Oath-Breaker's Recompense",       itemID = 224207, sourceInfo = "Raid: Nexus-King Salhadaar"},
            {slot = "Shield",    itemName = "Ward of the Weaving-Beast",       itemID = 224204, sourceInfo = "Raid: Loom'ithar"},
        }
    },
}

-- Helper function to fuzzy match specs
local specAliases = {
    -- Death Knight
    ["blood"] = "Blood Death Knight", ["bdk"] = "Blood Death Knight",
    ["frost dk"] = "Frost Death Knight", ["fdk"] = "Frost Death Knight",
    ["unholy"] = "Unholy Death Knight", ["uhdk"] = "Unholy Death Knight",
    -- Demon Hunter
    ["havoc"] = "Havoc Demon Hunter", ["hdh"] = "Havoc Demon Hunter",
    ["vengeance"] = "Vengeance Demon Hunter", ["vdh"] = "Vengeance Demon Hunter",
    -- Druid
    ["balance"] = "Balance Druid", ["boomkin"] = "Balance Druid",
    ["feral"] = "Feral Druid", ["cat"] = "Feral Druid",
    ["guardian"] = "Guardian Druid", ["bear"] = "Guardian Druid",
    ["resto druid"] = "Restoration Druid", ["rdruid"] = "Restoration Druid",
    -- Evoker
    ["devastation"] = "Devastation Evoker", ["dev"] = "Devastation Evoker",
    ["preservation"] = "Preservation Evoker", ["prev"] = "Preservation Evoker",
    ["augmentation"] = "Augmentation Evoker", ["aug"] = "Augmentation Evoker",
    -- Hunter
    ["bm"] = "Beast Mastery Hunter", ["beast mastery"] = "Beast Mastery Hunter",
    ["mm"] = "Marksmanship Hunter", ["marksmanship"] = "Marksmanship Hunter",
    ["sv"] = "Survival Hunter", ["survival"] = "Survival Hunter",
    -- Mage
    ["arcane"] = "Arcane Mage", ["fire"] = "Fire Mage", ["frost"] = "Frost Mage",
    -- Monk
    ["brew"] = "Brewmaster Monk", ["brewmaster"] = "Brewmaster Monk",
    ["mw"] = "Mistweaver Monk", ["mistweaver"] = "Mistweaver Monk",
    ["ww"] = "Windwalker Monk", ["windwalker"] = "Windwalker Monk",
    -- Paladin
    ["holy paladin"] = "Holy Paladin", ["hpal"] = "Holy Paladin",
    ["prot paladin"] = "Protection Paladin", ["protpal"] = "Protection Paladin",
    ["ret"] = "Retribution Paladin", ["retribution"] = "Retribution Paladin",
    -- Priest
    ["disc"] = "Discipline Priest", ["discipline"] = "Discipline Priest",
    ["holy priest"] = "Holy Priest", ["hpriest"] = "Holy Priest",
    ["shadow"] = "Shadow Priest", ["spriest"] = "Shadow Priest",
    -- Rogue
    ["ass"] = "Assassination Rogue", ["assassination"] = "Assassination Rogue",
    ["outlaw"] = "Outlaw Rogue",
    ["sub"] = "Subtlety Rogue", ["subtlety"] = "Subtlety Rogue",
    -- Shaman
    ["ele"] = "Elemental Shaman", ["elemental"] = "Elemental Shaman",
    ["enh"] = "Enhancement Shaman", ["enhancement"] = "Enhancement Shaman",
    ["rsham"] = "Restoration Shaman", ["resto shaman"] = "Restoration Shaman",
    -- Warlock
    ["aff"] = "Affliction Warlock", ["affliction"] = "Affliction Warlock",
    ["demo"] = "Demonology Warlock", ["demonology"] = "Demonology Warlock",
    ["destro"] = "Destruction Warlock", ["destruction"] = "Destruction Warlock",
    -- Warrior
    ["arms"] = "Arms Warrior", 
    ["fury"] = "Fury Warrior", 
    ["prot warrior"] = "Protection Warrior", ["protwar"] = "Protection Warrior",
}

--------------------------------------------------------------------------------
-- UI CREATION
--------------------------------------------------------------------------------

local BiSFrame = CreateFrame("Frame", "BiSFrame", UIParent, "BackdropTemplate")
BiSFrame:SetSize(400, 520)
BiSFrame:SetPoint("CENTER")
BiSFrame:SetMovable(true)
BiSFrame:EnableMouse(true)
BiSFrame:RegisterForDrag("LeftButton")
BiSFrame:SetScript("OnDragStart", BiSFrame.StartMoving)
BiSFrame:SetScript("OnDragStop", BiSFrame.StopMovingOrSizing)
BiSFrame:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
BiSFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
BiSFrame:Hide()

-- Title
local title = BiSFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -18)
title:SetText("BiS Displayer")

-- Close Button
local closeButton = CreateFrame("Button", nil, BiSFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -5, -5)

-- Source Info
local sourceText = BiSFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
sourceText:SetPoint("TOP", 0, -45)
sourceText:SetTextColor(0.7, 0.7, 0.7, 1)

-- Lines
local itemLines = {}
local MAX_LINES = 22

for i=1, MAX_LINES do
    local line = CreateFrame("Button", nil, BiSFrame)
    line:SetSize(350, 20)
    line:SetPoint("TOPLEFT", 25, -70 - ((i-1) * 20))
    
    local text = line:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetAllPoints(true)
    text:SetJustifyH("LEFT")
    line.text = text
    
    line:SetScript("OnEnter", function(self)
        if self.sourceInfo and self.sourceInfo ~= "" then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.sourceInfo, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    line:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Clicking links the item to chat if you want that functionality
    line:SetScript("OnClick", function(self)
        if self.itemLink and IsModifiedClick("CHATLINK") then
            ChatEdit_InsertLink(self.itemLink)
        end
    end)

    itemLines[i] = line
end

--------------------------------------------------------------------------------
-- LOGIC
--------------------------------------------------------------------------------

function addon:UpdatePlayerSpec()
    -- FIX: GetSpecialization returns an index (1,2,3), NOT the Global ID.
    local currentSpecIndex = GetSpecialization()
    if currentSpecIndex then
        local id, name = GetSpecializationInfo(currentSpecIndex)
        if id then
            playerSpecName = specIDMap[id]
        end
    else
        playerSpecName = nil
    end
end

function addon:UpdateDisplay(specName)
    -- Since we cut the data list for the response, make sure your full list is merged here
    -- In your real file, BiS_Lists needs to contain the full table you provided!
    local data = BiS_Lists[specName]
    
    if not data then 
        print(addonName .. ": No data found for " .. specName)
        return 
    end

    title:SetText("BiS List: " .. specName)
    sourceText:SetText("Source: " .. (data.source or "Unknown"))

    -- Cache equipped items
    local equippedItems = {}
    for i = 1, 19 do
        local itemID = GetInventoryItemID("player", i)
        if itemID then
            equippedItems[itemID] = true
        end
    end

    -- Reset lines
    for i=1, MAX_LINES do
        itemLines[i]:Hide()
        itemLines[i].sourceInfo = nil
        itemLines[i].itemLink = nil
    end

    if data.items then
        for i, itemData in ipairs(data.items) do
            if i <= MAX_LINES then
                local line = itemLines[i]
                line.sourceInfo = itemData.sourceInfo
                
                -- Determine color
                local color = "|cffa335ee" -- Purple (Epic) default
                if equippedItems[itemData.itemID] then
                    color = "|cff00ff00" -- Green (Equipped)
                    line.sourceInfo = (line.sourceInfo or "") .. " |cff00ff00(Equipped)|r"
                end
                
                -- Construct link string
                -- Note: Using the itemID directly creates a clickable link style string
                local linkString = string.format("%s: |Hitem:%d|h%s[%s]|r|h", 
                    itemData.slot, itemData.itemID, color, itemData.itemName)
                
                line.text:SetText(linkString)
                line.itemLink = string.format("item:%d", itemData.itemID) -- For chat linking
                line:Show()
            end
        end
    end

    BiSFrame:Show()
end

function addon:SlashCmdHandler(input)
    if not input or input:trim() == "" then
        -- Auto-detect
        addon:UpdatePlayerSpec()
        if playerSpecName and BiS_Lists[playerSpecName] then
            addon:UpdateDisplay(playerSpecName)
        else
            print(addonName .. ": Could not auto-detect spec or no list available. Try /bis [SpecName]")
        end
    else
        -- Manual Lookup
        local lookup = input:lower():trim()
        local mappedSpec = specAliases[lookup]
        
        -- Try to match keys in the main table if alias fails
        if not mappedSpec then
            for key, _ in pairs(BiS_Lists) do
                if key:lower() == lookup then
                    mappedSpec = key
                    break
                end
            end
        end

        if mappedSpec and BiS_Lists[mappedSpec] then
            addon:UpdateDisplay(mappedSpec)
        else
            print(addonName .. ": Could not find list for '" .. input .. "'.")
        end
    end
end

-- Event Handling
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
addon:SetScript("OnEvent", function(self, event, ...)
    self:UpdatePlayerSpec()
end)

-- Slash Commands
SLASH_BISDISPLAYER1 = "/bis"
SLASH_BISDISPLAYER2 = "/bestinslot"
SlashCmdList["BISDISPLAYER"] = function(msg) addon:SlashCmdHandler(msg) end

print("|cff00ff00" .. addonName .. " loaded!|r /bis to toggle.")