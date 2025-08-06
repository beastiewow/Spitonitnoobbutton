-- Queues.lua (General Utility Functions)
-- This lua is for tracking Heroic Strike and Cleave queuing 
if not SNB then SNB = {} end -- Initialize the namespace if it doesn't exist

-- Initialize the auto execute mode toggle (default to automatic mode)
if SNB.IsAutoExeMode == nil then
    SNB.IsAutoExeMode = true
end

-- Ensure pfUI's libcast is checked globally (at the top of your addon)
if not pfUI or not pfUI.api or not pfUI.api.libcast then
    DEFAULT_CHAT_FRAME:AddMessage("SNB: pfUI libcast not found! Using basic Execute behavior without Slam tracking.")
end

local libcast = pfUI and pfUI.api and pfUI.api.libcast
local player = UnitName("player")

-- Function to execute the correct function based on mode and spec
function SNB.ExecuteMacro()
    -- Check for Mortal Strike talent to determine Arms spec
    local hasMortalStrike = SNB.HasTalent("Mortal Strike")
    SNB.debug_print("Executing Execute mode")
    
    -- Use Arms Execute function with appropriate targeting mode based on toggle
    if hasMortalStrike then
        if SNB.IsAutoExeMode then
            SNB.ArmsExecuteHSNoSlamTrack() -- Automatic targeting function
        else
            SNB.ArmsExecuteOld() -- Manual mode
        end
    else
        SNB.CheckAndCastBloodthirstOrExecute()
    end
end

-- Function to toggle between automatic and manual execute modes
function SNB.ToggleAutoExecuteMode()
    SNB.IsAutoExeMode = not SNB.IsAutoExeMode
    
    local modeText = SNB.IsAutoExeMode and "Automatic (Auto-targeting)" or "Manual (No auto-targeting)"
    DEFAULT_CHAT_FRAME:AddMessage("SNB: Execute mode set to " .. modeText)
end

-- Slash command to swap between Cleave mode and Bloodthirst/Execute mode
SLASH_EXECUTESWAP1 = "/exeswap"
SlashCmdList["EXECUTESWAP"] = function()
    SNB.ToggleExecuteMode()    -- Call the original toggle function
    SNB.UpdateExecuteButton()      -- Immediately update the Execute/Cleave icon state after toggling
end

-- New slash command to toggle between automatic and manual execute modes
SLASH_AUTOEXETOGGLE1 = "/autoexe"
SlashCmdList["AUTOEXETOGGLE"] = function()
    SNB.ToggleAutoExecuteMode()
end

SLASH_EXECUTEMACRO1 = "/executemacro"
SlashCmdList["EXECUTEMACRO"] = SNB.ExecuteMacro
