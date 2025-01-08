-- Function for handling the 20% health threshold for Bloodthirst or Execute, with Bloodrage for Enrage optimization
function SNB.CheckAndCastBloodthirstOrExecute()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local currentRage = UnitMana("player") -- Get current rage value


    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst

    -- Calculate Bloodthirst cooldown
    local bdCooldown = bdStart + bdDuration - GetTime()
    if bdCooldown < 0 then bdCooldown = 0 end

    -- If the target is below 20% HP, activate Execute/Bloodthirst logic
    if targetHealthPercent <= 20 then
        -- Condition to use Bloodthirst if attack power > 1800, rage between 30-35, and Bloodthirst is off cooldown
        if attackPower > 1800 and currentRage >= 30 and currentRage <= 35 and bdCooldown == 0 then
            CastSpellByName("Bloodthirst")
        -- Otherwise, use Execute if rage >= 10
        elseif currentRage >= 15 then
            CastSpellByName("Execute")
        else
        end
    else
    end
end


-- Function for handling the Execute phase with Cleave and Bloodrage for Enrage optimization
function SNB.ExecuteCleave()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local currentRage = UnitMana("player") -- Get current rage value
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst cooldown info
    local brStart, brDuration, brEnabled = SNB.GetSpellCooldownById(2687) -- Bloodrage cooldown info
    local enrageActive = SNB.EnrageActive() -- Check if Enrage is active

    -- If Enrage is not active, Bloodthirst cooldown > 0.5 sec, and Bloodrage is off cooldown, cast Bloodrage
    if not enrageActive and bdStart + bdDuration - GetTime() > 0.5 and brStart == 0 then
        CastSpellByName("Bloodrage")
        return -- Exit to allow Bloodrage to proc Enrage before considering other actions
    end

    -- Check if Cleave is queued
    local CleaveIsQueued = SNB.IsCleaveQueued()  -- Call function to determine if Cleave is queued

    -- If the target is below 20% HP, activate Execute/Bloodthirst logic
    if targetHealthPercent <= 20 then
        -- Check if Cleave is queued and swing timer is less than 1.5 seconds, and enough rage
        if CleaveIsQueued and st_timer < 0.5 and currentRage >= 30 then
            return -- Pausing Execute/Bloodthirst until Cleave goes off
        end

        -- Bloodthirst condition
        if attackPower >= 2000 and bdStart == 0 and currentRage >= 30 then
            CastSpellByName("Bloodthirst")
        elseif currentRage >= 10 then
            CastSpellByName("Execute")

            -- Queue Cleave if there is enough rage (20 rage or more)
            if currentRage >= 20 then
                CastSpellByName("Cleave")
            end
        else
        end
    else
    end
end

function SNB.ArmsExecuteHS()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local isBoss = UnitClassification("target") == "worldboss" -- Check if target is a boss
    local rage = UnitMana("player")
    local exeStart, exeDuration = SNB.GetSpellCooldownById(20662) -- Execute
    local exeCooldown = (exeStart + exeDuration) - GetTime()

    -- Boss logic
    if isBoss then
        -- Target between 5% and 20% HP
        if targetHealthPercent <= 20 then
            CastSpellByName("Execute")
            return
        end

        -- Target at or below 5% HP
        if targetHealthPercent <= 5 and rage >= 15 then
            CastSpellByName("Execute")
            return
        end
    end

    -- Non-boss logic
    if not isBoss and targetHealthPercent <= 20 and rage >= 15 then
        CastSpellByName("Execute")
        return
    end
end



SLASH_ARMSSLAM1 = "/armsexe"
SlashCmdList["ARMSEXE"] = function()
    SNB.ArmsExecuteHS()
end

-- Function for handling the Execute phase with Cleave, using Bloodrage for Enrage optimization (Arms spec, no Bloodthirst)
function SNB.ArmsExecuteCleave()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local currentRage = UnitMana("player") -- Get current rage value
    local brStart, brDuration = SNB.GetSpellCooldownById(2687) -- Bloodrage cooldown info
    local enrageActive = SNB.EnrageActive() -- Check if Enrage is active

    -- Trigger Bloodrage if Enrage is inactive and Bloodrage is off cooldown
    if not enrageActive and brStart == 0 then
        CastSpellByName("Bloodrage")
        return
    end

    -- Check if Cleave is queued
    local CleaveIsQueued = SNB.IsCleaveQueued()

    -- Execute phase logic
    if targetHealthPercent <= 20 then
        -- Pause Execute if Cleave is queued and swing timer is less than 1.5 seconds, and enough rage
        if CleaveIsQueued and st_timer < 0.5 and currentRage >= 30 then
            return
        end

        -- Execute if rage >= 10
        if currentRage >= 10 then
            CastSpellByName("Execute")

            -- Queue Cleave if there is enough rage (20 rage or more)
            if currentRage >= 20 then
                CastSpellByName("Cleave")
            end
        else
        end
    else
    end
end

