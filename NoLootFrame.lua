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
    "CHAT_MSG_LOOT",
}

local PoorQualityColor = '|c' .. select(4, GetItemQualityColor(0))

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

    if event == 'LOOT_OPENED' then
        self.autoLoot = ...
    end

    if event == 'CHAT_MSG_LOOT' then
        local guid =  select(12, ...)
        if guid ~= UnitGUID('player') then
            return
        end
        local msg = ...
        local pre, color, link, post = msg:match('^(.*)(|c........)(|H.+|h)(.*)$')
        if color == PoorQualityColor then
            return
        end
        local txt = '|cff33cc33' .. pre .. FONT_COLOR_CODE_CLOSE
                    .. color .. link .. '|r' ..
                    '|cff33cc33' .. post .. FONT_COLOR_CODE_CLOSE
        UIErrorsFrame:AddMessage(txt)
        return
    end

    if not self.autoLoot then
        if not InCombatLockdown() then
            LootFrame_OnEvent(LootFrame, event, ...)
        end
        return
    end

    if event == 'LOOT_CLOSED' then
        self.autoLoot = nil
    end
end

NoLootFrame:SetScript('OnEvent', NoLootFrame_OnEvent)

for _, event in ipairs(events) do
    LootFrame:UnregisterEvent(event)
    NoLootFrame:RegisterEvent(event)
end
