local function LootInfo(...)
    local info        = { ... }
    local link        = info[1]:match("(|c.+|r)")
    local guid        = info[12]
    local player      = info[2]
    local class       = select(2, GetPlayerInfoByGUID(guid))
    local classColor  = C_ClassColor.GetClassColor(class)
    local classPlayer = classColor:WrapTextInColorCode(player)
    local icon        = select(10, GetItemInfo(link))
    local rarity      = select(3, GetItemInfo(link))
    local itemID      = info[1]:match("item:(%d*):")
    return icon, player, classPlayer, link, rarity, itemID
end

local function InitialiseNanoLoot()
    local NanoLootListener = CreateFrame("Frame")
    NanoLootListener:RegisterEvent("CHAT_MSG_LOOT")
    NanoLootListener:SetScript("OnEvent", function(self, event, ...)
        if event == "CHAT_MSG_LOOT" then
            local icon, player, classPlayer, link, rarity, itemID = LootInfo(...)
            print("icon:" ..
                icon ..
                "player:" ..
                player ..
                "classPlayer:" .. classPlayer ..
                "link:" .. link .. "rarity:" .. rarity .. "itemID:" .. itemID)
        end
    end)
end

InitialiseNanoLoot()
