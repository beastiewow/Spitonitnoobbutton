-- Initialize the saved variable (ShieldEquippedCurrently)
ShieldEquippedCurrently = ShieldEquippedCurrently or {}

-- Debug mode toggle (default is false)
local DEBUG_MODE = false

-- Function to print debug messages
local function DebugPrint(msg)
    if DEBUG_MODE then
        print("[Debug] " .. msg)
    end
end

-- Function to toggle debug mode
SLASH_DEBUGSHIELD1 = "/shielddebug"
function SlashCmdList.DEBUGSHIELD()
    DEBUG_MODE = not DEBUG_MODE
    print("Shield addon debug mode is now " .. (DEBUG_MODE and "ON" or "OFF"))
end

-- Function to determine if the player is in Defensive Stance
local function IsInDefensiveStance()
    local stanceCount = GetNumShapeshiftForms()
    for index = 1, stanceCount do
        local _, _, active = GetShapeshiftFormInfo(index)
        if active and index == 2 then  -- 2 corresponds to Defensive Stance
            return true
        end
    end
    return false
end

-- Function to cast Shield Block after equipping the shield
local function CastShieldBlock()
    local spellName = "Shield Block"
    CastSpellByName(spellName)
    DebugPrint("Casting Shield Block!")
end

-- Function to equip the shield when /shield command is used
SLASH_EQUIPSHIELD1 = "/shield"

function SlashCmdList.EQUIPSHIELD(msg, editBox)
    -- Check if the user provided a new shield name
    if msg and msg ~= "" then
        ShieldEquippedCurrently.shieldName = msg  -- Save shield name in saved variable
        print("Shield name set to: " .. ShieldEquippedCurrently.shieldName)  -- Keep this print
        return
    end

    -- If no shield name has been set, alert the user
    if not ShieldEquippedCurrently.shieldName then
        print("No shield name has been set. Use '/shield [name]' to set the shield.")  -- Important print remains
        return
    end

    -- Check if the player is in Defensive Stance
    if not IsInDefensiveStance() then
        DebugPrint("You are not in Defensive Stance. Equip the shield only in Defensive Stance!")
        return
    end

    local offHandLink = GetInventoryItemLink("player", 17)  -- 17 is the slot for Off Hand

    -- Check if we are already equipped with the shield
    if offHandLink then
        local _, _, itemName = string.find(offHandLink, "%[(.+)%]")
        if itemName == ShieldEquippedCurrently.shieldName then
            DebugPrint("You are already wearing the shield!")
            CastShieldBlock()  -- Cast Shield Block if the shield is already equipped
            return
        end
    end

    -- Try to equip the shield from the bags
    local foundShield = false
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
                        EquipCursorItem(17) -- Equip in Off-Hand
                        DebugPrint("Equipping shield: " .. ShieldEquippedCurrently.shieldName)
                        foundShield = true
                        CastShieldBlock()  -- Cast Shield Block after equipping the shield
                        return
                    end
                end
            end
        end
    end

    if not foundShield then
        DebugPrint("Shield not found in your bags!")
    end
end

-- Function to initialize the saved variable when the addon is loaded
local function OnAddonLoaded(self, event, addonName)
    if addonName == "EquipShieldAddon" then  -- Replace this with the name of your addon folder if necessary
        -- Ensure the saved variable is initialized
        if not ShieldEquippedCurrently.shieldName then
            ShieldEquippedCurrently.shieldName = nil
            print("No shield name saved. Please set a shield name using '/shield [name]'.")
        else
            DebugPrint("Loaded saved shield name: " .. ShieldEquippedCurrently.shieldName)
        end
    end
end

-- Register event frame for ADDON_LOADED
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnAddonLoaded)
