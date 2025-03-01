-- Unified Arms Single Target Rotation
function SNB.ArmsSingleTargetUnified()
    -- Battle Shout Check
    local i, hasBattleShout = 1, false
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            hasBattleShout = true
        end
        i = i + 1
    end
    if not hasBattleShout and SNB.CanCastBattleShout() then
        CastSpellByName("Battle Shout")
        return
    end

    -- Get cooldowns for Mortal Strike and Whirlwind
    local msStart, msDuration = SNB.GetSpellCooldownById(21553) -- Mortal Strike
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local msCooldown = (msStart + msDuration) - GetTime()
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local overpowerReady = SNB.IsOverpowerAvailable() -- Custom function to check Overpower availability
    local rage = UnitMana("player")

    -- Overpower logic
    if SNB.isOverpowerMode and overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.6) and st_timer < 2 and msCooldown >= 0.5 then
        if SNB.IsInBattleStance() and rage > 5 then
            CastSpellByName("Overpower")
            return
        elseif not SNB.IsInBattleStance() then
            CastSpellByName("Battle Stance")
            return
        end
    elseif not overpowerReady and not SNB.IsInBerserkerStance() then
        CastSpellByName("Berserker Stance")
    end

    -- Mortal Strike logic
    if rage >= 30 and msCooldown <= 0 then
        CastSpellByName("Mortal Strike")
        return
    end

    -- Whirlwind logic based on toggle
    if SNB.isWhirlwindMode and rage >= 25 and wwCooldown <= 0 and msCooldown > 1.2 then
        CastSpellByName("Whirlwind")
        return
    end

    -- Slam logic
    if rage >= 15 and (st_timer < 3.4 and st_timer > 1.4) then
        SNB.debug_print("Casting Slam due to high rage and cooldown proximity")
        CastSpellByName("Slam")
    end

    -- Heroic Strike logic
    if not SNB.IsHeroicStrikeQueued() and rage > 100 and st_timer > 3 then
        CastSpellByName("Heroic Strike")
    elseif SNB.IsHeroicStrikeQueued() and rage < 60 then
        SpellStopCasting("Heroic Strike")
    end
end


-- AOE Rotation function for Arms Warrior in SNB namespace
function SNB.ArmsAOERotation()
    -- Battle Shout Check
    local i, hasBattleShout = 1, false
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            hasBattleShout = true
        end
        i = i + 1
    end
    if not hasBattleShout and SNB.CanCastBattleShout() then
        CastSpellByName("Battle Shout")
        return
    end

    -- Get cooldowns for Mortal Strike and Whirlwind
    local msStart, msDuration = SNB.GetSpellCooldownById(12294) -- Mortal Strike
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local msCooldown = (msStart + msDuration) - GetTime()
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local rage = UnitMana("player")

    -- AOE Rotation priority order
    -- 1. Whirlwind if off cooldown and 25+ rage
    if rage >= 25 and wwCooldown <= 0 then
        CastSpellByName("Whirlwind")
    elseif rage >= 55 and msCooldown <= 0 then
        CastSpellByName("Mortal Strike")
    elseif rage >= 30 and msCooldown <= 0 and wwCooldown > 4 then
        CastSpellByName("Mortal Strike")
    end

    -- Cleave if 30+ rage, swing timer is more than 0.5 seconds, and Cleave is not currently queued
    if not SNB.IsCleaveQueued() then
        -- 1. Cancel if both MS and WW cooldowns are <= 1.5, less than 70 rage, and swing timer <= 0.5
        if rage > 90 then
            CastSpellByName("Cleave")
        elseif rage > 70 and wwCooldown > 5.5 then
            CastSpellByName("Cleave")
        elseif rage > 50 and wwCooldown > 5.5 and msCooldown > 2.5 then
            CastSpellByName("Cleave")
        elseif rage > 20 and wwCooldown > 5.5 and msCooldown > 5 then
            CastSpellByName("Cleave")
        end
    end
end

-- Macro to call the Arms AOE Rotation function
SLASH_ARMSAOE1 = "/armsaoe"
SlashCmdList["ARMSAOE"] = function()
    SNB.ArmsAOERotation()
end

-- Function to cast Sweeping Strikes with stance management based on cooldown and active status
function SNB.CastSweepingStrikes()
    -- Check Sweeping Strikes cooldown
    local ssStart, ssDuration = SNB.GetSpellCooldownById(12292)  -- Replace 12292 with Sweeping Strikes ID
    local ssCooldown = (ssStart + ssDuration) - GetTime()

    -- Check if Sweeping Strikes is already active
    local isSweepingStrikesActive = SNB.SweepingStrikesActive()

    -- Check Bloodrage cooldown
    local brStart, brDuration = SNB.GetSpellCooldownById(2687) -- Replace 2687 with Bloodrage ID
    local brCooldown = (brStart + brDuration) - GetTime()

    -- Current rage
    local rage = UnitMana("player")

    -- If Sweeping Strikes is on cooldown or already active, switch to Berserker Stance
    if ssCooldown > 0 or isSweepingStrikesActive then
        if not SNB.IsInBerserkerStance() then
            CastSpellByName("Berserker Stance")
        end
        return
    end

    -- If Sweeping Strikes is off cooldown and not active, ensure enough rage
    if rage < 10 and brCooldown <= 0 then
        CastSpellByName("Bloodrage")
        return -- Exit to let Bloodrage generate rage before continuing
    end

    -- Switch to Battle Stance and cast Sweeping Strikes
    if not SNB.IsInBattleStance() then
        CastSpellByName("Battle Stance")
    end

    CastSpellByName("Sweeping Strikes")

    -- After casting Sweeping Strikes, swap back to Berserker Stance
    if not SNB.IsInBerserkerStance() then
        CastSpellByName("Berserker Stance")
    end
end



-- Macro to call the Sweeping Strikes stance-swap function
SLASH_SWEEPINGSTRIKES1 = "/sweepingstrikes"
SlashCmdList["SWEEPINGSTRIKES"] = function()
    SNB.CastSweepingStrikes()
end
