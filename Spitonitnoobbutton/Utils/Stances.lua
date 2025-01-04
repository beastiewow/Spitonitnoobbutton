-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Function to determine if the player is in Defensive Stance
function SNB.IsInDefensiveStance()
    local stanceCount = GetNumShapeshiftForms()
    for index = 1, stanceCount do
        local _, _, active = GetShapeshiftFormInfo(index)
        if active and index == 2 then  -- 2 corresponds to Defensive Stance
            return true
        end
    end
    return false
end

-- Function to determine if the player is in Berserker Stance
function SNB.IsInBerserkerStance()
    local stanceCount = GetNumShapeshiftForms()
    for index = 1, stanceCount do
        local _, _, active = GetShapeshiftFormInfo(index)
        if active and index == 3 then  -- 3 corresponds to Berserker Stance
            return true
        end
    end
    return false
end

-- Function to determine if the player is in Battle Stance
function SNB.IsInBattleStance()
    local stanceCount = GetNumShapeshiftForms()
    for index = 1, stanceCount do
        local _, _, active = GetShapeshiftFormInfo(index)
        if active and index == 1 then  -- 1 corresponds to Battle Stance
            return true
        end
    end
    return false
end