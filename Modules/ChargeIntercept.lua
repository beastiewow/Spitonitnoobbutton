-- Function to handle charge/intercept macro logic
function SNB.ChargeOrIntercept()
    local g = GetShapeshiftFormInfo
    local c = CastSpellByName
    local t, n, bas = g(1)
    local t, n, ber = g(3)
    if UnitAffectingCombat("player") then
        if ber then
            SNB.debug_print("Casting Intercept")
            c("Intercept")
        else
            SNB.debug_print("Switching to Berserker Stance")
            c("Berserker Stance")
        end
    else
        if bas then
            SNB.debug_print("Casting Charge")
            c("Charge")
        else
            SNB.debug_print("Switching to Battle Stance")
            c("Battle Stance")
        end
    end
end

-- Check if Sweeping Strikes is talented
local function IsSweepingStrikesTalented()
    local _, _, _, _, rank = GetTalentInfo(1, 13) -- Arms tree, talent position 11
    return rank > 0
end

-- Function to handle charge/intercept with Sweeping Strikes behavior
function SNB.ChargeOrInterceptWithSweeping()
    local g = GetShapeshiftFormInfo
    local c = CastSpellByName
    local UnitAffectingCombat = UnitAffectingCombat
    local GetSpellCooldown = SNB.GetSpellCooldownById
    local UnitMana = UnitMana

    -- Sweeping Strikes conditions
    local sweepingStrikesAvailable = IsSweepingStrikesTalented() and SNB.isSweepingStrikesMode
    local sweepingStrikesCooldownStart, sweepingStrikesCooldownDuration = GetSpellCooldown(12292) -- Sweeping Strikes
    local sweepingStrikesReady = (sweepingStrikesCooldownStart + sweepingStrikesCooldownDuration - GetTime()) <= 0
    local rage = UnitMana("player")

    -- Get stance info
    local _, _, bas = g(1) -- Battle Stance
    local _, _, ber = g(3) -- Berserker Stance

    if not UnitAffectingCombat("player") then
        -- Out of combat
        if sweepingStrikesAvailable and sweepingStrikesReady then
            if not bas then
                SNB.debug_print("Switching to Battle Stance for Charge and Sweeping Strikes.")
                c("Battle Stance")
                return
            end
            SNB.debug_print("Casting Charge and preparing to cast Sweeping Strikes.")
            c("Charge")
            rage = UnitMana("player")
            if rage >= 10 then
                SNB.debug_print("Casting Sweeping Strikes after Charge.")
                c("Sweeping Strikes")
            else
                SNB.debug_print("Not enough rage for Sweeping Strikes after Charge.")
            end
        else
            -- Default Charge logic
            if not bas then
                SNB.debug_print("Switching to Battle Stance for normal Charge.")
                c("Battle Stance")
            else
                SNB.debug_print("Casting normal Charge.")
                c("Charge")
            end
        end
    else
        -- In combat
        if sweepingStrikesAvailable and sweepingStrikesReady then
            if not bas then
                SNB.debug_print("Switching to Battle Stance for Sweeping Strikes in combat.")
                c("Battle Stance")
                return
            end
            SNB.debug_print("Casting Sweeping Strikes in combat.")
            c("Sweeping Strikes")
        else
            -- Default Intercept logic
            if not ber then
                SNB.debug_print("Switching to Berserker Stance for Intercept.")
                c("Berserker Stance")
            else
                SNB.debug_print("Casting Intercept.")
                c("Intercept")
            end
        end
    end
end

-- Function to determine which Charge/Intercept logic to use
function SNB.TalentedChargeOrIntercept()
    local hasBloodthirst = SNB.HasTalent("Bloodthirst")
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    if hasBloodthirst then
        SNB.debug_print("Using regular Charge/Intercept rotation (Bloodthirst).")
        SNB.ChargeOrIntercept()
    elseif hasMortalStrike then
        SNB.debug_print("Using Charge/Intercept with Sweeping Strikes behavior (Mortal Strike).")
        SNB.ChargeOrInterceptWithSweeping()
    else
        SNB.debug_print("No capstone talents found, using Charge/Intercept with Sweeping Strikes behavior.")
        SNB.ChargeOrInterceptWithSweeping()
    end
end

-- Slash command to use the dynamic Charge/Intercept function
SLASH_CHARGEINTERCEPT1 = "/ci"
SlashCmdList["CHARGEINTERCEPT"] = function()
    SNB.TalentedChargeOrIntercept()
end
