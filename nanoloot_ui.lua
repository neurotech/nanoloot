local function GetLootText(lootInfo)
    local lootText = lootInfo.classPlayerNoRealm .. "|r > " .. lootInfo.link
    return lootText
end

local function GetMessageText(lootInfo, isSelf)
    local messageText = ""

    if isSelf then
        messageText = "Does anyone need this? " .. lootInfo.link
    else
        messageText = "Hey, do you need that item you just looted? (" ..
            lootInfo.link .. ") If not, could I please grab it?"
    end

    return messageText
end

local function CreateMainPanel()
    local NanoLootPanel = Elements.Panel.CreatePanel(
        UIParent,
        "NANOLOOT_PANEL_BASE",
        NanoLoot.Globals.NANOLOOT_PANEL_WIDTH,
        NanoLoot.Globals.NANOLOOT_PANEL_HEIGHT,
        0,
        0,
        nil,
        nil,
        true,
        "BOTTOM",
        "BOTTOM"
    )

    return NanoLootPanel
end

local function CreateTitleBar(parent)
    local NanoLootTitleBar = Elements.Panel.CreatePanel(
        parent,
        "NANOLOOT_TITLE_BAR",
        NanoLoot.Globals.NANOLOOT_PANEL_WIDTH,
        NanoLoot.Globals.NANOLOOT_BAR_HEIGHT,
        0,
        0,
        nil,
        Elements.Palette.RGB.PURPLE,
        false,
        "TOP", "TOP"
    )
    Elements.Utilities.AddHighlightAndShadow(NanoLootTitleBar)

    Elements.Text.CreateText(
        NanoLoot.Globals.NANOLOOT_FONT_PATH,
        "NANOLOOT_TITLE_BAR_TEXT",
        NanoLootTitleBar,
        NanoLootTitleBar,
        "TOPLEFT",
        25,
        "nanoloot",
        8,
        NanoLoot.Globals.NANOLOOT_PADDING,
        3,
        "LEFT",
        "NONE"
    )

    return NanoLootTitleBar
end

local function CreateWaitingBar(parent)
    local NanoLootWaitingBar = Elements.Panel.CreatePanel(parent,
        "NANOLOOT_WAITING_BAR",
        NanoLoot.Globals.NANOLOOT_PANEL_WIDTH,
        NanoLoot.Globals.NANOLOOT_BAR_HEIGHT + 1,
        0,
        1,
        nil,
        Elements.Palette.RGB.DARK_GREY,
        false,
        "TOPLEFT",
        "BOTTOMLEFT"
    )

    Elements.Text.CreateText(NanoLoot.Globals.NANOLOOT_FONT_PATH,
        "NANOLOOT_WAITING_BAR_TEXT",
        NanoLootWaitingBar,
        NanoLootWaitingBar,
        "TOPLEFT",
        25,
        "|cffa398acWaiting for loot...|r",
        8,
        NanoLoot.Globals.NANOLOOT_PADDING,
        2,
        "LEFT",
        "NONE",
        { 21 / 255, 19 / 255, 23 / 255 },
        1
    )
end

