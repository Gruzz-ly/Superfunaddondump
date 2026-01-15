local addonName = ...

-- 1. DATABASE & INITIALIZATION
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        if not GlamourDB then GlamourDB = {} end
        -- Legacy data fix (just in case)
        for k, v in pairs(GlamourDB) do
            if type(v) == "string" then
                GlamourDB[k] = { code = v, author = "Unknown", class = "PRIEST" }
            end
        end
    end

    if event == "ADDON_LOADED" and (arg1 == "Blizzard_DressUpFrame" or arg1 == addonName) then
        if DressUpFrame and not DressUpFrame.GlamourSaveButton then
            CreateDressUpButton()
        end
    end
end)

-- === DELETE CONFIRMATION DIALOG ===
StaticPopupDialogs["GLAMOUR_CONFIRM_DELETE"] = {
    text = "Are you sure you want to cast '%s' into the Twisting Nether?",
    button1 = "Burn It",
    button2 = "Keep It",
    OnAccept = function(self, data)
        if data then
            GlamourDB[data] = nil
            -- Refresh the list
            SlashCmdList["GLAMOUR"]("refresh")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- 2. PREVIEW FUNCTION
local function PreviewOutfit(codeString, outfitName)
    if not codeString then return end
    
    local clean = codeString:gsub("%[.-%]", "")
    clean = clean:gsub("^%s+", ""):gsub("%s+$", "")
    clean = clean:gsub("^/outfit%s+", ""):gsub("^v1%s+", "")
    
    -- FORCE LOAD: Ensure the frame is shown and model initialized
    if not DressUpFrame:IsShown() then 
        DressUpFrame_Show(DressUpFrame) 
    end
    
    local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
    if not playerActor then return end

    if clean:find(",") and not clean:find("outfit:") then
        playerActor:Undress()
        for sourceID in string.gmatch(clean, "([^,]+)") do
            local id = tonumber(sourceID)
            if id and id > 0 then playerActor:TryOn(id) end
        end
    else
        local payload = clean
        if not payload:find("^outfit:") then payload = "outfit:" .. payload end
        local fakeLink = "|cffFF69B4|H" .. payload .. "|h[Glam]|h|r"
        local success = pcall(function() DressUpLink(fakeLink) end)
        if not success then
             SetItemRef(payload, fakeLink, "LeftButton", ChatFrame1)
        end
    end
end

-- 3. GUI SETUP
local mainFrame = CreateFrame("Frame", "GlamourFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(380, 500)
mainFrame:SetPoint("CENTER")
mainFrame:Hide()
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

mainFrame.suggestedAuthor = nil

mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY")
mainFrame.title:SetFontObject("GameFontHighlight")
mainFrame.title:SetPoint("LEFT", mainFrame.TitleBg, "LEFT", 5, 0)
mainFrame.title:SetText("Glamour")

local nameInput = CreateFrame("EditBox", nil, mainFrame, "InputBoxTemplate")
nameInput:SetSize(140, 25)
nameInput:SetPoint("TOPLEFT", 20, -40)
nameInput:SetAutoFocus(false)
nameInput:SetText("Outfit Name")

local codeInput = CreateFrame("EditBox", nil, mainFrame, "InputBoxTemplate")
codeInput:SetSize(100, 25)
codeInput:SetPoint("LEFT", nameInput, "RIGHT", 10, 0)
codeInput:SetAutoFocus(false)
codeInput:SetText("Paste Code")

local saveBtn = CreateFrame("Button", nil, mainFrame, "GameMenuButtonTemplate")
saveBtn:SetPoint("LEFT", codeInput, "RIGHT", 10, 0)
saveBtn:SetSize(60, 25)
saveBtn:SetText("Save")

local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -80)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(320, 1)
scrollFrame:SetScrollChild(content)

-- 4. BUTTON POOL & REFRESH
local buttonPool = {}

local function RefreshList()
    for _, btn in pairs(buttonPool) do btn:Hide() end

    local keys = {}
    for k in pairs(GlamourDB) do table.insert(keys, k) end
    table.sort(keys)

    local yOffset = 0
    for i, name in ipairs(keys) do
        local entry = GlamourDB[name]
        
        if not buttonPool[i] then
            local btn = CreateFrame("Button", nil, content, "GameMenuButtonTemplate")
            btn:SetSize(320, 42)
            btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btn.Text:SetPoint("TOPLEFT", 10, -5)
            btn.SubText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.SubText:SetPoint("BOTTOMLEFT", 10, 5)
            
            btn.delBtn = CreateFrame("Button", nil, btn, "UIPanelCloseButton")
            btn.delBtn:SetSize(25, 25)
            btn.delBtn:SetPoint("RIGHT", -5, 0)
            
            btn.copyBtn = CreateFrame("Button", nil, btn)
            btn.copyBtn:SetSize(22, 22)
            btn.copyBtn:SetPoint("RIGHT", btn.delBtn, "LEFT", -2, 0)
            btn.copyBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
            btn.copyBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
            
            buttonPool[i] = btn
        end
        
        local btn = buttonPool[i]
        btn:Show()
        btn:SetPoint("TOPLEFT", 0, yOffset)
        
        btn.outfitCode = entry.code
        btn.outfitName = name
        
        local color = C_ClassColor.GetClassColor(entry.class or "PRIEST") or {r=1, g=1, b=1}
        btn.Text:SetText(name)
        btn.Text:SetTextColor(color.r, color.g, color.b)
        btn.SubText:SetText("Author: " .. (entry.author or "Unknown"))

        btn:SetScript("OnClick", function(self)
            PreviewOutfit(self.outfitCode, self.outfitName)
        end)
        
        btn.delBtn:SetScript("OnClick", function()
            StaticPopup_Show("GLAMOUR_CONFIRM_DELETE", name, nil, name)
        end)
        
        btn.copyBtn:SetScript("OnClick", function(self)
            local parent = self:GetParent()
            if not ChatFrame1EditBox:IsShown() then ChatFrame1EditBox:Show() end
            local out = parent.outfitCode:gsub("%[.-%]", "")
            if not out:find("^/outfit") then out = "/outfit v1 " .. out end
            ChatFrame1EditBox:SetText(out)
            ChatFrame1EditBox:SetFocus()
            print("|cffFF69B4[Glamour]|r: Code copied to chat.")
        end)
        
        yOffset = yOffset - 45
    end
    content:SetHeight(math.abs(yOffset))
end

-- 5. SAVE BUTTON
saveBtn:SetScript("OnClick", function()
    local name = nameInput:GetText()
    local code = codeInput:GetText()
    if name == "" or name == "Outfit Name" then return end
    if code == "" or code == "Paste Code" then return end
    
    local author = mainFrame.suggestedAuthor
    if not author then 
        author = UnitName("player") .. "-" .. GetRealmName()
    end
    
    local _, classFilename = UnitClassBase("player") 
    
    GlamourDB[name] = { code = code, author = author, class = classFilename }
    
    mainFrame.suggestedAuthor = nil
    RefreshList()
end)

-- 6. DRESSING ROOM BUTTON
function CreateDressUpButton()
    local btn = CreateFrame("Button", "GlamourDressUpSaveBtn", DressUpFrame, "UIPanelButtonTemplate")
    btn:SetSize(100, 22)
    
    -- Fixed Anchor: Inside ModelScene, Top Left
    if DressUpFrame.ModelScene then
        btn:SetPoint("TOPLEFT", DressUpFrame.ModelScene, "TOPLEFT", 10, -10)
    else
        btn:SetPoint("TOPLEFT", DressUpFrame, "TOPLEFT", 10, -60)
    end
    
    btn:SetFrameLevel(DressUpFrame:GetFrameLevel() + 50)
    btn:SetText("Save to Glam")
    
    btn:SetScript("OnClick", function()
        local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
        if not playerActor then return end
        
        local slotOrder = {1, 3, 15, 5, 4, 19, 9, 10, 6, 7, 8, 16, 17}
        local classicString = "/outfit v1"
        
        local parts = {}
        for _, slotID in ipairs(slotOrder) do
            local info = playerActor:GetItemTransmogInfo(slotID)
            if info and info.appearanceID and info.appearanceID > 0 then
                table.insert(parts, info.appearanceID)
            else
                table.insert(parts, "0")
            end
        end
        
        classicString = classicString .. " " .. table.concat(parts, ",")
        
        if not mainFrame:IsShown() then mainFrame:Show() end
        
        if UnitExists("target") then
            mainFrame.suggestedAuthor = GetUnitName("target", true)
        else
            mainFrame.suggestedAuthor = UnitName("player") .. "-" .. GetRealmName()
        end
        
        RefreshList()
        codeInput:SetText(classicString)
        nameInput:SetFocus()
        
        print("|cffFF69B4[Glamour]|r: Outfit captured from " .. mainFrame.suggestedAuthor .. "! Name it and Save.")
    end)
end

-- 7. COMMANDS
SLASH_GLAMOUR1 = "/glam"
SLASH_GLAMOUR2 = "/fab"
SlashCmdList["GLAMOUR"] = function(msg)
    if msg == "refresh" and mainFrame:IsShown() then
        RefreshList()
    elseif mainFrame:IsShown() then 
        mainFrame:Hide() 
    else 
        mainFrame:Show()
        RefreshList() 
    end
end