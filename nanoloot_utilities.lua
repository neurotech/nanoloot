local function GetTruncatedLink(link)
    local truncatedLink = ''
    local maxLength = 20
    local itemName = link:match("%[(.+)%]")

    if string.len(itemName) > maxLength then
        local truncatedName = string.sub(itemName, 1, maxLength) .. "..."
        truncatedLink = link:gsub("%[(.+)%]", "[" .. truncatedName .. "]")

        return truncatedLink
    end

    return link
end

local function LootInfo(...)
    local info        = { ... }
    local link        = info[1]:match("(|c.+|r)")
    local guid        = info[12]
    local player      = info[2]
    local class       = select(2, GetPlayerInfoByGUID(guid))
    local classColor  = C_ClassColor.GetClassColor(class)
    local classPlayer = classColor:WrapTextInColorCode(player)
    local rarity      = select(3, GetItemInfo(link))
    local itemLevel   = select(4, GetItemInfo(link))
    local itemID      = info[1]:match("item:(%d*):")
    local itemType    = select(12, GetItemInfo(link))
    local itemSubType = select(13, GetItemInfo(link))

    return player, classPlayer, link, rarity, itemLevel, itemID, itemType, itemSubType
end

NanoLoot.Utilities = {
    GetTruncatedLink = GetTruncatedLink,
    LootInfo = LootInfo,
}
