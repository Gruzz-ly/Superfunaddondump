-- 1. SETUP & DEFAULTS
local ADDON_NAME, ns = ...
local f = CreateFrame("Frame", ADDON_NAME)

local defaults = {
    hideRealm = true,       -- Raid Frames
    hideRealmParty = true,  -- Party Frames
    hideRealmChat = true,   -- Chat Channels & System Messages
    hideRealmGuild = true,  -- Guild Roster
    hideRealmNP = false,    -- Nameplates
    hideRealmSocial = true, -- Quick Join (List & Tooltip)
}

local db -- Database variable
local configCategory -- To store the official Settings ID

-- 2. HELPER FUNCTIONS
local function StripRealm(name)
    if not name then return nil end
    -- Takes "Bobby-Sargeras" and returns "Bobby"
    local s = name:match("^[^-]+")
    return s or name
end

local function GetNameFontString(frame)
    return frame and (frame.name or frame.Name)
end

-- 3. CHAT & SYSTEM MESSAGE CLEANER
local function ChatFilter(self, event, message, sender, ...)
    local cleanSender = StripRealm(sender)

    -- Clean System Messages (e.g., "[Bobby-Sargeras] has come online")
    if event == "CHAT_MSG_SYSTEM" and message then
        message = message:gsub("(|h%[)([^%]-]+)%-[^%]]+(%]|h)", "%1%2%3")
        message = message:gsub("(%[)([^%]-]+)%-[^%]]+(%])", "%1%2%3")
    end

    return false, message, cleanSender, ...
end

local chatEvents = {
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER",
    "CHAT_MSG_SYSTEM",
}

local function UpdateChatFilters()
    if not db then return end
    if db.hideRealmChat then
        for _, event in ipairs(chatEvents) do
            ChatFrame_AddMessageEventFilter(event, ChatFilter)
        end
    else
        for _, event in ipairs(chatEvents) do
            ChatFrame_RemoveMessageEventFilter(event, ChatFilter)
        end
    end
end

-- 4. SOCIAL, GUILD & QUICK JOIN
local function HookCommunitiesList()
    if not CommunitiesMemberListEntryMixin then return end
    hooksecurefunc(CommunitiesMemberListEntryMixin, "SetMember", function(self, memberInfo)
        if db.hideRealmGuild and memberInfo and memberInfo.name then
            local cleanName = StripRealm(memberInfo.name)
            if self.NameFrame and self.NameFrame.Name then
                self.NameFrame.Name:SetText(cleanName)
            end
        end
    end)
end

-- NEW: Quick Join Tooltip Hook
local function HookSocialTooltip()
    if not SocialQueueUtil_SetTooltip then return end
    hooksecurefunc("SocialQueueUtil_SetTooltip", function(tooltip, playerDisplayName, queues)
        if not db.hideRealmSocial then return end
        -- NOTE: If Blizzard crashes before this line, we can't fix it.
        -- But for working tooltips, this will scrub the name.
        local cleanName = StripRealm(playerDisplayName)
        if cleanName == playerDisplayName then return end
        
        local toolName = tooltip:GetName()
        for i = 1, tooltip:NumLines() do
            local line = _G[toolName .. "TextLeft" .. i]
            local text = line:GetText()
            if text and text:find(playerDisplayName, 1, true) then
                local safePlayerName = playerDisplayName:gsub("%-", "%%-")
                local newText = text:gsub(safePlayerName, cleanName)
                line:SetText(newText)
            end
        end
    end)
end

-- NEW: Quick Join LIST Hook (Fixes the window names)
local function HookQuickJoinList()
    if not QuickJoinFrame or not QuickJoinFrame.ScrollBox then return end
    
    local function CleanEntry(button)
        if db.hideRealmSocial and button.Name then
            local text = button.Name:GetText()
            if text then button.Name:SetText(StripRealm(text)) end
        end
    end

    hooksecurefunc(QuickJoinFrame.ScrollBox, "Update", function(self)
        if not db.hideRealmSocial then return end
        self:ForEachFrame(CleanEntry)
    end)
end

-- 5. VISUAL UPDATE FUNCTIONS
local function UpdatePartyFrames()
    if not db then return end
    if PartyFrame and PartyFrame.PartyMemberFramePool and PartyFrame.PartyMemberFramePool.EnumerateActive then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            if frame and not frame:IsForbidden() then
                local fs = frame.Name or frame.name
                if db.hideRealmParty and frame.unit and UnitIsPlayer(frame.unit) and fs then
                    local uname = GetUnitName(frame.unit, true)
                    if uname then fs:SetText(StripRealm(uname)) end
                end
            end
        end
    else
        for i = 1, 4 do
            local frame = _G["PartyMemberFrame"..i]
            local frameName = _G["PartyMemberFrame"..i.."Name"]
            if frame and db.hideRealmParty and frame.unit and UnitIsPlayer(frame.unit) and frameName then
                local uname = GetUnitName(frame.unit, true)
                if uname then frameName:SetText(StripRealm(uname)) end
            end
        end
    end
end

local hooksAdded = { nameUpdate = false, communities = false, social = false }

