-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist
-- Initialize the execute only mode toggle (default to false - use full rotation)
if SNB.IsExeOnlyMode == nil then
    SNB.IsExeOnlyMode = false
end
-- Ensure pfUI's libcast is checked globally (at the top of your addon)
if not pfUI or not pfUI.api or not pfUI.api.libcast then
    DEFAULT_CHAT_FRAME:AddMessage("SNB: pfUI libcast not found! Using basic Execute behavior without Slam tracking.")
end
local libcast = pfUI and pfUI.api and pfUI.api.libcast
local player = UnitName("player")

-- Function to execute the correct function based on mode and spec
function SNB.ExecuteMacro()
    -- Check for talents to determine spec
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    local hasBloodthirst = SNB.HasTalent("Bloodthirst")
    SNB.debug_print("Executing Execute mode")
    
    if hasMortalStrike then
        -- Arms spec with Mortal Strike
        if SNB.IsExeOnlyMode then
            SNB.CheckAndCastExecuteOnly() -- Execute only mode
        else
            SNB.ArmsExecuteOld() -- Full rotation with MS/WW priority
        end
    elseif hasBloodthirst then
        -- Fury spec with Bloodthirst
        if SNB.IsExeOnlyMode then
            SNB.CheckAndCastExecuteOnly() -- Execute only mode
        else
            SNB.CheckAndCastBloodthirstOrExecute() -- Bloodthirst/Execute weaving
        end
    else
        -- No capstone talents (no Bloodthirst or Mortal Strike) - Always Execute only
        SNB.CheckAndCastExecuteOnly()
    end
end

-- Function to toggle between full rotation and execute only modes
function SNB.ToggleExecuteOnlyMode()
    SNB.IsExeOnlyMode = not SNB.IsExeOnlyMode
    
    local modeText = SNB.IsExeOnlyMode and "Execute Only" or "Full Rotation"
    DEFAULT_CHAT_FRAME:AddMessage("SNB: Execute mode set to " .. modeText)
end

-- Slash command to swap between Cleave mode and Bloodthirst/Execute mode
SLASH_EXECUTESWAP1 = "/exeswap"
SlashCmdList["EXECUTESWAP"] = function()
    SNB.ToggleExecuteMode()    -- Call the original toggle function
    SNB.UpdateExecuteButton()      -- Immediately update the Execute/Cleave icon state after toggling
end

-- New slash command to toggle between full rotation and execute only modes
SLASH_EXEONLYTOGGLE1 = "/exeonly"
SlashCmdList["EXEONLYTOGGLE"] = function()
    SNB.ToggleExecuteOnlyMode()
end

SLASH_EXECUTEMACRO1 = "/executemacro"
SlashCmdList["EXECUTEMACRO"] = SNB.ExecuteMacro