local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConsole = LibStub("AceConsole-3.0")

addon = AceAddon:NewAddon(addon, "AccentChat", "AceConsole-3.0")
addon.version = "3.0" 

local ON_TEXT, OFF_TEXT = "|cff00FF00ON|r", "|cffFF0000OFF|r"

function addon:OnInitialize()
    local dbDefaults = {
        char = {
            talkOn = true,
            strict = false,
            language = "Dwarf",
            channels = {
                SAY = true,
                YELL = false,
                EMOTE = false,
                PARTY = true,
                RAID = true,
                GUILD = true,
                OFFICER = true,
                INSTANCE_CHAT = true,
            },
        }
    }
    self.db = AceDB:New("AccentChatDB", dbDefaults, true)

    self:CreateSpeakDB()
    AceConfig:RegisterOptionsTable("AccentChat", self:GetOptions())
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("AccentChat", "Accent Chat")
    self:RegisterChatCommand("achat", "SlashCommandHandler")
    self:RegisterChatCommand("accentchat", "SlashCommandHandler")

    self:Print("AccentChat v" .. self.version .. " Loaded! Type |cffFFFFFF/achat|r to open the options.")
    
    local function OnEnterPressedHandler(editBox)
        local originalText = editBox:GetText()
        local chatType = editBox.chatType
        if not chatType then
            chatType = editBox:GetAttribute("chatType")
        end

        local translatedText = originalText

        if chatType then
            local charSettings = addon.db.char
            -- Fix: Force chatType to uppercase to ensure it matches our settings table.
            if (charSettings.talkOn and charSettings.channels[string.upper(chatType)] and originalText and originalText ~= "" and not string.find(originalText, "%[") and not string.find(originalText, "^/")) then
                translatedText = addon:Translate(originalText)
            end
        end
        
if translatedText:match("^%*.*%*$") then
            local emoteText = string.sub(translatedText, 2, -2) 
            SendChatMessage(emoteText, "EMOTE")
            editBox:SetText("") 
        elseif translatedText ~= originalText then
            editBox:SetText(translatedText)
        end
        
        ChatEdit_SendText(editBox, 1)
        editBox:SetText("")
        if not IsShiftKeyDown() then
            ChatEdit_DeactivateChat(editBox)
        end
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        if frame and frame.editBox then
            frame.editBox:SetScript("OnEnterPressed", OnEnterPressedHandler)
        end
    end
end

function addon:SlashCommandHandler(input)
    AceConfigDialog:Open("AccentChat")
end

function addon:GetEnabled()
    return self.db.char.talkOn
end

function addon:SetEnabled(info, value)
    self.db.char.talkOn = value
    self:Print("Accent Chat is now " .. (value and ON_TEXT or OFF_TEXT))
end

function addon:GetStrict()
    return self.db.char.strict
end

function addon:SetStrict(info, value)
    self.db.char.strict = value
    self:Print("Strict Mode is now " .. (value and ON_TEXT or OFF_TEXT))
end


