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

local function AnnounceLoot(info)
    if info and info.quantity > 0 and info.quality > 0 then
        local colorInfo = ITEM_QUALITY_COLORS[info.quality]
        local color = CreateColor(colorInfo.r, colorInfo.g, colorInfo.b, colorInfo.a)
        local txt = color:WrapTextInColorCode('[' .. info.item .. ']')
            txt = txt
                .. '|cff19a919'
                .. format('x%d', info.quantity or 0)
                .. FONT_COLOR_CODE_CLOSE
            UIErrorsFrame:AddMessage(txt)
    end
end

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
        if not InCombatLockdown() then
            LootFrame_OnEvent(LootFrame, event, ...)
        end
        return
    end

    if event == 'LOOT_CLOSED' then
        if self.lootInfo then
            for _, info in ipairs(self.lootInfo or {}) do
                AnnounceLoot(info)
            end
            self.lootInfo = nil
        end
    end
end

NoLootFrame:SetScript('OnEvent', NoLootFrame_OnEvent)

for _, event in ipairs(events) do
    LootFrame:UnregisterEvent(event)
    NoLootFrame:RegisterEvent(event)
end
