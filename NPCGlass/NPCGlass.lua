local addonName, ns = ...
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

-- ============================================================
-- CONFIG: THE PALETTE
-- ============================================================
local C = {
    bg      = {0.05, 0.05, 0.07, 0.9},    -- Obsidian Background
    topLine = {0.6, 0.5, 0.3, 0.8},       -- The thin gold/tan line at the top
    input   = {0.03, 0.03, 0.04, 1},      -- Darker inset for typing
    btn     = {0.12, 0.12, 0.14, 1},      -- Button Face
    btnHigh = {0.20, 0.20, 0.25, 1},      -- Button Hover
    bevelH  = {1, 1, 1, 0.15},            -- Highlight (Brighter for visibility)
    bevelS  = {0, 0, 0, 0.8},             -- Shadow (Darker for depth)
}

-- HELPER: Create a "Chiseled" 3D Bevel
local function AddBevel(frame)
    if frame.bevel then return end
    local t = frame:CreateTexture(nil, "OVERLAY"); t:SetPoint("TOPLEFT"); t:SetPoint("TOPRIGHT"); t:SetHeight(1); t:SetColorTexture(unpack(C.bevelH))
    local l = frame:CreateTexture(nil, "OVERLAY"); l:SetPoint("TOPLEFT"); l:SetPoint("BOTTOMLEFT"); l:SetWidth(1); l:SetColorTexture(unpack(C.bevelH))
    local b = frame:CreateTexture(nil, "OVERLAY"); b:SetPoint("BOTTOMLEFT"); b:SetPoint("BOTTOMRIGHT"); b:SetHeight(1); b:SetColorTexture(unpack(C.bevelS))
    local r = frame:CreateTexture(nil, "OVERLAY"); r:SetPoint("TOPRIGHT"); r:SetPoint("BOTTOMRIGHT"); r:SetWidth(1); r:SetColorTexture(unpack(C.bevelS))
    frame.bevel = true
end

local trash = CreateFrame("Frame"); trash:Hide()

