local addonName, addonTable = ...

-- 1. DATABASE & DEFAULTS
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local portraitLoaded = false
local ASI_LEVELS = { [4]=true, [8]=true, [12]=true, [16]=true, [19]=true, [20]=true }

-- MATH HELPERS
local function GetModifier(score)
    return math.floor((score - 10) / 2)
end

local function RecalculateStats()
    if not RP_CharacterData then return end
    
    local str = RP_CharacterData.stats.STR or 10
    local dex = RP_CharacterData.stats.DEX or 10
    local con = RP_CharacterData.stats.CON or 10
    local lvl = RP_CharacterData.level or 1
    
    local conMod = GetModifier(con)
    local dexMod = GetModifier(dex)
    
    local hp = (10 + conMod) + ((lvl - 1) * (6 + conMod))
    local ac = 10 + dexMod
    
    RP_CharacterData.hp = hp
    RP_CharacterData.ac = ac
end

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if RP_CharacterData == nil then
            RP_CharacterData = {
                level = 1,
                points = 27,   
                locked = false,
                stats = { STR=8, DEX=8, CON=8, INT=8, WIS=8, CHA=8 },
                hp = 0, 
                ac = 0, 
            }
        else
            if RP_CharacterData.points == nil then RP_CharacterData.points = 27 end
            if RP_CharacterData.locked == nil then RP_CharacterData.locked = false end
            if RP_CharacterData.stats == nil then RP_CharacterData.stats = { STR=8, DEX=8, CON=8, INT=8, WIS=8, CHA=8 } end
        end
        RecalculateStats()
        print("|cff00ff00[RP Sheet]|r Loaded! Type /rp to open.")
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        if RP_MainFrame and RP_MainFrame.Portrait then
            RP_MainFrame.Portrait:SetUnit("player") 
            RP_MainFrame.Portrait:SetPortraitZoom(1)
            RP_MainFrame.Portrait:SetAnimation(0)
            local _, classFile = UnitClass("player")
            local r, g, b = C_ClassColor.GetClassColor(classFile):GetRGB()
            RP_MainFrame.NameText:SetTextColor(r, g, b)
            RP_MainFrame.NameText:SetText(UnitName("player"))
            portraitLoaded = true 
        end
    end
end)

-- 2. MAIN FRAME
local MainFrame = CreateFrame("Frame", "RP_MainFrame", UIParent, "BasicFrameTemplateWithInset")
-- [FIX] Increased height from 370 to 400 to give the button room
MainFrame:SetSize(340, 400) 
MainFrame:SetPoint("CENTER")
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)
MainFrame.TitleBg:SetHeight(30)
MainFrame.TitleText:SetText("Adventurer's Sheet")
MainFrame:Hide()

-- Layout Constants
local COL_1_X = 35  
local COL_2_X = 190 
local START_Y = -135 
local ROW_H = 30 

-- 3. PORTRAIT & HEADER
MainFrame.Portrait = CreateFrame("PlayerModel", nil, MainFrame)
MainFrame.Portrait:SetSize(75, 75)
MainFrame.Portrait:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 20, -30)
MainFrame.Portrait:SetUnit("player")
MainFrame.Portrait:SetPortraitZoom(1)
MainFrame.Portrait:SetCamDistanceScale(1)
MainFrame.Portrait:SetRotation(0)
MainFrame.Portrait:SetAnimation(0) 

local HeaderFrame = CreateFrame("Frame", nil, MainFrame)
HeaderFrame:SetSize(200, 80)
HeaderFrame:SetPoint("TOPLEFT", MainFrame.Portrait, "TOPRIGHT", 15, -5)

MainFrame.NameText = HeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
MainFrame.NameText:SetPoint("TOPLEFT", 0, 0)
MainFrame.NameText:SetText("Character Name")

local LevelText = HeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
LevelText:SetPoint("TOPLEFT", MainFrame.NameText, "BOTTOMLEFT", 0, -5)
LevelText:SetText("Level 1")
LevelText:SetTextColor(1, 1, 1)

-- Points Display Box
local PointsFrame = CreateFrame("Frame", nil, HeaderFrame, "BackdropTemplate")
PointsFrame:SetSize(130, 25)
PointsFrame:SetPoint("TOPLEFT", LevelText, "BOTTOMLEFT", -5, -8)
PointsFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
PointsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
PointsFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

