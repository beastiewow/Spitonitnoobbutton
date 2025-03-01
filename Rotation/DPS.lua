-- Last cast time tracking for Battle Shout
SNB.lastBattleShoutTime = 0

function SNB.CheckAndCastSpellUnified()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local i, x = 1, 0

    -- Check for Battle Shout buff
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            x = 1
        end
        i = i + 1
    end

    -- Cooldowns
    local bdStart, bdDuration = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local wdStart, wdDuration = SNB.GetSpellCooldownById(1680) -- Whirlwind
    local hsStart, hsDuration = SNB.GetSpellCooldownById(27584) -- Hamstring
    local overpowerReady = SNB.IsOverpowerAvailable() -- Check Overpower availability

    local bd = (bdStart + bdDuration) - GetTime()
    local wd = (wdStart + wdDuration) - GetTime()
    local hs = (hsStart + hsDuration) - GetTime()

    -- Sanity check for cooldown values
    if bd < 0 then bd = 0 end
    if wd < 0 then wd = 0 end
    if hs < 0 then hs = 0 end

    -- Recast Battle Shout if needed
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
        return
    end

    -- Overpower logic if enabled
    if SNB.isOverpowerMode and overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.6) then
        if SNB.IsInBerserkerStance() and UnitMana("player") < 50 and st_timer > 0.5 then
            CastSpellByName("Overpower")
            return
        elseif SNB.IsInBattleStance() and UnitMana("player") >= 5 then
            CastSpellByName("Overpower")
            return
        elseif not SNB.IsInBerserkerStance() then
            CastSpellByName("Berserker Stance")
            return
        end
    end

    -- Logic based on Windfury presence
    local hasWindfury = SNB.IsMainHandEnchantActive()

    if hasWindfury then
        -- Boss rotation with Windfury
        if bdStart == 0 and UnitMana("player") >= 30 then
            CastSpellByName("Bloodthirst")
        elseif flurryTimeLeft == nil and hsStart == 0 and UnitMana("player") >= 50 and bd > 1.5 and st_timer > 1 then
            CastSpellByName("Hamstring")
        elseif SNB.isWhirlwindMode and wdStart == 0 and bd > 1.5 and UnitMana("player") >= 30 then
            CastSpellByName("Whirlwind")
        elseif bd > 1.5 and wd > 1.5 and UnitMana("player") >= 65 and st_timer > 0.5 then
            CastSpellByName("Sunder Armor")
        end
    else
        -- Farm rotation without Windfury
        if bdStart == 0 and UnitMana("player") >= 30 then
            CastSpellByName("Bloodthirst")
        elseif flurryTimeLeft == nil and UnitMana("player") >= 60 and (bd > 1.5 and wd > 1.5) then
            CastSpellByName("Hamstring")
        elseif SNB.isWhirlwindMode and wdStart == 0 and bd > 1 and UnitMana("player") >= 25 then
            CastSpellByName("Whirlwind")
        end
    end

    -- Heroic Strike logic
    if UnitMana("player") >= 12 and st_timer > 0.5 and not SNB.IsHeroicStrikeQueued() then
        CastSpellByName("Heroic Strike")
    end

    -- Cancel Heroic Strike if low rage or priorities change
    if SNB.IsHeroicStrikeQueued() then
        if wd < 1.5 and bd < 1.5 and UnitMana("player") < 67 then
            SpellStopCasting("Heroic Strike")
        elseif bd <= 1 and UnitMana("player") < 47 then
            SpellStopCasting("Heroic Strike")
        elseif wd <= 1 and UnitMana("player") < 42 then
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 35 then
            SpellStopCasting("Heroic Strike")
        end
    end
end

-- Unified single target spell casting logic for 2-handers
function SNB.CheckAndCastSpell2handerUnified()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local i, x = 1, 0

    -- Check for Battle Shout buff
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            x = 1
        end
        i = i + 1
    end

    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind

    local bd = (bdStart + bdDuration) - GetTime()
    local wd = (wdStart + wdDuration) - GetTime()

    -- Sanity check for cooldown values
    if bd < 0 then bd = 0 end
    if wd < 0 then wd = 0 end

    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    elseif bdStart == 0 and UnitMana("player") >= 30 then
        CastSpellByName("Bloodthirst")
    elseif SNB.isWhirlwindMode and wdStart == 0 and bd > 1 and UnitMana("player") >= 80 then
        CastSpellByName("Whirlwind")
    elseif not SNB.isWhirlwindMode and flurryTimeLeft == nil and hsStart == 0 and UnitMana("player") >= 50 and bd > 1.5 and st_timer > 1 then
        CastSpellByName("Hamstring")
    elseif bd > 1.5 and UnitMana("player") >= 35 and st_timer > 0.5 then
        CastSpellByName("Sunder Armor")
    end

    if bd < 1.5 and UnitMana("player") >= 37 then
        CastSpellByName("Heroic Strike")
    elseif bd < 1 and UnitMana("player") >= 47 then
        CastSpellByName("Heroic Strike")
    elseif bd > 3 and UnitMana("player") >= 30 then
        CastSpellByName("Heroic Strike")
    end

    -- Cancel Heroic Strike if below rage thresholds
    if SNB.IsHeroicStrikeQueued() then
        if bd <= 1 and UnitMana("player") < 42 and st_timer < 0.5 then
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 30 and st_timer < 0.5 then
            SpellStopCasting("Heroic Strike")
        end
    end
end


-- General spell casting 2hander boss
function SNB.CheckAndCastSpell2handerCleaveBuildSingle()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local i, x = 1, 0
    
    -- Check for Battle Shout buff
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            x = 1
        end
        i = i + 1
    end

    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind
    
    local wd = (wdStart + wdDuration) - GetTime()

    -- Sanity check for cooldown values
    if wd < 0 then wd = 0 end

    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    elseif wdStart == 0 and UnitMana("player") >= 25 then
        CastSpellByName("Whirlwind")
    elseif overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.3) and wd > 3 and UnitMana("player") < 50 then
        CastSpellByName("Overpower")
    elseif overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.3) and UnitMana("player") < 25 then
        CastSpellByName("Overpower")
    elseif wd > 0.5 and UnitMana("player") >= 60 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        CastSpellByName("Sunder Armor")
    elseif wd > 3 and UnitMana("player") >= 50 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        CastSpellByName("Sunder Armor")
    elseif wd > 1 and UnitMana("player") >= 40 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        CastSpellByName("Sunder Armor")
    elseif wd > 2 and UnitMana("player") >= 30 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        CastSpellByName("Sunder Armor")
    elseif wd > 1.6 and UnitMana("player") > 99 and SNB.IsShamanInGroup() and st_timer > 1 and SNB.IsWindfuryAvailable() then
        CastSpellByName("Sunder Armor")
    end

    if wd < 1.5 and UnitMana("player") >= 35 then
        CastSpellByName("Heroic Strike")
    elseif wd < 1 and UnitMana("player") >= 45 then
        CastSpellByName("Heroic Strike")
    elseif wd > 3 and UnitMana("player") >= 30 then
        CastSpellByName("Heroic Strike")
    end

    -- Cancel Heroic Strike if below 20 rage or if Bloodthirst is off cooldown and rage is less than 30
    if SNB.IsHeroicStrikeQueued() then
        if wd <= 1 and UnitMana("player") < 42 and st_timer < 0.5 then
            SpellStopCasting("Heroic Strike")
        elseif wd > 3 and UnitMana("player") < 20 and st_timer > 0.5 then
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 30 then
            SpellStopCasting("Heroic Strike")
        end
    end
end