f:SetScript("OnEvent", function()
    -- ============================================================
    -- 1. SCORCHED EARTH: REMOVE ALL DEFAULT TEXTURES
    -- ============================================================
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame"..i]
        
        -- Kill default borders/backgrounds by iterating regions
        local regions = {cf:GetRegions()}
        for _, region in ipairs(regions) do
            if region:IsObjectType("Texture") then
                region:SetTexture(nil)
                region:Hide()
            end
        end

        -- Nuke Buttons, Scrollbars, Tabs
        local targets = { 
            _G["ChatFrame"..i.."ButtonFrame"], 
            _G["ChatFrame"..i.."ScrollBar"], 
            _G["ChatFrame"..i.."Background"],
            cf.ScrollBar, 
            cf.ScrollToBottomButton 
        }
        for _, obj in ipairs(targets) do 
            if obj then obj:Hide(); obj:SetParent(trash) end 
        end

        local tab = _G["ChatFrame"..i.."Tab"]
        if tab then
            local texs = {"Left","Middle","Right","ActiveLeft","ActiveMiddle","ActiveRight","HighlightLeft","HighlightMiddle","HighlightRight"}
            for _, t in ipairs(texs) do if tab[t] then tab[t]:SetTexture(nil) end end
            tab:SetAlpha(0); tab:EnableMouse(false); tab:SetScript("OnShow", tab.Hide)
        end
    end

    -- ============================================================
    -- 2. MAIN WINDOW FRAME
    -- ============================================================
    local frame = ChatFrame1
    frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) if IsAltKeyDown() then self:StartMoving() end end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    frame:SetClampedToScreen(true)

    if not frame.sleekBg then
        local bg = CreateFrame("Frame", nil, frame)
        -- Tweak points to fit content perfectly
        bg:SetPoint("TOPLEFT", -30, 20)
        bg:SetPoint("BOTTOMRIGHT", 10, -60) -- Extended down to hold the permanent buttons
        bg:SetFrameLevel(frame:GetFrameLevel() - 1)
        
        local tex = bg:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints(bg)
        tex:SetColorTexture(unpack(C.bg))
        
        local topBar = bg:CreateTexture(nil, "OVERLAY")
        topBar:SetHeight(1)
        topBar:SetPoint("TOPLEFT", 0, 0); topBar:SetPoint("TOPRIGHT", 0, 0)
        topBar:SetColorTexture(unpack(C.topLine))
        
        frame.sleekBg = bg
    end

    -- ============================================================
    -- 3. PERMANENT BOTTOM DOCK (Holds Input Look + Buttons)
    -- ============================================================
    local dock = CreateFrame("Frame", nil, frame)
    dock:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -20, -55)
    dock:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -55)
    dock:SetHeight(55)

    -- 3A. FAKE INPUT BAR (The Look)
    local fakeInput = CreateFrame("Frame", nil, dock)
    fakeInput:SetHeight(28)
    fakeInput:SetPoint("TOPLEFT", 0, 0)
    fakeInput:SetPoint("TOPRIGHT", 0, 0)
    
    local fiBg = fakeInput:CreateTexture(nil, "BACKGROUND")
    fiBg:SetAllPoints(); fiBg:SetColorTexture(unpack(C.input))
    AddBevel(fakeInput)

    -- Fake "Say" Button
    local fiLbl = fakeInput:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fiLbl:SetPoint("LEFT", 15, 0); fiLbl:SetText("Say"); fiLbl:SetTextColor(0.6, 0.6, 0.6)
    local fiSep1 = fakeInput:CreateTexture(nil, "OVERLAY"); fiSep1:SetColorTexture(1,1,1,0.1); fiSep1:SetSize(1,20); fiSep1:SetPoint("LEFT", 50, 0)

    -- Fake "Send" Button
    local fiSend = fakeInput:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fiSend:SetPoint("RIGHT", -15, 0); fiSend:SetText("Send"); fiSend:SetTextColor(0.6, 0.6, 0.6)
    local fiSep2 = fakeInput:CreateTexture(nil, "OVERLAY"); fiSep2:SetColorTexture(1,1,1,0.1); fiSep2:SetSize(1,20); fiSep2:SetPoint("RIGHT", -50, 0)

    -- Placeholder Text
    local fiPh = fakeInput:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fiPh:SetPoint("LEFT", 60, 0); fiPh:SetText("Type a message..."); fiPh:SetTextColor(0.3, 0.3, 0.3)

    -- ============================================================
    -- 4. REAL EDITBOX (Hidden until needed)
    -- ============================================================
    local eb = ChatFrame1EditBox
    local ebTexs = {"Left", "Mid", "Right", "FocusLeft", "FocusMid", "FocusRight"}
    for _, t in ipairs(ebTexs) do if _G["ChatFrame1EditBox"..t] then _G["ChatFrame1EditBox"..t]:SetTexture(nil) end end
    if _G["ChatFrame1EditBoxHeader"] then _G["ChatFrame1EditBoxHeader"]:Hide() end

    eb:ClearAllPoints()
    eb:SetAllPoints(fakeInput) -- Snap exactly to our fake bar
    eb:SetAltArrowKeyMode(false)
    eb:SetFrameLevel(dock:GetFrameLevel() + 10) -- Ensure it sits ON TOP
    
    -- When typing, hide the placeholder text
    eb:HookScript("OnShow", function() fiPh:Hide() end)
    eb:HookScript("OnHide", function() fiPh:Show() end)

    -- ============================================================
    -- 5. CHANNEL BUTTONS (Anchored to Dock)
    -- ============================================================
    local groups = {
        { {L="S",C="/s "}, {L="Y",C="/y "}, {L="E",C="/e "} },
        { {L="P",C="/p "}, {L="R",C="/raid "}, {L="G",C="/g "}, {L="O",C="/o "}, {L="W",C="/w "}, {L="N",C="/rn "} },
        { {L="D",C="/dance "}, {L="C",C="/clap "} }
    }

    local btnSize = 22
    local spacing = 2
    local groupSpacing = 10
    
    -- Filter Icon
    local funnel = dock:CreateTexture(nil, "ARTWORK")
    funnel:SetSize(14, 14)
    funnel:SetPoint("TOPLEFT", fakeInput, "BOTTOMLEFT", 0, -8)
    funnel:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up"); funnel:SetDesaturated(true); funnel:SetAlpha(0.7)

    local xOffset = 20 -- Start after funnel
    for _, group in ipairs(groups) do
        for _, data in ipairs(group) do
            local btn = CreateFrame("Button", nil, dock)
            btn:SetSize(btnSize, btnSize)
            btn:SetPoint("TOPLEFT", fakeInput, "BOTTOMLEFT", xOffset, -4)
            
            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(); bg:SetColorTexture(unpack(C.btn))
            btn.bg = bg
            AddBevel(btn) -- Chiseled look

            btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btn.text:SetPoint("CENTER", 0, 0)
            btn.text:SetText(data.L)
            btn.text:SetTextColor(0.6, 0.6, 0.6)

            btn:SetScript("OnEnter", function() btn.bg:SetColorTexture(unpack(C.btnHigh)); btn.text:SetTextColor(1, 1, 1) end)
            btn:SetScript("OnLeave", function() btn.bg:SetColorTexture(unpack(C.btn)); btn.text:SetTextColor(0.6, 0.6, 0.6) end)
            btn:SetScript("OnClick", function() ChatFrame_OpenChat(data.C) end)
            
            xOffset = xOffset + btnSize + spacing
        end
        xOffset = xOffset + groupSpacing
    end

    -- ============================================================
    -- 6. SIDEBAR ICONS
    -- ============================================================
    local sidebar = CreateFrame("Frame", nil, frame)
    sidebar:SetSize(24, 100)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", -28, 0)
    
    local sideButtons = {
        { icon = "Interface\\Buttons\\UI-OptionsButton", func = function() if ChatConfigFrame:IsShown() then ChatConfigFrame:Hide() else ChatConfigFrame:Show() end end },
        { icon = "Interface\\Buttons\\UI-GuildButton-PublicIcon-Up", func = function() ToggleFriendsFrame(1) end },
        { icon = "Interface\\Buttons\\UI-StopButton", func = function() ChatFrame1:Clear() end }
    }
    
    for i, data in ipairs(sideButtons) do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(16, 16)
        btn:SetPoint("TOP", 0, -(i-1)*26)
        
        local nTex = btn:CreateTexture(nil, "ARTWORK")
        nTex:SetAllPoints(); nTex:SetTexture(data.icon); nTex:SetDesaturated(true); nTex:SetAlpha(0.5)
        btn:SetNormalTexture(nTex)
        
        local hTex = btn:CreateTexture(nil, "HIGHLIGHT")
        hTex:SetAllPoints(); hTex:SetTexture(data.icon); hTex:SetAlpha(1)
        btn:SetHighlightTexture(hTex)

        btn:SetScript("OnClick", data.func)
    end

    -- ============================================================
    -- 7. PREVENT TEXT OVERLAP (PADDING)
    -- ============================================================
    ChatFrame1:SetClampRectInsets(0, 0, 0, 60)

    -- ============================================================
    -- 8. CUSTOM SCROLLBAR (FIXED LOGIC)
    -- ============================================================
    local sb = CreateFrame("Slider", "MySleekScroll", ChatFrame1, "UIPanelScrollBarTemplate")
    sb:SetPoint("RIGHT", frame, "RIGHT", 8, 0)
    sb:SetPoint("TOP", frame, "TOP", 0, -10)
    sb:SetPoint("BOTTOM", frame, "BOTTOM", 0, 60)
    sb:SetWidth(6)
    
    -- Hide Ugly Default Arrows/Backgrounds
    local badBits = {"ScrollUpButton", "ScrollDownButton", "BG", "Track"}
    for _, bit in ipairs(badBits) do
        if _G[sb:GetName()..bit] then _G[sb:GetName()..bit]:Hide() end
    end

    -- Custom Thumb Texture
    sb:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = sb:GetThumbTexture()
    thumb:SetWidth(4)
    thumb:SetHeight(30)
    thumb:SetVertexColor(0.4, 0.4, 0.4, 0.8)

    -- Loop Prevention
    local isUpdating = false

    -- 1. DRAG: When the slider is moved, scroll the chat
    sb:SetScript("OnValueChanged", function(self, val)
        if isUpdating then return end
        isUpdating = true
        ChatFrame1:SetScrollOffset(select(2, sb:GetMinMaxValues()) - val)
        isUpdating = false
    end)

    -- 2. SCROLL: Wiretap the chat frame's internal scroll function
    -- This catches mouse wheel, page up/down, and game engine scrolls
    hooksecurefunc(ChatFrame1, "SetScrollOffset", function(self, offset)
        if isUpdating then return end
        isUpdating = true
        local min, max = sb:GetMinMaxValues()
        sb:SetValue(max - offset)
        isUpdating = false
    end)

    -- 3. NEW TEXT: Update the slider range when new lines appear
    hooksecurefunc(ChatFrame1, "AddMessage", function(self)
        local maxLines = self:GetNumMessages()
        sb:SetMinMaxValues(0, maxLines)
        
        -- If we were at the bottom, stay at the bottom
        if self:AtBottom() then
            sb:SetValue(maxLines)
        else
            -- Maintain relative position
            sb:SetValue(maxLines - self:GetScrollOffset())
        end
    end)

end)