local debugMode = false -- Default: off

local function PrintDebug(message)
    if debugMode then
        print(message)
    end
end

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
		result[nb+1] = string.sub(str, lastPos)
	end
	if onlyLast then
		return result[nb+1]
	else
		return result[1], result[2]
	end
end

local function UseJujuFlurry()
    local itemID = 12450
    local bag, slot
    local found = false

    -- Search through all bags and slots to find the item
    for bagIndex = 0, 4 do
        for slotIndex = 1, GetContainerNumSlots(bagIndex) do
            local itemLink = GetContainerItemLink(bagIndex, slotIndex)
            if itemLink then
                local _, itemLinkID = strsplit(":", itemLink)
                if tonumber(itemLinkID) == itemID then
                    bag = bagIndex
                    slot = slotIndex
                    found = true
                    break
                end
            end
        end
        if found then break end
    end

    if found then
        local start, duration, enable = GetContainerItemCooldown(bag, slot)
        if enable == 1 and (start + duration - GetTime()) <= 0 then
            UseContainerItem(bag, slot)
            PrintDebug("Juju Flurry used.")
        else
            PrintDebug("Juju Flurry is on cooldown.")
        end
    else
        PrintDebug("Juju Flurry not found in bags.")
    end
end

-- Command to toggle debug mode
local function ToggleDebugMode()
    debugMode = not debugMode
    if debugMode then
        print("Debug mode ON.")
    else
        print("Debug mode OFF.")
    end
end

-- Command to use Juju Flurry
SLASH_USEFLURRY1 = "/useflurry"
SlashCmdList["USEFLURRY"] = UseJujuFlurry

-- Command to toggle debug mode
SLASH_TOGGLEDEBUG1 = "/flurrydebug"
SlashCmdList["TOGGLEDEBUG"] = ToggleDebugMode
