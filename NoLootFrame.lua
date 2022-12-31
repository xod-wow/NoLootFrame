--[[----------------------------------------------------------------------------

  NoLootFrame

  Copyright 2019 Mike Battersby

  NoLootFrame is free software: you can redistribute it and/or modify it under
  the terms of the GNU General Public License, version 2, as published by
  the Free Software Foundation.

  NoLootFrame is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
  more details.

  The file LICENSE included with NoLootFrame contains a copy of the
  license. If the LICENSE file is missing, you can find a copy at
  http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local PoorQualityColor = select(4, GetItemQualityColor(Enum.ItemQuality.Poor))

local LootFrame_OnEvent = LootFrame_OnEvent

local function AnnounceLoot(info)
    if info and info.quantity > 0 and info.quality > 0 then
        local color = ITEM_QUALITY_COLORS[info.quality].color
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

local function NoLootFrame_OnEvent(self, event, ...)

    if event == 'LOOT_OPENED' then
        self.autoLoot = ...
        if self.autoLoot then
            LootFrame:SetScript('OnEvent', nil)
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
        local pre, link, color, post = msg:match('^(.*)(|c(........)|H.+|h|r)(.*)$')
        if color == PoorQualityColor then
            return
        end
        local txt = '|cff33cc33' .. pre .. FONT_COLOR_CODE_CLOSE ..
                    link .. 
                    '|cff33cc33' .. post .. FONT_COLOR_CODE_CLOSE
        UIErrorsFrame:AddMessage(txt)
        return
    end

    if event == 'LOOT_CLOSED' then
        if self.autoLoot then
            LootFrame:SetScript('OnEvent', LootFrameMixin.OnEvent)
        end
        self.autoLoot = nil
        return
    end
end

_G.NoLootFrame = CreateFrame('Frame', UIParent)
NoLootFrame:SetScript('OnEvent', NoLootFrame_OnEvent)

-- We need to make sure we get this event before LootFrame so that we can
-- unset it's OnEvent handler if we're autolooting.

LootFrame:UnregisterEvent('LOOT_OPENED')
NoLootFrame:RegisterEvent('LOOT_OPENED')
LootFrame:RegisterEvent('LOOT_OPENED')

NoLootFrame:RegisterEvent('LOOT_CLOSED')
NoLootFrame:RegisterEvent('CHAT_MSG_LOOT')

