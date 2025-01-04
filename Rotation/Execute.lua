-- Function for handling the 20% health threshold for Bloodthirst or Execute, with Bloodrage for Enrage optimization
function SNB.CheckAndCastBloodthirstOrExecute()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local currentRage = UnitMana("player") -- Get current rage value

    -- Debug lines to print current Attack Power and Rage
    SNB.debug_print("Current Attack Power: " .. tostring(attackPower))
    SNB.debug_print("Current Rage: " .. tostring(currentRage))

    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst

    -- Calculate Bloodthirst cooldown
    local bdCooldown = bdStart + bdDuration - GetTime()
    if bdCooldown < 0 then bdCooldown = 0 end

    -- If the target is below 20% HP, activate Execute/Bloodthirst logic
    if targetHealthPercent <= 20 then
        -- Condition to use Bloodthirst if attack power > 1800, rage between 30-35, and Bloodthirst is off cooldown
        if attackPower > 1800 and currentRage >= 30 and currentRage <= 35 and bdCooldown == 0 then
            SNB.debug_print("Casting Bloodthirst due to attack power > 1800, rage between 30-35, and Bloodthirst off cooldown")
            CastSpellByName("Bloodthirst")
        -- Otherwise, use Execute if rage >= 10
        elseif currentRage >= 15 then
            SNB.debug_print("Casting Execute due to target HP <= 20% and enough rage")
            CastSpellByName("Execute")
        else
            SNB.debug_print("Not enough rage to cast Execute or Bloodthirst")
        end
    else
        SNB.debug_print("Target health > 20%, not casting Bloodthirst or Execute")
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

    -- Debugging current attack power and rage
    SNB.debug_print("Current Attack Power: " .. tostring(attackPower) .. ", Current Rage: " .. tostring(currentRage))

    -- If Enrage is not active, Bloodthirst cooldown > 0.5 sec, and Bloodrage is off cooldown, cast Bloodrage
    if not enrageActive and bdStart + bdDuration - GetTime() > 0.5 and brStart == 0 then
        SNB.debug_print("Casting Bloodrage to trigger Enrage as Bloodthirst is on cooldown and Enrage is not active")
        CastSpellByName("Bloodrage")
        return -- Exit to allow Bloodrage to proc Enrage before considering other actions
    end

    -- Check if Cleave is queued
    local CleaveIsQueued = SNB.IsCleaveQueued()  -- Call function to determine if Cleave is queued

    -- If the target is below 20% HP, activate Execute/Bloodthirst logic
    if targetHealthPercent <= 20 then
        -- Check if Cleave is queued and swing timer is less than 1.5 seconds, and enough rage
        if CleaveIsQueued and st_timer < 0.5 and currentRage >= 30 then
            SNB.debug_print("Pausing Execute/Bloodthirst: Cleave is queued and swing timer is less than 1.5 seconds.")
            return -- Pausing Execute/Bloodthirst until Cleave goes off
        end

        -- Bloodthirst condition
        if attackPower >= 2000 and bdStart == 0 and currentRage >= 30 then
            SNB.debug_print("Casting Bloodthirst due to AP >= 2000 and Bloodthirst off cooldown")
            CastSpellByName("Bloodthirst")
        elseif currentRage >= 10 then
            SNB.debug_print("Casting Execute due to target HP <= 20% and enough rage")
            CastSpellByName("Execute")

            -- Queue Cleave if there is enough rage (20 rage or more)
            if currentRage >= 20 then
                SNB.debug_print("Queuing Cleave: Rage is sufficient.")
                CastSpellByName("Cleave")
            end
        else
            SNB.debug_print("Not enough rage to cast Execute")
        end
    else
        SNB.debug_print("Target health > 20%, not casting Bloodthirst or Execute")
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

    -- Debug Information
    SNB.debug_print("Attack Power: " .. tostring(attackPower))
    SNB.debug_print("Rage: " .. tostring(rage))
    SNB.debug_print("Target Health Percent: " .. tostring(targetHealthPercent))
    SNB.debug_print("Is Boss: " .. tostring(isBoss))
    SNB.debug_print("Execute Cooldown: " .. tostring(exeCooldown))
    SNB.debug_print("Swing Timer: " .. tostring(st_timer))

    -- Boss logic
    if isBoss then
        -- Target between 5% and 20% HP
        if targetHealthPercent <= 20 then
            SNB.debug_print("Non-Boss: Casting Execute (Health <= 20%, Rage >= 15)")
            CastSpellByName("Execute")
            return
        end

        -- Target at or below 5% HP
        if targetHealthPercent <= 5 and rage >= 15 then
            SNB.debug_print("Boss: Casting Execute (Health <= 5%, Rage >= 15)")
            CastSpellByName("Execute")
            return
        end
    end

    -- Non-boss logic
    if not isBoss and targetHealthPercent <= 20 and rage >= 15 then
        SNB.debug_print("Non-Boss: Casting Execute (Health <= 20%, Rage >= 15)")
        CastSpellByName("Execute")
        return
    end

    -- No valid condition met
    SNB.debug_print("No valid condition met for Execute or Slam.")
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

    -- Debugging current attack power and rage
    SNB.debug_print("Current Attack Power: " .. tostring(attackPower) .. ", Current Rage: " .. tostring(currentRage))

    -- Trigger Bloodrage if Enrage is inactive and Bloodrage is off cooldown
    if not enrageActive and brStart == 0 then
        SNB.debug_print("Casting Bloodrage to trigger Enrage as it is not active and Bloodrage is off cooldown")
        CastSpellByName("Bloodrage")
        return
    end

    -- Check if Cleave is queued
    local CleaveIsQueued = SNB.IsCleaveQueued()

    -- Execute phase logic
    if targetHealthPercent <= 20 then
        -- Pause Execute if Cleave is queued and swing timer is less than 1.5 seconds, and enough rage
        if CleaveIsQueued and st_timer < 0.5 and currentRage >= 30 then
            SNB.debug_print("Pausing Execute: Cleave is queued and swing timer is less than 1.5 seconds.")
            return
        end

        -- Execute if rage >= 10
        if currentRage >= 10 then
            SNB.debug_print("Casting Execute due to target HP <= 20% and enough rage")
            CastSpellByName("Execute")

            -- Queue Cleave if there is enough rage (20 rage or more)
            if currentRage >= 20 then
                SNB.debug_print("Queuing Cleave: Rage is sufficient.")
                CastSpellByName("Cleave")
            end
        else
            SNB.debug_print("Not enough rage to cast Execute")
        end
    else
        SNB.debug_print("Target health > 20%, not casting Execute or Cleave")
    end
end

