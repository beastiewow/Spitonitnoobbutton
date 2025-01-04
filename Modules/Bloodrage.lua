-- Define the SNB namespace if it doesn’t already exist
SNB = SNB or {}

-- Bloodrage Spell ID in Vanilla WoW
local BLOODRAGE_SPELL_ID = 2687

-- Define the texture path for Enrage
SNB.ENRAGE_TEXTURE = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"

-- Function to check if Enrage is active on the player
function SNB.IsEnrageActive()
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

-- Function to use Bloodrage if Enrage is not active
function SNB.UseBloodrageIfNoEnrage()
    -- Check if Enrage is active
    if not SNB.IsEnrageActive() then
        -- Check if Bloodrage is off cooldown using the custom method
        local brStart, brDuration, brEnabled = SNB.GetSpellCooldownById(BLOODRAGE_SPELL_ID)
        if brDuration == 0 then
            CastSpellByName("Bloodrage")
            SNB.debug_print("Casting Bloodrage to trigger Enrage.")
        else
            SNB.debug_print("Bloodrage is on cooldown.")
        end
    else
        SNB.debug_print("Enrage is already active, skipping Bloodrage.")
    end
end

-- Slash command to trigger the Bloodrage macro logic
SLASH_BLOODRAGE1 = "/bloodrage"
SlashCmdList["BLOODRAGE"] = function()
    SNB.UseBloodrageIfNoEnrage()
end
