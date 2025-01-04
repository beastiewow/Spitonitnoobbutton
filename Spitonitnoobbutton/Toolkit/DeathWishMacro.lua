local DEBUG = false -- Set to true to enable debug mode, false to disable

local DEATH_WISH_ID = 12328 -- Spell ID for Death Wish
local BLOOD_FURY_ID = 20572 -- Spell ID for Blood Fury
local BADGE_OF_SWARMGUARD_ID = 21670 -- Item ID for Badge of the Swarmguard
local KISS_OF_THE_SPIDER_ID = 22954 -- Item ID for Kiss of the Spider

-- Debug print function
local function debug_print(msg)
    if DEBUG then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

-- Function to get the spell slot for a given spell name
local function FindSpellBookSlotByName(spellName)
    for i = 1, 120 do
        local spellBookName = GetSpellName(i, "spell")
        if spellBookName and spellBookName == spellName then
            return i
        end
    end
    return nil
end

-- Function to get spell cooldown by spell name
local function GetSpellCooldownByName(spellName)
    local slot = FindSpellBookSlotByName(spellName)
    if slot then
        local start, duration, enabled = GetSpellCooldown(slot, "spell")
        return start, duration, enabled
    end
    return nil, nil, nil
end

-- Function to check if a spell is on cooldown
local function CanUseSpell(spellName)
    local start, duration = GetSpellCooldownByName(spellName)
    return start == 0
end

-- Function to extract item ID from item link
local function GetItemIDFromLink(itemLink)
    if itemLink then
        local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
        return itemID
    end
    return nil
end

-- Function to check if a trinket is equipped
local function IsTrinketEquipped(trinketID)
    for slot = 13, 14 do -- Checking both trinket slots (13 and 14)
        local itemLink = GetInventoryItemLink("player", slot)
        local itemID = GetItemIDFromLink(itemLink)
        if itemID == trinketID then
            return true, slot
        end
    end
    return false, nil
end

-- Function to use Death Wish and Badge of the Swarmguard
local function UseDeathWishAndBadge()
    -- Check if Death Wish is off cooldown
    if CanUseSpell("Death Wish") then
        debug_print("Casting Death Wish")
        CastSpellByName("Death Wish")
    else
        debug_print("Death Wish is on cooldown")
    end

    -- Check if Badge of the Swarmguard is equipped and use it
    local isBadgeEquipped, badgeSlot = IsTrinketEquipped(BADGE_OF_SWARMGUARD_ID)
    if isBadgeEquipped then
        debug_print("Using Badge of the Swarmguard")
        UseInventoryItem(badgeSlot)
    else
        debug_print("Badge of the Swarmguard is not equipped")
    end
end

-- Function to use Blood Fury and Kiss of the Spider
local function UseBloodFuryAndKiss()
    -- Check if Blood Fury is off cooldown
    if CanUseSpell("Blood Fury") then
        debug_print("Casting Blood Fury")
        CastSpellByName("Blood Fury")
    else
        debug_print("Blood Fury is on cooldown")
    end

    -- Check if Kiss of the Spider is equipped and use it
    local isKissEquipped, kissSlot = IsTrinketEquipped(KISS_OF_THE_SPIDER_ID)
    if isKissEquipped then
        debug_print("Using Kiss of the Spider")
        UseInventoryItem(kissSlot)
    else
        debug_print("Kiss of the Spider is not equipped")
    end
end

-- Slash commands for Death Wish & Badge and Blood Fury & Kiss
SLASH_DEATHWISH1 = "/deathwish"
SlashCmdList["DEATHWISH"] = UseDeathWishAndBadge

SLASH_BLOODFURYKISS1 = "/bloodfurykiss"
SlashCmdList["BLOODFURYKISS"] = UseBloodFuryAndKiss
