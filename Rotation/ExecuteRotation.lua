-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Function to execute the correct function based on the current mode (Cleave or Bloodthirst/Execute), adapted for Arms or Fury spec
function SNB.ExecuteMacro()
    -- Check for Mortal Strike talent to determine Arms spec
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")

    if SNB.isCleaveMode then
        SNB.debug_print("Executing Cleave mode")

        -- Use Arms Cleave function if Mortal Strike talent is detected; otherwise, use default Execute Cleave function
        if hasMortalStrike then
            SNB.ArmsExecuteCleave()
        else
            SNB.ExecuteCleave()
        end
    else
        SNB.debug_print("Executing Execute mode")

        -- Use Arms Execute function with Heroic Strike if Mortal Strike is detected; otherwise, use default Bloodthirst/Execute function
        if hasMortalStrike then
            SNB.ArmsExecuteHS()
        else
            SNB.CheckAndCastBloodthirstOrExecute()
        end
    end
end

-- Function to toggle between Cleave mode and Bloodthirst/Execute mode
function SNB.ToggleExecuteMode()
    SNB.isCleaveMode = not SNB.isCleaveMode
    if SNB.isCleaveMode then
        SNB.debug_print("Switched to Cleave mode.")
    else
        SNB.debug_print("Switched to Bloodthirst/Execute mode.")
    end
end

-- Slash command to swap between Cleave mode and Bloodthirst/Execute mode
SLASH_EXECUTESWAP1 = "/exeswap"
SlashCmdList["EXECUTESWAP"] = function()
    SNB.ToggleExecuteMode()    -- Call the original toggle function
    SNB.UpdateExecuteButton()      -- Immediately update the Execute/Cleave icon state after toggling
end

SLASH_EXECUTEMACRO1 = "/executemacro"
SlashCmdList["EXECUTEMACRO"] = SNB.ExecuteMacro