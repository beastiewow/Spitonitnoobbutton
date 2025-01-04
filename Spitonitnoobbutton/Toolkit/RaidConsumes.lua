local healthConsumables = {
    [12451] = 16323, -- Juju Power itemID and buffID
    [13452] = 17538, -- Elixir of the Mongoose itemID and buffID
    [12820] = 17038, -- Winterfall Firewater itemID and buffID
    [8410] = 10667,  -- R.I.O.D.S itemID and buffID
    [13445] = 11348, -- Elixir of Superior Defense itemID and buffID
    [3825] = 3593,   -- Elixir of Fortitude itemID and buffID
    [20079] = 24382, -- Spirit of Zanza itemID and buffID
    [21151] = 25804, -- Rumsey Rum Black Label itemID and buffID
}

local speedConsumables = {
    [12451] = 16323, -- Juju Power itemID and buffID
    [13452] = 17538, -- Elixir of the Mongoose itemID and buffID
    [12820] = 17038, -- Winterfall Firewater itemID and buffID
    [8410] = 10667,  -- R.I.O.D.S itemID and buffID
    [13445] = 11348, -- Elixir of Superior Defense itemID and buffID
    [3825] = 3593,   -- Elixir of Fortitude itemID and buffID
    [20081] = 24383, -- Swiftness of Zanza itemID and buffID
    [21151] = 25804, -- Rumsey Rum Black Label itemID and buffID
}

local tankHealthConsumables = {
    [12451] = 16323, -- Juju Power itemID and buffID
    [13452] = 17538, -- Elixir of the Mongoose itemID and buffID
    [12820] = 17038, -- Winterfall Firewater itemID and buffID
    [13445] = 11348, -- Elixir of Superior Defense itemID and buffID
    [3825] = 3593,   -- Elixir of Fortitude itemID and buffID
    [20079] = 24382, -- Spirit of Zanza itemID and buffID
    [21151] = 25804, -- Rumsey Rum Black Label itemID and buffID
    [8412] = 10669,  -- Ground Scorpok Assay itemID and buffID
    [9088] = 11371,  -- Gift of Arthas itemID and buffID
}

local tankSpeedConsumables = {
    [12451] = 16323, -- Juju Power itemID and buffID
    [13452] = 17538, -- Elixir of the Mongoose itemID and buffID
    [12820] = 17038, -- Winterfall Firewater itemID and buffID
    [13445] = 11348, -- Elixir of Superior Defense itemID and buffID
    [3825] = 3593,   -- Elixir of Fortitude itemID and buffID
    [20081] = 24383, -- Swiftness of Zanza itemID and buffID
    [21151] = 25804, -- Rumsey Rum Black Label itemID and buffID
    [8412] = 10669,  -- Ground Scorpok Assay itemID and buffID
    [9088] = 11371,  -- Gift of Arthas itemID and buffID
}

local testConsumables = {
    [20709] = 25037, -- Rumsey Rum Light itemID and buffID
    [9187] = 11334,  -- Elixir of Greater Agility itemID and buffID
}

local function HasBuff(buffID, threshold)
    for i = 0, 31 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local buff = GetPlayerBuffID(i)
            if buff == buffID then
                local timeleft = GetPlayerBuffTimeLeft(id)
                if timeleft <= threshold then
                    return false
                end
                return true
            end
        end
    end
    return false
end

local function FindAndUseItem(itemID)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, itemLinkID = strsplit(":", itemLink)
                if tonumber(itemLinkID) == itemID then
                    UseContainerItem(bag, slot)
                    return
                end
            end
        end
    end
end

local function UseConsumables(consumables, threshold)
    for itemID, buffID in pairs(consumables) do
        if not HasBuff(buffID, threshold) then
            FindAndUseItem(itemID)
            return
        end
    end
end

SLASH_HEALTHCONSUMES1 = "/healthconsumes"
SlashCmdList["HEALTHCONSUMES"] = function()
    local allBuffsPresent = true
    for _, buffID in pairs(healthConsumables) do
        if not HasBuff(buffID, 120) then
            allBuffsPresent = false
            break
        end
    end
    if not allBuffsPresent then
        UseConsumables(healthConsumables, 120)
    end
end

SLASH_SPEEDCONSUMES1 = "/speedconsumes"
SlashCmdList["SPEEDCONSUMES"] = function()
    local allBuffsPresent = true
    for _, buffID in pairs(speedConsumables) do
        if not HasBuff(buffID, 120) then
            allBuffsPresent = false
            break
        end
    end
    if not allBuffsPresent then
        UseConsumables(speedConsumables, 120)
    end
end

SLASH_TANKHEALTH1 = "/tankhealth"
SlashCmdList["TANKHEALTH"] = function()
    local allBuffsPresent = true
    for _, buffID in pairs(tankHealthConsumables) do
        if not HasBuff(buffID, 120) then
            allBuffsPresent = false
            break
        end
    end
    if not allBuffsPresent then
        UseConsumables(tankHealthConsumables, 120)
    end
end

SLASH_TANKSPEED1 = "/tankspeed"
SlashCmdList["TANKSPEED"] = function()
    local allBuffsPresent = true
    for _, buffID in pairs(tankSpeedConsumables) do
        if not HasBuff(buffID, 120) then
            allBuffsPresent = false
            break
        end
    end
    if not allBuffsPresent then
        UseConsumables(tankSpeedConsumables, 120)
    end
end

SLASH_TESTCONSUMES1 = "/testconsumes"
SlashCmdList["TESTCONSUMES"] = function()
    local allBuffsPresent = true
    for _, buffID in pairs(testConsumables) do
        if not HasBuff(buffID, 120) then
            allBuffsPresent = false
            break
        end
    end
    if not allBuffsPresent then
        UseConsumables(testConsumables, 120)
    end
end

SLASH_CHECKTIME1 = '/checktime'
function SlashCmdList.CHECKTIME()
    for i = 0, 31 do
        local id, cancel = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local timeleft = GetPlayerBuffTimeLeft(id)
            DEFAULT_CHAT_FRAME:AddMessage("Buff Index "..i..": "..timeleft.." seconds left")
        end
    end
end
