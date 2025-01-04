-- Initialize the shared namespace
SNB = SNB or {}

-- Move all global variables to the SNB namespace
SNB.DEBUG = false
SNB.isWhirlwindMode = true  -- Default to Whirlwind mode
SNB.isFarmMode = false      -- Track if Farm mode is active

-- Function to print messages to the default chat frame
function SNB.tp_print(msg)
    if type(msg) == "boolean" then msg = msg and "true" or "false" end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- Function to print debug messages if DEBUG mode is enabled
function SNB.debug_print(msg)
    if SNB.DEBUG then SNB.tp_print(msg) end
end

-- Function to toggle DEBUG mode
function SNB.ToggleDebugMode()
    SNB.DEBUG = not SNB.DEBUG
    if SNB.DEBUG then
        SNB.tp_print("|cff00ff00DEBUG mode enabled.|r") -- Green text for enabled
    else
        SNB.tp_print("|cffff0000DEBUG mode disabled.|r") -- Red text for disabled
    end
end

-- Function to print the help menu
function SNB.ShowHelpMenu()
    SNB.tp_print("|cffffd700SpitNoobButton Help Menu:|r")  -- Title in yellow color
    SNB.tp_print("|cff00ff00/single|r - Executes the active mode's casting logic (DPS rotation depends on whether you have WF or not. If you are in defensive stance, it will use a tank rotation).")
    SNB.tp_print("|cff00ff00/toggleww|r - Toggles between Whirlwind mode and Regular Single-Target mode (unless Farm mode is active).")
    SNB.tp_print("|cff00ff00/aoe|r - Executes Cleave and Whirlwind for AoE situations.")
    SNB.tp_print("|cff00ff00/executemacro|r - Executes either Cleave or Bloodthirst/Execute based on current toggle.")
    SNB.tp_print("|cff00ff00/exeswap|r - Toggles between Cleave mode and Bloodthirst/Execute mode.")
    SNB.tp_print("|cff00ff00/sunder|r - Executes the Sunder Armor macro, applying Sunder Armor.")
    SNB.tp_print("|cff00ff00/ci|r - Casts Charge or Intercept based on the current stance.")
    SNB.tp_print("|cff00ff00/pummel|r - Casts interrupt (Pummel).")
    SNB.tp_print("|cff00ff00/debugsnb|r - Toggles DEBUG mode (print debug messages on/off).")
    SNB.tp_print("|cff00ff00/wwicon|r - Change the scale of the whirlwind toggle icon from 1 to 100) Example: /wwicon 50 scales the icons to 50 for both Execute and Whirlwind toggle buttons")
    SNB.tp_print("|cff00ff00/wwicon lock|r - Locks the whirlwind icon in place. Replace lock with unlock to unlock it).")
    SNB.tp_print("|cff00ff00/shield|r - Automatically equips shield and cast shield block on next press. Define your shield by typing /shield shieldname i.e /shield The Face of Death).")
    SNB.tp_print("|cff00ff00/shieldbash|r - Locks the whirlwind icon in place. Replace lock with unlock to unlock it).")
    SNB.tp_print("|cff00ff00/offhand|r - /offhand lets you select the offhand you want equipped when in berserker stance. Example: /offhand The Hungering Cold ).")
    SNB.tp_print("|cff00ff00/2hander|r - /2hander lets you select the 2hander you want to use when using your rotation buttons. /single and /aoe when you have it equipped. MUST SELECT A 2 HANDER Example: /2hander Bonereaver's Edge').")
    SNB.tp_print("|cff00ff00/lastchance|r - Automatically uses Last Stand and Nordanaar Herbal Tea when your health drops below the defined threshold. Use /lastchance <number> to set threshold. /lastchance rage shows current threshold.")
    SNB.tp_print("|cff00ff00/lastchancedebug|r - Toggles DEBUG mode for Last Stand and Nordanaar Herbal Tea logic.")
end

-- Slash command to bring up the help menu
SLASH_SNB1 = "/snb"
SlashCmdList["SNB"] = SNB.ShowHelpMenu

-- Slash command to toggle DEBUG mode
SLASH_DEBUGSNB1 = "/debugsnb"
SlashCmdList["DEBUGSNB"] = SNB.ToggleDebugMode
