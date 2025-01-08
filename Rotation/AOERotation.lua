-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Update the AOE rotation to equip offhand in Berserker Stance or Battle Stance
function SNB.CastBasedOnAOEFunction()
    -- Determine if player has Mortal Strike, Bloodthirst, or Cleave Build
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    local hasBloodthirst = SNB.HasTalent("Bloodthirst")
    local hasCleaveBuild = SNB.HasCleaveBuild()

    if SNB.IsInDefensiveStance() then
        -- Use tank AOE rotation when in Defensive Stance
        SNB.CheckAndCastTankAOE()

    elseif SNB.IsTwoHanderEquipped() then
        -- Cleave Build check for all modes when using a two-hander
        if hasCleaveBuild then
            SNB.CheckAndCastSpell2handerCleaveBuildAOE()
        elseif hasMortalStrike then
            -- Use Mortal Strike AOE rotation if Mortal Strike talent is detected
            SNB.ArmsAOERotation()
        elseif hasBloodthirst then
            -- Use Cleave/Whirlwind with 2-hander if Bloodthirst is detected
            SNB.CheckAndCastCleaveWhirlwind2Hander()
        end

    elseif SNB.IsInBerserkerStance() or SNB.IsInBattleStance() then
        -- Equip offhand if in Berserker Stance or Battle Stance
        SNB.EquipOffhandIfInBerserkerStance()

        if not SNB.IsMainHandEnchantActive() then
            -- AOE rotation without Windfury
            if hasCleaveBuild then
                SNB.CheckAndCastSpell2handerCleaveBuildAOE()
            elseif hasMortalStrike then
                SNB.ArmsAOERotation()  -- Mortal Strike-based AOE rotation without Windfury
            else
                SNB.CheckAndCastCleaveWhirlwindNOWF()  -- Existing AOE rotation without Windfury
            end
        else
            -- AOE rotation with Windfury
            if hasCleaveBuild then
                SNB.CheckAndCastSpell2handerCleaveBuildAOE()
            elseif hasMortalStrike then
                SNB.ArmsAOERotation()  -- Mortal Strike-based AOE rotation with Windfury
            else
                SNB.CheckAndCastCleaveWhirlwind()  -- Existing regular AOE rotation
            end
        end
    end
end

-- We assume "GetTime()" exists in Turtle WoW 1.12.1 and returns
-- a float representing seconds since the client started.

local lastAOECallTime = 0
local aoeThrottleDelay = 0.1  -- 0.2 seconds; adjust to your preference

-- Throttled function for AOE
function SNB.CastBasedOnAOEFunction_Throttled()
    local currentTime = GetTime()
    if (currentTime - lastAOECallTime) < aoeThrottleDelay then
        -- Too soon, skip this call
        return
    end
    -- Update the last call time
    lastAOECallTime = currentTime

    -- Perform the normal AOE logic
    SNB.CastBasedOnAOEFunction()
end

-- Replace the slash command to point to the throttled function
SLASH_AOE1 = "/aoe"
SlashCmdList["AOE"] = SNB.CastBasedOnAOEFunction_Throttled