--[[----------------------------------------------------------------------------

    NoLootFrame

----------------------------------------------------------------------------]]--

NoLootFrame = CreateFrame('Frame', UIParent)

local events = {
    "LOOT_OPENED",
    "LOOT_SLOT_CLEARED",
    "LOOT_SLOT_CHANGED",
    "LOOT_CLOSED",
    "LOOT_READY",
}

-- AutoLoot is done server-side now, so all we have to do is handle
-- the events so the window doesn't show

function NoLootFrame_OnEvent(self, event, ...)

    if event == 'LOOT_READY' then
        self.lootInfo = GetLootInfo()
        return
    end

    if event == 'LOOT_OPENED' then
        self.autoLoot = ...
    end

    if not self.autoLoot then
        LootFrame_OnEvent(LootFrame, event, ...)
        return
    end

    if event == 'LOOT_SLOT_CLEARED' then
        local slot = ...
        local info = self.lootInfo[slot]
        if info and info.quantity > 0 and info.quality > 0 then
            local colorInfo = ITEM_QUALITY_COLORS[info.quality]
            local color = CreateColor(colorInfo.r, colorInfo.g, colorInfo.b, colorInfo.a)
            local txt = color:WrapTextInColorCode('[' .. info.item .. ']')
                txt = txt
                    .. '|cff19a919'
                    .. format('x%d', info.quantity or 0)
                    .. FONT_COLOR_CODE_CLOSE
                UIErrorsFrame:AddMessage(txt)
            self.lootInfo[slot] = nil
        end
    end

    if event == 'LOOT_CLOSED' then
        self.lootInfo = nil
    end
end

NoLootFrame:SetScript('OnEvent', NoLootFrame_OnEvent)

for _, event in ipairs(events) do
    LootFrame:UnregisterEvent(event)
    NoLootFrame:RegisterEvent(event)
end
