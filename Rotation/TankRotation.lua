-- Tanking rotation: Heroic Strike, Revenge, and Bloodthirst
function SNB.CheckAndCastTankSingleTarget()
    local i = 1
    local x = 0
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    
    -- Check for Battle Shout buff
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            x = 1
        end
        i = i + 1
    end

    -- Cooldown and mana checks
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local revStart, revDuration, revEnabled = SNB.GetSpellCooldownById(6572) -- Revenge

    local bd = (bdStart + bdDuration) - GetTime()
    local rev = (revStart + revDuration) - GetTime()

    if bd < 0 then bd = 0 end
    if rev < 0 then rev = 0 end

    -- Heroic Strike if enough rage (20+ rage)
    if UnitMana("player") >= 20 then
        SNB.debug_print("Casting Heroic Strike")
        CastSpellByName("Heroic Strike")
    end

    -- Revenge when available (requires block, dodge, or parry)
    if revStart == 0 and UnitMana("player") >= 5 then
        SNB.debug_print("Casting Revenge")
        CastSpellByName("Revenge")
    end

    -- Bloodthirst when available (30+ rage)
    if bdStart == 0 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    end

    -- Stop Heroic Strike if low rage and Bloodthirst is coming off cooldown
    if SNB.IsHeroicStrikeQueued() then
        if bd <= 1 and UnitMana("player") < 47 and st_timer < 0.5 then
            SNB.debug_print("Stopping Heroic Strike due to low rage and Bloodthirst priority")
            SpellStopCasting("Heroic Strike")
        elseif UnitMana("player") < 25 and st_timer < 0.5 then
            SNB.debug_print("Stopping Heroic Strike due to low rage")
            SpellStopCasting("Heroic Strike")
        end
    end
end

-- Tanking rotation: Cleave, Revenge, and Bloodthirst
function SNB.CheckAndCastTankAOE()
    local i = 1
    local x = 0
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    
    -- Check for Battle Shout buff
    while UnitBuff("player", i) do
        if UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_BattleShout" then
            x = 1
        end
        i = i + 1
    end

    -- Cooldown and mana checks
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local revStart, revDuration, revEnabled = SNB.GetSpellCooldownById(6572) -- Revenge

    local bd = (bdStart + bdDuration) - GetTime()
    local rev = (revStart + revDuration) - GetTime()

    if bd < 0 then bd = 0 end
    if rev < 0 then rev = 0 end

    -- Heroic Strike if enough rage (20+ rage)
    if UnitMana("player") >= 20 then
        SNB.debug_print("Casting Cleave")
        CastSpellByName("Cleave")
    end

    -- Revenge when available (requires block, dodge, or parry)
    if revStart == 0 and UnitMana("player") >= 5 then
        SNB.debug_print("Casting Revenge")
        CastSpellByName("Revenge")
    end

    -- Bloodthirst when available (30+ rage)
    if bdStart == 0 and UnitMana("player") >= 30 then
        SNB.debug_print("Casting Bloodthirst")
        CastSpellByName("Bloodthirst")
    end

    -- Stop Cleave if low rage and Bloodthirst is coming off cooldown
    if SNB.IsCleaveQueued() then
        if bd <= 1 and UnitMana("player") < 50 and st_timer < 0.5 then
            SNB.debug_print("Stopping Cleave due to low rage and Bloodthirst priority")
            SpellStopCasting("Cleave")
        elseif UnitMana("player") < 30 and st_timer < 0.5 then
            SNB.debug_print("Stopping Cleave due to low rage")
            SpellStopCasting("Cleave")
        end
    end
end