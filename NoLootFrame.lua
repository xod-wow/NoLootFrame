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

local MAX_LOOT_ENTRIES = 200

local function printf(fmt, ...)
    if fmt then
        local msg = string.format(fmt, ...)
        SELECTED_CHAT_FRAME:AddMessage(msg)
    end
end

local LootFrame, LootFrameMixin = LootFrame, LootFrameMixin

local defaults = { eventLog = {} }

NoLootFrameMixin = {}

-- AutoLoot is done server-side now, so all we have to do is handle
-- the events so the window doesn't show

function NoLootFrameMixin:OnEvent(event, ...)

    if self.db then
        table.insert(self.db.eventLog, { event, { ... } })
    end

    if event == 'PLAYER_LOGIN' then
        NoLootFrameDB = CreateFromMixins(defaults, NoLootFrameDB or {})
        self.db = NoLootFrameDB
        while #self.db.eventLog > MAX_LOOT_ENTRIES do
            table.remove(self.db.eventLog, 1)
        end
    end

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

        local info = ChatTypeInfo.CURRENCY
        self:AddMessage(msg, info.r, info.g, info.b)
        return
    end

    -- [01] text,
    -- [02] playerName,
    -- [03] languageName,
    -- [04] channelName,
    -- [05] playerName2,
    -- [06] specialFlags,
    -- [07] zoneChannelID,
    -- [08] channelIndex,
    -- [09] channelBaseName,
    -- [10] languageID,
    -- [11] lineID,
    -- [12] guid,
    -- [13] bnSenderID,
    -- [14] isMobile,
    -- [15] isSubtitle,
    -- [16] hideSenderInLetterbox,
    -- [17] supressRaidIcons = ...

    if event == 'CHAT_MSG_LOOT' then
        local msg = ...
        if msg == "" then return end

        -- lootHistory messages don't have a GUID [12] == nil
        local guid = select(12, ...)
        if not guid then return end

        local linkType = LinkUtil.ExtractLink(msg)
        local _, _, link = ExtractHyperlinkString(msg)

        -- local pre, link, color, post = msg:match('^(.*)(|c(........)|H.+|h|r)(.*)$')

        local minQualityName = ( guid == UnitGUID('player') ) and 'Common' or 'Rare'

        -- If we got an item we can filter quality, otherwise who knows
        if linkType == 'item' then
            local quality = select(3, GetItemInfo(link))
            if quality < Enum.ItemQuality[minQualityName] then return end
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

    NoLootFrame:RegisterEvent('PLAYER_LOGIN')
    NoLootFrame:RegisterEvent('LOOT_CLOSED')
    NoLootFrame:RegisterEvent('CHAT_MSG_LOOT')
    NoLootFrame:RegisterEvent('CHAT_MSG_CURRENCY')
end
