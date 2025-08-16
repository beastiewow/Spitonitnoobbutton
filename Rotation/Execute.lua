-----------------------------
-- Slam tracking logic
-----------------------------
-- Ensure pfUI's libcast is available globally (defined at the top of your addon)
if not pfUI or not pfUI.api or not pfUI.api.libcast then
    DEFAULT_CHAT_FRAME:AddMessage("SlamCastTracker: pfUI libcast not found! This addon requires pfUI for enhanced Slam tracking.")
    -- Note: We won't return here; we'll allow fallback behavior instead
end

local libcast = pfUI and pfUI.api and pfUI.api.libcast
local player = UnitName("player")

-- Function to get the remaining Slam cast time (returns nil if not casting or pfUI unavailable)
local function GetSlamRemainingTime()
    if not libcast then
        return nil -- pfUI libcast not available, use fallback behavior
    end

    local db = libcast.db[player]
    if db and db.cast == "Slam" and db.start and db.casttime then
        local currentTime = GetTime()
        local startTime = db.start
        local duration = db.casttime / 1000 -- Convert from milliseconds to seconds
        local elapsed = currentTime - startTime
        local remaining = duration - elapsed

        if remaining > 0 then
            return remaining -- Return remaining time in seconds
        end
    end
    return 0 -- Slam not being cast or cast has ended
end

-- Function to check if Elixir of Demonslaying buff is active
function SNB.HasElixirOfDemonslaying()
    for i = 0, 31 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local buffID = GetPlayerBuffID(i)
            if buffID == 11406 then -- Elixir of Demonslaying buff ID
                return true
            end
        end
    end
    return false
end

-- Function to check if Mark of the Champion (Argent Dawn Commission) buff is active
function SNB.HasMarkOfTheChampion()
    for i = 0, 31 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local buffID = GetPlayerBuffID(i)
            if buffID == 17670 then -- Argent Dawn Commission buff ID
                return true
            end
        end
    end
    return false
end

-- Function to check if Consecrated Sharpening Stone is active on weapons
function SNB.HasConsecratedSharpeningStone()
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
    
    -- Check main hand weapon enchant
    if hasMainHandEnchant then
        local mainHandTexture = GetInventoryItemTexture("player", 16)
        -- Consecrated Sharpening Stone has a specific texture pattern
        -- You may need to adjust this texture check based on what the actual texture path is
        if mainHandTexture and string.find(mainHandTexture, "Sharpening") then
            return true
        end
    end
    
    -- Check off hand weapon enchant (for dual wield)
    if hasOffHandEnchant then
        local offHandTexture = GetInventoryItemTexture("player", 17)
        if offHandTexture and string.find(offHandTexture, "Sharpening") then
            return true
        end
    end
    
    return false
end

-- Function to calculate effective attack power including demon slaying bonuses
function SNB.GetEffectiveAttackPower()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local bonusAP = 0
    
    -- Add bonus AP for demon slaying effects
    if SNB.HasElixirOfDemonslaying() then
        bonusAP = bonusAP + 265 -- Elixir of Demonslaying gives +265 AP vs demons
    end
    
    if SNB.HasMarkOfTheChampion() then
        bonusAP = bonusAP + 150 -- Mark of the Champion gives +150 AP vs undead
    end
    
    if SNB.HasConsecratedSharpeningStone() then
        bonusAP = bonusAP + 100 -- Consecrated Sharpening Stone gives +100 AP vs undead
    end
    
    return attackPower + bonusAP
end

-----------------------------
-- Function for handling the 20% health threshold for Bloodthirst or Execute, with Bloodrage for Enrage optimization
-----------------------------
function SNB.CheckAndCastBloodthirstOrExecute()
    local effectiveAttackPower = SNB.GetEffectiveAttackPower()
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local currentRage = UnitMana("player") -- Get current rage value
    local bdStart, bdDuration, bdEnabled = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    -- Calculate Bloodthirst cooldown
    local bdCooldown = bdStart + bdDuration - GetTime()
    if bdCooldown < 0 then bdCooldown = 0 end
    
    -- If the target is below 20% HP, activate Execute/Bloodthirst logic
    if targetHealthPercent <= 20 then
        -- Condition to use Bloodthirst if effective attack power > 2150, rage between 30-35, and Bloodthirst is off cooldown
        if effectiveAttackPower > 2150 and currentRage >= 30 and bdCooldown == 0 then
            CastSpellByName("Bloodthirst")
        -- Otherwise, use Execute if rage >= 15
        elseif currentRage >= 10 then
            CastSpellByName("Execute")
        else
            -- no action
        end
    else
        -- no action
    end
