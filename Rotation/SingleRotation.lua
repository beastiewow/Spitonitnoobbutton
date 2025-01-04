-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Main function to determine which spell-casting function to call from /single
function SNB.CastBasedOnActiveFunction()
    -- Determine if player has Mortal Strike, Bloodthirst, or Cleave Build
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    local hasBloodthirst = SNB.HasTalent("Bloodthirst")
    local hasCleaveBuild = SNB.HasCleaveBuild()

    if SNB.IsInDefensiveStance() then
        -- Tank rotation when in Defensive Stance
        SNB.debug_print("Using Tank Single Target Rotation")
        SNB.CheckAndCastTankSingleTarget()

    elseif SNB.IsTwoHanderEquipped() then
        -- Cleave Build check for all modes when using a two-hander
        if hasCleaveBuild then
            SNB.debug_print("Using Cleave Build Single Target Rotation")
            SNB.CheckAndCastSpell2handerCleaveBuildSingle()
        elseif hasMortalStrike then
            -- Use Mortal Strike Slam rotation if Mortal Strike talent is detected
            SNB.debug_print("Using Arms Single Target Rotation with Slam")
            SNB.ArmsSingleTargetUnified()
        elseif hasBloodthirst then
            -- Two-Handed specific rotation with unified logic
            SNB.debug_print("Using Unified Two-Handed Rotation")
            SNB.CheckAndCastSpell2handerUnified()
        end

    elseif SNB.IsInBerserkerStance() then
        -- Berserker Stance logic
        SNB.EquipOffhandIfInBerserkerStance()  -- Equip offhand if in Berserker Stance

        if SNB.IsMainHandEnchantActive() then
            -- Boss Mode with Windfury
            SNB.debug_print("Boss Mode with Windfury in Berserker Stance")
            SNB.CheckAndCastSpellUnified()
        else
            -- Farm Mode without Windfury
            SNB.debug_print("Farm Mode without Windfury in Berserker Stance")
            SNB.CheckAndCastSpellUnified()
        end

    elseif SNB.IsInBattleStance() then
        -- Battle Stance logic
        SNB.EquipOffhandIfInBerserkerStance()  -- Equip offhand if in Battle Stance

        if SNB.IsMainHandEnchantActive() then
            -- Boss Mode with Windfury in Battle Stance
            SNB.debug_print("Boss Mode with Windfury in Battle Stance")
            SNB.CheckAndCastSpellUnified()
        else
            -- Farm Mode without Windfury in Battle Stance
            SNB.debug_print("Farm Mode without Windfury in Battle Stance")
            SNB.CheckAndCastSpellUnified()
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
            SNB.debug_print("Switched to Farm Mode with Whirlwind.")
        else
            SNB.debug_print("Switched to Farm Mode without Whirlwind.")
        end
    else
        -- Boss Mode
        if SNB.isWhirlwindMode then
            SNB.debug_print("Switched to Boss Mode with Whirlwind.")
        else
            SNB.debug_print("Switched to Boss Mode without Whirlwind.")
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
            SNB.debug_print("Switched to Farm Mode with Overpower.")
        else
            SNB.debug_print("Switched to Farm Mode without Overpower.")
        end
    else
        -- Boss Mode
        if SNB.isOverpowerMode then
            SNB.debug_print("Switched to Boss Mode with Overpower.")
        else
            SNB.debug_print("Switched to Boss Mode without Overpower.")
        end
    end
end

-- Slash command to toggle Overpower mode
SLASH_TOGGLEOVERPOWER1 = "/toggleop"
SlashCmdList["TOGGLEOVERPOWER"] = SNB.ToggleOverpowerMode


-- Slash command to swap to Farm mode
function SNB.SwapToFarmMode()
    SNB.isFarmMode = true
    SNB.debug_print("Switched to Farm mode. Using current Whirlwind setting.")
end

-- Slash command to reset from Farm mode and allow Whirlwind/Single toggle for Boss Mode
function SNB.ExitFarmMode()
    if SNB.isFarmMode then
        SNB.isFarmMode = false
        SNB.debug_print("Exited Farm mode. Using current Whirlwind setting for Boss mode.")
    end
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

-- Slash command to cast based on the active mode
SLASH_SINGLE1 = "/single"
SlashCmdList["SINGLE"] = SNB.CastBasedOnActiveFunction

-- Register the slash command /tanksingletarget
SLASH_TANKSINGLE1 = "/tanksingletarget"
SlashCmdList["TANKSINGLE"] = SNB.CheckAndCastTankSingleTarget