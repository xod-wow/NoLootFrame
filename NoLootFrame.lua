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
        return
    end

    if event == 'LOOT_OPENED' then
        self.autoLoot = ...
    end

    if not self.autoLoot then
        LootFrame_OnEvent(LootFrame, event, ...)
    end

end

NoLootFrame:SetScript('OnEvent', NoLootFrame_OnEvent)

for _, event in ipairs(events) do
    LootFrame:UnregisterEvent(event)
    NoLootFrame:RegisterEvent(event)
end
