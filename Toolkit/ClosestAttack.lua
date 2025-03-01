------------------------------------------
-- Your existing debug utilities
------------------------------------------
local DEBUG = false

local function tp_print(msg)
    if type(msg) == "boolean" then 
        msg = msg and "true" or "false" 
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function debug_print(msg)
    if DEBUG then
        tp_print(msg)
    end
end

------------------------------------------
-- AUTO ATTACK STATE & FRAME
-- (Baked-in Roid Macros logic)
------------------------------------------
-- Data table to store our lock/flags
local TPAutoAttackData = {
    autoAttackLock = false,  -- Whether we're currently "lock-protecting" auto-attack
    autoAttack     = false,  -- Are we in auto-attack?
}

-- Frame for watching relevant combat events
local TPAutoAttackFrame = CreateFrame("Frame")
TPAutoAttackFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
TPAutoAttackFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
TPAutoAttackFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

TPAutoAttackFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTER_COMBAT" then
        TPAutoAttackData.autoAttack     = true
        TPAutoAttackData.autoAttackLock = false
    elseif event == "PLAYER_LEAVE_COMBAT" then
        TPAutoAttackData.autoAttack     = false
        TPAutoAttackData.autoAttackLock = false
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Safely reset locks when your target changes
        TPAutoAttackData.autoAttack     = false
        TPAutoAttackData.autoAttackLock = false
    end
end)

------------------------------------------
-- Check if auto-attack is active
------------------------------------------
local function IsAutoAttackActive()
    for i = 1, 120 do
        if IsCurrentAction(i) then
            -- Found a slot that's toggled on to "Attack"
            return true
        end
    end
    return false
end

------------------------------------------
-- Lock for 0.2s using GetTime() approach
------------------------------------------
local function StartAutoAttack()
    -- ... your existing checks ...
    if not TPAutoAttackData.autoAttackLock 
       and not IsAutoAttackActive()
       and UnitExists("target")
       and not UnitIsDead("target")
       and UnitCanAttack("player", "target") 
    then
        AttackTarget()  -- start auto-attack
        TPAutoAttackData.autoAttackLock = true

        local startTime = GetTime()
        TPAutoAttackFrame:SetScript("OnUpdate", function()
            -- Compare current time vs. the moment we started
            local now = GetTime()
            if (now - startTime) >= 0.2 then
                TPAutoAttackData.autoAttackLock = false
                TPAutoAttackFrame:SetScript("OnUpdate", nil)
            end
        end)
    else
        debug_print("Auto-attack is already active or locked.")
    end
end


------------------------------------------
-- 5-yard "Execute" slot detection
------------------------------------------
local yard05  -- Holds the action bar index of Execute

local function SNB_InitDistance()
    for i = 1, 120 do
        local t = GetActionTexture(i)
        if t then
            -- If it's "INV_Sword_48", assume that's Execute
            if not yard05 and string.find(t, "INV_Sword_48") then
                yard05 = i
                DEFAULT_CHAT_FRAME:AddMessage("Found 5 yard spell (execute) in slot: " .. i)
                break
            end
        end
    end

    if not yard05 then
        DEFAULT_CHAT_FRAME:AddMessage("5 yard spell not found – please add Execute to an action bar slot.")
    end
end

------------------------------------------
-- Main Targeting Function
------------------------------------------
local function TargetClosestEnemy()
    local closestDistance = 1000
    local closestTarget   = nil
    local currentTarget   = UnitName("target")
    local currentDistance = 1000

    if currentTarget and not UnitIsDead("target") then
        if not yard05 then 
            SNB_InitDistance() 
        end
        -- Use IsActionInRange for ~5 yards check
        if yard05 and IsActionInRange(yard05) == 1 then
            currentDistance = 5
        elseif CheckInteractDistance("target", 3) then
            currentDistance = 8
        end
    end

    local isBossTarget = currentTarget and (UnitClassification("target") == "worldboss")

    debug_print("Current Target: " .. (currentTarget or "None"))
    debug_print("Current Target Distance: " .. currentDistance)
    debug_print("Is Boss Target: " .. tostring(isBossTarget))

    -- If current target is a marked target within 5 yards (not a boss), keep it
    if currentTarget 
       and not UnitIsDead("target") 
       and GetRaidTargetIndex("target") 
       and (currentDistance == 5) 
       and not isBossTarget then
        debug_print("Keeping marked target: " .. currentTarget)
        StartAutoAttack()
        return
    end

    -- If current target is valid within 8 yards (or a boss), keep it
    if currentTarget 
       and not UnitIsDead("target") 
       and (currentDistance <= 8 or isBossTarget) then
        debug_print("Maintaining target: " .. currentTarget)
        StartAutoAttack()
        return
    end

    -- Otherwise, search for a better (closer) target
    for i = 1, 5 do
        TargetNearestEnemy()
        if UnitExists("target") and not UnitIsDead("target") then
            local tName           = UnitName("target")
            local candidateDist   = 1000

            if yard05 and IsActionInRange(yard05) == 1 then
                candidateDist = 5
            elseif CheckInteractDistance("target", 3) then
                candidateDist = 8
            end

            debug_print("Checking Target: " .. tName .. " at Distance: " .. candidateDist)

            if candidateDist < closestDistance then
                closestDistance = candidateDist
                closestTarget   = tName
                debug_print("New Closest Target: " .. closestTarget .. " at Distance: " .. closestDistance)
            end
        end
    end

    if closestTarget and (closestTarget ~= currentTarget) then
        debug_print("Targeting New Closest Target: " .. closestTarget)
        TargetByName(closestTarget)
    else
        debug_print("No new valid target found or current target still closest.")
    end

    -- Start auto-attack if we ended up with a target
    StartAutoAttack()
end

------------------------------------------
-- Slash Command Setup
------------------------------------------
local function ToggleDebug()
    DEBUG = not DEBUG
    tp_print("Debug mode is now " .. (DEBUG and "ON" or "OFF"))
end

SLASH_CLOSESTINRANGE1 = "/closestinrange"
SlashCmdList["CLOSESTINRANGE"] = TargetClosestEnemy

SLASH_TOGGLEDEBUG1 = "/toggledebug"
SlashCmdList["TOGGLEDEBUG"] = ToggleDebug