local PointsText = PointsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
PointsText:SetPoint("CENTER", PointsFrame, "CENTER", 0, 0)
PointsText:SetText("Points Left: 27")

-- Finalize Button
local FinalizeBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
FinalizeBtn:SetSize(140, 25)
-- [FIX] Anchored 10px from bottom (plenty of space now)
FinalizeBtn:SetPoint("BOTTOM", MainFrame, "BOTTOM", 0, 10) 
FinalizeBtn:SetText("Finalize Stats")

-- 4. STAT BACKGROUND PANEL
local StatBg = CreateFrame("Frame", nil, MainFrame, "BackdropTemplate")
StatBg:SetSize(320, 105) 
StatBg:SetPoint("TOP", MainFrame, "TOP", 0, START_Y + 12)
StatBg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
StatBg:SetBackdropColor(0, 0, 0, 0.4) 
StatBg:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.5) 

-- STAT GRID
local statList = {"STR", "DEX", "CON", "INT", "WIS", "CHA"}
local statRows = {} 

for i, statName in ipairs(statList) do
    local isCol2 = (i > 3)
    local colIndex = (i - 1) % 3
    local xPos = isCol2 and COL_2_X or COL_1_X
    local yPos = START_Y - (colIndex * ROW_H)

    local label = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", xPos, yPos)
    label:SetText(statName)
    label:SetWidth(40)
    label:SetJustifyH("LEFT")

    local minBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    minBtn:SetSize(18, 18) 
    minBtn:SetPoint("LEFT", label, "RIGHT", 5, 0)
    minBtn:SetText("-")
    
    local valText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    valText:SetPoint("LEFT", minBtn, "RIGHT", 5, 0)
    valText:SetWidth(30)
    valText:SetJustifyH("CENTER")
    valText:SetText("8")

    local plsBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    plsBtn:SetSize(18, 18)
    plsBtn:SetPoint("LEFT", valText, "RIGHT", 5, 0)
    plsBtn:SetText("+")

    statRows[statName] = { label = label, val = valText, min = minBtn, pls = plsBtn }

    minBtn:SetScript("OnClick", function()
        local current = RP_CharacterData.stats[statName] or 8
        if current > 8 then 
            RP_CharacterData.stats[statName] = current - 1
            RP_CharacterData.points = (RP_CharacterData.points or 0) + 1
            RecalculateStats() 
            MainFrame.UpdateDisplay()
        end
    end)

    plsBtn:SetScript("OnClick", function()
        if (RP_CharacterData.points or 0) > 0 then
            RP_CharacterData.stats[statName] = (RP_CharacterData.stats[statName] or 8) + 1
            RP_CharacterData.points = RP_CharacterData.points - 1
            RecalculateStats() 
            MainFrame.UpdateDisplay()
        end
    end)
end

-- 5. HP & AC
local secondaryY = START_Y - (3 * ROW_H) - 20 

local function CreateStatDisplay(parent)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(50, 20) 
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0, 0, 0, 0.6) 
    f:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
    
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight") 
    f.text:SetPoint("CENTER", 0, 0)
    f.text:SetTextColor(1, 0.82, 0) -- Gold Text
    return f
end

local hpLabel = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
hpLabel:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", COL_1_X, secondaryY)
hpLabel:SetText("HP:")

local hpDisplay = CreateStatDisplay(MainFrame)
hpDisplay:SetPoint("LEFT", hpLabel, "RIGHT", 10, 0)

local acLabel = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
acLabel:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", COL_2_X, secondaryY)
acLabel:SetText("AC:")

local acDisplay = CreateStatDisplay(MainFrame)
acDisplay:SetPoint("LEFT", acLabel, "RIGHT", 10, 0)


-- 6. DICE & ACTIONS
local bottomY = secondaryY - 45

local diceHeader = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
diceHeader:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", COL_1_X, bottomY + 15)
diceHeader:SetText("DICE BAG")

local actionHeader = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
actionHeader:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", COL_2_X, bottomY + 15)
actionHeader:SetText("ACTIONS")

