local DEBUG = false  -- Set to true to enable debug mode

local function tp_print(msg)
    if DEBUG then
        if type(msg) == "boolean" then msg = msg and "true" or "false" end
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

local function debug_print(msg)
    if DEBUG then tp_print(msg) end
end

local player_guid = nil
local tracked_guids = {}
local SHIELD_BASH_SPELL_ID = 1672

-- Use the shared saved variable for shield equip functionality
ShieldEquippedCurrently = ShieldEquippedCurrently or {}

-- Function to get spell book slot for a given spell name
local function FindSpellBookSlotByName(spellName)
    for i = 1, 120 do
        local spellBookName, spellBookRank = GetSpellName(i, "spell")
        if spellBookName == spellName then
            return i
        end
    end
    return nil
end

-- Function to get spell cooldown
local function GetSpellCooldownById(spellID)
    local name, rank, texture, minRange, maxRange = SpellInfo(spellID)
    if name then
        local slot = FindSpellBookSlotByName(name)
        if slot then
            return GetSpellCooldown(slot, "spell")
        end
    end
    return nil, nil, nil
end

-- Function to equip the shield if not already equipped
local function EquipShieldIfNecessary()
    if not ShieldEquippedCurrently.shieldName then
        tp_print("No shield name set. Use '/shield [name]' to set the shield.")
        return false
    end

    local offHandLink = GetInventoryItemLink("player", 17)  -- 17 is the Off-Hand slot
    if offHandLink then
        local _, _, itemName = string.find(offHandLink, "%[(.+)%]")
        if itemName == ShieldEquippedCurrently.shieldName then
            debug_print("Shield is already equipped.")
            return true
        end
    end

    -- Try to find and equip the shield from the bags
    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    local _, _, itemName = string.find(itemLink, "%[(.+)%]")
                    if itemName == ShieldEquippedCurrently.shieldName then
                        -- Equip the shield
                        PickupContainerItem(bag, slot)
                        EquipCursorItem(17)  -- Equip in Off-Hand
                        debug_print("Equipping shield: " .. ShieldEquippedCurrently.shieldName)
                        return true
                    end
                end
            end
        end
    end

    tp_print("Shield not found in bags!")
    return false
end

-- HookScript function
function HookScript(f, script, func)
    local prev = f:GetScript(script)
    f:SetScript(script, function(a1, a2, a3, a4, a5, a6, a7, a8, a9)
        if prev then prev(a1, a2, a3, a4, a5, a6, a7, a8, a9) end
        func(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    end)
end

-- Tracking spell cast
local function Events()
    if event == "UNIT_CASTEVENT" then
        local _, source = UnitExists(arg1)
        if not source then return end
        for guid, data in pairs(tracked_guids) do
            if source == guid then
                if arg3 == "START" then
                    tracked_guids[guid].casting = true
                elseif arg3 == "FAIL" or arg3 == "CAST" then
                    tracked_guids[guid].casting = false
                end
                break
            end
        end
    end
end

local function Update()
    for _, plate in pairs({ WorldFrame:GetChildren() }) do
        local guid = plate:GetName(1)
        if not tracked_guids[guid] then
            tracked_guids[guid] = {
                casting = false,
            }
        end
    end
end

local function Init()
    if event == "PLAYER_ENTERING_WORLD" then
        _, player_guid = UnitExists("player")
        this:SetScript("OnEvent", Events)
        this:SetScript("OnUpdate", Update)
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end

local shieldBashFrame = CreateFrame("Frame")
shieldBashFrame:SetScript("OnEvent", Init)
shieldBashFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
shieldBashFrame:RegisterEvent("UNIT_CASTEVENT")

SLASH_SHIELDBASH1 = "/shieldbash"
SlashCmdList["SHIELDBASH"] = function()
    local target = "target"
    if UnitExists(target) and UnitCanAttack("player", target) then
        local shieldBashStart, shieldBashDuration, shieldBashEnabled = GetSpellCooldownById(SHIELD_BASH_SPELL_ID)
        local shieldBashCooldown = (shieldBashStart + shieldBashDuration) - GetTime()

        -- Check if target is casting and Shield Bash is ready
        for guid, unit in pairs(tracked_guids) do
            if UnitIsUnit(target, guid) and unit.casting then
                -- Equip shield only if target is casting
                if EquipShieldIfNecessary() then
                    -- Proceed with Shield Bash if Shield is equipped
                    if shieldBashCooldown <= 0 then
                        CastSpellByName("Shield Bash", target)
                        return
                    else
                        tp_print("Shield Bash is on cooldown.")
                    end
                end
                return
            end
        end

        -- If no target is casting, print message
        tp_print("Target is not casting.")
    end
end
