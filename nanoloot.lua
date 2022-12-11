local function NanoLootEventHandler(_, event, ...)
    if event == "CHAT_MSG_LOOT" then
        local currentPlayer = UnitName("player")
        local player, classPlayer, link, rarity, itemLevel, itemID, itemType, itemSubType = NanoLoot.Utilities.LootInfo(...)
        local playerNoRealm = player:gsub("%-.+", "")
        local classPlayerNoRealm = classPlayer:gsub("%-.+", "")
        local isSelf = playerNoRealm == currentPlayer
        local inInstance, instanceType = IsInInstance()
        local inDungeonOrRaid = instanceType == 'party' or instanceType == 'raid'
        local listNotAtMax = #NanoLootDB.LootList ~= NanoLoot.Globals.NANOLOOT_LOOTLIST_LIMIT
        local rareOrEpic = rarity == 3 or rarity == 4
        local equippable = itemType == 2 or itemType == 4 or itemType == 9
        local shouldHandle = inInstance and inDungeonOrRaid and listNotAtMax and rareOrEpic and equippable

        -- Debug:
        -- shouldHandle = true

        if shouldHandle then
            local loot = {
                classPlayer = classPlayer,
                itemLevel = itemLevel,
                link = link,
                player = player,
                playerNoRealm = playerNoRealm,
                classPlayerNoRealm = classPlayerNoRealm,
                isSelf = isSelf,
                itemType = itemType,
                itemSubType = itemSubType
            }
            table.insert(NanoLootDB.LootList, loot)
            GetItemInfo(link)
            NanoLoot.UI.RenderLoot()
        end
    end
end

local function InitialiseNanoLoot()
    local NanoLootListener = CreateFrame("Frame")
    NanoLootListener:RegisterEvent("CHAT_MSG_LOOT")
    NanoLootListener:SetScript("OnEvent", NanoLootEventHandler)

    local NanoLootPanel = NanoLoot.UI.CreateMainPanel()
    local NanoLootTitleBar = NanoLoot.UI.CreateTitleBar(NanoLootPanel)
    NanoLoot.UI.CreateWaitingBar(NanoLootTitleBar)

    NanoLoot.UI.SetMainPanelSize()

    NanoLoot.UI.RenderLoot()
end

local loadingEvents = CreateFrame("Frame")
loadingEvents:RegisterEvent("ADDON_LOADED")
loadingEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
loadingEvents:RegisterEvent("PLAYER_LOGOUT")

loadingEvents:SetScript(
    "OnEvent",
    function(_, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "nanoloot" then
            if not NanoLootDB then
                NanoLootDB = {}
                NanoLootDB.LootList = {}
            else
                if not NanoLootDB.LootList then
                    NanoLootDB.LootList = {}
                end
            end

            InitialiseNanoLoot()

            loadingEvents:UnregisterEvent("ADDON_LOADED")
        end

        if event == "PLAYER_ENTERING_WORLD" then
            if _G["NANOLOOT_PANEL_BASE"] then
                Elements.Utilities.SetPixelScaling(_G["NANOLOOT_PANEL_BASE"])
            end
            loadingEvents:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end

        if event == "PLAYER_LOGOUT" then
            if NanoLootDB and NanoLootDB.LootList then
                NanoLootDB.LootList = {}
            end
        end
    end
)
