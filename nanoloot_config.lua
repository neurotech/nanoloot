local function colorCallback(restore)
    local newR, newG, newB, newA;
    if restore then
        -- The user bailed, we extract the old color from the table created by ShowColorPicker.
        newR, newG, newB, newA = unpack(restore);
    else
        -- Something changed
        newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
    end

    -- Update our internal storage.
    NanoLootDB.TitleBarBackground = { newR, newG, newB }

    -- And update any UI elements that use this color...
    _G["NANOLOOT_TITLEBAR_BG_COLOUR_SWATCH"]:SetBackdropColor(unpack({ newR, newG, newB }))
    _G["NANOLOOT_TITLE_BAR"]:SetBackdropColor(unpack({ newR, newG, newB }))
end

local function ShowColorPicker(r, g, b, changedCallback)
    ColorPickerFrame.previousValues = { r, g, b };
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc =
    changedCallback, changedCallback, changedCallback;
    ColorPickerFrame:SetColorRGB(r, g, b);
    ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
    ColorPickerFrame:Show();
end

local function GetCurrentClassColour()
    return C_ClassColor.GetClassColor(select(2, UnitClass("player")))
end

local function HandleClassColourClick()
    local colourSwatch = _G["NANOLOOT_TITLEBAR_BG_COLOUR_SWATCH"]
    local colourPickerButton = _G["NANOLOOT_TITLEBAR_BG_COLOR_PICKER"]

    if NanoLootDB.UseClassColour then
        local currentClassColour = GetCurrentClassColour()
        colourSwatch:SetBackdropColor(currentClassColour.r, currentClassColour.g, currentClassColour.b)
        colourPickerButton:Disable()
        NanoLootDB.TitleBarBackground = { currentClassColour.r, currentClassColour.g, currentClassColour.b }
    else
        colourSwatch:SetBackdropColor(
            NanoLootDB.TitleBarBackground[1],
            NanoLootDB.TitleBarBackground[2],
            NanoLootDB.TitleBarBackground[3]
        )
        colourPickerButton:Enable()
    end

    _G["NANOLOOT_TITLE_BAR"]:SetBackdropColor(unpack({
        NanoLootDB.TitleBarBackground[1],
        NanoLootDB.TitleBarBackground[2],
        NanoLootDB.TitleBarBackground[3]
    }))
end

local function CreateConfigFrame()
    local categoryName = "nanoloot |Tinterface/cursor/crosshair/lootall:18:18:0:0|t"
    local configFrame = CreateFrame("Frame", "NANOLOOT_CONFIG_FRAME", UIParent, "BackdropTemplate")

    -- Header
    local headerText = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    headerText:SetPoint("TOPLEFT", 10, -10)
    headerText:SetText(NanoLoot.Globals.NANOLOOT_LOGO)

    -- Colour Options subheading
    local colourOptionsText = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    colourOptionsText:SetPoint("TOPLEFT", 10, -40)
    colourOptionsText:SetPoint("TOPLEFT", headerText, "BOTTOMLEFT", 0, -20)
    colourOptionsText:SetText("Title bar colour")

    -- 'Use Class Colour' checkbox
    local classColourCheckbox = CreateFrame("CheckButton", "NANOLOOT_CLASS_COLOUR_CHECKBOX", configFrame,
        "SettingsCheckBoxTemplate")
    classColourCheckbox:SetPoint("TOPLEFT", colourOptionsText, "BOTTOMLEFT", 0, -10)

    -- 'Use class colour' text
    classColourCheckbox.text = classColourCheckbox:CreateFontString("NANOLOOT_CLASS_COLOUR_CHECKBOX_TEXT", "ARTWORK",
        "GameFontNormal")
    classColourCheckbox.text:SetText("Use class colour")
    classColourCheckbox.text:SetPoint("LEFT", classColourCheckbox, "RIGHT", 4, 0)
    classColourCheckbox:SetChecked(NanoLootDB.UseClassColour)
    classColourCheckbox:SetScript("OnClick", function()
        NanoLootDB.UseClassColour = not NanoLootDB.UseClassColour
        classColourCheckbox:SetChecked(NanoLootDB.UseClassColour)
        HandleClassColourClick()
    end)

    -- Colour swatch
    local colourSwatch = Elements.Panel.CreatePanel(
        configFrame,
        "NANOLOOT_TITLEBAR_BG_COLOUR_SWATCH",
        20,
        20,
        10,
        -(headerText:GetHeight() + 20),
        nil,
        NanoLootDB.TitleBarBackground,
        false,
        nil,
        nil,
        1
    )
    colourSwatch:SetPoint("TOPLEFT", classColourCheckbox, "BOTTOMLEFT", 2, -10)

    -- Custom colour picker button
    local colourPickerButton = CreateFrame("Button", "NANOLOOT_TITLEBAR_BG_COLOR_PICKER", configFrame,
        "UIPanelButtonTemplate")
    colourPickerButton:SetText("Custom")
    colourPickerButton:SetWidth(120)
    colourPickerButton:SetPoint("BOTTOMLEFT", classColourCheckbox, "BOTTOMLEFT", colourSwatch:GetWidth() + 10, -30)

    colourPickerButton:SetScript("OnClick", function()
        ShowColorPicker(
            NanoLootDB.TitleBarBackground[1],
            NanoLootDB.TitleBarBackground[2],
            NanoLootDB.TitleBarBackground[3],
            colorCallback
        )
    end)

    HandleClassColourClick()

    -- Visibility subheading
    local visibilityText = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    visibilityText:SetPoint("BOTTOMLEFT", colourSwatch, "BOTTOMLEFT", 0, -40)
    visibilityText:SetText("Visibility")

    -- 'Hide when empty' checkbox
    local hideWhenEmptyCheckbox = CreateFrame("CheckButton", "NANOLOOT_HIDE_WHEN_EMPTY_CHECKBOX", configFrame,
        "SettingsCheckBoxTemplate")
    hideWhenEmptyCheckbox:SetPoint("TOPLEFT", visibilityText, "BOTTOMLEFT", 0, -10)

    -- 'Hide when empty' text
    hideWhenEmptyCheckbox.text = hideWhenEmptyCheckbox:CreateFontString(
        "NANOLOOT_HIDE_WHEN_EMPTY_CHECKBOX_TEXT",
        "ARTWORK",
        "GameFontNormal"
    )
    hideWhenEmptyCheckbox.text:SetText("Hide when empty")
    hideWhenEmptyCheckbox.text:SetPoint("LEFT", hideWhenEmptyCheckbox, "RIGHT", 4, 0)
    hideWhenEmptyCheckbox:SetChecked(NanoLootDB.HideWhenEmpty)
    hideWhenEmptyCheckbox:SetScript("OnClick", function()
        NanoLootDB.HideWhenEmpty = not NanoLootDB.HideWhenEmpty
        hideWhenEmptyCheckbox:SetChecked(NanoLootDB.HideWhenEmpty)
        if NanoLootDB.HideWhenEmpty then
            _G["NANOLOOT_PANEL_BASE"]:Hide()
        else
            _G["NANOLOOT_PANEL_BASE"]:Show()
        end
    end)

    -- Register config frame
    local category = Settings.RegisterCanvasLayoutCategory(configFrame, categoryName)
    Settings.RegisterAddOnCategory(category)
end

NanoLoot.Config = {
    CreateConfigFrame = CreateConfigFrame
}
