-- Saved Variables
WWIconSettings = WWIconSettings or {
    isFaded = false,
    point = "CENTER",
    xOfs = 0,
    yOfs = 0,
    size = 64
}

-- Add a global table for SNB if it doesn't already exist
SNB = SNB or {}
SNB.isWhirlwindMode = true  -- Initialize whirlwind mode as active
SNB.isOverpowerMode = false  -- Initialize overpower mode as inactive
SNB.isSweepingStrikesMode = true -- Initialize Sweeping Strikes Mode as inactive

-- Create the Whirlwind button frame
local whirlwindButton = CreateFrame("Button", "WhirlwindButton", UIParent)
whirlwindButton:SetWidth(WWIconSettings.size)  -- Set width from saved variable
whirlwindButton:SetHeight(WWIconSettings.size)  -- Set height from saved variable
whirlwindButton:SetPoint(WWIconSettings.point, UIParent, WWIconSettings.point, WWIconSettings.xOfs, WWIconSettings.yOfs)  -- Load saved position
whirlwindButton:EnableMouse(true)  -- Enable mouse interaction
whirlwindButton:SetMovable(true)  -- Allow the button to be moved

-- Add the Whirlwind icon texture
local whirlwindTexture = whirlwindButton:CreateTexture(nil, "BACKGROUND")
whirlwindTexture:SetTexture("Interface\\Icons\\Ability_Whirlwind")  -- Whirlwind icon path
whirlwindTexture:SetAllPoints(whirlwindButton)  -- Fill the button with the texture

-- Create the Overpower button frame
local overpowerButton = CreateFrame("Button", "OverpowerButton", UIParent)
overpowerButton:SetWidth(WWIconSettings.size)  -- Set width from saved variable
overpowerButton:SetHeight(WWIconSettings.size)  -- Set height from saved variable
overpowerButton:SetPoint("LEFT", whirlwindButton, "RIGHT", 0, 0)  -- Anchor to the right of Whirlwind button
overpowerButton:EnableMouse(true)  -- Enable mouse interaction

-- Add the Overpower icon texture
local overpowerTexture = overpowerButton:CreateTexture(nil, "BACKGROUND")
overpowerTexture:SetTexture("Interface\\Icons\\Ability_MeleeDamage")  -- Overpower icon path
overpowerTexture:SetAllPoints(overpowerButton)  -- Fill the button with the texture

-- Sweeping Strikes button settings
local sweepingFrame = CreateFrame("Button", "SweepingStrikesIconFrame", UIParent)
sweepingFrame:SetWidth(WWIconSettings.size)  -- Set width
sweepingFrame:SetHeight(WWIconSettings.size)  -- Set height
sweepingFrame:SetPoint("LEFT", overpowerButton, "RIGHT", 0, 0)  -- Position next to Overpower button
sweepingFrame:SetMovable(true)
sweepingFrame:EnableMouse(true)

-- Sweeping Strikes icon texture
local sweepingTexture = sweepingFrame:CreateTexture(nil, "BACKGROUND")
sweepingTexture:SetTexture("Interface\\Icons\\Ability_Rogue_SliceDice")  -- Sweeping Strikes icon
sweepingTexture:SetAllPoints(sweepingFrame)

-- Function to update the visibility of the Whirlwind icon based on Whirlwind mode
function SNB.UpdateWhirlwindIcon()
    if SNB.isWhirlwindMode then
        whirlwindButton:SetAlpha(1.0)  -- Full opacity
    else
        whirlwindButton:SetAlpha(0.3)  -- Faded opacity
    end
end

-- Function to update the Overpower button icon based on Overpower mode
function SNB.UpdateOverpowerButton()
    if SNB.isOverpowerMode then
        overpowerButton:SetAlpha(1.0)  -- Full opacity when Overpower mode is active
    else
        overpowerButton:SetAlpha(0.3)  -- Faded opacity when Overpower mode is inactive
    end
end

-- Check if player is talented into Sweeping Strikes
local function IsSweepingStrikesTalented()
    local _, _, _, _, rank = GetTalentInfo(1, 13) -- 1 = Arms tree, 11 = Sweeping Strikes
    return rank > 0
end

-- Function to toggle Sweeping Strikes visibility
function SNB.UpdateSweepingStrikesButton()
    if IsSweepingStrikesTalented() then
        sweepingFrame:Show()
    else
        sweepingFrame:Hide()
    end
end

-- Function to toggle Whirlwind mode
function SNB.ToggleWhirlwindMode()
    SNB.isWhirlwindMode = not SNB.isWhirlwindMode  -- Toggle the mode
    SNB.UpdateWhirlwindIcon()  -- Update the icon visibility
end

-- Function to toggle Overpower mode
function SNB.ToggleOverpowerMode()
    SNB.isOverpowerMode = not SNB.isOverpowerMode  -- Toggle the mode
    SNB.UpdateOverpowerButton()  -- Update the icon visibility
end

-- Button click functionality to toggle Sweeping Strikes mode
local function ToggleSweepingStrikesFromButton()
    SNB.ToggleSweepingStrikesMode()
    if SNB.isSweepingStrikesMode then
        sweepingFrame:SetAlpha(1.0)  -- Full opacity when active
    else
        sweepingFrame:SetAlpha(0.3)  -- Faded opacity when inactive
    end
end

