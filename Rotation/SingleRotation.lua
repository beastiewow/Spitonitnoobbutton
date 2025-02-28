if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Main function to determine which spell-casting function to call from /single
function SNB.CastBasedOnActiveFunction()
    -- Determine if player has Mortal Strike, Bloodthirst, or Cleave Build
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    local hasBloodthirst = SNB.HasTalent("Bloodthirst")
    local hasCleaveBuild = SNB.HasCleaveBuild()

    if hasBloodthirst then
        -- Bloodthirst specialization logic based on stance
        if SNB.IsInDefensiveStance() then
            SNB.CheckAndCastTankSingleTarget()
        elseif SNB.IsInBerserkerStance() then
            SNB.EquipOffhandIfInBerserkerStance()  -- Equip offhand for dual-wielding
            SNB.CheckAndCastSpellUnified()
        elseif SNB.IsInBattleStance() then
            SNB.EquipOffhandIfInBerserkerStance()  -- Equip offhand for dual-wielding
            SNB.CheckAndCastSpellUnified()
        end
    elseif hasMortalStrike then
        -- Mortal Strike specialization logic
        if hasCleaveBuild then
            SNB.CheckAndCastSpell2handerCleaveBuildSingle()
        else
            SNB.ArmsSingleTargetUnified()
        end
    end
end

-- Slash command to toggle between Whirlwind mode and Single-Target mode for both Farm and Boss Modes
function SNB.ToggleWhirlwindMode()
    -- Toggle between Whirlwind Mode and Single-Target Mode
    SNB.isWhirlwindMode = not SNB.isWhirlwindMode

    -- Determine current mode (Farm Mode or Boss Mode) and notify the player
    if not SNB.IsMainHandEnchantActive() then
        -- Farm Mode
        if SNB.isWhirlwindMode then
        else
        end
    else
        -- Boss Mode
        if SNB.isWhirlwindMode then
        else
        end
    end
end

-- Slash command to toggle between Overpower mode on and off for both Farm and Boss Modes
function SNB.ToggleOverpowerMode()
    -- Toggle between Overpower Mode on and off
    SNB.isOverpowerMode = not SNB.isOverpowerMode

    -- Determine current mode (Farm Mode or Boss Mode) and notify the player
    if not SNB.IsMainHandEnchantActive() then
        -- Farm Mode
        if SNB.isOverpowerMode then
        else
        end
    else
        -- Boss Mode
        if SNB.isOverpowerMode then
        else
        end
    end
end

-- Slash command to toggle Overpower mode
SLASH_TOGGLEOVERPOWER1 = "/toggleop"
SlashCmdList["TOGGLEOVERPOWER"] = SNB.ToggleOverpowerMode


-- Slash command to swap to Farm mode
function SNB.SwapToFarmMode()
    SNB.isFarmMode = true
end

-- Slash command to reset from Farm mode and allow Whirlwind/Single toggle for Boss Mode
function SNB.ExitFarmMode()
    if SNB.isFarmMode then
        SNB.isFarmMode = false
    end
end

-- We assume "GetTime()" exists in Turtle WoW 1.12.1 and returns
-- a float representing seconds since the client started.

local lastCastTime = 0  -- Tracks the last execution timestamp
local throttleDelay = 0.1  -- 0.2s delay (adjust if desired)

function SNB.CastBasedOnActiveFunction_Throttled()
    local currentTime = GetTime()
    if (currentTime - lastCastTime) < throttleDelay then
        -- Too soon, skip
        return
    end
    -- Update the last cast time
    lastCastTime = currentTime

    -- Now safely call your normal rotation
    SNB.CastBasedOnActiveFunction()
end

-- Slash command to toggle Whirlwind mode (or Single-Target mode)
SLASH_TOGGLEWW1 = "/toggleww"
SlashCmdList["TOGGLEWW"] = function()
    SNB.ToggleWhirlwindMode()  -- Call the original toggle function
    SNB.UpdateWhirlwindIcon()      -- Immediately update the Whirlwind icon state after toggling
end

-- Slash command for swapping to Farm mode
SLASH_SWAPFARM1 = "/swapfarm"
SlashCmdList["SWAPFARM"] = SNB.SwapToFarmMode

-- Slash command for exiting Farm mode
SLASH_EXITFARM1 = "/exitfarm"
SlashCmdList["EXITFARM"] = SNB.ExitFarmMode

-- Slash command to cast based on the active mode with throttling
SLASH_SINGLE1 = "/single"
SlashCmdList["SINGLE"] = SNB.CastBasedOnActiveFunction_Throttled

-- Register the slash command /tanksingletarget
SLASH_TANKSINGLE1 = "/tanksingletarget"
SlashCmdList["TANKSINGLE"] = SNB.CheckAndCastTankSingleTarget