local function Roll(sides, label)
    local result = math.random(1, sides)
    local msg = "rolls " .. label .. " (D"..sides..") and gets: " .. result
    if sides == 20 and result == 20 then
        msg = msg .. " (CRITICAL HIT!)"; PlaySound(8959)
    elseif sides == 20 and result == 1 then
        msg = msg .. " (CRITICAL FAIL...)"; PlaySound(8960)
    end
    SendChatMessage(msg, "EMOTE")
end

local diceTypes = {4, 6, 8, 10, 12, 20, 100}
local dCol, dRow = 0, 0
for _, sides in ipairs(diceTypes) do
    local btn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    btn:SetSize(45, 22)
    btn:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", COL_1_X + (dCol * 48), bottomY - (dRow * 25))
    btn:SetText("D"..sides)
    btn:SetScript("OnClick", function() Roll(sides, "a die") end)
    
    dCol = dCol + 1
    if dCol > 2 then dCol = 0; dRow = dRow + 1 end
end

local function PerformCheck(checkName, statName)
    local score = RP_CharacterData.stats[statName] or 10
    local mod = GetModifier(score)
    local roll = math.random(1, 20)
    local total = roll + mod
    local sign = (mod >= 0) and "+" or ""
    local msg = "rolls " .. checkName .. " (" .. statName .. sign .. mod .. "): " .. roll .. sign .. mod .. " = " .. total
    
    if roll == 20 then msg = msg .. " (NAT 20!)"; PlaySound(8959)
    elseif roll == 1 then msg = msg .. " (NAT 1...)"; PlaySound(8960) end
    SendChatMessage(msg, "EMOTE")
end

local actions = {
    { name="Init", stat="DEX", label="Init" },   
    { name="Spot", stat="WIS", label="Spot" },   
    { name="Sneak", stat="DEX", label="Hide" },  
    { name="Talk", stat="CHA", label="Talk" },   
}