-- Manually show or hide the Sweeping Strikes button
function SNB.ShowSweepingStrikesButton()
    sweepingFrame:Show()
    sweepingFrame:SetAlpha(1.0)
    print("Sweeping Strikes button is now visible.")
end

function SNB.HideSweepingStrikesButton()
    sweepingFrame:Hide()
    print("Sweeping Strikes button is now hidden.")
end

-- Enable dragging with right click for the Whirlwind button
whirlwindButton:RegisterForDrag("RightButton")
whirlwindButton:SetScript("OnDragStart", function()
    if not WWIconSettings.locked then
        whirlwindButton:StartMoving()
    end
end)

whirlwindButton:SetScript("OnDragStop", function()
    whirlwindButton:StopMovingOrSizing()  -- Stop moving
    -- Save the new position
    local point, _, _, xOfs, yOfs = whirlwindButton:GetPoint()
    WWIconSettings.point = point
    WWIconSettings.xOfs = xOfs
    WWIconSettings.yOfs = yOfs
end)

-- Set the click behavior for the Whirlwind button
whirlwindButton:RegisterForClicks("LeftButtonUp")  -- Listen for left-click release
whirlwindButton:SetScript("OnClick", SNB.ToggleWhirlwindMode)  -- Call the toggle function on click

-- Set the click behavior for the Overpower button
overpowerButton:RegisterForClicks("LeftButtonUp")  -- Listen for left-click release
overpowerButton:SetScript("OnClick", SNB.ToggleOverpowerMode)  -- Call the toggle function on click

-- Initialize Sweeping Strikes button
sweepingFrame:RegisterForClicks("LeftButtonUp")
sweepingFrame:SetScript("OnClick", ToggleSweepingStrikesFromButton)
sweepingFrame:SetScript("OnShow", function()
    if SNB.isSweepingStrikesMode then
        sweepingFrame:SetAlpha(1.0)
    else
        sweepingFrame:SetAlpha(0.3)
    end
end)

-- Function to resize the buttons
local function ResizeButtons(size)
    size = tonumber(size)  -- Ensure the input is treated as a number
    if size and size >= 16 and size <= 128 then
        whirlwindButton:SetWidth(size)
        whirlwindButton:SetHeight(size)
        overpowerButton:SetWidth(size)
        overpowerButton:SetHeight(size)
        sweepingFrame:SetHeight(size)
        sweepingFrame:SetWidth(size)
        WWIconSettings.size = size  -- Save size to variable
        print(string.format("Buttons resized to: %d x %d", size, size))
    else
        print("Invalid size! Please enter a number between 16 and 128.")
    end
end

-- Function to hide all icons
function SNB.HideIcons()
    whirlwindButton:Hide()
    overpowerButton:Hide()
    print("Icons are now hidden.")
end

-- Function to show all icons
function SNB.ShowIcons()
    whirlwindButton:Show()
    overpowerButton:Show()
    print("Icons are now visible.")
end

-- Slash command to scale, lock/unlock, hide/show all buttons
SLASH_WWICON1 = "/wwicon"
SlashCmdList["WWICON"] = function(input)
    if input == "lock" then
        WWIconSettings.locked = true
        print("Icons are now locked.")
    elseif input == "unlock" then
        WWIconSettings.locked = false
        print("Icons are now unlocked.")
    elseif input == "hide" then
        whirlwindButton:Hide()
        overpowerButton:Hide()
        sweepingFrame:Hide()
        print("Icons are now hidden.")
    elseif input == "show" then
        whirlwindButton:Show()
        overpowerButton:Show()
        sweepingFrame:Show()
        print("Icons are now visible.")
    elseif input == "ssshow" then
        SNB.ShowSweepingStrikesButton()
    elseif input == "sshide" then
        SNB.HideSweepingStrikesButton()
    else
        local size = tonumber(input)
        if size then
            ResizeButtons(size)
        else
            print("Please enter a valid command: lock, unlock, hide, show, ssshow, sshide, or a size between 16 and 128.")
        end
    end
end

-- Create a slash command for resizing
SLASH_WWRESIZE1 = "/wwresize"
SlashCmdList["WWRESIZE"] = function(input)
    ResizeButtons(input)
end

-- Initialize saved variables on addon load
local function InitializeButtons()
    whirlwindButton:SetWidth(WWIconSettings.size)
    whirlwindButton:SetHeight(WWIconSettings.size)
    whirlwindButton:SetPoint(WWIconSettings.point, UIParent, WWIconSettings.point, WWIconSettings.xOfs, WWIconSettings.yOfs)
    overpowerButton:SetWidth(WWIconSettings.size)
    overpowerButton:SetHeight(WWIconSettings.size)
    sweepingFrame:SetHeight(WWIconSettings.size)
    sweepingFrame:SetWidth(WWIconSettings.size)
    overpowerButton:SetPoint("LEFT", whirlwindButton, "RIGHT", 0, 0)  -- Anchor to the right of Whirlwind button
    sweepingFrame:SetPoint("LEFT", overpowerButton, "RIGHT", 0, 0) -- Anchor to the right of Overpower Button
    SNB.UpdateWhirlwindIcon()  -- Ensure visibility matches the current mode
    SNB.UpdateOverpowerButton()  -- Ensure visibility matches the current mode
    SNB.UpdateSweepingStrikesButton()
    print("Button settings loaded.")
end

-- Hook for PLAYER_LOGIN to ensure settings are applied after UI load
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", InitializeButtons)