-- Utilities.lua (General Utility Functions)
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Add more utility functions here
-- Function to get spell book slot for a given spell name

function SNB.FindSpellBookSlotByName(spellName)
    for i = 1, 120 do
        local spellBookName, spellBookRank = GetSpellName(i, "spell")
        if spellBookName == spellName then
            return i
        end
    end
    return nil
end

-- Function to get spell cooldown
function SNB.GetSpellCooldownById(spellID)
    local name, rank, texture, minRange, maxRange = SpellInfo(spellID)
    if name then
        local slot = SNB.FindSpellBookSlotByName(name)
        if slot then
            return GetSpellCooldown(slot, "spell")
        end
    end
    return nil, nil, nil
end

-- Function to find action slot by texture
function SNB.FindActionSlotByTexture(texture)
    for lActionSlot = 1, 120 do
        local lActionTexture = GetActionTexture(lActionSlot)
        if lActionTexture == texture then
            return lActionSlot
        end
    end
    return nil
end

-- Function to check if there is a shaman in the group
function SNB.IsShamanInGroup()
    local groupSize = GetNumPartyMembers()
    local isInRaid = false

    if groupSize == 0 then
        groupSize = GetNumRaidMembers()
        isInRaid = true
    end

    for i = 1, groupSize do
        local unit = isInRaid and "raid" .. i or "party" .. i
        if UnitClass(unit) == "Shaman" then
            return true
        end
    end

    return false
end