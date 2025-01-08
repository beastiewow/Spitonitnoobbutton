-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist


-- Function to check if Heroic Strike is queued
function SNB.IsHeroicStrikeQueued()
    local slot = SNB.FindActionSlotByTexture(SNB.HEROIC_STRIKE_TEXTURE)
    if slot then
        local isQueued = IsCurrentAction(slot) == 1
        return isQueued
    else
        return false
    end
end

-- Function to check if Cleave is queued
function SNB.IsCleaveQueued()
    local slot = SNB.FindActionSlotByTexture(SNB.CLEAVE_TEXTURE)
    if slot then
        local isQueued = IsCurrentAction(slot) == 1
        return isQueued
    else
        return false
    end
end