end

-----------------------------
-- Function for handling the 20% health threshold for Execute only (no Bloodthirst or Mortal Strike)
-----------------------------
function SNB.CheckAndCastExecuteOnly()
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local currentRage = UnitMana("player") -- Get current rage value
    
    -- If the target is below 20% HP, use Execute if we have enough rage
    if targetHealthPercent <= 20 then
        if currentRage >= 15 then
            CastSpellByName("Execute")
        else
            -- no action - not enough rage
        end
    else
        -- no action - target not in execute range
    end
end

-----------------------------
-- Function for handling the Execute phase with Cleave and Bloodrage for Enrage optimization (Fury version)
-----------------------------
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
        end
    end
end

-----------------------------
-- SNB – Auto-Attack Helpers (from closestattack.lua)
-----------------------------
local DEBUG = false

local function tp_print(msg)
    if type(msg) == "boolean" then msg = msg and "true" or "false" end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function debug_print(msg)
    if DEBUG then tp_print(msg) end
end

-- Check if auto-attack is currently active by iterating over action slots.
local function IsAutoAttackActive()
    for i = 1, 120 do
        if IsCurrentAction(i) then
            return true  -- Auto-attack is active
        end
    end
    return false  -- Auto-attack is not active
end

-- Roid macros auto-attack logic with stronger locking mechanism
local function StartAutoAttack()
    -- Check if a valid target exists and auto-attack isn't running
    if not IsAutoAttackActive() and UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
        debug_print("Starting auto-attack.")
        AttackTarget()  -- Start auto-attack

        -- Lock the auto-attack to prevent it from being toggled off
        Roids.CurrentSpell.autoAttackLock = true

        -- Timer to unlock after 0.2 seconds in case something interrupts
        local elapsed = 0
        Roids.Frame:SetScript("OnUpdate", function()
            elapsed = elapsed + arg1
            if Roids.CurrentSpell.autoAttackLock and elapsed > 0.2 then
                Roids.CurrentSpell.autoAttackLock = false
                Roids.Frame:SetScript("OnUpdate", nil)
            end
        end)
    else
        debug_print("Auto-attack is already active or locked.")
    end
end

-----------------------------
-- SNB – Helper: Initialize 5 Yard Spell Slot (using Execute as reference)
-----------------------------
local yard05  -- holds the action slot index for our 5-yard check (Execute)

local function SNB_InitDistance()
    for i = 1, 120 do
        local t = GetActionTexture(i)
        if t then
            if not yard05 and string.find(t, "INV_Sword_48") then
                yard05 = i
                DEFAULT_CHAT_FRAME:AddMessage("Found 5 yard spell (execute) in slot: " .. i)
                break
            end
        end
    end

    if not yard05 then
        DEFAULT_CHAT_FRAME:AddMessage("5 yard spell not found – please add execute to an action bar slot.")
    end
end

