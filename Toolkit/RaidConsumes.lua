-- Consumables tables (unchanged)
local healthConsumables = {
    [12451] = 16323, -- Juju Power
    [9206]  = 11405, -- Elixir of Giants
    [13452] = 17538, -- Elixir of the Mongoose
    [12820] = 17038, -- Winterfall Firewater
    [8410]  = 10667, -- R.O.I.D.S
    [13445] = 11348, -- Elixir of Superior Defense
    [3825]  = 3593,  -- Elixir of Fortitude
    [20079] = 24382, -- Spirit of Zanza
    [21151] = 25804, -- Rumsey Rum Black Label
}

local speedConsumables = {
    [12451] = 16323, -- Juju Power
    [9206]  = 11405, -- Elixir of Giants
    [13452] = 17538, -- Elixir of the Mongoose
    [12820] = 17038, -- Winterfall Firewater
    [8410]  = 10667, -- R.O.I.D.S
    [13445] = 11348, -- Elixir of Superior Defense
    [3825]  = 3593,  -- Elixir of Fortitude
    [20081] = 24383, -- Swiftness of Zanza
    [21151] = 25804, -- Rumsey Rum Black Label
}

local tankHealthConsumables = {
    [12451] = 16323, -- Juju Power
    [9206]  = 11405, -- Elixir of Giants
    [13452] = 17538, -- Elixir of the Mongoose
    [12820] = 17038, -- Winterfall Firewater
    [13445] = 11348, -- Elixir of Superior Defense
    [3825]  = 3593,  -- Elixir of Fortitude
    [20079] = 24382, -- Spirit of Zanza
    [21151] = 25804, -- Rumsey Rum Black Label
    [8412]  = 10669, -- Ground Scorpok Assay
    [9088]  = 11371, -- Gift of Arthas
}

local tankSpeedConsumables = {
    [12451] = 16323, -- Juju Power
    [9206]  = 11405, -- Elixir of Giants
    [13452] = 17538, -- Elixir of the Mongoose
    [12820] = 17038, -- Winterfall Firewater
    [13445] = 11348, -- Elixir of Superior Defense
    [3825]  = 3593,  -- Elixir of Fortitude
    [20081] = 24383, -- Swiftness of Zanza
    [21151] = 25804, -- Rumsey Rum Black Label
    [8412]  = 10669, -- Ground Scorpok Assay
    [9088]  = 11371, -- Gift of Arthas
}

local testConsumables = {
    [20709] = 25037, -- Rumsey Rum Light
    [9187] = 11334,  -- Elixir of Greater Agility
}

function strsplit(delim, str, maxNb, onlyLast)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    if onlyLast then
        return result[nb + 1]
    else
        return result[1], result[2]
    end
end

-- Check if a buff is present and has more than the threshold time left
local function HasBuff(buffID, threshold)
    for i = 0, 31 do
        local id, _ = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
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

-- Check if an item is in your bags
local function HasItem(itemID)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, itemLinkID = strsplit(":", itemLink)
                if tonumber(itemLinkID) == itemID then
                    return true
                end
            end
        end
    end
    return false
end

-- Find and use an item from your bags
local function FindAndUseItem(itemID)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, itemLinkID = strsplit(":", itemLink)
                if tonumber(itemLinkID) == itemID then
                    UseContainerItem(bag, slot)
                    return true
                end
            end
        end
    end
    return false
end

-- Global variable to track the last time the message was printed
local lastMessageTime = 0
local COOLDOWN_TIME = 10  -- 10 seconds cooldown

-- Apply all missing consumables that are in your bags and collect missing ones
local function UseConsumables(consumables, threshold)
    local missingItems = {}

    -- Special handling for strength buff (Juju Power and Elixir of Giants)
    local strengthBuffPresent = HasBuff(16323, threshold) or HasBuff(11405, threshold)
    if not strengthBuffPresent then
        local jujuPowerID = 12451
        local giantsElixirID = 9206
        if HasItem(jujuPowerID) then
            FindAndUseItem(jujuPowerID)
        elseif HasItem(giantsElixirID) then
            FindAndUseItem(giantsElixirID)
        else
            table.insert(missingItems, "Juju Power or Elixir of Giants")
        end
    end

    -- Process the remaining consumables, skipping Juju Power and Elixir of Giants
    for itemID, buffID in pairs(consumables) do
        if itemID ~= 12451 and itemID ~= 9206 then -- Skip Juju Power and Elixir of Giants
            if not HasBuff(buffID, threshold) then
                if HasItem(itemID) then
                    FindAndUseItem(itemID)
                else
                    local itemName = GetItemInfo(itemID)
                    if itemName then
                        table.insert(missingItems, itemName)
                    else
                        table.insert(missingItems, "item ID " .. itemID)
                    end
                end
            end
        end
    end

    -- Construct and print a single message for all missing items
    if table.getn(missingItems) > 0 then
        local currentTime = GetTime()
        if currentTime - lastMessageTime >= COOLDOWN_TIME then
            local message = "You need to restock on "
            if table.getn(missingItems) == 1 then
                message = message .. missingItems[1]
            elseif table.getn(missingItems) == 2 then
                message = message .. missingItems[1] .. " and " .. missingItems[2]
            else
                message = message .. table.concat(missingItems, ", ", 1, table.getn(missingItems) - 1) .. ", and " .. missingItems[table.getn(missingItems)]
            end
            print(message)
            lastMessageTime = currentTime  -- Update the last message time
        end
    end
end

-- Slash commands
SLASH_HEALTHCONSUMES1 = "/healthconsumes"
SlashCmdList["HEALTHCONSUMES"] = function()
    UseConsumables(healthConsumables, 300)
end

SLASH_SPEEDCONSUMES1 = "/speedconsumes"
SlashCmdList["SPEEDCONSUMES"] = function()
    UseConsumables(speedConsumables, 300)
end

SLASH_TANKHEALTH1 = "/tankhealth"
SlashCmdList["TANKHEALTH"] = function()
    UseConsumables(tankHealthConsumables, 300)
end

SLASH_TANKSPEED1 = "/tankspeed"
SlashCmdList["TANKSPEED"] = function()
    UseConsumables(tankSpeedConsumables, 300)
end

SLASH_TESTCONSUMES1 = "/testconsumes"
SlashCmdList["TESTCONSUMES"] = function()
    UseConsumables(testConsumables, 300)
end

SLASH_CHECKTIME1 = "/checktime"
SlashCmdList["CHECKTIME"] = function()
    for i = 0, 31 do
        local id, _ = GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE")
        if id > -1 then
            local timeleft = GetPlayerBuffTimeLeft(id)
            DEFAULT_CHAT_FRAME:AddMessage("Buff Index " .. i .. ": " .. timeleft .. " seconds left")
        end
    end
end