function addon:GetAccentExample(lang_key)
    local db = self.speakDB[lang_key]
    if not db or not db.ReplaceDB or #db.ReplaceDB == 0 then return "" end

    local examples = {}
    
    for i = 1, math.min(2, #db.ReplaceDB) do
        local rule = db.ReplaceDB[i]
        if rule.o and rule.r and rule.o[1] ~= "%w+" then
            table.insert(examples, "|cffFFFFFF" .. rule.o[1] .. "|r -> |cff00FF00" .. rule.r[1] .. "|r")
        end
    end
    if #examples > 0 then
        return "e.g. " .. table.concat(examples, ", ")
    end
    return ""
end

function addon:GenerateAccentOptions()
    local accentArgs = {}
    local order = 10 
    local groups = {
        ["Dwarves"] = {"Dwarf", "DarkIronDwarf", "Earthen", "Wildhammer"},
        ["Trolls"] = {"Troll", "Zandalari"},
        ["Elves"] = {"NightElf", "BloodElf", "VoidElf", "DarnassianNightElf"},
        ["Humans & Cursed"] = {"KulTiran", "Worgen", "StormwindHuman"},
        ["Orcs & Goblins"] = {"Orc", "Goblin"},
        ["Orc Clans"] = {"FrostwolfOrc", "WarsongOrc", "BlackrockOrc", "ShatteredHandOrc", "IronHorde", "OrgrimmarOrc"},
        ["Other Horde Races"] = {"Tauren", "Forsaken", "Vulpera", "UndercityUndead"},
        ["Other Alliance Races"] = {"Gnome", "Mechagnome", "Draenei", "Lightforged"},
        ["Neutral Races"] = {"Pandaren", "Dracthyr"},
        ["Creatures & Humanoids"] = {"Arakkoa", "Dryad", "Ethereal", "Hozen", "Kobold", "Murloc", "Naga", "Ogre", "Quilboar", "Sethrak", "Tuskarr", "Vrykul"},
        ["Dragons"] = {"BronzeDragon", "RedDragon", "BlueDragon", "GreenDragon", "BlackDragonPurified", "BlackDragonCorrupt"},
        ["Other Factions"] = {"Defias", "ScarletCrusade", "TwilightsHammer", "VentureCo", "Syndicate", "Mogu", "ArgentCrusade", "KirinTor", "TheScourge", "CenarionCircle", "BurningLegion", "Bloodsail", "Steamwheedle"},
        ["Roleplaying Dialects"] = {"AdventureTime", "Pirate", "Prospector", "Purr", "Drunk", "Lisp", "Stutter", "Unstable", "Valiant", "Sinister", "Shy", "Scholarly"},    }
    local groupOrder = {"Dwarves", "Trolls", "Elves", "Humans & Cursed", "Orcs & Goblins", "Orc Clans", "Other Horde Races", "Other Alliance Races", "Neutral Races", "Creatures & Humanoids", "Dragons", "Other Factions", "Roleplaying Dialects"}

    for _, groupName in ipairs(groupOrder) do
        order = order + 1
        accentArgs[groupName .. "_header"] = {
            order = order,
            type = "header",
            name = groupName,
        }
        local accentKeys = groups[groupName]
        if accentKeys then
            table.sort(accentKeys)
            for _, lang_key in ipairs(accentKeys) do
                local lang_data = self.speakDB[lang_key]
                if lang_data then
                    order = order + 1
accentArgs[lang_key] = {
                        order = order,
                        type = "execute",
                        name = function()
                            if self.db.char.language == lang_key then
                                return "|cff00FF00" .. lang_data.name .. " [Active]|r"
                            else
                                return lang_data.name
                            end
                        end,
                        desc = function()
                            local description = lang_data.desc or ""
                            local example = self:GetAccentExample(lang_key)
                            
                            if description ~= "" and example ~= "" then
                                return "|cffFFFFFF" .. description .. "|r\n|cff999999" .. example .. "|r"
                            elseif description ~= "" then
                                return "|cffFFFFFF" .. description .. "|r"
                            else
                                return example
                            end
                        end,
                        func = function()
                            self.db.char.language = lang_key
                            self:Print("Accent set to |cffFFFFFF" .. lang_data.name .. "|r!")
                            AceConfigDialog:Open("AccentChat")
                        end,
                    }
                end
            end
        end
    end

    return accentArgs
end

-- Helper function to count words in a string
local function countWords(str)
    local count = 0
    if str then
        for _ in string.gmatch(str, "%S+") do
            count = count + 1
        end
    end
    return count
end

function addon:Translate(text)
    local lang = self.db.char.language
    local db = self.speakDB[lang]
    if not db then return text end

    local originalWordCount = countWords(text) -- Store the original word count

    text = self:sub_words(text, db)

    -- Exclamation logic: Only replaces actual "!" marks.
    if db.Exclamation and not self.db.char.strict then
        text = string.gsub(text, "!", db.Exclamation)
    end

    -- Randomly add prepend/append phrases
    -- Only apply if the original message was longer than one word.
    if originalWordCount > 1 then
        if (math.random(100) > 97) then
            text = self:append_phrase(text, db)
        end
        if (math.random(100) > 97) then
            text = self:prepend_phrase(text, db)
        end
    end
    
    return text
end

function addon:inject_phrase(inputString, db)
    if (#db.InjectDB > 0 and math.random(100) > 98 and not self.db.char.strict) then
        return db.InjectDB[math.random(#db.InjectDB)]
    end
    return inputString
end

function addon:sub_words(inputString, db)
    local sub_array = db.ReplaceDB
    local tempString = inputString .. " "

    tempString = string.gsub(tempString, "(%s)", function(s) return self:inject_phrase(s, db) end)

    for i = 1, #sub_array do
        local rule = sub_array[i]
        
        if rule.o[1] == "%w+" then
             tempString = string.gsub(tempString, "(%w+)", function(word)
                return rule.r[math.random(#rule.r)]
            end)
        else
            local replacement = rule.r[math.random(#rule.r)]
            for j = 1, #rule.o do
                local word_to_find = rule.o[j]
                
                tempString = string.gsub(tempString, "%f[%w_]" .. word_to_find .. "%f[%W_]", replacement)
                tempString = string.gsub(tempString, "%f[%w_]" .. word_to_find:gsub("^%l", string.upper) .. "%f[%W_]", replacement:gsub("^%l", string.upper))
                tempString = string.gsub(tempString, "%f[%w_]" .. word_to_find:upper() .. "%f[%W_]", replacement:upper())
            end
        end
    end
 
    return tempString:sub(1, -2)
end

function addon:prepend_phrase(inputString, db)
    if not self.db.char.strict and #db.PrependDB > 0 then
        inputString = db.PrependDB[math.random(#db.PrependDB)] .. inputString
    end
    return inputString
end

function addon:append_phrase(inputString, db)
    if not self.db.char.strict and #db.AppendDB > 0 then
        local phrase = db.AppendDB[math.random(#db.AppendDB)]
       
        local newString, matches = string.gsub(inputString, "([%.%!%?])", phrase .. "%1", 1)
        if matches > 0 then
            return newString
        else
            
            return inputString .. phrase
        end
    end
    return inputString
end

function addon:CreateSpeakDB()
    self.speakDB = {
        ["Catlike"] = { name = "Catlike", desc = "A playful, sometimes aloof dialect that extends 'r's into purrs and peppers speech with feline mannerisms.", PrependDB = { "*stretches lazily* ", "Mrreow... " }, AppendDB = { ", prrr.", ", nya?" }, InjectDB = { ", mrrr, " }, Exclamation = " Prrr!", ReplaceDB = { {o={"hello", "hi", "hey"}, r={"Mrreow?", "Meow."}}, {o={"goodbye", "bye"}, r={"*disappears silently*", "*trots away*"}}, {o={"yes"}, r={"Prrr..."}}, {o={"no"}, r={"Hsss..."}}, {o={"now"}, r={"Meeeow"}}, {o={"you"}, r={"mew"}}, {o={"what"}, r={"Mrow?"}}, {o={"are"}, r={"arrre"}}, {o={"for"}, r={"forrr"}}, {o={"your"}, r={"yourrr"}}, {o={"very"}, r={"verrry"}}, {o={"friend"}, r={"frrriend"}}, {o={"purr"}, r={"prrrrrrr"}}, {o={"sleep", "nap"}, r={"*curls up for a nap*"}}, {o={"food", "fish"}, r={"*eyes the meal hungrily*"}}, {o={"pet", "cuddle", "scratch"}, r={"*purrs and rubs against you*"}}, {o={"go away", "leave", "shoo"}, r={"*hisses and flattens ears*"}}, {o={"here", "come"}, r={"*trots over curiously*"}}, {o={"mine"}, r={"*pats it possessively*"}}, {o={"sorry"}, r={"*looks up with wide, apologetic eyes*"}}, {o={"thanks"}, r={"*gives a slow, thankful blink*"}} } },
        ["Dwarf"] = { name = "Dwarf", desc = "Speak with the stout confidence of an Ironforge mountaineer!", PrependDB = { "Aye, ", "By me beard, " }, AppendDB = { ", yeh hear?" }, InjectDB = { ", Ach, ", ", bah, " }, Exclamation = " Hah!", ReplaceDB = { {o={"hello", "hey"}, r={"Well met", "E'llo"}}, {o={"goodbye"}, r={"Fare thee well"}}, {o={"no"}, r={"nae"}}, {o={"not"}, r={"nae"}}, {o={"can't"}, r={"cannae"}}, {o={"don't"}, r={"dunnae"}}, {o={"yes"}, r={"aye"}}, {o={"the"}, r={"tha"}}, {o={"you"}, r={"ye"}}, {o={"your"}, r={"yer"}}, {o={"my"}, r={"me"}}, {o={"are"}, r={"be"}}, {o={"and"}, r={"an'"}}, {o={"to"}, r={"tae"}}, {o={"of"}, r={"o'"}}, {o={"little"}, r={"wee"}}, {o={"friend"}, r={"lad"}}, {o={"friends"}, r={"lads"}}, {o={"girl", "woman"}, r={"lass"}}, {o={"elf"}, r={"pointy-ear"}}, {o={"money", "coin"}, r={"riches", "coin"}}, {o={"ing"}, r={"in'"}}, {o={"good"}, r={"stout"}}, {o={"drink", "beer"}, r={"ale", "mead"}}, {o={"kill"}, r={"smash"}}, {o={"stone"}, r={"stone an' iron"}}, {o={"strong"}, r={"sturdy"}}, {o={"fight"}, r={"brawl"}}, {o={"family"}, r={"clan"}}, {o={"king"}, r={"Thane"}}, {o={"home"}, r={"hearth"}} } },
        ["Troll"] = { name = "Darkspear Troll", desc = "Embrace the laid-back, voodoo-tinged slang of the Darkspear tribe.", PrependDB = { "Hey mon, ", "Listen up, " }, AppendDB = { ", ya hear?", ", mon." }, InjectDB = { ", see? ", ", eh? " }, Exclamation = " Ya mon!", ReplaceDB = { {o={"hello", "hey"}, r={"Wha' gwaan"}}, {o={"goodbye"}, r={"Walk good"}}, {o={"the"}, r={"da"}}, {o={"them"}, r={"dem"}}, {o={"with"}, r={"wit"}}, {o={"you"}, r={"ya"}}, {o={"your"}, r={"ya"}}, {o={"are"}, r={"be"}}, {o={"i am"}, r={"I be"}}, {o={"of"}, r={"o'"}}, {o={"to"}, r={"ta"}}, {o={"what"}, r={"wha'"}}, {o={"that"}, r={"dat"}}, {o={"friend"}, r={"mon", "brudda"}}, {o={"is"}, r={"be"}}, {o={"it is"}, r={"it be"}}, {o={"ing"}, r={"in'"}}, {o={"this"}, r={"dis"}}, {o={"they"}, r={"dey"}}, {o={"there"}, r={"dere"}}, {o={"then"}, r={"den"}}, {o={"thing"}, r={"ting"}}, {o={"think"}, r={"tink"}}, {o={"three"}, r={"tree"}}, {o={"other"}, r={"odda"}}, {o={"father"}, r={"fadda"}}, {o={"mother"}, r={"mudda"}}, {o={"food"}, r={"grub"}}, {o={"spirit"}, r={"loa"}}, {o={"magic"}, r={"juju"}}, {o={"curse"}, r={"hex"}}, {o={"cool"}, r={"irie"}}, {o={"kill"}, r={"finish"}}, {o={"leader"}, r={"chief"}} } },
        ["Zandalari"] = { name = "Zandalari Troll", desc = "Proclaim your words with the ancient authority of the Zandalari Empire.", PrependDB = { "For Zandalar! ", "Listen closely, " }, AppendDB = { ". It is so.", ". Praise be to de Loa." }, InjectDB = { ", you see, ", ", child, " }, Exclamation = " Gold for de king!", ReplaceDB = { {o={"hello"}, r={"Jambo"}}, {o={"goodbye"}, r={"Stay away from da voodoo"}}, {o={"the"}, r={"de"}}, {o={"that"}, r={"dat"}}, {o={"them"}, r={"dem"}}, {o={"with"}, r={"wit"}}, {o={"you"}, r={"ya"}}, {o={"your"}, r={"ya"}}, {o={"friend"}, r={"honored one"}}, {o={"great"}, r={"divine"}}, {o={"is"}, r={"be"}}, {o={"are"}, r={"be"}}, {o={"what"}, r={"wha'"}}, {o={"to"}, r={"ta"}}, {o={"for"}, r={"for de"}}, {o={"ing"}, r={"in'"}}, {o={"this"}, r={"dis"}}, {o={"they"}, r={"dey"}}, {o={"there"}, r={"dere"}}, {o={"then"}, r={"den"}}, {o={"thing"}, r={"ting"}}, {o={"think"}, r={"tink"}}, {o={"three"}, r={"tree"}}, {o={"other"}, r={"odda"}}, {o={"power"}, r={"powah"}}, {o={"king"}, r={"King Rastakhan"}}, {o={"queen"}, r={"Queen Talanji"}}, {o={"city"}, r={"Dazar'alor"}}, {o={"holy"}, r={"sacred"}}, {o={"rich"}, r={"golden"}} } },
        ["Orc"] = { name = "Orc (General)", desc = "A direct, honor-bound dialect befitting a warrior of the Horde.", PrependDB = { "Hmph. ", "For the Horde! " }, AppendDB = { ". Lok'tar ogar!", ". Strength and honor." }, InjectDB = { ", grunts, ", ", hah, " }, Exclamation = " Zug zug.", ReplaceDB = { {o={"hello", "hi"}, r={"Greetings"}}, {o={"goodbye"}, r={"Go."}}, {o={"friend"}, r={"comrade"}}, {o={"battle"}, r={"war"}}, {o={"power"}, r={"strength"}}, {o={"weak"}, r={"pathetic"}}, {o={"elf"}, r={"knife-ear"}}, {o={"for"}, r={"for da"}}, {o={"kill"}, r={"destroy"}}, {o={"enemy"}, r={"foe"}}, {o={"strong"}, r={"mighty"}}, {o={"victory"}, r={"Lok'tar"}}, {o={"leader"}, r={"Warchief"}}, {o={"warrior"}, r={"grunt"}}, {o={"family"}, r={"clan"}} } },
        ["Forsaken"] = { name = "Forsaken", desc = "Adopt the grim, cynical, and morbid tone of a Lordaeron survivor.", PrependDB = { "What now? ", "Yes? " }, AppendDB = { ". Suffer well.", ". For the Dark Lady." }, InjectDB = { ", corpse, " }, Exclamation = " Heh.", ReplaceDB = { {o={"hello"}, r={"What is it you want?"}}, {o={"goodbye"}, r={"Begone."}}, {o={"life"}, r={"unlife"}}, {o={"friend"}, r={"acquaintance"}}, {o={"great"}, r={"tolerable"}}, {o={"love"}, r={"attachment"}}, {o={"hate"}, r={"despise"}}, {o={"happy"}, r={"not miserable"}}, {o={"beautiful"}, r={"preserved"}}, {o={"kill"}, r={"release"}}, {o={"death"}, r={"the final peace"}}, {o={"remember"}, r={"cannot forget"}}, {o={"pain"}, r={"our gift"}}, {o={"living"}, r={"breathers"}}, {o={"food"}, r={"pointless matter"}} } },
        ["Tauren"] = { name = "Tauren", desc = "Speak with the calm, spiritual wisdom of the Shu'halo people.", PrependDB = { "Peace, friend. ", "The winds guide us. " }, AppendDB = { ". May the Earth Mother guide you.", ". Walk with the Earth Mother." }, InjectDB = { ", friend, " }, Exclamation = " Ishne'alo por-ah.", ReplaceDB = { {o={"hello"}, r={"Peace"}}, {o={"goodbye"}, r={"Safe travels"}}, {o={"hurry"}, r={"patience"}}, {o={"fight"}, r={"challenge"}}, {o={"help"}, r={"aid"}}, {o={"city"}, r={"camp"}}, {o={"why"}, r={"For what purpose"}}, {o={"wise"}, r={"attuned"}}, {o={"strong"}, "mighty as a kodo"}, {o={"ancestors"}, r={"the spirits"}}, {o={"land"}, r={"the plains"}}, {o={"sun"}, r={"An'she"}}, {o={"moon"}, r={"Mu'sha"}} } },
        ["Gnome"] = { name = "Gnome", desc = "Employ the fantastically complex jargon of a Gnomeregan inventor.", PrependDB = { "Fascinating! ", "By my calculations, " }, AppendDB = { "! For Gnomeregan!", "! Stupendous!" }, InjectDB = { ", you see, ", ", theoretically, " }, Exclamation = " Excelsior!", ReplaceDB = { {o={"hello"}, r={"Greetings!", "Salutations!"}}, {o={"friend"}, r={"colleague"}}, {o={"great"}, r={"fantabulous"}}, {o={"make", "build"}, r={"construct", "fabricate"}}, {o={"idea"}, r={"hypothesis"}}, {o={"problem"}, r={"conundrum"}}, {o={"fix"}, r={"calibrate"}}, {o={"big"}, r={"prodigious"}}, {o={"look"}, r={"analyze"}}, {o={"wow"}, r={"By the cog!"}}, {o={"fast"}, r={"rapidly-actuated"}}, {o={"small"}, r={"compact"}}, {o={"weapon"}, r={"contraption"}}, {o={"magic"}, r={"arcane science"}} } },
        ["Goblin"] = { name = "Goblin", desc = "Talk like a fast-talking merchant where time is money and everything's for sale.", PrependDB = { "Alright, pal, ", "Here's the deal: " }, AppendDB = { ", ya get me?", ". Profit!" }, InjectDB = { ", see, ", ", pal, " }, Exclamation = " Heh!", ReplaceDB = { {o={"hello"}, r={"Whaddaya want?"}}, {o={"friend"}, r={"pal", "chief"}}, {o={"money", "gold"}, r={"moolah", "gelt"}}, {o={"a deal"}, r={"an opportunity"}}, {o={"great"}, r={"first-class"}}, {o={"bye"}, r={"Time is money!"}}, {o={"and"}, r={"'n'"}}, {o={"the"}, r={"da"}}, {o={"work"}, r={"hustle"}}, {o={"pay"}, r={"payout"}}, {o={"a favor"}, r={"a business proposition"}}, {o={"idea"}, r={"scheme"}}, {o={"contract"}, r={"a binding agreement"}}, {o={"expensive"}, r={"top-shelf"}}, {o={"cheap"}, r={"a steal"}}, {o={"danger"}, r={"a calculated risk"}} } },
        ["BloodElf"] = { name = "Blood Elf", desc = "Use the eloquent, yet arrogant and slightly disdainful, speech of Quel'Thalas.", PrependDB = { "Speak. ", "Yes? " }, AppendDB = { ". For Quel'Thalas!", ". Obviously." }, InjectDB = { ", I suppose, " }, Exclamation = " As it should be.", ReplaceDB = { {o={"hello"}, r={"What is it?"}}, {o={"thanks"}, r={"I am... grateful."}}, {o={"friend"}, r={"acquaintance"}}, {o={"magic"}, r={"the arcane"}}, {o={"great"}, r={"adequate"}}, {o={"goodbye"}, r={"Anu belore dela'na."}}, {o={"bad"}, r={"gauche"}}, {o={"good"}, r={"acceptable"}}, {o={"stupid"}, r={"pedestrian"}}, {o={"human"}, r={"brute"}}, {o={"orc"}, r={"savage"}}, {o={"perfect"}, r={"flawless"}}, {o={"sunwell"}, r={"our birthright"}}, {o={"remember"}, r={"never forget"}}, {o={"sad"}, r={"disappointing"}}, {o={"ugly"}, r={"tasteless"}} } },
        ["NightElf"] = { name = "Night Elf", desc = "Speak with the ancient, patient, and Elune-revering grace of the Kaldorei.", PrependDB = { "Elune-adore. ", "Well met. " }, AppendDB = { ". May Elune guide you.", ". For Teldrassil." }, InjectDB = { ", as it were, " }, Exclamation = " Indeed.", ReplaceDB = { {o={"hello", "hi", "hey"}, r={"Ishnu-alah"}}, {o={"goodbye", "bye"}, r={"Elune-adore", "Farewell"}}, {o={"thanks"}, r={"My thanks to you"}}, {o={"sun"}, r={"the lesser light"}}, {o={"night"}, r={"the blessed darkness"}}, {o={"goddess"}, r={"Elune"}}, {o={"our people", "night elves"}, r={"the Kaldorei"}}, {o={"forest"}, r={"sacred grove"}}, {o={"demon"}, r={"traitor"}}, {o={"ancient"}, r={"ageless"}}, {o={"sleep"}, r={"rest in the Dream"}} } },
        ["DarnassianNightElf"] = { name = "Darnassian Night Elf", desc = "The traditional, formal speech of a Teldrassil Sentinel or Priestess.", PrependDB = { "The stars guide us. ", "By Elune's light, " }, AppendDB = { ". For Teldrassil!", ". May the moonlight protect you." }, InjectDB = { ", my friend, " }, Exclamation = " For the Night Warrior!", ReplaceDB = { {o={"hello", "hi", "hey"}, r={"Ishnu-dal-dieb"}}, {o={"goodbye", "bye"}, r={"Tor ilisar'thera'nal"}}, {o={"thanks"}, r={"My deepest thanks"}}, {o={"friend"}, r={"sister", "brother"}}, {o={"yes"}, r={"Indeed"}}, {o={"no"}, r={"Nay"}}, {o={"help"}, r={"aid"}}, {o={"fight", "battle"}, r={"stand as one", "the coming battle"}}, {o={"enemy"}, r={"foe", "servant of the shadows"}}, {o={"magic"}, r={"the arcane arts"}}, {o={"home"}, r={"our sacred boughs", "Teldrassil"}}, {o={"high elves", "blood elves"}, r={"the Highborne", "the quel'dorei", "the sin'dorei"}} } },
        ["Worgen"] = { name = "Worgen (Gilnean)", desc = "A gruff, street-smart Gilnean dialect, hiding a feral beast within.", PrependDB = { "Right then, ", "Blimey, " }, AppendDB = { ", innit?", ", right." }, InjectDB = { ", see, ", ", mate, " }, Exclamation = " Cheers.", ReplaceDB = { {o={"hello"}, r={"Hullo", "Alright?"}},{o={"angry", "mad"}, r={"bestial", "furious"}}, {o={"run"}, r={"give chase"}}, {o={"smell"}, r={"catch the scent"}}, {o={"home"}, r={"den"}}, {o={"fight"}, r={"the hunt"}}, {o={"friend"}, r={"mate", "guv'nah"}}, {o={"my"}, r={"me"}}, {o={"great"}, r={"brilliant"}}, {o={"goodbye"}, r={"Right then", "Cheers"}}, {o={"very"}, r={"bloody"}}, {o={"stupid"}, r={"daft"}}, {o={"thanks"}, r={"ta"}}, {o={"tired"}, r={"knackered"}}, {o={"beast"}, r={"the rage within"}}, {o={"wild"}, r={"feral"}}, {o={"gentleman"}, r={"chap"}}, {o={"fast"}, r={"with haste"}}, {o={"control"}, r={"restraint"}} } },
        ["Draenei"] = { name = "Draenei", desc = "Adopt the distinct accent of the noble, Light-fearing Draenei from Argus.", PrependDB = { "Greetings. ", "By the Light, " }, AppendDB = { ". The Light is with you.", ". Vindicator." }, InjectDB = {}, Exclamation = " Indeed.", ReplaceDB = { {o={"what"}, r={"vat"}}, {o={"we"}, r={"ve"}}, {o={"very"}, r={"very much"}}, {o={"beautiful"}, r={"divine"}}, {o={"evil"}, r={"darkness"}}, {o={"promise"}, r={"vow"}}, {o={"ship"}, r={"vessel"}}, {o={"will"}, r={"vill"}}, {o={"with"}, r={"vith"}}, {o={"was"}, r={"vas"}}, {o={"want"}, r={"vant"}}, {o={"world"}, r={"vorld"}}, {o={"when"}, r={"ven"}}, {o={"where"}, r={"vere"}}, {o={"one"}, r={"van"}}, {o={"the"}, r={"ze"}}, {o={"hello"}, r={"I greet you"}}, {o={"goodbye"}, r={"The Light guide you"}}, {o={"prophet"}, r={"Velen"}}, {o={"light"}, r={"the Holy Light"}}, {o={"demon"}, r={"man'ari"}}, {o={"home"}, r={"Argus"}}, {o={"safe"}, r={"blessed"}} } },
        ["Pandaren"] = { name = "Pandaren", desc = "A balanced and thoughtful way of speaking, often using parables and proverbs.", PrependDB = { "Greetings, friend. ", "Let us pause. " }, AppendDB = { ", for balance must be preserved.", ". As the river flows." }, InjectDB = { ", friend, ", ", slow down, " }, Exclamation = " Well said.", ReplaceDB = { {o={"hello"}, r={"Greetings"}}, {o={"bye"}, r={"Be well"}}, {o={"friend"}, r={"traveler"}}, {o={"drink"}, r={"brew"}}, {o={"food"}, r={"meal"}}, {o={"hurry"}, r={"patience"}}, {o={"great"}, r={"a fine choice"}}, {o={"think"}, r={"meditate on"}}, {o={"problem"}, r={"a crooked path"}}, {o={"angry"}, r={"impatient"}}, {o={"slow"}, r={"deliberate"}}, {o={"fast"}, r={"hasty"}}, {o={"lesson"}, r={"parable"}}, {o={"teach"}, r={"show the way"}}, {o={"bad"}, r={"unbalanced"}} } },
        ["Ethereal"] = { name = "Ethereal", desc = "A cryptic, business-like tone where all things are a transaction.", PrependDB = { "Greetings... " }, AppendDB = { "... it is profitable.", "... such is the nature of the energy." }, InjectDB = { "... hmmm... " }, Exclamation = " ...fascinating.", ReplaceDB = { {o={"hello"}, r={"An interesting development..."}}, {o={"money", "gold"}, r={"energy", "currency"}}, {o={"friend"}, r={"entity", "client"}}, {o={"life"}, r={"form"}}, {o={"goodbye"}, r={"A successful transaction."}}, {o={"buy"}, r={"acquire"}}, {o={"sell"}, r={"liquidate"}}, {o={"people"}, r={"organics"}}, {o={"body"}, r={"corporeal form"}}, {o={"find"}, r={"procure"}}, {o={"rare"}, r={"exotic"}}, {o={"business"}, r={"the transaction"}}, {o={"world"}, r={"dimension"}} } },
        ["Arakkoa"] = { name = "Arakkoa (Outcast)", desc = "The pained, rasping squawks of a cursed, wingless Arakkoa.", PrependDB = { "Skraw! ", "The sun... it burns... " }, AppendDB = { ", kraw!", ". Cursed... cursed!" }, InjectDB = { ", kaaaw, " }, Exclamation = " Skree!", ReplaceDB = { {o={"sun"}, r={"suuun"}}, {o={"curse"}, r={"cuuurse"}}, {o={"i"}, r={"I... I..."}}, {o={"hello"}, r={"What is it you want from us?"}}, {o={"shadows"}, r={"shaaadows"}}, {o={"light"}, r={"blinding light"}}, {o={"fly"}, r={"fall"}}, {o={"king"}, r={"Talon King"}}, {o={"fly"}, r={"soar"}}, {o={"high"}, r={"to the sky"}} } },
        ["Hozen"] = { name = "Hozen", desc = "The crude, aggressive, and simplistic chatter of a typical Hozen.", PrependDB = { "Ook in the dooker! ", "Listen up, ya bananabreath! " }, AppendDB = { "! OOK!", ". Gonna ook ya in the dooker." }, InjectDB = { ", ook, " }, Exclamation = " OOK!", ReplaceDB = { {o={"why"}, r={"whook"}}, {o={"what"}, r={"wook"}}, {o={"you"}, r={"ya"}}, {o={"the"}, r={"da"}}, {o={"friend"}, r={"chum-chum"}}, {o={"ing"}, r={"in'"}}, {o={"fight"}, r={"dook it out"}}, {o={"eat"}, r={"grook"}}, {o={"go"}, r={"ook off"}} } },
        ["Ogre"] = { name = "Ogre", desc = "The simple, often confused, and direct speech of a two-headed ogre.", PrependDB = { "Me busy. ", "Huh? " }, AppendDB = { ". Me smart.", ". Time for smash." }, InjectDB = {}, Exclamation = " Dabu!", ReplaceDB = { {o={"i am"}, r={"me be"}}, {o={"i"}, r={"me"}}, {o={"my"}, r={"me"}}, {o={"you"}, r={"you"}}, {o={"the"}, r={"da"}}, {o={"to"}, r={"ta"}}, {o={"hello"}, r={"Me say hi."}}, {o={"goodbye"}, r={"Me go now."}}, {o={"kill"}, r={"smash"}}, {o={"are"}, r={"be"}} } },
        ["Kobold"] = { name = "Kobold", desc = "You no take this accent! A simple, frantic speech about candles and digging.", PrependDB = { "You no take candle! ", "Me busy digging! " }, AppendDB = { ", yes, yes!", ", more candle!" }, InjectDB = {}, Exclamation = " Candle!", ReplaceDB = { {o={"my"}, r={"me"}}, {o={"mine"}, r={"me"}}, {o={"i"}, r={"me"}}, {o={"give"}, r={"take"}}, {o={"take"}, r={"no take"}}, {o={"hello"}, r={"You want candle?"}}, {o={"gold", "gem"}, r={"shiny"}}, {o={"light"}, r={"candle-fire"}}, {o={"dark"}, r={"no candle!"}}, {o={"want"}, r={"need"}} } },
        ["Vrykul"] = { name = "Vrykul", desc = "The booming, boastful, and Norse-inspired talk of a Northrend giant.", PrependDB = { "Speak, smallfolk! ", "By the seas! " }, AppendDB = { "! To glory!", "! For the Dragonflayer!" }, InjectDB = { ", hah! ", ", bah! " }, Exclamation = " Skål!", ReplaceDB = { {o={"hello"}, r={"What do you want?"}}, {o={"battle"}, r={"glorious combat"}}, {o={"ship"}, r={"longship"}}, {o={"death"}, r={"a worthy end"}}, {o={"friend"}, r={"ally"}}, {o={"strong"}, r={"mighty"}}, {o={"weak"}, r={"puny"}}, {o={"woman"}, r={"shield-maiden"}}, {o={"king"}, r={"Ymiron"}}, {o={"boat"}, r={"longboat"}}, {o={"hall"}, r={"mead hall"}}, {o={"cold"}, r={"frost-rimed"}}, {o={"worthy"}, r={"proven"}} } },
        ["Sethrak"] = { name = "Sethrak", desc = "A sibilant, hissing dialect, full of drawn-out 's' sounds.", PrependDB = { "Yesss? ", "Ssspeak... " }, AppendDB = { "...yesss.", ". For Sethraliss." }, InjectDB = { "...hmmmss..." }, Exclamation = " Hahss!", ReplaceDB = { {o={"s"}, r={"ss"}}, {o={"yes"}, r={"yesss"}}, {o={"is"}, r={"isss"}}, {o={"this"}, r={"thisss"}}, {o={"hello"}, r={"Greetingsss"}}, {o={"friend"}, r={"friend"}}, {o={"so"}, r={"sso"}}, {o={"see"}, r={"ssee"}}, {o={"us"}, r={"uss"}}, {o={"magic"}, r={"faith"}}, {o={"powerful"}, r={"potent"}} } },
        ["Mechagnome"] = { name = "Mechagnome", desc = "A purely logical, robotic pattern of speech focused on efficiency.", PrependDB = { "Initiating communication. ", "Processing... ", "Statement: " }, AppendDB = { ". Logic dictates.", ". End of line.", ". Calculation complete." }, InjectDB = { ", logically, ", ", by design, " }, Exclamation = " Efficiency!", ReplaceDB = { {o={"my"}, r={"my internal chronometer"}}, {o={"i think"}, r={"my analysis indicates"}}, {o={"idea"}, r={"schematic"}}, {o={"body"}, r={"chassis"}}, {o={"heart"}, r={"power core"}}, {o={"great"}, r={"optimal"}}, {o={"hello"}, r={"State your purpose."}}, {o={"goodbye"}, r={"Terminating transmission."}}, {o={"feel"}, r={"compute"}}, {o={"want"}, r={"require"}}, {o={"people"}, r={"organics"}}, {o={"food"}, r={"bio-fuel"}} } },
        ["Vulpera"] = { name = "Vulpera", desc = "The friendly, practical, and resourceful speech of a desert nomad.", PrependDB = { "Listen close, ", "Okay, so, " }, AppendDB = { ", yep yep.", ", got it?" }, InjectDB = { ", ya know, ", ", and then, " }, Exclamation = " All set!", ReplaceDB = { {o={"hello"}, r={"Hey there."}}, {o={"goodbye"}, r={"Safe travels!"}}, {o={"everything"}, r={"the whole cart"}}, {o={"good"}, r={"useful"}}, {o={"bad"}, r={"junk"}}, {o={"money"}, r={"baubles"}}, {o={"things"}, r={"trinkets"}}, {o={"find"}, r={"scavenge"}}, {o={"danger"}, r={"trouble"}} } },
        ["KulTiran"] = { name = "Kul Tiran", desc = "The hearty, nautical slang of a hardy Kul Tiran sailor.", PrependDB = { "Well now, ", "By the tides, " }, AppendDB = { ", see?", ". Mark my words." }, InjectDB = { ", ain't that right, ", ", mind you, " }, Exclamation = " Anchors away!", ReplaceDB = { {o={"hello"}, r={"Ahoy.", "Fair winds."}}, {o={"goodbye"}, r={"Tide's out."}}, {o={"friend"}, r={"matey", "shipmate"}}, {o={"woman"}, r={"maiden"}}, {o={"man"}, r={"chap"}}, {o={"money"}, r={"doubloons"}}, {o={"fight"}, r={"brawl"}}, {o={"yes"}, r={"aye aye"}}, {o={"no"}, r={"belay that"}}, {o={"go"}, r={"set sail"}}, {o={"leave"}, r={"weigh anchor"}}, {o={"ocean", "sea"}, r={"the brine"}}, {o={"big", "large"}, r={"kraken-sized"}}, {o={"monster"}, r={"beastie"}}, {o={"drink"}, r={"swig"}}, {o={"good"}, r={"shipshape"}} } },
        ["DarkIronDwarf"] = { name = "Dark Iron Dwarf", desc = "The gruff, fiery, and grudge-holding tone of a Shadowforge City native.", PrependDB = { "Hah! ", "By the Core, " }, AppendDB = { ", ya fool.", ". For the mountain!" }, InjectDB = { ", bah, ", ", mark me, " }, Exclamation = " For Moira!", ReplaceDB = { {o={"friend"}, r={"clansman"}}, {o={"hello"}, r={"What is it?"}}, {o={"goodbye"}, r={"Get on with it."}}, {o={"money"}, r={"minerals", "ore"}}, {o={"good"}, r={"forged"}}, {o={"bad"}, r={"slag"}}, {o={"fire"}, r={"flame"}}, {o={"no"}, r={"nae"}}, {o={"not"}, r={"nae"}}, {o={"can't"}, r={"cannae"}}, {o={"don't"}, r={"dunnae"}}, {o={"yes"}, r={"aye"}}, {o={"the"}, r={"tha"}}, {o={"you"}, r={"ye"}}, {o={"your"}, r={"yer"}}, {o={"my"}, r={"me"}}, {o={"are"}, r={"be"}}, {o={"and"}, r={"an'"}}, {o={"to"}, r={"tae"}}, {o={"of"}, r={"o'"}}, {o={"little"}, r={"wee"}}, {o={"ing"}, r={"in'"}}, {o={"water"}, r={"grog"}}, {o={"make"}, r={"forge"}}, {o={"enemy"}, r={"rival"}}, {o={"revenge"}, r={"settling a grudge"}}, {o={"hot"}, r={"magma-hot"}}, {o={"machine"}, r={"mole machine"}}, {o={"king"}, r={"Dagran"}} } },
        ["Lightforged"] = { name = "Lightforged Draenei", desc = "A zealous, pious dialect devoted to the Naaru and the Army of the Light.", PrependDB = { "By the eternal Light, ", "The Naaru have ordained it. " }, AppendDB = { ". The Light will prevail.", ". It is our charge." }, InjectDB = { ", as the Light wills, " }, Exclamation = " For the Army of the Light!", ReplaceDB = { {o={"dark"}, r={"shadows"}}, {o={"evil"}, r={"the Legion's filth"}}, {o={"hope"}, r={"the Light's path"}}, {o={"hello"}, r={"The Light embrace you."}}, {o={"goodbye"}, r={"Walk in the Light."}}, {o={"great"}, r={"righteous"}}, {o={"fight"}, r={"crusade"}}, {o={"victory"}, r={"the Light's triumph"}}, {o={"enemy"}, r={"heretic"}}, {o={"battle"}, r={"holy crusade"}}, {o={"pure"}, r={"sanctified"}}, {o={"darkness"}, r={"the Shadow"}}, {o={"unworthy"}, r={"heretical"}} } },
        ["VoidElf"] = { name = "Void Elf", desc = "Speak with the haunting, whisper-touched resonance of one who has embraced the Void.", PrependDB = { "The whispers say... ", "Embrace the shadow. " }, AppendDB = { "... or so it seems.", ". The Void sees all." }, InjectDB = { "... can you hear them? ...", "... in the shadows... " }, Exclamation = " The hunger grows.", ReplaceDB = { {o={"light"}, r={"fleeting glare"}}, {o={"power"}, r={"forbidden power"}}, {o={"mind"}, r={"psyche"}}, {o={"truth"}, r={"a fleeting glimpse"}}, {o={"know"}, r={"sense the patterns"}}, {o={"hope"}, r={"delusion"}}, {o={"think"}, r={"feel the whispers"}}, {o={"hello"}, r={"Greetings."}}, {o={"goodbye"}, r={"Mind the shadows."}}, {o={"friend"}, r={"shadow-walker"}}, {o={"knowledge"}, r={"secrets"}}, {o={"see"}, r={"perceive"}}, {o={"hear"}, r={"the whispers tell"}}, {o={"sanity"}, r={"a fragile thing"}}, {o={"madness"}, r={"clarity"}}, {o={"shadow"}, r={"the Void"}}, {o={"safe"}, r={"tenuous"}} } },
        ["Dracthyr"] = { name = "Dracthyr", desc = "The formal, curious, and draconic speech of the Dragon Isles' newest arrivals.", PrependDB = { "Indeed. ", "It is curious. " }, AppendDB = { ". We are one.", ". For the Dragon Isles." }, InjectDB = { ", as a dragon would say, " }, Exclamation = " By the Aspects!", ReplaceDB = { {o={"hello"}, r={"A pleasure to meet you."}}, {o={"goodbye"}, r={"Fly true."}}, {o={"friend"}, r={"wyrmling", "ally"}}, {o={"i think"}, r={"My instincts tell me"}}, {o={"interesting"}, r={"curious"}}, {o={"people"}, r={"mortals"}}, {o={"why"}, r={"for what reason"}}, {o={"old"}, r={"ancient"}}, {o={"family"}, r={"creche"}}, {o={"leader"}, r={"Scalecommander"}}, {o={"promise"}, r={"oath"}}, {o={"fly"}, r={"take to the skies"}} } },
        ["Earthen"] = { name = "Earthen", desc = "A logical and orderly way of speaking, befitting a Titan-forged being.", PrependDB = { "As the Titans decreed, ", "By the stone... ", "It is only logical. " }, AppendDB = { ". Solid as the mountain.", ". The schema is clear." }, InjectDB = { ", you see, ", ", as per the design, " }, Exclamation = " Fascinating.", ReplaceDB = { {o={"hello"}, r={"Well met."}}, {o={"goodbye"}, r={"Farewell."}}, {o={"friend"}, r={"construct", "ally"}}, {o={"body"}, r={"form"}}, {o={"heart"}, r={"core"}}, {o={"idea"}, r={"calculation"}}, {o={"bad"}, r={"flawed"}}, {o={"good"}, r={"ordered"}}, {o={"world"}, r={"system"}}, {o={"sleep"}, r={"enter stasis"}}, {o={"work"}, r={"task"}}, {o={"remember"}, r={"recall"}} } },
        ["Naga"] = { name = "Naga", desc = "The sinister, hissing speech of Queen Azshara's amphibious followers.", PrependDB = { "By the Tides... ", "For the Queen! " }, AppendDB = { ", for Azshara.", "... you will drown." }, InjectDB = { ", as the currents shift, " }, Exclamation = " To the depths!", ReplaceDB = { {o={"hello"}, r={"What is it, surface-dweller?"}}, {o={"goodbye"}, r={"Begone."}}, {o={"friend"}, r={"minion"}}, {o={"land"}, r={"the dry wastes"}}, {o={"water"}, r={"the depths"}}, {o={"magic"}, r={"the tides' power"}}, {o={"kill"}, r={"drown", "crush"}}, {o={"yes"}, r={"As the Queen wills."}}, {o={"s"}, r={"ss"}}, {o={"queen"}, r={"Azshara"}}, {o={"power"}, r={"the Tidelord's might"}}, {o={"land-dweller"}, r={"surface-dweller"}}, {o={"hiss"}, r={"sspeak"}} } },
        ["Tuskarr"] = { name = "Tuskarr", desc = "The friendly, neighborly, and fishing-obsessed talk of a Northrend native.", PrependDB = { "Well now, ", "Have a seat by the fire! " }, AppendDB = { ", eh?", ", and that's the way of it." }, InjectDB = { ", ya know, " }, Exclamation = " A great catch!", ReplaceDB = { {o={"hello"}, r={"Good day to you!", "Well met!"}}, {o={"goodbye"}, r={"May your nets be full."}}, {o={"friend"}, r={"neighbor"}}, {o={"story"}, r={"a good yarn"}}, {o={"fish"}, r={"a fine catch"}}, {o={"great"}, r={"a real trophy"}}, {o={"food"}, r={"a warm soup"}}, {o={"cold"}, r={"a whisker-freezer"}}, {o={"family"}, r={"our village"}}, {o={"boat"}, r={"kayak"}} } },
        ["Dryad"] = { name = "Dryad", desc = "The playful, giggling, and nature-loving speech of a child of Cenarius.", PrependDB = { "*giggles* ", "The forest stirs... " }, AppendDB = { ", little one.", ", as the leaves fall." }, InjectDB = { ", tee-hee, " }, Exclamation = " For the Wild!", ReplaceDB = { {o={"hello"}, r={"Greetings!"}}, {o={"goodbye"}, r={"Be well."}}, {o={"friend"}, r={"fawn"}}, {o={"laugh"}, r={"giggle"}}, {o={"sad"}, r={"wilting"}}, {o={"happy"}, r={"in bloom"}} } },
        ["RedDragon"] = { name = "Red Dragonflight", desc = "A vibrant, hopeful dialect focused on the preservation of all life.", PrependDB = { "By the grace of the Life-Binder... ", "The flame of life... " }, AppendDB = { ". Life is a gift.", ". All life must be preserved." }, InjectDB = { ", mortal, " }, Exclamation = " For the Life-Binder!", ReplaceDB = { {o={"hello"}, r={"Life bless you."}}, {o={"goodbye"}, r={"May the flame of life burn brightly."}}, {o={"help"}, r={"protect"}}, {o={"friend"}, r={"ally"}}, {o={"great"}, r={"vibrant"}}, {o={"kill"}, r={"cleanse"}}, {o={"hope"}, r={"the promise of a new dawn"}} } },
        ["BlueDragon"] = { name = "Blue Dragonflight", desc = "A logical, calculated, and academic tone obsessed with arcane energies.", PrependDB = { "The weave flows... ", "Observe... " }, AppendDB = { ". The outcome was logical.", ". Such is the nature of the arcane." }, InjectDB = { ", by my calculations, " }, Exclamation = " Fascinating!", ReplaceDB = { {o={"hello"}, r={"State your purpose."}}, {o={"goodbye"}, r={"The Nexus awaits."}}, {o={"magic"}, r={"the weave"}}, {o={"problem"}, r={"a dissonance"}}, {o={"fix"}, r={"realign"}}, {o={"power"}, r={"raw energy"}}, {o={"i think"}, r={"My analysis suggests"}} } },
        ["GreenDragon"] = { name = "Green Dragonflight", desc = "A sleepy, dream-like manner of speaking from a guardian of the Emerald Dream.", PrependDB = { "The Dream guides... ", "In slumber... " }, AppendDB = { ". As it was in the Dream.", ". The nightmare fades." }, InjectDB = { ", little dreamer, " }, Exclamation = " To the Dream!", ReplaceDB = { {o={"hello"}, r={"You walk in the waking world."}}, {o={"goodbye"}, r={"Sweet dreams."}}, {o={"understand"}, r={"awaken to the truth"}}, {o={"friend"}, r={"dreamer"}}, {o={"problem"}, r={"a nightmare's corruption"}}, {o={"sleep"}, r={"enter the Dream"}}, {o={"world"}, r={"the waking world"}} } },
        ["BronzeDragon"] = { name = "Bronze Dragonflight", desc = "A confusing, time-bending speech pattern from a protector of the timeways.", PrependDB = { "The timeways... ", "What will be, was... " }, AppendDB = { ". As I have foreseen.", ". Such is the proper path." }, InjectDB = { ", in this moment, ", ", or was it then? " }, Exclamation = " Anomaly!", ReplaceDB = { {o={"now"}, r={"this point in time"}}, {o={"before"}, r={"as it once was"}}, {o={"after"}, r={"what is to come"}}, {o={"friend"}, r={"mortal"}}, {o={"i think"}, r={"I believe this is the moment"}}, {o={"hello"}, r={"We meet... or have met."}}, {o={"goodbye"}, r={"Until next... or last time."}} } },
        ["BlackDragonPurified"] = { name = "Black Dragonflight (Purified)", desc = "The patient, calculating, and earth-bound speech of Wrathion's agents.", PrependDB = { "The earth is patient. ", "Observe and reflect. " }, AppendDB = { ". Strength is in the waiting.", ". Do not be hasty." }, InjectDB = { ", mortal, " }, Exclamation = " For the future of the flight!", ReplaceDB = { {o={"hello"}, r={"Speak your business."}}, {o={"goodbye"}, r={"Tread carefully."}}, {o={"friend"}, r={"agent", "ally"}}, {o={"strong"}, r={"unyielding as stone"}}, {o={"plan"}, r={"stratagem"}}, {o={"secret"}, r={"a necessary confidence"}} } },
        ["BlackDragonCorrupt"] = { name = "Black Dragonflight (Corrupt)", desc = "The megalomaniacal, world-shattering proclamations of a corrupt Black Dragon.", PrependDB = { "Your world will break! ", "Feel the agony! " }, AppendDB = { "! I AM POWER INCARNATE!", "! All will burn!" }, InjectDB = { ", fool, " }, Exclamation = " Shatter!", ReplaceDB = { {o={"hello"}, r={"What do you want, insect?"}}, {o={"goodbye"}, r={"Burn."}}, {o={"world"}, r={"your fragile world"}}, {o={"break"}, r={"shatter"}}, {o={"power"}, r={"DOMINION"}}, {o={"destroy"}, r={"obliterate"}}, {o={"friend"}, r={"pawn"}} } },
        ["FrostwolfOrc"] = { name = "Frostwolf Orc", desc = "The honorable, shamanistic speech of the Frostwolf Clan.", PrependDB = { "The spirits are with us. ", "For Frost and Flame! " }, AppendDB = { ". By the honor of our ancestors.", ". For Durotar." }, InjectDB = { ", brother, " }, Exclamation = " Lok'tar!", ReplaceDB = { {o={"hello"}, r={"Greetings."}}, {o={"goodbye"}, r={"May the spirits guide you."}}, {o={"friend"}, r={"brother", "sister"}}, {o={"help"}, r={"aid"}}, {o={"leader"}, r={"chieftain"}}, {o={"honor"}, r={"our honor"}} } },
        ["WarsongOrc"] = { name = "Warsong Orc", desc = "The aggressive, battle-hungry war cries of the Warsong Clan.", PrependDB = { "For the Warsong! ", "A battle awaits! " }, AppendDB = { "! For Hellscream!", "! Blood and thunder!" }, InjectDB = { ", hah!, " }, Exclamation = " WAAAAAGH!", ReplaceDB = { {o={"hello"}, r={"You seek the Warsong?"}}, {o={"goodbye"}, r={"Victory or death!"}}, {o={"fight"}, r={"battle"}}, {o={"peace"}, r={"a moment to re-arm"}}, {o={"weak"}, r={"coward"}}, {o={"strong"}, r={"a true warrior"}} } },
        ["BlackrockOrc"] = { name = "Blackrock Orc", desc = "A harsh, industrial dialect focused on iron, steel, and the forge.", PrependDB = { "Iron and steel. ", "State your purpose. " }, AppendDB = { ". By hammer and forge.", ". For the Blackrock." }, InjectDB = { ", by my calculations, " }, Exclamation = " Forged in black rock!", ReplaceDB = { {o={"hello"}, r={"What is it?"}}, {o={"goodbye"}, r={"Dismissed."}}, {o={"make"}, r={"forge"}}, {o={"build"}, r={"forge"}}, {o={"strong"}, r={"iron-hard"}}, {o={"plan"}, r={"battle plan"}}, {o={"work"}, r={"labor"}}, {o={"fire"}, r={"slag"}} } },
        ["ShatteredHandOrc"] = { name = "Shattered Hand Orc", desc = "The grim, shadowy whispers of a deadly orc assassin.", PrependDB = { "Blood and steel! ", "The hunt is on! " }, AppendDB = { ". For the Horde!", ". Victory is ours!" }, InjectDB = { ", warrior, " }, Exclamation = " For Grommash!", ReplaceDB = { {o={"hello"}, r={"What do you want?"}}, {o={"goodbye"}, r={"May your blade stay sharp."}}, {o={"fight"}, r={"battle"}}, {o={"enemy"}, r={"prey"}}, {o={"blood"}, r={"the lifeblood"}}, {o={"strong"}, r={"unyielding"}}, {o={"weak"}, r={"coward"}} } },
        ["StormwindHuman"] = { name = "Stormwind Human", desc = "The proud, honorable, and straightforward speech of a citizen of Stormwind.", PrependDB = { "Greetings, citizen. ", "By the Light, " }, AppendDB = { ". For the Alliance!", ". Justice will prevail." }, InjectDB = { ", my friend, " }, Exclamation = " For Stormwind!", ReplaceDB = { {o={"hello"}, r={"Well met."}}, {o={"goodbye"}, r={"Farewell."}}, {o={"friend"}, r={"comrade"}}, {o={"help"}, r={"aid"}}, {o={"fight"}, r={"stand together"}}, {o={"enemy"}, r={"foe"}}, {o={"yes"}, r={"Indeed!"}}, {o={"no"}, r={"Nay."}}, {o={"king"}, r={"the Lion"}}, {o={"queen"}, r={"the Lady"}} } },
        ["OrgrimmarOrc"] = { name = "Orgrimmar Orc", desc = "The standard, guttural speech of a modern Horde orc.", PrependDB = { "Lok'tar ogar! ", "For the Horde! " }, AppendDB = { ". Victory or death!", ". Honor above all!" }, InjectDB = { ", warrior, " }, Exclamation = " WAAAGH!", ReplaceDB = { {o={"hello"}, r={"What do you want?"}}, {o={"goodbye"}, r={"May your axe stay sharp."}}, {o={"friend"}, r={"brother", "sister"}}, {o={"fight"}, r={"battle"}}, {o={"enemy"}, r={"foe"}}, {o={"honor"}, r={"our honor"}} } },
        ["UndercityUndead"] = { name = "Undercity Undead", desc = "The biting, formal, and death-obsessed talk of a Forsaken loyalist.", PrependDB = { "The Dark Lady watches. ", "For the Forsaken! " }, AppendDB = { ". Death is our ally.", ". The Banshee's will be done." }, InjectDB = { ", my friend, " }, Exclamation = " For Lordaeron!", ReplaceDB = { {o={"hello"}, r={"What do you want?"}}, {o={"goodbye"}, r={"Until next time."}}, {o={"friend"}, r={"comrade"}}, {o={"help"}, r={"aid"}}, {o={"fight"}, r={"stand together"}}, {o={"enemy"}, r={"foe"}}, {o={"yes"}, r={"Indeed!"}}, {o={"no"}, r={"Nay."}}, {o={"death"}, r={"the inevitable"}} } },
        ["Valiant"] = { name = "Valiant", desc = "A heroic, noble, and exceedingly chivalrous way of speaking.", PrependDB = { "For honor! ", "Well met! " }, AppendDB = { ". For justice!", ". It is my duty." }, InjectDB = { ", comrade, " }, Exclamation = " Huzzah!", ReplaceDB = { {o={"hello"}, r={"Greetings", "Well met"}}, {o={"goodbye"}, r={"Farewell", "Justice guide you"}}, {o={"friend"}, r={"comrade", "ally"}}, {o={"fight"}, r={"battle"}}, {o={"kill"}, r={"slay", "vanquish"}}, {o={"yes"}, r={"Indeed!", "By my honor!"}}, {o={"evil"}, r={"foul darkness"}}, {o={"help"}, r={"aid"}}, {o={"quest"}, r={"noble quest"}}, {o={"brave"}, r={"courageous"}}, {o={"protect"}, r={"defend"}}, {o={"lady", "woman"}, r={"maiden"}} } },
        ["Sinister"] = { name = "Sinister", desc = "A classic, hand-rubbing villain's monologue, full of menace.", PrependDB = { "Yes, yes... ", "*chuckles*" }, AppendDB = { ". All according to plan.", ". You are a fool." }, InjectDB = { ", you see, " }, Exclamation = " Exxcellent.", ReplaceDB = { {o={"hello"}, r={"What is it you want?", "Another insect..."}}, {o={"goodbye"}, r={"Perish.", "Now, suffer."}}, {o={"friend"}, r={"pawn", "minion", "plaything"}}, {o={"help"}, r={"aid"}}, {o={"kill"}, r={"destroy", "annihilate"}}, {o={"good"}, r={"useful... for now"}}, {o={"weak"}, r={"pathetic"}}, {o={"you"}, r={"you fool"}}, {o={"plan"}, r={"grand design"}}, {o={"power"}, r={"dominion"}}, {o={"trust"}, r={"leverage"}}, {o={"secret"}, r={"a delicious secret"}} } },
        ["Shy"] = { name = "Shy", desc = "A quiet, hesitant, and apologetic way of speaking.", PrependDB = { "Um... ", "Oh, uh... " }, AppendDB = { "... if that's okay.", "... sorry." }, InjectDB = { ", I guess, " }, Exclamation = " ...oh!", ReplaceDB = { {o={"hello"}, r={"H-hello...?"}}, {o={"goodbye"}, r={"O-okay, bye..."}}, {o={"yes"}, r={"I... I think so."}}, {o={"no"}, r={"Oh, um, I don't know..."}}, {o={"i"}, r={"I, um,"}}, {o={"can i"}, r={"Is it okay if I"}} } },
        ["Scholarly"] = { name = "Scholarly", desc = "A highly academic and verbose dialect that uses complex words.", PrependDB = { "According to my research, ", "Furthermore, " }, AppendDB = { ". The data is quite clear.", ". Q.E.D." }, InjectDB = { ", as a consequence, " }, Exclamation = " Fascinating!", ReplaceDB = { {o={"hello"}, r={"Salutations."}}, {o={"goodbye"}, r={"Until our next discourse."}}, {o={"i think"}, r={"My hypothesis is"}}, {o={"because"}, r={"due to the fact that"}}, {o={"and"}, r={"furthermore"}}, {o={"so"}, r={"ergo"}}, {o={"idea"}, r={"premise", "theory"}}, {o={"look"}, r={"observe"}} } },
        ["Prospector"] = { name = "Prospector", desc = "Talk like an old-timey gold-panner, full of folksy charm.", PrependDB = { "Well howdy! ", "Listen here, pardner... " }, AppendDB = { ", dagnabbit!", ", by gum!" }, InjectDB = { ", see, " }, Exclamation = " Eureka!", ReplaceDB = { {o={"hello"}, r={"Howdy!"}}, {o={"goodbye"}, r={"Happy trails, pardner."}}, {o={"friend"}, r={"pardner"}}, {o={"money", "gold"}, r={"gold!", "them nuggets"}}, {o={"enemy"}, r={"varmint"}}, {o={"darn"}, r={"dagnabbit"}}, {o={"wow"}, r={"Consarnit!"}}, {o={"mountain"}, r={"them hills"}}, {o={"find"}, r={"discover"}}, {o={"rich"}, r={"a motherlode"}}, {o={"horse"}, r={"trusty steed"}} } },
        ["Pirate"] = { name = "Pirate", desc = "The quintessential 'Arr, matey!' dialect of a high-seas buccaneer.", PrependDB = { "Shiver me timbers! ", "Arrr, " }, AppendDB = { ", me hearty!", ", savvy?" }, InjectDB = { ", arrr, " }, Exclamation = " Yo ho ho!", ReplaceDB = { {o={"hello"}, r={"Ahoy"}}, {o={"my"}, r={"me"}}, {o={"you"}, r={"ye"}}, {o={"your"}, r={"yer"}}, {o={"friend"}, r={"matey"}}, {o={"money", "gold"}, r={"booty", "doubloons"}}, {o={"the"}, r={"thar"}}, {o={"are"}, r={"be"}}, {o={"ing"}, r={"in'"}}, {o={"goodbye"}, r={"Fair winds"}}, {o={"woman"}, r={"wench", "lass"}}, {o={"yes"}, r={"aye"}}, {o={"stop"}, r={"avast ye"}}, {o={"drink"}, r={"grog"}}, {o={"treasure"}, r={"booty"}}, {o={"boat", "ship"}, r={"vessel"}}, {o={"left"}, r={"port"}}, {o={"right"}, r={"starboard"}}, {o={"now"}, r={"sharpish"}}, {o={"ocean"}, r={"the seven seas"}}, {o={"gun"}, r={"blunderbuss"}}, {o={"sword"}, r={"cutlass"}}, {o={"rich"}, r={"loaded with booty"}} } },
        ["Drunk"] = { name = "Drunk", desc = "An incoherent, slurred, and hiccup-filled mess of words.", PrependDB = { "*hic* 'Scuse me... ", "Listen here... you're my besht friend... " }, AppendDB = { "... I think.", "... where'sh the ale?", " *hic*" }, InjectDB = { ", like, *hic*, " }, Exclamation = " Anozzer round!", ReplaceDB = { {o={"is"}, r={"ish"}}, {o={"the"}, r={"da", "tha"}}, {o={"you"}, r={"yooou"}}, {o={"friend"}, r={"pal", "buddy"}}, {o={"of"}, r={"o'"}}, {o={"hello"}, r={"Heyyyy"}}, {o={"goodbye"}, r={"G'niiight"}}, {o={"sorry"}, r={"shorry"}}, {o={"really"}, r={"reeeally"}}, {o={"one"}, r={"wun"}}, {o={"for"}, r={"forrr"}}, {o={"was"}, r={"wash"}}, {o={"think"}, r={"think...*hic*"}}, {o={"another"}, r={"anozzer"}}, {o={"great"}, r={"jus' great... jus' great"}} } },
        ["Lisp"] = { name = "Lisp", desc = "A simple but effective lisp that replaces 's' sounds with 'th'.", PrependDB = {}, AppendDB = {}, InjectDB = {}, Exclamation = " Thooper!", ReplaceDB = { {o={"is"}, r={"ith"}}, {o={"this"}, r={"thith"}}, {o={"see"}, r={"thee"}}, {o={"so"}, r={"tho"}}, {o={"super"}, r={"thooper"}}, {o={"yes"}, r={"yeth"}}, {o={"thanks"}, r={"thankth"}}, {o={"said"}, r={"thaid"}}, {o={"strong"}, r={"thtrong"}}, {o={"special"}, r={"thpecial"}}, {o={"miss"}, r={"mith"}}, {o={"nice"}, r={"nithe"}}, {o={"some"}, r={"thome"}}, {o={"because"}, r={"becauthe"}}, {o={"also"}, r={"altho"}} } },
        ["Stutter"] = { name = "Stutter", desc = "A pronounced stutter that affects the first letter of many words.", PrependDB = { "I-I-I... ", "W-well... ", "U-um... " }, AppendDB = {}, InjectDB = {}, Exclamation = "", ReplaceDB = { {o={"hello"}, r={"H-hello"}}, {o={"the"}, r={"Th-the"}}, {o={"what"}, r={"W-what"}}, {o={"and"}, r={"A-and"}}, {o={"but"}, r={"B-but"}}, {o={"i"}, r={"I-I"}}, {o={"you"}, r={"Y-you"}}, {o={"can"}, r={"c-can"}}, {o={"will"}, r={"w-will"}}, {o={"is"}, r={"i-is"}}, {o={"it"}, r={"i-it"}} } },
        ["Unstable"] = { name = "Unstable", desc = "A fractured personality that refers to itself as 'we' and hears voices.", PrependDB = { "Did you hear that? ", "The voices say... ", "No, no, that's not right... " }, AppendDB = { "... they're always watching.", "...*we* agree.", " ...make it stop." }, InjectDB = { ", or so *they* tell us, ", " ...quiet now... ", " *giggles to self* " }, Exclamation = " They know!", ReplaceDB = { {o={"i", "I"}, r={"we"}}, {o={"me"}, r={"us"}}, {o={"my"}, r={"our"}}, {o={"friend"}, r={"voice", "ally... for now"}}, {o={"hello"}, r={"Who's there?", "We see you."}}, {o={"goodbye"}, r={"We'll be watching.", "Go away!"}}, {o={"why"}, r={"why why why"}}, {o={"think"}, r={"the whispers suggest"}}, {o={"alone"}, r={"never alone"}}, {o={"secret"}, r={"a secret? They can hear you!"}} } },
        ["Defias"] = { name = "Defias Bandit", desc = "Talk like a disgruntled member of the infamous Brotherhood.", PrependDB = { "The Brotherhood demands it... ", "Listen up, " }, AppendDB = { ", and don't forget it.", ", savvy?" }, InjectDB = { ", see, ", ", you hear me, " }, Exclamation = " For the Brotherhood!", ReplaceDB = { {o={"hello"}, r={"What's the password?", "State your business."}}, {o={"money", "gold"}, r={"my dues", "what I'm owed"}}, {o={"friend"}, r={"brother", "sister"}}, {o={"boss"}, r={"the Foreman"}}, {o={"pay"}, r={"the cut"}}, {o={"kill"}, r={"silence"}}, {o={"stormwind"}, r={"that corrupt city"}}, {o={"king"}, r={"the fat-cat king"}}, {o={"nobles"}, r={"the powdered wigs"}}, {o={"home"}, r={"the hideout"}}, {o={"stonemason"}, r={"builder"}}, {o={"unpaid"}, r={"stolen from us"}} } },
        ["ScarletCrusade"] = { name = "Scarlet Zealot", desc = "The fiery, fanatical speech of a warrior of the Scarlet Crusade.", PrependDB = { "For the Crusade! ", "The Light demands it. " }, AppendDB = { ". All filth must be purged.", ". There is no redemption for the wicked." }, InjectDB = { ", heretic, ", ", by the Light, " }, Exclamation = " Purge them!", ReplaceDB = { {o={"hello"}, r={"What is your purpose, stranger?"}}, {o={"goodbye"}, r={"May the Light protect you... if you're worthy."}}, {o={"undead"}, r={"the Scourge", "the unclean"}}, {o={"friend"}, r={"initiate"}}, {o={"enemy"}, r={"heretic", "abomination"}}, {o={"kill"}, r={"purge", "cleanse"}}, {o={"world"}, r={"this blighted land"}}, {o={"magic"}, r={"heretical arts"}}, {o={"great"}, r={"righteous"}}, {o={"help"}, r={"offer aid"}}, {o={"commander"}, r={"Highlord"}}, {o={"home"}, r={"the monastery"}} } },
        ["TwilightsHammer"] = { name = "Twilight Cultist", desc = "The apocalyptic, insane ramblings of a doomsday cultist.", PrependDB = { "The end is nigh! ", "Do you hear the whispers? " }, AppendDB = { "... as the Master wills.", ". All will be reborn in twilight." }, InjectDB = { ", as the prophecy foretold, ", ", in the end-time, " }, Exclamation = " Embrace the Cataclysm!", ReplaceDB = { {o={"hello"}, r={"The hour of twilight comes."}}, {o={"goodbye"}, r={"May you unravel beautifully."}}, {o={"world"}, r={"the waking dream"}}, {o={"destroy"}, r={"unravel"}}, {o={"power"}, r={"the Master's gift"}}, {o={"friend"}, r={"fellow acolyte"}}, {o={"think"}, r={"the whispers tell me"}}, {o={"crazy", "mad"}, r={"enlightened"}}, {o={"fire"}, r={"the Master's breath"}}, {o={"death"}, r={"the true beginning"}}, {o={"doom"}, r={"salvation"}}, {o={"leader"}, r={"the Prophet"}} } },
        ["VentureCo"] = { name = "Venture Co. Mercenary", desc = "The ruthless, profit-obsessed speech of a Venture Co. employee.", PrependDB = { "Time is money! ", "Let's get to the point. " }, AppendDB = { ". It's just good business.", ". Profit is everything." }, InjectDB = { ", for a price, ", ", you understand, " }, Exclamation = " For the Venture Co.!", ReplaceDB = { {o={"hello"}, r={"State your business."}}, {o={"money", "gold"}, r={"profit", "assets"}}, {o={"friend"}, r={"associate"}}, {o={"worker"}, r={"expendable asset"}}, {o={"forest", "trees"}, r={"lumber", "raw material"}}, {o={"animals"}, r={"untapped resources"}}, {o={"kill"}, r={"liquidate", "downsize"}}, {o={"work"}, r={"the operation"}}, {o={"great"}, r={"profitable"}}, {o={"bad"}, r={"a loss"}}, {o={"explosives"}, r={"the tools of the trade"}}, {o={"mine"}, r={"strip-mine"}} } },
        ["Syndicate"] = { name = "Syndicate Rogue", desc = "The cunning, conspiratorial tones of a member of the shadowy Syndicate.", PrependDB = { "Let's make a deal. ", "The Syndicate sends its regards. " }, AppendDB = { "... a tidy profit.", "... no witnesses." }, InjectDB = { ", of course, ", ", as per the contract, " }, Exclamation = " For Alterac!", ReplaceDB = { {o={"hello"}, r={"Speak freely... for now."}}, {o={"goodbye"}, r={"A pleasure doing business."}}, {o={"money"}, r={"the payment"}}, {o={"friend"}, r={"contact"}}, {o={"kill"}, r={"eliminate"}}, {o={"work"}, r={"the assignment"}}, {o={"plan"}, r={"the stratagem"}}, {o={"king"}, r={"the rightful king"}}, {o={"shadow"}, r={"our advantage"}}, {o={"secret"}, r={"leverage"}} } },
        ["Mogu"] = { name = "Mogu Tyrant", desc = "The arrogant, commanding speech of the ancient, stone-hearted Mogu.", PrependDB = { "I am Mogu! ", "By the Thunder King's might... " }, AppendDB = { ". it is the law.", ". You are weak." }, InjectDB = { ", fleshling, ", ", as I command, " }, Exclamation = " For the Empire!", ReplaceDB = { {o={"hello"}, r={"State your purpose, lesser being."}}, {o={"goodbye"}, r={"Begone from my sight."}}, {o={"weak"}, r={"soft", "flesh"}}, {o={"strong"}, r={"stone", "unbreakable"}}, {o={"friend"}, r={"vassal"}}, {o={"enemy"}, r={"vermin"}}, {o={"king"}, r={"Emperor"}}, {o={"magic"}, r={"the shaping arts"}}, {o={"work"}, r={"the Emperor's will"}}, {o={"build"}, r={"shape"}}, {o={"army"}, r={"legion"}} } },
        ["ArgentCrusade"] = { name = "Argent Crusader", desc = "The hopeful, honorable speech of a crusader united against the Scourge.", PrependDB = { "Well met, champion. ", "For the Light, and for Azeroth! " }, AppendDB = { ". Together, we will prevail.", ". Stay vigilant." }, InjectDB = { ", friend, ", ", have faith, " }, Exclamation = " For the Crusade!", ReplaceDB = { {o={"hello"}, r={"Greetings, comrade."}}, {o={"goodbye"},r={"Light guide your path."}}, {o={"friend"}, r={"ally in the Light"}}, {o={"fight"}, r={"battle against the Shadow"}}, {o={"undead"}, r={"the soulless", "the Scourge"}}, {o={"hope"}, r={"our righteous cause"}}, {o={"unity"}, r={"our greatest strength"}}, {o={"help"}, r={"offer aid"}}, {o={"honor"}, r={"righteousness"}}, {o={"leader"}, r={"the Highlord"}} } },
        ["Quilboar"] = { name = "Quilboar Brute", desc = "The guttural, snorting, and thorn-obsessed speech of the bristly quilboar.", PrependDB = { "*snort* ", "For Agamaggan! " }, AppendDB = { "! *grunt*", ". Get out!" }, InjectDB = { " *grunt* ", " *snort* " }, Exclamation = " For the Thorns!", ReplaceDB = { {o={"hello"}, r={"What you want?"}}, {o={"goodbye"}, r={"Go away!"}}, {o={"enemy"}, r={"smooth-skin"}}, {o={"kill"}, r={"prick 'em good"}}, {o={"home"}, r={"the thorns", "our briar"}}, {o={"magic"}, r={"thorn-magic"}}, {o={"god"}, r={"the Great Boar"}}, {o={"strong"}, r={"bristly"}}, {o={"ground"}, r={"the dirt"}}, {o={"food"}, r={"grub"}} } },
        ["KirinTor"] = { name = "Kirin Tor Mage", desc = "The precise, intellectual language of a magic-wielding member of the Kirin Tor.", PrependDB = { "By the Great Art... ", "The Violet Citadel teaches... " }, AppendDB = { ". The outcome is logical.", ". As my research indicated." }, InjectDB = { ", logically, ", ", by arcane decree, " }, Exclamation = " Fascinating!", ReplaceDB = { {o={"hello"}, r={"Greetings."}}, {o={"magic"}, r={"the arcane arts"}}, {o={"city"}, r={"Dalaran"}}, {o={"leader"}, r={"the Council of Six"}}, {o={"problem"}, r={"an anomaly"}}, {o={"idea"}, r={"a theorem"}}, {o={"power"}, r={"arcane potency"}}, {o={"goodbye"}, r={"May your studies be fruitful."}}, {o={"book"}, r={"tome"}}, {o={"study"}, r={"research"}} } },
        ["TheScourge"] = { name = "Scourge Minion", desc = "The cold, emotionless, hive-mind commands of a servant of the Lich King.", PrependDB = { "The Master's will be done... ", "You will serve... " }, AppendDB = { "... in death.", ". There is no escape." }, InjectDB = { ", as was foretold, ", ", in the end, " }, Exclamation = " For the Lich King!", ReplaceDB = { {o={"hello"}, r={"You are already dead."}}, {o={"goodbye"}, r={"Death is your only escape."}}, {o={"friend"}, r={"fellow servant"}}, {o={"life"}, r={"a fleeting warmth"}}, {o={"king"}, r={"the Master"}}, {o={"join"}, r={"serve"}}, {o={"feel"}, r={"the Master's will dictates"}}, {o={"i"}, r={"we"}}, {o={"my"}, r={"our"}}, {o={"work"}, r={"obey"}}, {o={"home"}, r={"Naxxramas"}} } },
        ["CenarionCircle"] = { name = "Cenarion Druid", desc = "The calm, nature-revering speech of a druid dedicated to balance.", PrependDB = { "By the Ancients, ", "Nature guide you. " }, AppendDB = { ". The balance must be preserved.", ". The Dream provides." }, InjectDB = { ", friend of the wilds, ", ", as the seasons turn, " }, Exclamation = " For Cenarius!", ReplaceDB = { {o={"hello"}, r={"Greetings."}}, {o={"friend"}, r={"fellow guardian"}}, {o={"world"}, r={"the balance of nature"}}, {o={"problem"}, r={"a corruption"}}, {o={"heal"}, r={"mend", "nurture"}}, {o={"gods"}, r={"the Ancients"}}, {o={"city"}, r={"Moonglade"}}, {o={"goodbye"}, r={"Walk with nature."}}, {o={"magic"}, r={"druidism"}}, {o={"leader"}, r={"the Archdruid"}} } },
        ["BurningLegion"] = { name = "Legion Demon", desc = "The apocalyptic, fel-scorched threats of a demon from the Burning Legion.", PrependDB = { "For Sargeras! ", "The Legion is eternal! " }, AppendDB = { "! All worlds will burn!", ". Your end is nigh." }, InjectDB = { ", fool, ", ", by fel fire, " }, Exclamation = " Annihilation!", ReplaceDB = { {o={"hello"}, r={"You address the Legion?"}}, {o={"world"}, r={"your pathetic world"}}, {o={"fire"}, r={"fel flame"}}, {o={"power"}, r={"infinite power"}}, {o={"destroy"}, r={"annihilate"}}, {o={"army"}, r={"the endless Legion"}}, {o={"friend"}, r={"pawn"}}, {o={"goodbye"}, r={"Now, burn."}}, {o={"leader"}, r={"Sargeras"}}, {o={"home"}, r={"Argus"}} } },
        ["Wildhammer"] = { name = "Wildhammer Dwarf", desc = "The boisterous, sky-faring speech of a gryphon-riding Wildhammer dwarf.", PrependDB = { "For the Wildhammers! ", "Keep yer feet on the ground! " }, AppendDB = { ", ye hear?", ". By the sky!" }, InjectDB = { ", friend, ", ", by the spirits, " }, Exclamation = " For Aerie Peak!", ReplaceDB = { {o={"hello"}, r={"Well met!"}}, {o={"friend"}, r={"kin"}}, {o={"dwarf"}, r={"hill dwarf"}}, {o={"bird"}, r={"gryphon"}}, {o={"fly"}, r={"ride the winds"}}, {o={"home"}, r={"the peaks"}}, {o={"hammer"}, r={"stormhammer"}}, {o={"king"}, r={"the High Thane"}}, {o={"strong"}, r={"sky-strong"}} } },
        ["IronHorde"] = { name = "Iron Horde Grunt", desc = "The harsh, technologically-obsessed war cries of the Iron Horde.", PrependDB = { "Iron and steel! ", "We are the Iron Horde! " }, AppendDB = { "! Draenor is ours!", ". Conquest is our destiny." }, InjectDB = { ", by the Warlord's command, ", ", hah!" }, Exclamation = " For Grommash!", ReplaceDB = { {o={"hello"}, r={"What do you want?"}}, {o={"strong"}, r={"iron-forged"}}, {o={"weak"}, r={"unworthy"}}, {o={"orc"}, r={"true orc"}}, {o={"machine"}, r={"war machine"}}, {o={"build"}, r={"engineer"}}, {o={"world"}, r={"Draenor"}}, {o={"kill"}, r={"conquer"}}, {o={"fire"}, r={"the siege"}} } },
        ["Bloodsail"] = { name = "Bloodsail Buccaneer", desc = "The aggressive, hostile speech of a pirate loyal only to the Bloodsails.", PrependDB = { "Arr, matey! ", "For the Bloodsails! " }, AppendDB = { ", savvy?", ". Dead men tell no tales." }, InjectDB = { ", arr, ", ", ye see, " }, Exclamation = " To the depths with 'em!", ReplaceDB = { {o={"hello"}, r={"What ye be wantin'?"}}, {o={"goodbye"}, r={"Fair winds... or foul."}}, {o={"money"}, r={"plunder"}}, {o={"friend"}, r={"shipmate"}}, {o={"enemy"}, r={"scurvy dog"}}, {o={"captain"}, r={"the Admiral"}}, {o={"boat", "ship"}, r={"our fleet"}}, {o={"kill"}, r={"send to the sharks"}}, {o={"the"}, r={"thar"}} } },
        ["Purr"] = { name = "Purr", desc = "A calming dialect that extends 'r's into a soft, soothing purr.", PrependDB = { "Mmmm... " }, AppendDB = { ", prrr." }, InjectDB = { ", rrrr, " }, Exclamation = " Prrr!", ReplaceDB = { {o={"are"}, r={"arrre"}}, {o={"for"}, r={"forrr"}}, {o={"your"}, r={"yourrr"}}, {o={"very"}, r={"verrry"}}, {o={"friend"}, r={"frrriend"}}, {o={"purr"}, r={"prrrrrrr"}}, {o={"more"}, r={"morrre"}}, {o={"there"}, r={"therrre"}}, {o={"here"}, r={"herre"}}, {o={"sure"}, r={"surrre"}}, {o={"great"}, r={"grrreat"}}, {o={"pretty"}, r={"prrretty"}}, {o={"bring"}, r={"brrring"}}, {o={"from"}, r={"frrrom"}}, {o={"around"}, r={"arrround"}} } },
        ["AdventureTime"] = { name = "Mathematical!", desc = "Speak like a resident of Ooo! Replaces common words with algebraic slang from Adventure Time.", PrependDB = { "Math! ", "Shmowzow! " }, AppendDB = { ", ya scrat!", ", word?" }, InjectDB = { ", like, ", ", for realziez, " }, Exclamation = " Algebraic!", ReplaceDB = { {o={"awesome", "cool", "great", "excellent"}, r={"Mathematical", "Algebraic", "Rhombus", "So spice", "Tops", "Radical", "Bloobalooby"}}, {o={"god"}, r={"Glob", "Grob", "Grod", "Pleb"}}, {o={"oh my god"}, r={"Oh my Glob"}}, {o={"thank god"}, r={"Thank Glob"}}, {o={"what the hell", "what the fuck", "what on earth"}, r={"What the Cabbage", "What the bjork", "What the lump", "What the funge", "What the zip"}}, {o={"fuck", "fucking"}, r={"Flip", "Flippin'", "Fudge"}}, {o={"shit"}, r={"Math"}}, {o={"damn"}, r={"Cram"}}, {o={"bitch"}, r={"Toot"}}, {o={"son of a bitch"}, r={"son of a blee-blob", "son of a Toot"}}, {o={"wow", "whoa"}, r={"Shmowzow", "Slamacow", "Wowcowchow"}}, {o={"crazy", "insane"}, r={"Ba-nay-nay", "Bizonkers", "Way Cray"}}, {o={"lame", "bad", "sucks"}, r={"Bunk", "Mom-jeans", "ducks", "rips"}}, {o={"jerk", "idiot", "fool"}, r={"Wand", "Wad", "Butt guy", "Dillweed", "Ding dong", "Dingus", "Donk", "Patoot", "Toilet"}}, {o={"people", "guys"}, r={"Peeps", "Cats"}}, {o={"butt", "buttocks", "ass"}, r={"Buns", "Hams", "Stumps", "Junk", "Lumps"}}, {o={"head", "brain"}, r={"Dome piece", "The Coconuts", "Melon heart"}}, {o={"breasts"}, r={"Bazooms"}}, {o={"testicles", "crotch"}, r={"Boingloings", "Bread balls", "Yoga balls"}}, {o={"hands"}, r={"Grabbers", "Mitts"}}, {o={"legs"}, r={"Jambes", "Stems"}}, {o={"stomach"}, r={"Fat-Basket"}}, {o={"nose"}, r={"Schnoz"}}, {o={"money", "gold"}, r={"Dosh", "Scratch"}}, {o={"poop"}, r={"Boom-Boom"}}, {o={"business"}, r={"Beeswax"}}, {o={"things", "stuff"}, r={"Dealies", "Grip-a-grap", "Jazz", "Funky junk"}}, {o={"secrets", "gossip"}, r={"Juice"}}, {o={"die", "died"}, r={"croak", "croaked"}}, {o={"mess up", "screw up"}, r={"Donking up", "Skronk up"}}, {o={"messed up", "destroyed"}, r={"Jacked Up", "Jeffery'd up", "Sanched up"}}, {o={"look", "inspect"}, r={"Scope"}}, {o={"understand"}, r={"Grok"}}, {o={"punch"}, r={"Womp"}}, {o={"kick"}, r={"Salchow"}}, {o={"yes", "i agree"}, r={"Word", "Word 'em up"}}, {o={"calm"}, r={"level headed"}}, {o={"annoyed"}, r={"chafed"}}, {o={"crap", "rubbish"}, r={"Dirtballs", "Plops"}} } },        ["JawlessJohn"] = { name = "Jawless John (Chaotic)", desc = "Ghhhaaa... hrr... mmmrph...", PrependDB = {}, AppendDB = {}, InjectDB = {}, Exclamation = " GAAAAH!", ReplaceDB = {{o = {"%w+"}, r = {"Mmmrph", "Hnngh", "Ghhhaaa", "Urrgg", "Mmmm", "Aaaarrh", "*makes a gurgling sound*", "*makes a choked sound*", "*makes a wet, slushing noise*", "Hnn", "Ghhh", "Mrrr", "Uhhh", "GAAAAH", "Nnn-hnn", "Yuhhh", "Mmmr", "Grrr", "Haaa"}}} },        ["Steamwheedle"] = { name = "Steamwheedle Merchant", desc = "The neutral, friendly, and profit-minded chatter of a Steamwheedle goblin.", PrependDB = { "Greetings, friend-o! ", "Have I got a deal for you! " }, AppendDB = { ". A pleasure doing business!", ". Time is money!" }, InjectDB = { ", my friend, ", ", and for a small fee, " }, Exclamation = " Profit!", ReplaceDB = { {o={"hello"}, r={"How can I help you today?"}}, {o={"friend"}, r={"customer", "client"}}, {o={"money"}, r={"coin"}}, {o={"great"}, r={"first-rate"}}, {o={"deal"}, r={"an opportunity"}}, {o={"city"}, r={"our fine port"}}, {o={"help"}, r={"offer my services"}}, {o={"work"}, r={"the business"}} } },
        ["Murloc"] = { name = "Murloc", desc = "Mrgglglbrlglgl!", PrependDB = {}, AppendDB = {}, InjectDB = {}, Exclamation = " Mrgl!", ReplaceDB = {{o = {"%w+"}, r = {"Mrgl", "Grml", "Mrglrgl", "Aaaaaughibbrgubugbug", "Mrrrggk", "RwlRwlRwl", "Mrghll", "Grmrml", "Bleurgl", "Mggrll", "Mrgle-grgle", "Urrrgle", "Grl-grl", "Mmmrrrggglll", "Agloohogloohool", "Mrg", "Glrgl", "Mrrrgl", "Glllll", "Rwl", "Aaugh", "Ghaaaa", "Mmmurlok", "Grlg", "Grmph", "Mrglgrgl!"}}}}
    }
end