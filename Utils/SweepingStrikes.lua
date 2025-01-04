-- Utilities.lua (General Utility Functions)
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Add more utility functions here
-- Function to get spell book slot for a given spell name

-- Sweeping Strikes Tracking 
-- Define the texture for Sweeping Strikes
SNB.SWEEPING_STRIKES_TEXTURE = "Interface\\Icons\\Ability_Rogue_SliceDice"

-- Function to check if Sweeping Strikes is active in the player's buffs
function SNB.SweepingStrikesActive()
    for i = 1, 32 do
        local buffTexture = UnitBuff("player", i)
        
        -- Break the loop if there are no more buffs
        if not buffTexture then
            break
        end

        -- Check if the current buff's texture matches the Sweeping Strikes texture
        if buffTexture == SNB.SWEEPING_STRIKES_TEXTURE then
            return true -- Sweeping Strikes is detected, return true
        end
    end
    return false -- Sweeping Strikes is not detected, return false
end

-- Toggle for Sweeping Strikes
SNB.isSweepingStrikesMode = false  -- Default to false (disabled)

-- Slash command to toggle Sweeping Strikes mode
function SNB.ToggleSweepingStrikesMode()
    -- Toggle the mode
    SNB.isSweepingStrikesMode = not SNB.isSweepingStrikesMode

    -- Notify the player about the current state
    if SNB.isSweepingStrikesMode then
        SNB.debug_print("Sweeping Strikes mode ENABLED.")
    else
        SNB.debug_print("Sweeping Strikes mode DISABLED.")
    end
end

-- Slash command registration for Sweeping Strikes
SLASH_TOGGLESWEEPING1 = "/sweeping"
SlashCmdList["TOGGLESWEEPING"] = SNB.ToggleSweepingStrikesMode