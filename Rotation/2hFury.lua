-- 2handed fury lua

-- Toggle function for Battle Shout behavior
-- Update your ToggleBattleShout function to include alpha updates
function SNB.ToggleBattleShout()
    SNB.battleShoutEnabled = not SNB.battleShoutEnabled
    SNB.UpdateBattleShoutButtonAlpha()
    
    -- Provide chat feedback
    if SNB.battleShoutEnabled then
        DEFAULT_CHAT_FRAME:AddMessage("Battle Shout |cff00ff00ENABLED|r", 1, 1, 0)
    else
        DEFAULT_CHAT_FRAME:AddMessage("Battle Shout |cffff0000DISABLED|r", 1, 1, 0)
    end
end

-- Slash command handler for SNB commands
SLASH_SNB1 = "/snb"
SlashCmdList["SNB"] = function(msg)
    local args = {}
    for word in string.gmatch(msg, "%S+") do
        table.insert(args, string.lower(word))
    end
    
    if args[1] == "bs" then
        SNB.ToggleBattleShout()
    else
        print("SNB Commands:")
        print("/snb bs - Toggle Battle Shout auto-casting")
    end
end

-- Function to check if Flurry buff is active using Superwow's buff ID system
function SNB.HasFlurryBuff()
    for i = 0, 32 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local buffID = GetPlayerBuffID(i)
            if buffID == 12970 then -- Flurry buff ID
                return true
            end
        end
    end
    return false
end

function SNB.TwoHandedFury()
    -- Battle Shout Check (if enabled)
    if SNB.battleShoutEnabled then
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
    end

    -- Get cooldowns for Bloodthirst and Whirlwind
    local bdStart, bdDuration = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local bdCooldown = (bdStart + bdDuration) - GetTime()
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local rage = UnitMana("player")

    -- Bloodthirst logic
    if rage >= 30 and bdCooldown <= 0.5 then
        CastSpellByName("Bloodthirst")
        return
    end

    -- Whirlwind logic based on toggle
    if SNB.isWhirlwindMode and rage >= 25 and wwCooldown <= 0.5 then
        CastSpellByName("Whirlwind")
        return
    end

    -- Slam logic - Adjusted for Flurry buff (2.5s without Flurry, 1.7s with Flurry)
    local hasFlurry = SNB.HasFlurryBuff()
    if hasFlurry then
        -- With Flurry: 1.7s cast time, use tighter timing windows
        if rage >= 30 and (st_timer < 3 and st_timer > 1.6) and bdCooldown > 0.5 then
            SNB.debug_print("Casting Slam with Flurry due to high rage and cooldown proximity")
            CastSpellByName("Slam")
        elseif rage >= 15 and (st_timer < 3 and st_timer > 1.6) and bdCooldown > 1.5 then
            SNB.debug_print("Casting Slam with Flurry due to high rage and cooldown proximity")
            CastSpellByName("Slam")
        end
    else
        -- Without Flurry: 2.5s cast time, use original timing windows
        if rage >= 30 and (st_timer < 3.7 and st_timer > 1.6) and bdCooldown > 0.5 then
            SNB.debug_print("Casting Slam without Flurry due to high rage and cooldown proximity")
            CastSpellByName("Slam")
        elseif rage >= 15 and (st_timer < 3.7 and st_timer > 1.6) and bdCooldown > 1.5 then
            SNB.debug_print("Casting Slam without Flurry due to high rage and cooldown proximity")
            CastSpellByName("Slam")
        end
    end
end

