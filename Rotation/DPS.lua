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

    SNB.debug_print("Attack Power: " .. tostring(attackPower))
    SNB.debug_print("Battle Shout active: " .. tostring(x == 1))

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

    SNB.debug_print("Bloodthirst cooldown: " .. tostring(bd))
    SNB.debug_print("Whirlwind cooldown: " .. tostring(wd))
    SNB.debug_print("Hamstring cooldown: " .. tostring(hs))
    SNB.debug_print("Player mana (rage): " .. tostring(UnitMana("player")))

    -- Recast Battle Shout if needed
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        SNB.debug_print("Casting Battle Shout")
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
        return
    end

    -- Overpower logic if enabled
    if SNB.isOverpowerMode and overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.6) then
        if SNB.IsInBerserkerStance() and UnitMana("player") < 50 and st_timer > 0.5 then
            SNB.debug_print("Casting Overpower in Berserker Stance")
            CastSpellByName("Overpower")
            return
        elseif SNB.IsInBattleStance() and UnitMana("player") >= 5 then
            SNB.debug_print("Casting Overpower in Battle Stance")
            CastSpellByName("Overpower")
            return
        elseif not SNB.IsInBerserkerStance() then
            SNB.debug_print("Switching to Berserker Stance for Overpower")
            CastSpellByName("Berserker Stance")
            return
        end
    end

    -- Logic based on Windfury presence
    local hasWindfury = SNB.IsMainHandEnchantActive()

    if hasWindfury then
        -- Boss rotation with Windfury
        if bdStart == 0 and UnitMana("player") >= 30 then
            SNB.debug_print("Casting Bloodthirst with Windfury")
            CastSpellByName("Bloodthirst")
        elseif flurryTimeLeft == nil and hsStart == 0 and UnitMana("player") >= 50 and bd > 1.5 and st_timer > 1 then
            SNB.debug_print("Casting Hamstring with Windfury")
            CastSpellByName("Hamstring")
        elseif SNB.isWhirlwindMode and wdStart == 0 and bd > 1.5 and UnitMana("player") >= 30 then
            SNB.debug_print("Casting Whirlwind with Windfury")
            CastSpellByName("Whirlwind")
        elseif bd > 1.5 and wd > 1.5 and UnitMana("player") >= 65 and st_timer > 0.5 then
            SNB.debug_print("Casting Sunder Armor with Windfury")
            CastSpellByName("Sunder Armor")
        end
    else
        -- Farm rotation without Windfury
        if bdStart == 0 and UnitMana("player") >= 30 then
            SNB.debug_print("Casting Bloodthirst without Windfury")
            CastSpellByName("Bloodthirst")
        elseif flurryTimeLeft == nil and UnitMana("player") >= 60 and (bd > 1.5 and wd > 1.5) then
            SNB.debug_print("Casting Hamstring without Windfury")
            CastSpellByName("Hamstring")
        elseif SNB.isWhirlwindMode and wdStart == 0 and bd > 1 and UnitMana("player") >= 25 then
            SNB.debug_print("Casting Whirlwind without Windfury")
            CastSpellByName("Whirlwind")
        end
    end

    -- Heroic Strike logic
    if UnitMana("player") >= 12 and st_timer > 0.5 and not SNB.IsHeroicStrikeQueued() then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    end

    -- Cancel Heroic Strike if low rage or priorities change
    if SNB.IsHeroicStrikeQueued() then
        if wd < 1.5 and bd < 1.5 and UnitMana("player") < 67 then
            SNB.debug_print("Stopping Heroic Strike due to cooldowns and low rage")
            SpellStopCasting("Heroic Strike")
        elseif bd <= 1 and UnitMana("player") < 47 then
            SNB.debug_print("Stopping Heroic Strike due to Bloodthirst cooldown and low rage")
            SpellStopCasting("Heroic Strike")
        elseif wd <= 1 and UnitMana("player") < 42 then
            SNB.debug_print("Stopping Heroic Strike due to Whirlwind cooldown and low rage")
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 35 then
            SNB.debug_print("Stopping Heroic Strike due to critically low rage")
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

    SNB.debug_print("Attack Power: " .. tostring(attackPower))
    SNB.debug_print("Battle Shout active: " .. tostring(x == 1))

    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind

    local bd = (bdStart + bdDuration) - GetTime()
    local wd = (wdStart + wdDuration) - GetTime()

    -- Sanity check for cooldown values
    if bd < 0 then bd = 0 end
    if wd < 0 then wd = 0 end

    SNB.debug_print("Bloodthirst cooldown: " .. tostring(bd))
    SNB.debug_print("Whirlwind cooldown: " .. tostring(wd))
    SNB.debug_print("Player mana (rage): " .. tostring(UnitMana("player")))

    SNB.debug_print("Checking Battle Shout conditions")
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        SNB.debug_print("Casting Battle Shout")
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    elseif bdStart == 0 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    elseif SNB.isWhirlwindMode and wdStart == 0 and bd > 1 and UnitMana("player") >= 80 then
        SNB.debug_print("Casting Whirlwind")
        CastSpellByName("Whirlwind")
    elseif not SNB.isWhirlwindMode and flurryTimeLeft == nil and hsStart == 0 and UnitMana("player") >= 50 and bd > 1.5 and st_timer > 1 then
        SNB.debug_print("Casting Hamstring (no Flurry active, 50+ rage, and Bloodthirst on cooldown)")
        CastSpellByName("Hamstring")
    elseif bd > 1.5 and UnitMana("player") >= 35 and st_timer > 0.5 then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    end

    if bd < 1.5 and UnitMana("player") >= 37 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    elseif bd < 1 and UnitMana("player") >= 47 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    elseif bd > 3 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    end

    -- Cancel Heroic Strike if below rage thresholds
    if SNB.IsHeroicStrikeQueued() then
        if bd <= 1 and UnitMana("player") < 42 and st_timer < 0.5 then
            SNB.debug_print("Stopping Heroic Strike due to Bloodthirst cooldown and low rage")
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 30 and st_timer < 0.5 then
            SNB.debug_print("Stopping Heroic Strike due to low rage")
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

    SNB.debug_print("Attack Power: " .. tostring(attackPower))
    SNB.debug_print("Battle Shout active: " .. tostring(x == 1))

    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind
    
    local wd = (wdStart + wdDuration) - GetTime()

    -- Sanity check for cooldown values
    if wd < 0 then wd = 0 end

    SNB.debug_print("Whirlwind cooldown: " .. tostring(wd))
    SNB.debug_print("Player mana (rage): " .. tostring(UnitMana("player")))

    SNB.debug_print("Checking Battle Shout conditions")
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        SNB.debug_print("Casting Battle Shout")
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    elseif wdStart == 0 and UnitMana("player") >= 25 then
        SNB.debug_print("Casting Whirlwind")
        CastSpellByName("Whirlwind")
    elseif overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.3) and wd > 3 and UnitMana("player") < 50 then
        SNB.debug_print("Casting Overpower due to proc, sufficient time left, and rage < 50")
        CastSpellByName("Overpower")
    elseif overpowerReady and GetTime() < (SNB.overpowerProcEndTime - 0.3) and UnitMana("player") < 25 then
        SNB.debug_print("Casting Overpower due to proc, sufficient time left, and rage < 50")
        CastSpellByName("Overpower")
    elseif wd > 0.5 and UnitMana("player") >= 60 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    elseif wd > 3 and UnitMana("player") >= 50 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    elseif wd > 1 and UnitMana("player") >= 40 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        SNB.debug_print("Casting Sunder Armor")
    elseif wd > 2 and UnitMana("player") >= 30 and st_timer > 0.3 and SNB.IsWindfuryAvailable() and SNB.IsShamanInGroup() then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    elseif wd > 1.6 and UnitMana("player") > 99 and SNB.IsShamanInGroup() and st_timer > 1 and SNB.IsWindfuryAvailable() then
        SNB.debug_print("Rage Dump Sunder Armor - Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    end

    if wd < 1.5 and UnitMana("player") >= 35 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    elseif wd < 1 and UnitMana("player") >= 45 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    elseif wd > 3 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    end

    -- Cancel Heroic Strike if below 20 rage or if Bloodthirst is off cooldown and rage is less than 30
    if SNB.IsHeroicStrikeQueued() then
        if wd <= 1 and UnitMana("player") < 42 and st_timer < 0.5 then
            SNB.debug_print("Stopping Heroic Strike due to Bloodthirst cooldown and low rage")
            SpellStopCasting("Heroic Strike")
        elseif wd > 3 and UnitMana("player") < 20 and st_timer > 0.5 then
            SNB.debug_print("Stopping Heroic Strike due to low rage")
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 30 then
            SNB.debug_print("Stopping Heroic Strike due to low rage")
            SpellStopCasting("Heroic Strike")
        end
    end
end