-----------------------------
-- SNB – Helper: Get a Nearby Candidate in Execute Range (≤20% HP) within 5 Yards
-- (Note: This currently uses UnitXP for distance, not the IsActionInRange check)
-----------------------------
local function SNB_GetExecuteCandidate()
    if not yard05 then
        SNB_InitDistance()
        if not yard05 then
            return nil
        end
    end

    local candidate = nil

    local function CheckCandidate(guid)
        if guid and UnitExists(guid) and not UnitIsDead(guid) and UnitCanAttack("player", guid) then
            local distance = UnitXP("distanceBetween", "player", guid, "meleeAutoAttack")  -- 1.12.1 custom distance check
            if distance and distance <= 5 then
                local curHealth = UnitHealth(guid)
                local maxHealth = UnitHealthMax(guid)
                local pct = (maxHealth and maxHealth > 0) and (curHealth / maxHealth * 100) or 0
                -- Only consider candidates at or below 20% HP.
                if pct <= 20 then
                    candidate = guid
                    return true
                end
            end
        end
        return false
    end

    -- (A) Scan PFUI nameplates (if available)
    local env = getfenv(0)
    for i = 1, 20 do
        local plate = env["pfNamePlate" .. i]
        if plate and plate:IsShown() then
            local guid
            if plate.parent and plate.parent.GetName then
                guid = plate.parent:GetName(1)
            end
            if CheckCandidate(guid) then
                return candidate
            end
        end
    end

    -- (B) Scan Blizzard default nameplates
    local frames = { WorldFrame:GetChildren() }
    for _, frame in ipairs(frames) do
        if frame:IsVisible() and (frame:GetName() == nil) then
            local guid = frame:GetName(1)
            if CheckCandidate(guid) then
                return candidate
            end
        end
    end

    return candidate
end

-----------------------------
-- SNB – Helper: Get any nearby attackable mob within 5 yards using IsActionInRange
-----------------------------
local function SNB_GetAnyCandidate()
    if not yard05 then
        SNB_InitDistance()
        if not yard05 then
            return nil
        end
    end

    local candidate = nil

    local function CheckCandidate(guid)
        if guid and UnitExists(guid) and not UnitIsDead(guid) and UnitCanAttack("player", guid) then
            -- Store whether there was a target
            local hadTarget = UnitExists("target")
            
            -- Temporarily target the candidate
            TargetUnit(guid)
            
            -- Check if within 5 yards using IsActionInRange
            local inRange = IsActionInRange(yard05)
            
            -- Restore the original target
            if hadTarget then
                TargetLastTarget() -- Switch back to the previous target
            else
                ClearTarget() -- Clear target if there was no previous target
            end

            if inRange then
                candidate = guid
                return true -- Stop scanning once a valid candidate is found
            end
        end
        return false
    end

    -- (A) Scan PFUI nameplates (if available)
    local env = getfenv(0)
    for i = 1, 20 do
        local plate = env["pfNamePlate" .. i]
        if plate and plate:IsShown() then
            local guid
            if plate.parent and plate.parent.GetName then
                guid = plate.parent:GetName(1)
            end
            if CheckCandidate(guid) then
                return candidate
            end
        end
    end

    -- (B) Scan Blizzard default nameplates
    local frames = { WorldFrame:GetChildren() }
    for _, frame in ipairs(frames) do
        if frame:IsVisible() and (frame:GetName() == nil) then
            local guid = frame:GetName(1)
            if CheckCandidate(guid) then
                return candidate
            end
        end
    end

    return candidate
end

function SNB.ArmsExecuteHS()
    if not UnitExists("target") or UnitIsDead("target") then
        return
    end

    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local isBoss = UnitClassification("target") == "worldboss"
    local rage = UnitMana("player")

    -- Boss logic: Always cancel Slam for Execute
    if isBoss then
        if targetHealthPercent <= 20 or (targetHealthPercent <= 5 and rage >= 15) then
            SpellStopCasting("Slam")
            CastSpellByName("Execute")
            StartAutoAttack()
            return
        end
    end

    -- Non-boss logic
    if not isBoss then
        local slamRemaining = GetSlamRemainingTime()
        local shouldCancelSlam = false

        if slamRemaining then -- pfUI is loaded, use enhanced logic
            if targetHealthPercent < 5 or (slamRemaining > 0.5 and targetHealthPercent <= 20) then
                shouldCancelSlam = true
            end
        else -- pfUI not loaded, use original behavior
            shouldCancelSlam = true
        end

        if targetHealthPercent <= 20 and rage >= 15 then
            if shouldCancelSlam then
                SpellStopCasting("Slam")
            end
            CastSpellByName("Execute")
            StartAutoAttack()
            return
        else
            -- Scan for a nearby candidate in Execute range
            local candidateGUID = SNB_GetExecuteCandidate()
            if candidateGUID then
                local candidatePct = (UnitHealth(candidateGUID) / UnitHealthMax(candidateGUID)) * 100
                if candidatePct < 3 or (targetHealthPercent <= 25 and candidatePct < 10) then
                    candidateGUID = nil
                end
            end

            if candidateGUID then
                TargetUnit(candidateGUID)
                if shouldCancelSlam then
                    SpellStopCasting("Slam")
                end
                CastSpellByName("Execute")
                StartAutoAttack()
                return
            else
                local currentTargetInRange = IsActionInRange(yard05)
                if currentTargetInRange then
                    StartAutoAttack()
                    return
                end

                local anyCandidate = SNB_GetAnyCandidate()
                if anyCandidate then
                    TargetUnit(anyCandidate)
                    StartAutoAttack()
                else
                end
                return
            end
        end
    end
