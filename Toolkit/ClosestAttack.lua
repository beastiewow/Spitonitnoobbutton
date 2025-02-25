local DEBUG = false

local function tp_print(msg)
    if type(msg) == "boolean" then msg = msg and "true" or "false" end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function debug_print(msg)
    if DEBUG then tp_print(msg) end
end

------------------------------------------------------------
-- Auto-Attack Helpers (from Roid macros)
------------------------------------------------------------
local function IsAutoAttackActive()
    for i = 1, 120 do
        if IsCurrentAction(i) then
            return true  -- Auto-attack is active
        end
    end
    return false  -- Auto-attack is not active
end

-- Roid macros auto-attack logic with stronger locking mechanism
local function StartAutoAttack()
    -- Check if a valid target exists and auto-attack isn't running
    if not IsAutoAttackActive() and UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
        debug_print("Starting auto-attack.")
        AttackTarget()  -- Start auto-attack

        -- Lock the auto-attack to prevent it from being toggled off
        Roids.CurrentSpell.autoAttackLock = true

        -- Timer to unlock after 0.2 seconds in case something interrupts
        local elapsed = 0
        Roids.Frame:SetScript("OnUpdate", function()
            elapsed = elapsed + arg1
            if Roids.CurrentSpell.autoAttackLock and elapsed > 0.2 then
                Roids.CurrentSpell.autoAttackLock = false
                Roids.Frame:SetScript("OnUpdate", nil)
            end
        end)
    else
        debug_print("Auto-attack is already active or locked.")
    end
end

------------------------------------------------------------
-- 5-Yard Check using Execute Action Slot
------------------------------------------------------------
local yard05  -- holds the action slot index for our execute spell

local function SNB_InitDistance()
    for i = 1, 120 do
        local t = GetActionTexture(i)
        if t then
            if not yard05 and string.find(t, "INV_Sword_48") then
                yard05 = i
                DEFAULT_CHAT_FRAME:AddMessage("Found 5 yard spell (execute) in slot: " .. i)
                break
            end
        end
    end

    if not yard05 then
        DEFAULT_CHAT_FRAME:AddMessage("5 yard spell not found – please add execute to an action bar slot.")
    end
end

------------------------------------------------------------
-- Targeting Function Using 5- and 8-Yard Checks
------------------------------------------------------------
local function TargetClosestEnemy()
    local closestDistance = 1000
    local closestTarget = nil
    local currentTarget = UnitName("target")
    local currentTargetDistance = 1000

    -- Determine current target's range:
    if currentTarget and not UnitIsDead("target") then
        if not yard05 then SNB_InitDistance() end
        -- Use our execute slot check for 5 yards:
        if yard05 and IsActionInRange(yard05) == 1 then
            currentTargetDistance = 5
        -- Otherwise, check for roughly 8 yards:
        elseif CheckInteractDistance("target", 3) then
            currentTargetDistance = 8
        end
    end

    local isBossTarget = currentTarget and (UnitClassification("target") == "worldboss")

    debug_print("Current Target: " .. (currentTarget or "None"))
    debug_print("Current Target Distance: " .. currentTargetDistance)
    debug_print("Is Boss Target: " .. tostring(isBossTarget))
    
    -- If currently attacking a marked target that is within 5 yards and not a boss, maintain it.
    if currentTarget and not UnitIsDead("target") and GetRaidTargetIndex("target") and currentTargetDistance == 5 and not isBossTarget then
        debug_print("Current marked target is within 5 yards, maintaining target: " .. currentTarget)
        StartAutoAttack()
        return
    end

    -- If the current target is valid, within 8 yards, and not a boss, maintain it.
    if currentTarget and not UnitIsDead("target") and currentTargetDistance <= 8 and not isBossTarget then
        debug_print("Current target is within range and alive, maintaining target: " .. currentTarget)
        StartAutoAttack()
        return
    elseif isBossTarget then
        debug_print("Current target is a boss, maintaining target: " .. currentTarget)
        StartAutoAttack()
        return
    end

    -- Otherwise, cycle through nearby enemies to find a closer candidate.
    for i = 1, 5 do
        TargetNearestEnemy()

        if UnitExists("target") and not UnitIsDead("target") then
            local targetName = UnitName("target")
            local candidateDistance = 1000

            if yard05 and IsActionInRange(yard05) == 1 then
                candidateDistance = 5
            elseif CheckInteractDistance("target", 3) then
                candidateDistance = 8
            end

            debug_print("Checking Target: " .. targetName .. " at Distance: " .. candidateDistance)
            
            if candidateDistance < closestDistance then
                closestDistance = candidateDistance
                closestTarget = targetName
                debug_print("New Closest Target: " .. closestTarget .. " at Distance: " .. closestDistance)
            end
        end
    end

    if closestTarget and closestTarget ~= currentTarget then
        debug_print("Targeting New Closest Target: " .. closestTarget)
        TargetByName(closestTarget)
    else
        debug_print("No valid target found or current target is still the closest.")
    end

    StartAutoAttack()
end

------------------------------------------------------------
-- Debug Toggle and Slash Commands
------------------------------------------------------------
local function ToggleDebug()
    DEBUG = not DEBUG
    local status = DEBUG and "ON" or "OFF"
    tp_print("Debug mode is now " .. status)
end

SLASH_CLOSESTINRANGE1 = "/closestinrange"
SlashCmdList["CLOSESTINRANGE"] = TargetClosestEnemy

SLASH_TOGGLEDEBUG1 = "/toggledebug"
SlashCmdList["TOGGLEDEBUG"] = ToggleDebug
