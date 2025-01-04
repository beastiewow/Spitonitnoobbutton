-- Buffs.lua (General Utility Functions)
-- This lua is for tracking Buffs throughout our addon
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Battle Shout Logic -- TBEdited
-- Last cast time tracking for Battle Shout
SNB.lastBattleShoutTime = 0
SNB.BATTLE_SHOUT_COOLDOWN = 3 -- 3 seconds
SNB.BATTLE_SHOUT_TEXTURE = "Interface\\Icons\\Ability_Warrior_BattleShout"
SNB.HEROIC_STRIKE_TEXTURE = "Interface\\Icons\\Ability_Rogue_Ambush" -- Change to the correct texture
SNB.CLEAVE_TEXTURE = "Interface\\Icons\\Ability_Warrior_Cleave"

-- Function to get the remaining time on Battle Shout buff
function SNB.GetBattleShoutTimeLeft()
    for i = 0, 31 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local texture = GetPlayerBuffTexture(id)
            if texture == SNB.BATTLE_SHOUT_TEXTURE then
                local timeleft = GetPlayerBuffTimeLeft(id)
                return timeleft
            end
        end
    end
    return nil
end

-- Function to check if Battle Shout needs to be recast based on remaining duration
function SNB.NeedsRecastBattleShout()
    local timeLeft = SNB.GetBattleShoutTimeLeft()
    if timeLeft and timeLeft < 10 then
        SNB.debug_print("Battle Shout needs recast: Time left is " .. tostring(timeLeft) .. " seconds")
        return true
    elseif not timeLeft then
        SNB.debug_print("Battle Shout needs recast: Not found")
        return true
    end
    SNB.debug_print("Battle Shout does not need recast: Time left is " .. tostring(timeLeft) .. " seconds")
    return false
end

-- Function to check if Battle Shout can be cast
function SNB.CanCastBattleShout()
    local currentTime = GetTime()
    local canCast = (currentTime - SNB.lastBattleShoutTime) >= SNB.BATTLE_SHOUT_COOLDOWN
    SNB.debug_print("Can cast Battle Shout: " .. tostring(canCast))
    return canCast
end

-- Enrage tracking 
-- Function to check if Enrage is active in the player's buffs
SNB.ENRAGE_TEXTURE = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
function SNB.EnrageActive()
    for i = 1, 32 do
        local buffTexture = UnitBuff("player", i)
        
        -- Break the loop if there are no more buffs
        if not buffTexture then
            break
        end

        -- Check if the current buff's texture matches the Enrage texture
        if buffTexture == SNB.ENRAGE_TEXTURE then
            return true -- Enrage is detected, return true
        end
    end
    return false -- Enrage is not detected, return false
end

-- Windfury Tracking 
-- Define the texture for Windfury
SNB.WINDFURY_TEXTURE = "Interface\\Icons\\Spell_Nature_Windfury"

-- Function to check if Windfury is active in the player's buffs
function SNB.IsMainHandEnchantActive()
    for i = 0, 31 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local texture = GetPlayerBuffTexture(id)
            if texture == SNB.WINDFURY_TEXTURE then
                return true -- Windfury is detected, return true
            end
        end
    end
    return false -- Windfury is not detected, return false
end