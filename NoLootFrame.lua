--[[----------------------------------------------------------------------------

    NoLootFrame

----------------------------------------------------------------------------]]--

local PoorQualityColor = select(4, GetItemQualityColor(LE_ITEM_QUALITY_POOR))

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
        if self.autoLoot then
            CloseLoot()
        return
        end
    end

    if event == 'CHAT_MSG_LOOT' then
        local guid =  select(12, ...)
        if guid ~= UnitGUID('player') then
            return
        end
        local msg = ...
        local pre, link, color, post = msg:match('^(.*)(|c(........)|H.+|h)(.*)$')
        if color == PoorQualityColor then
            return
        end
        local txt = '|cff33cc33' .. pre .. FONT_COLOR_CODE_CLOSE ..
                    link .. 
                    '|cff33cc33' .. post .. FONT_COLOR_CODE_CLOSE
        UIErrorsFrame:AddMessage(txt)
        return
    end

    -- Half-baked attempt to pass event through to the regular loot
    -- frame. Taint is a major issue, can't really do this.

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

LootFrame:UnregisterEvent('LOOT_OPENED')
LootFrame:UnregisterEvent('LOOT_SLOT_CLEARED')
LootFrame:UnregisterEvent('LOOT_SLOT_CHANGED')
LootFrame:UnregisterEvent('LOOT_CLOSED')
LootFrame:UnregisterEvent('LOOT_READY')

NoLootFrame = CreateFrame('Frame', UIParent)
NoLootFrame:SetScript('OnEvent', NoLootFrame_OnEvent)
NoLootFrame:RegisterEvent('LOOT_OPENED')
NoLootFrame:RegisterEvent('CHAT_MSG_LOOT')
