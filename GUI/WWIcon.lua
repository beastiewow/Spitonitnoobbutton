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
SNB.isSweepingStrikesMode = true -- Initialize Sweeping Strikes Mode as active

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

-- Create the Sweeping Strikes button
local sweepingFrame = CreateFrame("Button", "SweepingStrikesIconFrame", UIParent)
sweepingFrame:SetWidth(WWIconSettings.size)  -- Set width
sweepingFrame:SetHeight(WWIconSettings.size)  -- Set height
sweepingFrame:SetPoint("LEFT", overpowerButton, "RIGHT", 0, 0)  -- Anchor to the right of Overpower button
sweepingFrame:SetMovable(true)
sweepingFrame:EnableMouse(true)

-- Add the Sweeping Strikes icon texture
local sweepingTexture = sweepingFrame:CreateTexture(nil, "BACKGROUND")
sweepingTexture:SetTexture("Interface\\Icons\\Ability_Rogue_SliceDice")  -- Sweeping Strikes icon path
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
        overpowerButton:SetAlpha(1.0)  -- Full opacity
    else
        overpowerButton:SetAlpha(0.3)  -- Faded opacity
    end
end

-- Function to dynamically update Sweeping Strikes button visibility based on talent changes
local function CheckSweepingStrikesMessage(message)
    if message == "You have learned a new ability: Sweeping Strikes." then
        sweepingFrame:Show()
        sweepingFrame:SetAlpha(1.0)  -- Full opacity by default when learned
        print("Sweeping Strikes ability learned. Button is now visible.")
    elseif message == "You have unlearned Sweeping Strikes." then
        sweepingFrame:Hide()
        print("Sweeping Strikes ability unlearned. Button is now hidden.")
    end
end

-- Hook into the chat system to listen for relevant messages
local sweepingStrikesMessageFrame = CreateFrame("Frame")
sweepingStrikesMessageFrame:RegisterEvent("CHAT_MSG_SYSTEM")
sweepingStrikesMessageFrame:SetScript("OnEvent", function(_, _, message)
    CheckSweepingStrikesMessage(message)
end)

-- Function to update Sweeping Strikes button visibility based on talent
function SNB.UpdateSweepingStrikesButton()
    local _, _, _, _, rank = GetTalentInfo(1, 13) -- 1 = Arms tree, 13 = Sweeping Strikes
    if rank > 0 then
        sweepingFrame:Show()
        sweepingFrame:SetAlpha(1.0)
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
    SNB.isSweepingStrikesMode = not SNB.isSweepingStrikesMode
    if SNB.isSweepingStrikesMode then
        sweepingFrame:SetAlpha(1.0)  -- Full opacity
    else
        sweepingFrame:SetAlpha(0.3)  -- Faded opacity
    end
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
    local point, _, _, xOfs, yOfs = whirlwindButton:GetPoint()
    WWIconSettings.point = point
    WWIconSettings.xOfs = xOfs
    WWIconSettings.yOfs = yOfs
end)

-- Set the click behavior for the Whirlwind button
whirlwindButton:RegisterForClicks("LeftButtonUp")
whirlwindButton:SetScript("OnClick", SNB.ToggleWhirlwindMode)

-- Set the click behavior for the Overpower button
overpowerButton:RegisterForClicks("LeftButtonUp")
overpowerButton:SetScript("OnClick", SNB.ToggleOverpowerMode)

-- Initialize Sweeping Strikes button
sweepingFrame:RegisterForClicks("LeftButtonUp")
sweepingFrame:SetScript("OnClick", ToggleSweepingStrikesFromButton)

-- Function to resize all buttons
local function ResizeButtons(size)
    size = tonumber(size)
    if size and size >= 16 and size <= 128 then
        whirlwindButton:SetWidth(size)
        whirlwindButton:SetHeight(size)
        overpowerButton:SetWidth(size)
        overpowerButton:SetHeight(size)
        sweepingFrame:SetWidth(size)
        sweepingFrame:SetHeight(size)
        WWIconSettings.size = size
        print(string.format("Buttons resized to: %d x %d", size, size))
    else
        print("Invalid size! Please enter a number between 16 and 128.")
    end
end

-- Slash command to scale, lock/unlock, hide/show buttons
SLASH_WWICON1 = "/wwicon"
SlashCmdList["WWICON"] = function(input)
    local scale = tonumber(input)
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
    elseif scale then
        ResizeButtons(scale)
    else
        print("Please enter a valid command: lock, unlock, hide, show, or a number between 16 and 128 to resize.")
    end
end

-- Initialize buttons on addon load
local function InitializeButtons()
    whirlwindButton:SetWidth(WWIconSettings.size)
    whirlwindButton:SetHeight(WWIconSettings.size)
    whirlwindButton:SetPoint(WWIconSettings.point, UIParent, WWIconSettings.point, WWIconSettings.xOfs, WWIconSettings.yOfs)
    overpowerButton:SetWidth(WWIconSettings.size)
    overpowerButton:SetHeight(WWIconSettings.size)
    sweepingFrame:SetWidth(WWIconSettings.size)
    sweepingFrame:SetHeight(WWIconSettings.size)
    overpowerButton:SetPoint("LEFT", whirlwindButton, "RIGHT", 0, 0)
    sweepingFrame:SetPoint("LEFT", overpowerButton, "RIGHT", 0, 0)
    SNB.UpdateWhirlwindIcon()
    SNB.UpdateOverpowerButton()
    SNB.UpdateSweepingStrikesButton()
end

-- Hook PLAYER_LOGIN to ensure settings are applied after UI load
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", InitializeButtons)