function SNB.TwoHandedFurySlamPrio()
    -- Battle Shout Check (if enabled)
    if SNB.battleShoutEnabled then
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
    end
    
    -- Get cooldowns for Bloodthirst and Whirlwind
    local bdStart, bdDuration = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local bdCooldown = (bdStart + bdDuration) - GetTime()
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local rage = UnitMana("player")

    -- Bloodthirst logic - Fixed comment (was "Mortal Strike logic")
    if rage >= 30 and bdCooldown <= 0.5 and (st_timer < 1.8) then
        CastSpellByName("Bloodthirst")
        return
    end
    
    -- Whirlwind logic based on toggle
    if SNB.isWhirlwindMode and rage >= 25 and wwCooldown <= 0.5 and (st_timer < 1.8) then
        CastSpellByName("Whirlwind")
        return
    end
    
    -- Slam logic - Adjusted for Flurry buff (2.5s without Flurry, 1.7s with Flurry)
    local hasFlurry = SNB.HasFlurryBuff()
    if hasFlurry then
        -- With Flurry: 1.7s cast time, use tighter timing window
        if rage >= 30 and (st_timer < 3 and st_timer > 1.6) then
            SNB.debug_print("Casting Slam with Flurry due to high rage")
            CastSpellByName("Slam")
        end
    else
        -- Without Flurry: 2.5s cast time, use original timing window
        if rage >= 30 and (st_timer < 3.7 and st_timer > 2.3) then
            SNB.debug_print("Casting Slam without Flurry due to high rage")
            CastSpellByName("Slam")
        end
    end
end

function SNB.TwoHandedFurySlamPrioNoBT()
    -- Battle Shout Check (if enabled)
    if SNB.battleShoutEnabled then
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
    end
    
    -- Get cooldowns for Bloodthirst and Whirlwind
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local rage = UnitMana("player")
    
    -- Whirlwind logic based on toggle
    if SNB.isWhirlwindMode and rage >= 25 and wwCooldown <= 0.5 and (st_timer < 1.8) then
        CastSpellByName("Whirlwind")
        return
    end
    
    -- Slam logic - Adjusted for Flurry buff (2.5s without Flurry, 1.7s with Flurry)
    local hasFlurry = SNB.HasFlurryBuff()
    if hasFlurry then
        -- With Flurry: 1.7s cast time, use tighter timing window
        if rage >= 30 and (st_timer < 3 and st_timer > 1.6) then
            SNB.debug_print("Casting Slam with Flurry due to high rage")
            CastSpellByName("Slam")
        end
    else
        -- Without Flurry: 2.5s cast time, use original timing window
        if rage >= 30 and (st_timer < 3.7 and st_timer > 2.3) then
            SNB.debug_print("Casting Slam without Flurry due to high rage")
            CastSpellByName("Slam")
        end
    end
end

-- AOE Rotation function for Two-Handed Fury Warrior in SNB namespace
function SNB.TwoHandedFuryAOERotation()
    -- Battle Shout Check (if enabled)
    if SNB.battleShoutEnabled then
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
    end

    -- Get cooldowns for Bloodthirst and Whirlwind
    local bdStart, bdDuration = SNB.GetSpellCooldownById(23894) -- Bloodthirst
    local wwStart, wwDuration = SNB.GetSpellCooldownById(1680)  -- Whirlwind
    local bdCooldown = (bdStart + bdDuration) - GetTime()
    local wwCooldown = (wwStart + wwDuration) - GetTime()
    local rage = UnitMana("player")

    -- AOE Rotation priority order
    -- 1. Whirlwind if off cooldown and 25+ rage
    if rage >= 25 and wwCooldown <= 0 then
        CastSpellByName("Whirlwind")
    elseif rage >= 55 and bdCooldown <= 0 then -- Fixed: was msCooldown, now bdCooldown
        CastSpellByName("Bloodthirst")
    elseif rage >= 30 and bdCooldown <= 0 and wwCooldown > 2 then -- Fixed: was msCooldown, now bdCooldown
        CastSpellByName("Bloodthirst")
    end

    -- Cleave if 30+ rage, swing timer is more than 0.5 seconds, and Cleave is not currently queued
    if not SNB.IsCleaveQueued() then
        -- 1. Cancel if both MS and WW cooldowns are <= 1.5, less than 70 rage, and swing timer <= 0.5
        if rage > 90 then
            CastSpellByName("Cleave")
        elseif rage > 70 and wwCooldown > 5.5 then
            CastSpellByName("Cleave")
        elseif rage > 50 and wwCooldown > 5.5 and bdCooldown > 2.5 then
            CastSpellByName("Cleave")
        elseif rage > 20 and wwCooldown > 5.5 and bdCooldown > 5 then
            CastSpellByName("Cleave")
        end
    end
end