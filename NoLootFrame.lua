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

local LootFrame, LootFrameMixin = LootFrame, LootFrameMixin

NoLootFrameMixin = {}

-- AutoLoot is done server-side now, so all we have to do is handle
-- the events so the window doesn't show

function NoLootFrameMixin:OnEvent(event, ...)

    if event == 'LOOT_OPENED' then
        self.autoLoot = ...
        if self.autoLoot then
            LootFrame:SetScript('OnEvent', nil)
            CloseLoot()
        end
        return
    end

    if event == "CHAT_MSG_CURRENCY" then
        local msg = ...
        if msg == "" then return end

        local guid = select(12, ...)
        if guid ~= UnitGUID('player') then return end

        local info = ChatTypeInfo.CURRENCY
        self:AddMessage(msg, info.r, info.g, info.b)
        return
    end

    if event == 'CHAT_MSG_LOOT' then
        local msg = ...
        if msg == "" then return end

        -- local pre, link, color, post = msg:match('^(.*)(|c(........)|H.+|h|r)(.*)$')
        local _, _, link = ExtractHyperlinkString(msg)
        local quality = select(3, GetItemInfo(link))
        local guid = select(12, ...)
        if guid == UnitGUID('player') then  
            if quality < Enum.ItemQuality.Common then return end
        else
            if quality < Enum.ItemQuality.Rare then return end
        end

        local info = ChatTypeInfo.LOOT
        self:AddMessage(msg, info.r, info.g, info.b)
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

function NoLootFrameMixin:OnLoad()
    -- We need to make sure we get this event before LootFrame so that we can
    -- unset it's OnEvent handler if we're autolooting.

    LootFrame:UnregisterEvent('LOOT_OPENED')
    NoLootFrame:RegisterEvent('LOOT_OPENED')
    LootFrame:RegisterEvent('LOOT_OPENED')

    NoLootFrame:RegisterEvent('LOOT_CLOSED')
    NoLootFrame:RegisterEvent('CHAT_MSG_LOOT')
    NoLootFrame:RegisterEvent('CHAT_MSG_CURRENCY')
end
