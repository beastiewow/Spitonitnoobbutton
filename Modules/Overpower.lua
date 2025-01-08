-- Debug mode toggle for Overpower
SNB.debugOverpower = false  -- Set to false by default to disable debug messages
local dodgeFlag = false  -- This flag will be set to true only when a dodge occurs
SNB.overpowerProcEndTime = 0  -- Tracks the end time of the Overpower proc, now within SNB namespace

local function SNB_debug_print(msg)
    if SNB.debugOverpower then
        DEFAULT_CHAT_FRAME:AddMessage("[DEBUG] " .. msg, 1, 1, 0)
    end
end

local function SNB_print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0.7, 0.9)
end

-- Function to check if Overpower is currently available
function SNB.IsOverpowerAvailable()
    local op_spellID = 11585
    if op_spellID == nil then
        return false
    end

    local op_start, op_dur = SNB.GetSpellCooldownById(op_spellID)

    -- Check if Overpower is on cooldown and allow it if 1 second or less remains
    if op_start > 0 then
        local cooldownLeft = (op_start + op_dur) - GetTime()
        if cooldownLeft > 1 then
            return false
        else
        end
    end

    -- Check if the Overpower proc has expired
    if dodgeFlag then
        local timeLeft = SNB.overpowerProcEndTime - GetTime()
        if timeLeft > 0 then
            return true
        else
            dodgeFlag = false  -- Reset dodge flag after timer expires
            return false
        end
    else
    end

    return false
end

-- Slash command function to check Overpower status
function SNB.CheckOverpowerStatus()
    if SNB.IsOverpowerAvailable() then
        local timeLeft = SNB.overpowerProcEndTime - GetTime()
        SNB_print("Overpower is available for " .. string.format("%.1f", timeLeft) .. " seconds!")
    else
        local op_start, op_dur = GetSpellCooldown(GetSpellID("Overpower"), BOOKTYPE_SPELL)
        if op_start > 0 then
        else
        end
    end
end

-- Slash command function to cast Overpower if available
function SNB.CastOverpower()
    if SNB.IsOverpowerAvailable() then
        CastSpellByName("Overpower")
        dodgeFlag = false  -- Reset dodge flag after casting Overpower
    else
        local op_start, op_dur = GetSpellCooldown(GetSpellID("Overpower"), BOOKTYPE_SPELL)
        if op_start > 0 then
        else
        end
    end
end

-- Function to find spell book slot for a given spell name
function SNB.FindSpellBookSlotByName(spellName)
    for i = 1, 120 do
        local spellBookName = GetSpellName(i, "spell")
        if spellBookName == spellName then
            return i
        end
    end
    return nil
end

-- Function to get spell cooldown by spell ID
function SNB.GetSpellCooldownById(spellID)
    local name = SpellInfo(spellID)
    if name then
        local slot = SNB.FindSpellBookSlotByName(name)
        if slot then
            return GetSpellCooldown(slot, "spell")
        end
    end
    return nil, nil, nil
end

-- Event handling to detect when Overpower is triggered by a dodge only
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
f:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
f:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")

f:SetScript("OnEvent", function()
    local message = arg1  -- Capture the message in case it's not explicitly passed

    if not message then
        return
    end

    local event = event -- Capture the event name explicitly for clarity

    if event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        local a, b, str = string.find(message, "You attack. (.+) dodges.")
        if a then
            dodgeFlag = true  -- Set the dodge flag to true when a dodge is detected
            SNB.overpowerProcEndTime = GetTime() + 4  -- Set proc end time to 4 seconds from now
        else
        end

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
        local a, b, _, str = string.find(message, "Your (.+) was dodged by (.+).")
        if a then
            dodgeFlag = true  -- Set the dodge flag to true when a dodge is detected
            SNB.overpowerProcEndTime = GetTime() + 4  -- Set proc end time to 4 seconds from now
        else
        end
    end
end)

-- Slash command to check overpower status
SLASH_CHECKOP1 = "/checkop"
SlashCmdList["CHECKOP"] = SNB.CheckOverpowerStatus

-- Slash command to cast Overpower if available
SLASH_OVERPWR1 = "/overpwr"
SlashCmdList["OVERPWR"] = SNB.CastOverpower

-- Slash command to toggle debug mode for Overpower
SLASH_OVERPOWERDEBUG1 = "/overpowerdebug"
SlashCmdList["OVERPOWERDEBUG"] = function()
    SNB.debugOverpower = not SNB.debugOverpower
    if SNB.debugOverpower then
        SNB_print("Overpower debug mode enabled.")
    else
        SNB_print("Overpower debug mode disabled.")
    end
end
