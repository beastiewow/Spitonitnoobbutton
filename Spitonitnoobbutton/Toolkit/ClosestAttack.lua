-- Debug mode for detailed output
local DEBUG = false

-- Function to print debug messages
local function debug_print(msg)
    if DEBUG then
        DEFAULT_CHAT_FRAME:AddMessage("[DEBUG]: " .. tostring(msg))
    end
end

-- Function to check if auto-attack is currently running (toggled on)
local function IsAutoAttackActive()
    for i = 1, 120 do
        if IsCurrentAction(i) then
            return true -- Auto-attack is active
        end
    end
    return false -- Auto-attack is not active
end

-- Function to safely start auto-attack without resetting swing timer
local function StartAutoAttack()
    -- Only trigger auto-attack if it is not already active
    if not IsAutoAttackActive() and UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
        debug_print("Starting auto-attack.")
        AttackTarget() -- Start auto-attack
    else
        debug_print("Auto-attack is already active or no valid target.")
    end
end

-- Function to check if the current target has a raid marker
local function HasRaidMarker(target)
    for i = 1, 8 do
        if GetRaidTargetIndex(target) == i then
            return true
        end
    end
    return false
end

-- Function to find and target the closest enemy while respecting melee range, world boss, and raid mark priority
local function TargetClosestEnemy()
    local closestDistance = 1000 -- Initialize with a large distance
    local closestTargetName = nil -- Store the closest target's name
    local currentDistance = nil -- Store the distance to the current target

    debug_print("Starting search for the closest enemy...")

    -- Check the current target's distance, classification, and raid marker first
    if UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
        local currentClassification = UnitClassification("target") -- Get the unit's classification
        if HasRaidMarker("target") then
            debug_print("Current target has a raid marker. No switching allowed.")
            StartAutoAttack() -- Ensure auto-attack is running
            return
        elseif currentClassification == "worldboss" then
            debug_print("Current target is a world boss. No switching allowed.")
            StartAutoAttack() -- Ensure auto-attack is running
            return
        end

        currentDistance = UnitXP("distanceBetween", "player", "target") -- Measure distance to current target
        debug_print("Current Target: " .. (UnitName("target") or "Unknown") .. " at Distance: " .. (currentDistance or "Unknown"))

        -- If the current target is within 5 yards, do nothing
        if currentDistance and currentDistance <= 5 then
            debug_print("Current target is within 5 yards, no need to switch targets.")
            StartAutoAttack() -- Ensure auto-attack is running
            return
        end
    end

    -- Scan nearby enemies to find the closest target
    for i = 1, 5 do
        TargetNearestEnemy() -- Temporarily target the next nearest enemy
        if UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
            local targetName = UnitName("target")
            local distance = UnitXP("distanceBetween", "player", "target") -- Measure actual distance

            -- Ensure distance is valid
            if distance then
                debug_print("Checking Target: " .. (targetName or "Unknown") .. " at Distance: " .. distance)

                -- Update the closest target if the current one is closer
                if distance < closestDistance then
                    closestDistance = distance
                    closestTargetName = targetName
                    debug_print("New Closest Target: " .. (closestTargetName or "Unknown") .. " at Distance: " .. closestDistance)
                end
            else
                debug_print("Could not measure distance for target: " .. (targetName or "Unknown"))
            end
        end
    end

    -- Determine if we should change targets
    if closestTargetName and (not currentDistance or closestDistance < currentDistance) then
        if closestTargetName ~= UnitName("target") then
            TargetByName(closestTargetName) -- Switch to the closest target by name
            debug_print("Switching to Closest Target: " .. (UnitName("target") or "Unknown") .. " at Distance: " .. closestDistance)
        else
            debug_print("Closest target is already the current target.")
        end
    else
        debug_print("No need to change targets.")
    end

    -- Start auto-attack if it's not already active
    StartAutoAttack()
end

-- Register the slash command
SLASH_ATTACKNEAR1 = "/attacknear"
SlashCmdList["ATTACKNEAR"] = TargetClosestEnemy