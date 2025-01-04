-- AOE spell casting logic including Bloodthirst and Battle Shout
function SNB.CheckAndCastCleaveWhirlwind()
    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst

    local wd = (wdStart + wdDuration) - GetTime()
    local bd = (bdStart + bdDuration) - GetTime()

    SNB.debug_print("Checking Battle Shout conditions for Cleave Whirlwind")
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        SNB.debug_print("Casting Battle Shout")
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    end

    if wdStart == 0 and UnitMana("player") >= 25 then
        SNB.debug_print("Casting Whirlwind")
        CastSpellByName("Whirlwind")
    elseif bdStart == 0 and wd > 5.5 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    elseif bdStart == 0 and wd > 3 and UnitMana("player") >= 40 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    elseif bdStart == 0 and wd > 0.5 and UnitMana("player") >= 55 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    end

    if UnitMana("player") >= 20 and not SNB.IsCleaveQueued() and st_timer > 0.5 then
        SNB.debug_print("Casting Cleave")
        CastSpellByName("Cleave")
    end

    -- Cancel Cleave Conditions
    if SNB.IsCleaveQueued() then
        if wd < 1.5 and bd < 1.5 and UnitMana("player") < 70 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to cooldowns and low rage")
            SpellStopCasting("Cleave")
        elseif bd <= 1 and UnitMana("player") < 50 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to Bloodthirst cooldown and low rage")
            SpellStopCasting("Cleave")
        elseif wd <= 1 and UnitMana("player") < 45 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to Whirlwind cooldown and low rage")
            SpellStopCasting("Cleave")
        elseif UnitMana("player") < 35 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to low rage")
            SpellStopCasting("Cleave")
        end
    end
end

-- AOE spell casting logic including Bloodthirst and Battle Shout
function SNB.CheckAndCastCleaveWhirlwindNOWF()
    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst

    local wd = (wdStart + wdDuration) - GetTime()
    local bd = (bdStart + bdDuration) - GetTime()

    SNB.debug_print("Checking Battle Shout conditions for Cleave Whirlwind")
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        SNB.debug_print("Casting Battle Shout")
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    end

    if wdStart == 0 and UnitMana("player") >= 25 then
        SNB.debug_print("Casting Whirlwind")
        CastSpellByName("Whirlwind")
    elseif bdStart == 0 and wd > 1.6 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    elseif bdStart == 0 and wd < 1.6 and UnitMana("player") >= 55 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    end

    if UnitMana("player") >= 20 and not SNB.IsCleaveQueued() and st_timer > 0.5 then
        SNB.debug_print("Casting Cleave")
        CastSpellByName("Cleave")
    end

    -- Cancel Cleave Conditions
    if SNB.IsCleaveQueued() then
        if wd < 1.5 and bd < 1.5 and UnitMana("player") < 70 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to cooldowns and low rage")
            SpellStopCasting("Cleave")
        elseif bd <= 1 and UnitMana("player") < 50 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to Bloodthirst cooldown and low rage")
            SpellStopCasting("Cleave")
        elseif wd <= 1 and UnitMana("player") < 45 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to Whirlwind cooldown and low rage")
            SpellStopCasting("Cleave")
        elseif UnitMana("player") < 35 and st_timer <= 0.5 then
            SNB.debug_print("Stopping Cleave due to low rage")
            SpellStopCasting("Cleave")
        end
    end
end

-- AOE spell casting logic for 2 handers
function SNB.CheckAndCastCleaveWhirlwind2Hander()
    local wdStart, wdDuration, wdEnabled = SNB.GetSpellCooldownById(1680) -- Whirlwind
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst

    local wd = (wdStart + wdDuration) - GetTime()
    local bd = (bdStart + bdDuration) - GetTime()

    SNB.debug_print("Checking Battle Shout conditions for Cleave Whirlwind")
    if SNB.NeedsRecastBattleShout() and SNB.CanCastBattleShout() then
        SNB.debug_print("Casting Battle Shout")
        CastSpellByName("Battle Shout")
        SNB.lastBattleShoutTime = GetTime()
    end

    if wd > 1.5 and UnitMana("player") >= 55 then
        SNB.debug_print("Cleave queued")
        CastSpellByName("Cleave")
    elseif wd > 3 and UnitMana("player") >= 45 then
        SNB.debug_print("Cleave queued")
        CastSpellByName("Cleave")
    elseif wd > 6 and UnitMana("player") >= 35 then
        SNB.debug_print("Casting Cleave")
        CastSpellByName("Cleave")
    end

    if wdStart == 0 and UnitMana("player") >= 25 then
        SNB.debug_print("Casting Whirlwind")
        CastSpellByName("Whirlwind")
    elseif bdStart == 0 and wd > 1.5 and UnitMana("player") >= 75 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    elseif wd > 1.5 and UnitMana("player") >= 75 and st_timer > 0.5 and SNB.IsWindfuryAvailable() then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    elseif wd > 3 and UnitMana("player") >= 55 and st_timer > 0.5 and SNB.IsWindfuryAvailable() then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    elseif wd > 6 and UnitMana("player") >= 45 and st_timer > 0.5 and SNB.IsWindfuryAvailable() then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
    end

    -- Cancel Cleave Conditions
    if SNB.IsCleaveQueued() then
        if wd < 1.5 and UnitMana("player") < 65 then
            SNB.debug_print("Stopping Cleave due to cooldowns and low rage")
            SpellStopCasting("Cleave")
        elseif wd < 3 and UnitMana("player") < 45 then
            SNB.debug_print("Stopping Cleave due to Whirlwind cooldown and low rage")
            SpellStopCasting("Cleave")
        elseif UnitMana("player") < 35 then
            SNB.debug_print("Stopping Cleave due to low rage")
            SpellStopCasting("Cleave")
        end
    end
end

-- General spell casting 2hander boss
function SNB.CheckAndCastSpell2handerCleaveBuildAOE()
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

    if wd > 1.5 and UnitMana("player") >= 35 then
        SNB.debug_print("Cleave queued")
        CastSpellByName("Cleave")
    elseif wd > 3 and UnitMana("player") >= 35 then
        SNB.debug_print("Cleave queued")
        CastSpellByName("Cleave")
    elseif wd > 6 and UnitMana("player") >= 20 then
        SNB.debug_print("Casting Cleave")
        CastSpellByName("Cleave")
    end

    -- Cancel Cleave Conditions
    if SNB.IsCleaveQueued() then
        if wd < 1.5 and UnitMana("player") < 35 then
            SNB.debug_print("Stopping Cleave due to cooldowns and low rage")
            SpellStopCasting("Cleave")
        elseif wd < 3 and UnitMana("player") < 35 then
            SNB.debug_print("Stopping Cleave due to Whirlwind cooldown and low rage")
            SpellStopCasting("Cleave")
        elseif UnitMana("player") < 35 then
            SNB.debug_print("Stopping Cleave due to low rage")
            SpellStopCasting("Cleave")
        end
    end
end