local aCol, aRow = 0, 0
for _, act in ipairs(actions) do
    local btn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    btn:SetSize(60, 22)
    btn:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", COL_2_X + (aCol * 62), bottomY - (aRow * 25))
    btn:SetText(act.label)
    
    btn:SetScript("OnClick", function() PerformCheck(act.name, act.stat) end)
    btn:SetScript("OnEnter", function(self)
        local score = RP_CharacterData.stats[act.stat] or 10
        local mod = GetModifier(score)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(act.name .. " Check")
        GameTooltip:AddLine("Rolls D20 + " .. act.stat .. " Mod")
        GameTooltip:AddLine("Current Mod: " .. ((mod>=0 and "+" or "")..mod), 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)

    aCol = aCol + 1
    if aCol > 1 then aCol = 0; aRow = aRow + 1 end
end

-- 7. HELP WINDOW
local HelpFrame = CreateFrame("Frame", "RP_HelpFrame", UIParent, "BasicFrameTemplateWithInset")
HelpFrame:SetSize(300, 350)
HelpFrame:SetPoint("CENTER")
HelpFrame:SetFrameStrata("DIALOG") 
HelpFrame:SetMovable(true)
HelpFrame:EnableMouse(true)
HelpFrame:RegisterForDrag("LeftButton")
HelpFrame:SetScript("OnDragStart", HelpFrame.StartMoving)
HelpFrame:SetScript("OnDragStop", HelpFrame.StopMovingOrSizing)
HelpFrame.TitleBg:SetHeight(30)
HelpFrame.TitleText:SetText("Rules Reference")
HelpFrame:Hide()

local function AddHelpLine(text, yOff, isHeader)
    local fs = HelpFrame:CreateFontString(nil, "OVERLAY", isHeader and "GameFontNormalLarge" or "GameFontHighlight")
    fs:SetPoint("TOPLEFT", 15, yOff)
    fs:SetWidth(270)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    return fs
end

AddHelpLine("How Stats Work:", -30, true)
AddHelpLine("• Modifiers: (Score - 10) / 2", -55)
AddHelpLine("• HP: 10 + CON (Level 1)", -75)
AddHelpLine("        +6 + CON (Level 2+)", -90)
AddHelpLine("• AC: 10 + DEX Modifier", -110)
AddHelpLine("Point Buy System:", -140, true)
AddHelpLine("• You start with 27 points.", -165)
AddHelpLine("• Costs increase as stats get higher.", -180)
AddHelpLine("• You get +2 Points at levels:", -195)
AddHelpLine("   4, 8, 12, 16, 19, 20", -210)
AddHelpLine("Why Baseline Stats?", -240, true)
AddHelpLine("To keep roleplay simple, we use a", -265)
AddHelpLine("standard 'Adventurer' template", -280)
AddHelpLine("(d10 Hit Die, Unarmored Defense)", -295)
AddHelpLine("instead of managing complex classes.", -310)

local HelpBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
HelpBtn:SetSize(20, 20)
HelpBtn:SetPoint("TOPRIGHT", -10, -35)
HelpBtn:SetText("?")
HelpBtn:SetScript("OnClick", function()
    if HelpFrame:IsShown() then HelpFrame:Hide() else HelpFrame:Show() end
end)


-- 8. UPDATE LOGIC
function MainFrame.UpdateDisplay()
    if not RP_CharacterData then return end
    
    LevelText:SetText("Level " .. (RP_CharacterData.level or 1))
    PointsText:SetText("Points Left: " .. (RP_CharacterData.points or 0))
    PointsText:SetTextColor(RP_CharacterData.points > 0 and 0 or 0.5, RP_CharacterData.points > 0 and 1 or 0.5, 0)

    for stat, row in pairs(statRows) do
        local val = RP_CharacterData.stats[stat] or 8
        row.val:SetText(val)
        
        if RP_CharacterData.locked then
            row.min:Hide()
            if RP_CharacterData.points > 0 then row.pls:Show(); row.pls:Enable() else row.pls:Hide() end
        else
            row.min:Show(); row.pls:Show()
            if val <= 8 then row.min:Disable() else row.min:Enable() end
            if RP_CharacterData.points <= 0 then row.pls:Disable() else row.pls:Enable() end
        end
    end
    
    if RP_CharacterData.locked and RP_CharacterData.points == 0 then
        FinalizeBtn:Hide()
    elseif RP_CharacterData.locked and RP_CharacterData.points > 0 then
        FinalizeBtn:Hide()
    else
        FinalizeBtn:Show()
    end
    
    hpDisplay.text:SetText(RP_CharacterData.hp or "10")
    acDisplay.text:SetText(RP_CharacterData.ac or "10")
    
    if not portraitLoaded and MainFrame.Portrait then
        MainFrame.Portrait:SetUnit("player")
        MainFrame.Portrait:SetPortraitZoom(1)
        MainFrame.Portrait:SetAnimation(0)
        local _, classFile = UnitClass("player")
        local r, g, b = C_ClassColor.GetClassColor(classFile):GetRGB()
        MainFrame.NameText:SetTextColor(r, g, b)
        MainFrame.NameText:SetText(UnitName("player"))
        portraitLoaded = true
    end
end

-- EVENTS
FinalizeBtn:SetScript("OnClick", function()
    RP_CharacterData.locked = true
    MainFrame.UpdateDisplay()
    print("|cff00ff00[RP Sheet]|r Stats Locked!")
end)

local LvlUpBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate")
LvlUpBtn:SetPoint("LEFT", LevelText, "RIGHT", 10, 0)
LvlUpBtn:SetSize(25, 25)
LvlUpBtn:SetText("+")
LvlUpBtn:SetScript("OnClick", function()
    RP_CharacterData.level = (RP_CharacterData.level or 1) + 1
    local newLevel = RP_CharacterData.level
    if ASI_LEVELS[newLevel] then
        RP_CharacterData.points = RP_CharacterData.points + 2
        print("|cff00ccff[Level Up]|r ASI Gained! (+2 Points)"); PlaySound(17316)
    else
        PlaySound(1203)
    end
    RecalculateStats()
    MainFrame.UpdateDisplay()
end)

SLASH_RPSHEET1 = "/rp"
SlashCmdList["RPSHEET"] = function(msg)
    if msg == "reset" then RP_CharacterData = nil; ReloadUI() 
    elseif MainFrame:IsShown() then MainFrame:Hide(); HelpFrame:Hide()
    else MainFrame:Show(); MainFrame.UpdateDisplay() end
end