local function CompactNameHandler(frame)
    if not frame or frame:IsForbidden() or not db then return end
    local fs = GetNameFontString(frame)
    if not fs or not frame.unit then return end
    
    if db.hideRealm and UnitIsPlayer(frame.unit) then
        local uname = GetUnitName(frame.unit, true)
        if uname then fs:SetText(StripRealm(uname)); fs:Show() end
    end

    if db.hideRealmNP then
        local isInInstance, instType = IsInInstance()
        if (not isInInstance or instType == "none") and (not frame.ShouldShowName or frame:ShouldShowName()) then
            if frame.optionTable and frame.optionTable.colorNameBySelection then
                fs:SetText(GetUnitName(frame.unit)); fs:Show()
            end
        end
    end
end

local function EnsureHooks()
    if not hooksAdded.nameUpdate then 
        hooksecurefunc("CompactUnitFrame_UpdateName", CompactNameHandler)
        hooksAdded.nameUpdate = true 
    end
    
    if not hooksAdded.social then
        HookSocialTooltip()
        HookQuickJoinList()
        hooksAdded.social = true
    end
end

local function ApplySettings()
    if not db then return end
    EnsureHooks()
    UpdatePartyFrames()
    UpdateChatFilters()
end

-- 6. OPTIONS PANEL
function f:InitializeOptions()
    if self.panel or not db then return end
    self.panel = CreateFrame("Frame")
    self.panel.name = "Hidden Realms"

    local function createFontString(parent, font, justify, point1, relativeTo, point2, x, y, text)
        local fs = parent:CreateFontString(nil, 'ARTWORK', font)
        fs:SetJustifyH(justify)
        fs:SetPoint(point1, relativeTo, point2, x, y)
        fs:SetText(text)
        return fs
    end

    local function createCheckButton(parent, point1, relativeTo, x, y, text, dbKey)
        local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint(point1, relativeTo, x, y)
        cb.Text:SetText(text)
        cb:SetChecked(db[dbKey])
        cb:HookScript("OnClick", function() db[dbKey] = cb:GetChecked(); ApplySettings() end)
        return cb
    end

    local title = createFontString(self.panel, 'GameFontNormalHuge', 'LEFT', 'TOPLEFT', self.panel, 'TOPLEFT', 16, -16, self.panel.name)
    local subtitle = createFontString(self.panel, 'GameFontNormal', 'LEFT', 'TOPLEFT', title, 'BOTTOMLEFT', 0, -8, 'Hides server names to clean up the UI.')

    local subheader_groups = createFontString(self.panel, 'GameFontNormalLarge', 'LEFT', 'TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -30, 'Group Frame Options')
    local cb_hide_realms = createCheckButton(self.panel, "TOPLEFT", subheader_groups, 0, -20, "Hide in Raid Frames", "hideRealm")
    local cb_hide_realms_party = createCheckButton(self.panel, "TOPLEFT", cb_hide_realms, 0, -25, "Hide in Party Frames", "hideRealmParty")

    local subheader_social = createFontString(self.panel, 'GameFontNormalLarge', 'LEFT', 'TOPLEFT', cb_hide_realms_party, 'BOTTOMLEFT', 0, -30, 'Social Options')
    local cb_hide_chat = createCheckButton(self.panel, "TOPLEFT", subheader_social, 0, -20, "Hide in Chat & System Messages", "hideRealmChat")
    local cb_hide_guild = createCheckButton(self.panel, "TOPLEFT", cb_hide_chat, 0, -25, "Hide in Guild Roster", "hideRealmGuild")
    local cb_hide_social = createCheckButton(self.panel, "TOPLEFT", cb_hide_guild, 0, -25, "Hide in Quick Join (Social Queue)", "hideRealmSocial")

    local subheader_plates = createFontString(self.panel, 'GameFontNormalLarge', 'LEFT', 'TOPLEFT', cb_hide_social, 'BOTTOMLEFT', 0, -30, 'Nameplate Options')
    local cb_hide_realms_np = createCheckButton(self.panel, "TOPLEFT", subheader_plates, 0, -20, "Hide Realms (Open World Only)", "hideRealmNP")

    local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", cb_hide_realms_np, 0, -40)
    btn:SetText("Save and Reload")
    btn:SetWidth(120)
    btn:SetScript("OnClick", ReloadUI)

    if Settings and Settings.RegisterAddOnCategory then
        configCategory = Settings.RegisterCanvasLayoutCategory(self.panel, "Hidden Realms")
        Settings.RegisterAddOnCategory(configCategory)
    else
        InterfaceOptions_AddCategory(self.panel)
    end
end

-- 7. MAIN EVENTS
function f:OnEvent(event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            HiddenRealmsDB = HiddenRealmsDB or CopyTable(defaults)
            db = HiddenRealmsDB
            self.db = db
            for k, v in pairs(defaults) do if db[k] == nil then db[k] = v end end
            self:InitializeOptions()
            ApplySettings()
            
            if C_AddOns.IsAddOnLoaded("Blizzard_Communities") and not hooksAdded.communities then
                HookCommunitiesList(); hooksAdded.communities = true
            end
        elseif arg1 == "Blizzard_Communities" and not hooksAdded.communities then
            HookCommunitiesList(); hooksAdded.communities = true
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        ApplySettings()
    end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", f.OnEvent)

SLASH_HIDDENREALMS1 = "/hiddenrealms"
SLASH_HIDDENREALMS2 = "/hr"
SlashCmdList.HIDDENREALMS = function()
    if not db then print("HiddenRealms not loaded."); return end
    if Settings and Settings.OpenToCategory then
        if configCategory then Settings.OpenToCategory(configCategory:GetID()) end
    else
        InterfaceOptionsFrame_OpenToCategory(f.panel)
    end
end