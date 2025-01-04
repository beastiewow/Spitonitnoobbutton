-- Initialize the saved variables for offhand and two-hander weapons
OffhandName = OffhandName or {}
TwoHanderName = TwoHanderName or {}

-- Function to initialize the saved variable when the addon is loaded
local function OnAddonLoaded(self, event, addonName)
    if addonName == "Offhand" then  -- Replace this with the name of your addon folder if necessary
        -- Ensure the saved variable is initialized
        if not OffhandName.name then
            OffhandName.name = nil
            print("No offhand weapon name saved. Please set an offhand weapon using '/offhand [name]'.")
        else
            -- Optional: Debug print to confirm that it loaded
            -- debug_print("Loaded saved offhand weapon name: " .. OffhandName.name)
        end
    end
end

-- Register event frame for ADDON_LOADED
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnAddonLoaded)

-- Function to select and save the offhand weapon using a slash command
SLASH_OFFHAND1 = "/offhand"
function SlashCmdList.OFFHAND(msg)
    if msg and msg ~= "" then
        OffhandName.name = msg  -- Save the selected offhand name in the saved variable
        print("Offhand weapon set to: " .. OffhandName.name)
    else
        print("Please provide the name of the offhand weapon. Usage: /offhand [name]")
    end
end

-- Function to select and save the two-hander weapon using a slash command
SLASH_TWOHANDER1 = "/2hander"
function SlashCmdList.TWOHANDER(msg)
    if msg and msg ~= "" then
        TwoHanderName.name = msg  -- Save the selected two-hander name in the saved variable
        print("Two-hander weapon set to: " .. TwoHanderName.name)
    else
        print("Please provide the name of the two-hander. Usage: /2hander [name]")
    end
end

-- Function to check if the selected two-hander is currently equipped in the main hand
function SNB.IsTwoHanderEquipped()
    local mainHandLink = GetInventoryItemLink("player", 16)  -- 16 is the main hand slot
    if mainHandLink and TwoHanderName.name then
        local _, _, itemName = string.find(mainHandLink, "%[(.+)%]")
        if itemName == TwoHanderName.name then
            -- Debug print to confirm detection (optional, remove for production)
            return true  -- Return true if the selected two-hander is equipped
        end
    end
    return false
end

-- Function to equip the offhand weapon if in Berserker Stance or Battle Stance and no two-hander equipped
function SNB.EquipOffhandIfInBerserkerStance()
    -- Check if the player is in Berserker or Battle Stance
    if SNB.IsInBerserkerStance() or SNB.IsInBattleStance() then
        -- Check if the selected two-hander is equipped
        if SNB.IsTwoHanderEquipped() then
            -- If the two-hander is equipped, skip equipping the offhand
            return  -- Exit the function early to avoid equipping the offhand
        end

        -- Equip the saved offhand weapon if no two-hander is equipped
        if OffhandName.name then
            local offhandSlot = 17  -- Offhand slot ID
            for bag = 0, 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local itemLink = GetContainerItemLink(bag, slot)
                    if itemLink and string.find(itemLink, OffhandName.name) then
                        -- Equip the offhand from the player's bags
                        PickupContainerItem(bag, slot)
                        PickupInventoryItem(offhandSlot)
                        return
                    end
                end
            end
        end
    end
end