end

-----------------------------
-- SNB – Helper: Get any nearby attackable mob within 5 yards
-----------------------------
local function SNB_GetAnyCandidate()
    if not yard05 then
        SNB_InitDistance()
        if not yard05 then
            return nil
        end
    end

    local candidate = nil

    local function CheckCandidate(guid)
        if guid and UnitExists(guid) and not UnitIsDead(guid) and UnitCanAttack("player", guid) then
            local distance = UnitXP("distanceBetween", "player", guid, "meleeAutoAttack")
            if distance and distance <= 5 then
                candidate = guid
                return true
            end
        end
        return false
    end

    -- (A) Scan PFUI nameplates (if available)
    local env = getfenv(0)
    for i = 1, 20 do
        local plate = env["pfNamePlate" .. i]
        if plate and plate:IsShown() then
            local guid
            if plate.parent and plate.parent.GetName then
                guid = plate.parent:GetName(1)
            end
            if CheckCandidate(guid) then
                return candidate
            end
        end
    end

    -- (B) Scan Blizzard default nameplates
    local frames = { WorldFrame:GetChildren() }
    for _, frame in ipairs(frames) do
        if frame:IsVisible() and (frame:GetName() == nil) then
            local guid = frame:GetName(1)
            if CheckCandidate(guid) then
                return candidate
            end
        end
    end

    return candidate
end

-----------------------------
-- SNB – Modified Arms Execute Function (with Target Swapping and Auto-Attack)
-----------------------------
function SNB.ArmsExecuteHSNoSlamTrack()
-- Abort if current target is dead or no target exists.
    if not UnitExists("target") or UnitIsDead("target") then
        return
    end

    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local isBoss = UnitClassification("target") == "worldboss"
    local rage = UnitMana("player")
    local exeStart, exeDuration = SNB.GetSpellCooldownById(20662) -- Execute cooldown info (if needed)
    local exeCooldown = (exeStart + exeDuration) - GetTime()

    -- Boss logic remains unchanged.
    if isBoss then
        if targetHealthPercent <= 20 then
            SpellStopCasting("Slam")
            CastSpellByName("Execute")
            StartAutoAttack()
            return
        end
        if targetHealthPercent <= 5 and rage >= 15 then
            SpellStopCasting("Slam")
            CastSpellByName("Execute")
            StartAutoAttack()
            return
        end
    end

    -- Non-boss logic:
    if not isBoss then
        -- (1) If current target is already in execute range, use it.
        if targetHealthPercent <= 20 and rage >= 15 then
            SpellStopCasting("Slam")
            CastSpellByName("Execute")
            StartAutoAttack()
            return
        else
            -- (2) Scan for a nearby candidate via our GUID-based method.
            local candidateGUID = SNB_GetExecuteCandidate()
            if candidateGUID then
                local candidatePct = (UnitHealth(candidateGUID) / UnitHealthMax(candidateGUID)) * 100
                -- Rule 1: Do not swap if the candidate's HP is below 3%.
                if candidatePct < 3 then
                    candidateGUID = nil
                end
                -- Rule 2: If current target is ≤ 25% and candidate's HP < 10%, maintain current target.
                if targetHealthPercent <= 25 and candidateGUID and candidatePct < 10 then
                    candidateGUID = nil
                end
            end

            if candidateGUID then
                -- Swap target, then stop Slam and cast Execute.
                TargetUnit(candidateGUID)
                SpellStopCasting("Slam")
                CastSpellByName("Execute")
                StartAutoAttack()
                return
            else
                -- (3) No candidate found – maintain current target.
                local currentTargetInRange = IsActionInRange(yard05)
                if currentTargetInRange then
                    StartAutoAttack() -- Ensure auto-attack is on for the current target
                    return
                end

                -- (4) No Execute candidate found and current target not in range, try to find any candidate within 5 yards.
                local anyCandidate = SNB_GetAnyCandidate()
                if anyCandidate then
                    TargetUnit(anyCandidate)
                    StartAutoAttack()
                else
                end
                return
            end
        end
    end
