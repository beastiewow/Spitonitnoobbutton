-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Function to check if the player has specific talents
function SNB.HasTalent(talentName)
    -- Talent names and their tabIndex and talentIndex values
    local talents = {
        ["Mortal Strike"] = {tabIndex = 1, talentIndex = 18},  -- Arms talent tree, talent index 18
        ["Bloodthirst"] = {tabIndex = 2, talentIndex = 16},    -- Fury talent tree, talent index 16
        ["Sweeping Strikes"] = {tabIndex = 1, talentIndex = 13}, -- Arms, talent index 13
        ["Death Wish"] = {tabIndex = 2, talentIndex = 12}       -- Fury, talent index 12
    }

    -- Fetch talent data
    local talentData = talents[talentName]
    if not talentData then
        return false
    end

    -- Check if the talent is trained
    local tabIndex, talentIndex = talentData.tabIndex, talentData.talentIndex
    local _, _, _, _, rank = GetTalentInfo(tabIndex, talentIndex)
    return rank > 0
end

-- Function to check for Cleave Build (both Sweeping Strikes and Death Wish)
function SNB.HasCleaveBuild()
    local hasSweepingStrikes = SNB.HasTalent("Sweeping Strikes") -- Arms talent
    local hasDeathWish = SNB.HasTalent("Death Wish") -- Fury talent

    return hasSweepingStrikes and hasDeathWish
end

-- Macro to check and print player's specialization, including Cleave Build
SLASH_SPECCHECK1 = "/speccheck"
SlashCmdList["SPECCHECK"] = function()
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    local hasBloodthirst = SNB.HasTalent("Bloodthirst")
    local isCleaveBuild = SNB.HasCleaveBuild()

    if hasMortalStrike then
        print("Player is specialized in Arms (Mortal Strike).")
    elseif hasBloodthirst then
        print("Player is specialized in Fury (Bloodthirst).")
    elseif isCleaveBuild then
        print("Player is in Cleave Build (Sweeping Strikes and Death Wish).")
    else
        print("Player has neither Mortal Strike nor Bloodthirst; possibly a different spec.")
    end
end