local function SetMainPanelSize()
    if #NanoLootDB.LootList > 0 then
        _G["NANOLOOT_PANEL_BASE"]:SetSize(NanoLoot.Globals.NANOLOOT_PANEL_WIDTH,
            NanoLoot.Globals.NANOLOOT_BAR_HEIGHT + (NanoLoot.Globals.NANOLOOT_BAR_HEIGHT * #NanoLootDB.LootList))
    end
end

local function CreateLootBar(parent, index, lootInfo)
    local lootBar = Elements.Panel.CreatePanel(parent,
        "NANOLOOT_LOOT_BAR_" .. index,
        NanoLoot.Globals.NANOLOOT_PANEL_WIDTH,
        NanoLoot.Globals.NANOLOOT_BAR_HEIGHT + 1,
        0,
        1,
        nil,
        Elements.Palette.RGB.DARK_GREY,
        false,
        "TOPLEFT",
        "BOTTOMLEFT",
        true
    )

    local lootBarTextFrame, _ = Elements.Text.CreateText(NanoLoot.Globals.NANOLOOT_FONT_PATH,
        "NANOLOOT_LOOT_BAR_TEXT_" .. index,
        lootBar,
        lootBar,
        "TOPLEFT",
        25,
        GetLootText(lootInfo),
        8,
        NanoLoot.Globals.NANOLOOT_PADDING,
        2,
        "LEFT",
        "NONE",
        { 21 / 255, 19 / 255, 23 / 255 },
        1
    )
    lootBarTextFrame:SetHyperlinksEnabled(true)
    lootBarTextFrame:SetScript("OnHyperlinkEnter", function(self, data)
        _G["GameTooltip"]:SetOwner(self, "ANCHOR_CURSOR")
        _G["GameTooltip"]:SetHyperlink(data)
        GameTooltip_ShowCompareItem(_G["GameTooltip"])
        _G["GameTooltip"]:Show()
    end)
    lootBarTextFrame:SetScript("OnHyperlinkLeave", function(self, data)
        _G["GameTooltip"]:Hide()
    end)

    local skipButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_CLEAR_" .. index,
        "x",
        15,
        14,
        NanoLoot.Globals.NANOLOOT_FONT_PATH,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_LABEL,
        1,
        2,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_BORDER,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_BG,
        "RIGHT",
        -3,
        0,
        8,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_LABEL_SHADOW,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_HIGHLIGHT
    )
    skipButton:SetScript("OnClick", function(_, motion)
        if not motion then return end
        table.remove(NanoLootDB.LootList, index)
        PlaySoundFile([[Interface\Addons\nanoloot\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    local messageButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_MSG_" .. index,
        "@",
        15,
        14,
        NanoLoot.Globals.NANOLOOT_FONT_PATH,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_LABEL,
        0,
        2,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_BORDER,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_BG,
        "RIGHT",
        -(skipButton:GetWidth() + 4),
        0,
        8,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_LABEL_SHADOW,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_HIGHLIGHT
    )
    messageButton:SetScript("OnClick", function(_, motion)
        if not motion then return end

        if lootInfo.isSelf then
            SendChatMessage(GetMessageText(lootInfo, true), "INSTANCE_CHAT")
        else
            SendChatMessage(GetMessageText(lootInfo), "WHISPER", nil, lootInfo.player)
        end

        PlaySoundFile([[Interface\Addons\nanoloot\send_message.mp3]])
    end)
end

local function UpdateLootBar(index, lootInfo)
    _G["NANOLOOT_LOOT_BAR_" .. index]:Hide()

    _G["NANOLOOT_LOOT_BAR_TEXT_" .. index]:SetText(GetLootText(lootInfo))

    _G["NANOLOOT_LOOT_BAR_MSG_" .. index]:SetScript("OnClick", function(_, motion)
        if not motion then return end

        if lootInfo.isSelf then
            SendChatMessage(GetMessageText(lootInfo, true), "INSTANCE_CHAT")
        else
            SendChatMessage(GetMessageText(lootInfo), "WHISPER", nil, lootInfo.player)
        end
    end)

    _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index]:SetScript("OnClick", function(_, motion)
        if not motion then return end
        table.remove(NanoLootDB.LootList, index)
        NanoLoot.UI.RenderLoot()
    end)

    _G["NANOLOOT_LOOT_BAR_" .. index]:Show()
end

local function RenderLoot()
    local parent = _G["NANOLOOT_TITLE_BAR"]

    for i = 1, NanoLoot.Globals.NANOLOOT_LOOTLIST_LIMIT, 1 do
        if _G["NANOLOOT_LOOT_BAR_" .. i] then
            _G["NANOLOOT_LOOT_BAR_" .. i]:Hide();
        end
    end

    if #NanoLootDB.LootList == 0 then
        _G["NANOLOOT_WAITING_BAR"]:Show()
    else
        _G["NANOLOOT_WAITING_BAR"]:Hide()

        for index, value in ipairs(NanoLootDB.LootList) do
            if _G["NANOLOOT_LOOT_BAR_" .. index] then
                UpdateLootBar(index, value)
            else
                if index == 1 then
                    CreateLootBar(parent, index, value)
                else
                    CreateLootBar(_G["NANOLOOT_LOOT_BAR_" .. index - 1], index, value)
                end
            end
        end
    end

    SetMainPanelSize()
end

NanoLoot.UI = {
    CreateMainPanel = CreateMainPanel,
    CreateTitleBar = CreateTitleBar,
    CreateWaitingBar = CreateWaitingBar,
    SetMainPanelSize = SetMainPanelSize,
    RenderLoot = RenderLoot
}