end

-----------------------------
-- New: Old-Style Arms Execute (Arms spec, no Bloodthirst)
-----------------------------
function SNB.ArmsExecuteOld()
    local baseAttackPower, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + posBuff + negBuff
    local targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    local isBoss = UnitClassification("target") == "worldboss" -- Check if target is a boss
    local rage = UnitMana("player")
    
    -- Get cooldowns for Mortal Strike, Whirlwind, and Execute
    local msStart, msDuration = SNB.GetSpellCooldownById(21553) -- Mortal Strike
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local exeStart, exeDuration = SNB.GetSpellCooldownById(20662) -- Execute
    local msCooldown = (msStart + msDuration) - GetTime()
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local exeCooldown = (exeStart + exeDuration) - GetTime()
    
    -- Boss logic
    if isBoss then
        -- Target less than 20% HP
        if targetHealthPercent <= 20 then
            -- If swing timer > 1.5s, prioritize Mortal Strike and Whirlwind over Execute
            if st_timer > 1.5 then
                -- Prioritize Mortal Strike first if off cooldown and have rage
                if rage >= 30 and msCooldown <= 0.5 then
                    SpellStopCasting("Slam")
                    CastSpellByName("Mortal Strike")
                    return
                -- Then Whirlwind if Mortal Strike is on cooldown
                elseif SNB.isWhirlwindMode and rage >= 25 and wwCooldown <= 0.5 then
                    SpellStopCasting("Slam")
                    CastSpellByName("Whirlwind")
                    return
                end
            end
            -- Use Execute if swing timer <= 1.5s or if MS/WW not available
            if rage >= 15 then
                SpellStopCasting("Slam")
                CastSpellByName("Execute")
                return
            end
        end
    end
    
    -- Non-boss logic
    if not isBoss and targetHealthPercent <= 20 then
        -- If swing timer > 1.5s, prioritize Mortal Strike and Whirlwind over Execute
        if st_timer > 1.5 then
            -- Prioritize Mortal Strike first if off cooldown and have rage
            if rage >= 30 and msCooldown <= 0.5 then
                SpellStopCasting("Slam")
                CastSpellByName("Mortal Strike")
                return
            -- Then Whirlwind if Mortal Strike is on cooldown
            elseif SNB.isWhirlwindMode and rage >= 25 and wwCooldown <= 0.5 then
                SpellStopCasting("Slam")
                CastSpellByName("Whirlwind")
                return
            end
        end
        -- Use Execute if swing timer <= 1.5s or if MS/WW not available
        if rage >= 15 then
            SpellStopCasting("Slam")
            CastSpellByName("Execute")
            return
        end
    end
end

-----------------------------
-- Slash command to test Arms Execute
-- Now calls the OLD arms execute method
-----------------------------
SLASH_ARMSSLAM1 = "/executeold"
SlashCmdList["EXECUTEOLD"] = SNB.ArmsExecuteOld

-----------------------------
-- Same function: Execute phase with Cleave, Bloodrage for Enrage (Arms spec, no Bloodthirst)
-----------------------------
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
        end
    end
end
