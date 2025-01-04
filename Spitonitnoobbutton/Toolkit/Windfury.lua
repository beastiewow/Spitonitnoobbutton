-- SNB namespace setup
SNB = SNB or {}

-- Debug mode toggle for tracking Windfury procs
SNB.debugWindfury = false  -- Set to false by default to disable debug messages
SNB.windfuryCooldownEnd = 0  -- Tracks the end of Windfury's internal cooldown

local function debug_windfury_print(msg)
    if SNB.debugWindfury then
        DEFAULT_CHAT_FRAME:AddMessage("[DEBUG] " .. msg, 1, 1, 0)
    end
end

local function windfury_print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg, 0.5, 0.8, 1)
end

-- Slash command to toggle debug mode for Windfury tracking
SLASH_WINDFURYDEBUG1 = "/windfurydebug"
SlashCmdList["WINDFURYDEBUG"] = function()
    SNB.debugWindfury = not SNB.debugWindfury
    if SNB.debugWindfury then
        windfury_print("Windfury debug mode enabled.")
    else
        windfury_print("Windfury debug mode disabled.")
    end
end

-- Slash command to check Windfury proc status
SLASH_CHECKWFPROC1 = "/checkwfproc"
SlashCmdList["CHECKWFPROC"] = function()
    local currentTime = GetTime()
    if currentTime < SNB.windfuryCooldownEnd then
        local timeLeft = SNB.windfuryCooldownEnd - currentTime
        windfury_print("Windfury is on cooldown. Time remaining: " .. string.format("%.2f", timeLeft) .. " seconds.")
    else
        windfury_print("Windfury is ready!")
    end
end

-- Function to check if Windfury is available
function SNB.IsWindfuryAvailable()
    local currentTime = GetTime()
    if currentTime < SNB.windfuryCooldownEnd then
        local timeLeft = SNB.windfuryCooldownEnd - currentTime
        debug_windfury_print("Windfury is on cooldown. Time remaining: " .. string.format("%.2f", timeLeft) .. " seconds.")
        return false
    else
        debug_windfury_print("Windfury is ready!")
        return true
    end
end

-- Event handling to track Windfury procs and cooldown
local windfuryFrame = CreateFrame("Frame")
windfuryFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")

windfuryFrame:SetScript("OnEvent", function()
    local message = arg1  -- Capture the message
    if not message then
        debug_windfury_print("Error: arg1 (message) is nil for the current event.")
        return
    end

    -- Get the current time
    local currentTime = GetTime()

    -- Check for the specific Windfury proc message
    if string.find(message, "You gain 1 extra attack through Windfury Totem") then
        if currentTime < SNB.windfuryCooldownEnd then
            -- Windfury is still on cooldown
            windfury_print("Windfury is on cooldown.")
            debug_windfury_print("Windfury proc ignored due to cooldown. Cooldown ends in " .. string.format("%.2f", SNB.windfuryCooldownEnd - currentTime) .. " seconds.")
        else
            -- Windfury proc is valid
            windfury_print("Windfury proc detected: " .. message)
            debug_windfury_print("Full message: " .. message)
            -- Set the cooldown timer
            SNB.windfuryCooldownEnd = currentTime + 1.5
        end
    else
        debug_windfury_print("Message does not match Windfury proc: " .. message)
    end
end)
