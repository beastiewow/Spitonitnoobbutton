WWIconSettings = WWIconSettings or {
    point = "CENTER",
    xOfs = 0,
    yOfs = 0,
    size = 64,
    locked = false
}

-- Add SNB namespace if it doesn't exist
SNB = SNB or {}

-- Initialize mode variables
SNB.isWhirlwindMode = SNB.isWhirlwindMode or true
SNB.isOverpowerMode = SNB.isOverpowerMode or false
SNB.isSweepingStrikesMode = SNB.isSweepingStrikesMode or true
SNB.isSlamPriorityMode = SNB.isSlamPriorityMode or false
SNB.battleShoutEnabled = SNB.battleShoutEnabled or true

-- Create the main WWIcon frame
local WWIconFrame = nil
local isInitialized = false

-- Function to create and setup the frame
local function CreateWWIconFrame()
    
    WWIconFrame = CreateFrame("Frame", "SNB_WWIconFrame", UIParent)
    WWIconFrame.buttons = {}
    
    -- Set basic properties first
    WWIconFrame:SetWidth(150)
    WWIconFrame:SetHeight(80)
    -- Don't set position here - we'll do it in initialization after loading saved variables
    
    -- Create backdrop
    local backdrop = {
        bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 5, top = 3, bottom = 5 }
    }
    
    WWIconFrame:SetBackdrop(backdrop)
    WWIconFrame:SetBackdropColor(0, 0, 0, 0.8)
    WWIconFrame:SetBackdropBorderColor(1, 1, 1, 1)
    
    -- Make it movable
    WWIconFrame:SetMovable(true)
    WWIconFrame:EnableMouse(true)
    WWIconFrame:RegisterForDrag("LeftButton")
    
    -- Drag scripts
    WWIconFrame:SetScript("OnDragStart", function()
        if not WWIconSettings.locked then
            WWIconFrame:StartMoving()
        end
    end)
    
    WWIconFrame:SetScript("OnDragStop", function()
        WWIconFrame:StopMovingOrSizing()
        local point, _, _, xOfs, yOfs = WWIconFrame:GetPoint()
        WWIconSettings.point = point
        WWIconSettings.xOfs = xOfs
        WWIconSettings.yOfs = yOfs
    end)
    
    -- Create the Whirlwind button
    local whirlwindButton = CreateFrame("Button", "SNB_WhirlwindButton", WWIconFrame)
    whirlwindButton:SetWidth(WWIconSettings.size)
    whirlwindButton:SetHeight(WWIconSettings.size)
    whirlwindButton:SetPoint("LEFT", WWIconFrame, "LEFT", 10, 0)  -- 10 pixels from left edge
    whirlwindButton:EnableMouse(true)
    
    -- Add the Whirlwind icon texture
    local whirlwindTexture = whirlwindButton:CreateTexture(nil, "BACKGROUND")
    whirlwindTexture:SetTexture("Interface\\Icons\\Ability_Whirlwind")
    whirlwindTexture:SetAllPoints(whirlwindButton)
    
    -- Set click behavior
    whirlwindButton:RegisterForClicks("LeftButtonUp")
    whirlwindButton:SetScript("OnClick", function()
        SNB.ToggleWhirlwindMode()
    end)
    
    -- Store button reference
    WWIconFrame.whirlwindButton = whirlwindButton
    
    -- Create the Sweeping Strikes button
    local sweepingButton = CreateFrame("Button", "SNB_SweepingStrikesButton", WWIconFrame)
    sweepingButton:SetWidth(WWIconSettings.size)
    sweepingButton:SetHeight(WWIconSettings.size)
    sweepingButton:SetPoint("LEFT", whirlwindButton, "RIGHT", 5, 0)  -- 5 pixels to the right of Whirlwind
    sweepingButton:EnableMouse(true)
    
    -- Add the Sweeping Strikes icon texture
    local sweepingTexture = sweepingButton:CreateTexture(nil, "BACKGROUND")
    sweepingTexture:SetTexture("Interface\\Icons\\Ability_Rogue_SliceDice")
    sweepingTexture:SetAllPoints(sweepingButton)
    
    -- Set click behavior
    sweepingButton:RegisterForClicks("LeftButtonUp")
    sweepingButton:SetScript("OnClick", function()
        SNB.ToggleSweepingStrikesMode()
    end)
    
    -- Store button reference
    WWIconFrame.sweepingButton = sweepingButton
    
    -- Create the Slam Priority button
    local slamButton = CreateFrame("Button", "SNB_SlamPriorityButton", WWIconFrame)
    slamButton:SetWidth(WWIconSettings.size)
    slamButton:SetHeight(WWIconSettings.size)
    slamButton:SetPoint("LEFT", sweepingButton, "RIGHT", 5, 0)  -- 5 pixels to the right of Sweeping Strikes
    slamButton:EnableMouse(true)
    
    -- Add the Slam Priority icon texture
    local slamTexture = slamButton:CreateTexture(nil, "BACKGROUND")
    slamTexture:SetTexture("Interface\\Icons\\Ability_Warrior_DecisiveStrike")
    slamTexture:SetAllPoints(slamButton)
    
    -- Set click behavior
    slamButton:RegisterForClicks("LeftButtonUp")
    slamButton:SetScript("OnClick", function()
        SNB.ToggleSlamPriorityMode()
    end)
    
    -- Store button reference
    WWIconFrame.slamButton = slamButton
    
    -- Create the Battle Shout button
    local battleShoutButton = CreateFrame("Button", "SNB_BattleShoutButton", WWIconFrame)
    battleShoutButton:SetWidth(WWIconSettings.size)
    battleShoutButton:SetHeight(WWIconSettings.size)
    battleShoutButton:SetPoint("LEFT", slamButton, "RIGHT", 5, 0)  -- 5 pixels to the right of Slam Priority
    battleShoutButton:EnableMouse(true)

    -- Add the Battle Shout icon texture
    local battleShoutTexture = battleShoutButton:CreateTexture(nil, "BACKGROUND")
    battleShoutTexture:SetTexture("Interface\\Icons\\Ability_Warrior_BattleShout")
    battleShoutTexture:SetAllPoints(battleShoutButton)

    -- Set click behavior
    battleShoutButton:RegisterForClicks("LeftButtonUp")
    battleShoutButton:SetScript("OnClick", function()
        SNB.ToggleBattleShout()
    end)

    -- Store button reference
    WWIconFrame.battleShoutButton = battleShoutButton

    -- Force show
    WWIconFrame:Show()
    
    return WWIconFrame
end

-- Check if player is talented into Sweeping Strikes (from original code)
local function IsSweepingStrikesTalented()
    local _, _, _, _, rank = GetTalentInfo(1, 13) -- 1 = Arms tree, 13 = Sweeping Strikes
    return rank > 0
end

-- Check if player has Mortal Strike talent (Arms spec check)
local function HasMortalStrike()
    local _, _, _, _, rank = GetTalentInfo(1, 17) -- 1 = Arms tree, 17 = Mortal Strike
    return rank > 0
end

-- Function to update Sweeping Strikes button alpha (from original code)
function SNB.UpdateSweepingStrikesButtonAlpha()
    if WWIconFrame and WWIconFrame.sweepingButton then
        if SNB.isSweepingStrikesMode then
            WWIconFrame.sweepingButton:SetAlpha(1.0)  -- Full opacity when active
        else
            WWIconFrame.sweepingButton:SetAlpha(0.3)  -- Faded opacity when inactive
        end
    end
end-- Saved Variables for WWIcon GUI

-- Add this function for updating the Battle Shout button alpha
function SNB.UpdateBattleShoutButtonAlpha()
    if WWIconFrame and WWIconFrame.battleShoutButton then
        if SNB.battleShoutEnabled then
            WWIconFrame.battleShoutButton:SetAlpha(1.0)  -- Full opacity when active
        else
            WWIconFrame.battleShoutButton:SetAlpha(0.3)  -- Faded opacity when inactive
        end
    end
end

-- Function to update frame visibility and content
function SNB.UpdateWWIconGUI()
    if not WWIconFrame then
        CreateWWIconFrame()
        return
    end
    
    -- Update button visibility based on talents
    SNB.UpdateSweepingStrikesButton()
    SNB.UpdateSlamPriorityVisibility()
    
    -- Update button alpha states
    if WWIconFrame.whirlwindButton then
        SNB.UpdateWhirlwindIcon()
    end
    
    if WWIconFrame.sweepingButton then
        SNB.UpdateSweepingStrikesButtonAlpha()
    end
    
    if WWIconFrame.slamButton then
        SNB.UpdateSlamPriorityButtonAlpha()
    end
    
    if WWIconFrame.battleShoutButton then
        SNB.UpdateBattleShoutButtonAlpha()
    end

    -- Calculate frame size based on visible buttons
    local buttonSize = WWIconSettings.size
    local spacing = 5
    local padding = 10
    local visibleButtons = 2  -- Whirlwind is always visible
    
    -- Check if Sweeping Strikes button should be visible
    if IsSweepingStrikesTalented() then
        visibleButtons = visibleButtons + 1
    end
    
    -- Check if Slam Priority button should be visible (Arms warriors only)
    if HasMortalStrike() then
        visibleButtons = visibleButtons + 1
    end
    
    -- Adjust frame size
    local frameWidth = (visibleButtons * buttonSize) + ((visibleButtons - 1) * spacing) + (padding * 2)
    local frameHeight = buttonSize + (padding * 2)
    
    WWIconFrame:SetWidth(frameWidth)
    WWIconFrame:SetHeight(frameHeight)
    
    WWIconFrame:Show()
end

-- Check if player is talented into Sweeping Strikes (from original code)
local function IsSweepingStrikesTalented()
    local _, _, _, _, rank = GetTalentInfo(1, 13) -- 1 = Arms tree, 13 = Sweeping Strikes
    return rank > 0
end

-- Check if player has Mortal Strike talent (Arms spec check)
local function HasMortalStrike()
    local _, _, _, _, rank = GetTalentInfo(1, 17) -- 1 = Arms tree, 17 = Mortal Strike
    return rank > 0
end

-- Function to update Sweeping Strikes button visibility (from original code)
function SNB.UpdateSweepingStrikesButton()
    if not WWIconFrame or not WWIconFrame.sweepingButton then
        return
    end
    
    if IsSweepingStrikesTalented() then
        WWIconFrame.sweepingButton:Show()
    else
        WWIconFrame.sweepingButton:Hide()
    end
end

-- Function to update Slam Priority button visibility (only show for Arms warriors)
function SNB.UpdateSlamPriorityVisibility()
    if not WWIconFrame or not WWIconFrame.slamButton then
        return
    end
    
    if HasMortalStrike() then
        WWIconFrame.slamButton:Show()
    else
        WWIconFrame.slamButton:Hide()
    end
end

-- Function to update Slam Priority button alpha (from original code)
function SNB.UpdateSlamPriorityButtonAlpha()
    if WWIconFrame and WWIconFrame.slamButton then
        if SNB.isSlamPriorityMode then
            WWIconFrame.slamButton:SetAlpha(1.0)  -- Full opacity when active
        else
            WWIconFrame.slamButton:SetAlpha(0.3)  -- Faded opacity when inactive
        end
    end
end

-- Function to toggle Slam Priority mode (from original code)
function SNB.ToggleSlamPriorityMode()
    SNB.isSlamPriorityMode = not SNB.isSlamPriorityMode
    SNB.UpdateSlamPriorityButtonAlpha()
    
    -- Provide chat feedback
    if SNB.isSlamPriorityMode then
        DEFAULT_CHAT_FRAME:AddMessage("Slam Priority |cff00ff00ENABLED|r", 1, 1, 0)
    else
        DEFAULT_CHAT_FRAME:AddMessage("Slam Priority |cffff0000DISABLED|r", 1, 1, 0)
    end
end

-- Function to toggle Sweeping Strikes mode (from original code)
function SNB.ToggleSweepingStrikesMode()
    SNB.isSweepingStrikesMode = not SNB.isSweepingStrikesMode
    SNB.UpdateSweepingStrikesButtonAlpha()
    
    -- Provide feedback
    if SNB.isSweepingStrikesMode then
        print("Sweeping Strikes mode ENABLED")
    else
        print("Sweeping Strikes mode DISABLED")
    end
end

-- Function to update the Whirlwind icon based on mode (from original code)
function SNB.UpdateWhirlwindIcon()
    if WWIconFrame and WWIconFrame.whirlwindButton then
        if SNB.isWhirlwindMode then
            WWIconFrame.whirlwindButton:SetAlpha(1.0)  -- Full opacity
        else
            WWIconFrame.whirlwindButton:SetAlpha(0.3)  -- Faded opacity
        end
    end
end

-- Function to toggle Whirlwind mode (from original code)
function SNB.ToggleWhirlwindMode()
    SNB.isWhirlwindMode = not SNB.isWhirlwindMode
    SNB.UpdateWhirlwindIcon()
    
    -- Provide feedback like the original
    if SNB.isWhirlwindMode then
        print("Whirlwind mode ENABLED")
    else
        print("Whirlwind mode DISABLED")
    end
end

-- Function to show/hide the WWIcon frame
function SNB.ShowWWIcons()
    if not WWIconFrame then
        CreateWWIconFrame()
        -- Set position after creation
        if WWIconFrame then
            WWIconFrame:ClearAllPoints()
            WWIconFrame:SetPoint(WWIconSettings.point, UIParent, WWIconSettings.point, WWIconSettings.xOfs, WWIconSettings.yOfs)
        end
    end
    
    if WWIconFrame then
        WWIconFrame:Show()
        SNB.UpdateWWIconGUI()  -- Update button states and frame size
    else
        print("ERROR: WWIcon frame doesn't exist and failed to create.")
    end
end

function SNB.HideWWIcons()
    if WWIconFrame then
        WWIconFrame:Hide()
        print("WWIcon frame hidden.")
    else
        print("WWIcon frame doesn't exist.")
    end
end

-- Function to resize buttons
local function ResizeWWIconButtons(size)
    size = tonumber(size)
    if size and size >= 16 and size <= 128 then
        WWIconSettings.size = size
        
        -- Update button sizes if they exist
        if WWIconFrame then
            if WWIconFrame.whirlwindButton then
                WWIconFrame.whirlwindButton:SetWidth(size)
                WWIconFrame.whirlwindButton:SetHeight(size)
            end
            if WWIconFrame.sweepingButton then
                WWIconFrame.sweepingButton:SetWidth(size)
                WWIconFrame.sweepingButton:SetHeight(size)
            end
            if WWIconFrame.slamButton then
                WWIconFrame.slamButton:SetWidth(size)
                WWIconFrame.slamButton:SetHeight(size)
            end
        end
        
        print(string.format("WWIcon buttons resized to: %d x %d", size, size))
        SNB.UpdateWWIconGUI()  -- Refresh the GUI to update frame size
    else
        print("Invalid size! Please enter a number between 16 and 128.")
    end
end

-- Slash command handler
local function WWIcon_SlashCommand(msg)
    print("WWIcon slash command called with: '" .. (msg or "nil") .. "'")
    
    if not msg or msg == "" then
        -- Toggle visibility
        if not WWIconFrame then
            CreateWWIconFrame()
            -- Set position immediately after creation
            if WWIconFrame then
                WWIconFrame:ClearAllPoints()
                WWIconFrame:SetPoint(WWIconSettings.point, UIParent, WWIconSettings.point, WWIconSettings.xOfs, WWIconSettings.yOfs)
                WWIconFrame:Show()
                SNB.UpdateWWIconGUI()
            end
        elseif WWIconFrame:IsShown() then
            WWIconFrame:Hide()
            print("Frame hidden.")
        else
            WWIconFrame:Show()
            SNB.UpdateWWIconGUI()
            print("Frame shown.")
        end
        return
    end
    
    local lowerMsg = string.lower(msg)
    
    if lowerMsg == "lock" then
        WWIconSettings.locked = true
        print("WWIcon frame is now locked.")
    elseif lowerMsg == "unlock" then
        WWIconSettings.locked = false
        print("WWIcon frame is now unlocked.")
    elseif lowerMsg == "hide" then
        SNB.HideWWIcons()
    elseif lowerMsg == "show" then
        SNB.ShowWWIcons()
    elseif lowerMsg == "test" then
        print("Testing frame creation...")
        CreateWWIconFrame()
        if WWIconFrame then
            WWIconFrame:ClearAllPoints()
            WWIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)  -- Force center position for test
            WWIconFrame:Show()
            SNB.UpdateWWIconGUI()
            print("Test frame created at center.")
        end
    elseif lowerMsg == "reset" then
        print("Resetting frame position to center...")
        WWIconSettings.point = "CENTER"
        WWIconSettings.xOfs = 0
        WWIconSettings.yOfs = 0
        if WWIconFrame then
            WWIconFrame:ClearAllPoints()
            WWIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            WWIconFrame:Show()
            print("Frame reset to center and shown.")
        end
    elseif lowerMsg == "debug" then
        if WWIconFrame then
            print("Frame exists: " .. tostring(WWIconFrame ~= nil))
            print("Frame shown: " .. tostring(WWIconFrame:IsShown()))
            print("Frame visible: " .. tostring(WWIconFrame:IsVisible()))
            print("Frame parent: " .. tostring(WWIconFrame:GetParent():GetName()))
            local point, relativeTo, relativePoint, x, y = WWIconFrame:GetPoint()
            print("Frame position: " .. tostring(point) .. " " .. tostring(x) .. ", " .. tostring(y))
            print("Button size: " .. tostring(WWIconSettings.size))
            local width, height = WWIconFrame:GetWidth(), WWIconFrame:GetHeight()
            print("Frame size: " .. width .. "x" .. height)
        else
            print("Frame does not exist!")
        end
    elseif lowerMsg == "help" then
        print("WWIcon Commands:")
        print("/wwicon - Toggle frame visibility")
        print("/wwicon test - Force create frame at center")
        print("/wwicon reset - Reset position to center")
        print("/wwicon debug - Show debug info")
        print("/wwicon lock - Lock frame position")
        print("/wwicon unlock - Unlock frame position")
        print("/wwicon hide - Hide frame")
        print("/wwicon show - Show frame")
        print("/wwicon [size] - Resize buttons (16-128)")
        print("/wwicon help - Show this help")
    else
        -- Check if it's a number for resizing
        local size = tonumber(lowerMsg)
        if size then
            ResizeWWIconButtons(size)
        else
            print("Invalid command. Use '/wwicon help' for available commands.")
        end
    end
end

-- Initialize function
local function InitializeWWIcon()
    if isInitialized then
        return
    end
    
    -- Ensure saved variables exist with defaults
    WWIconSettings.point = WWIconSettings.point or "CENTER"
    WWIconSettings.xOfs = WWIconSettings.xOfs or 0
    WWIconSettings.yOfs = WWIconSettings.yOfs or 0
    WWIconSettings.size = WWIconSettings.size or 64
    WWIconSettings.locked = WWIconSettings.locked or false
    
    -- Create the frame
    CreateWWIconFrame()
    
    -- NOW set the saved position after frame creation
    if WWIconFrame then
        WWIconFrame:ClearAllPoints()
        WWIconFrame:SetPoint(WWIconSettings.point, UIParent, WWIconSettings.point, WWIconSettings.xOfs, WWIconSettings.yOfs)
        
        -- Update GUI to set initial button states and check talents
        SNB.UpdateWWIconGUI()
        
        -- Force the frame to be visible by default
        WWIconFrame:Show()
        print("Frame shown by default!")
        
        -- Debug frame state
        print("Frame debug - Shown: " .. tostring(WWIconFrame:IsShown()))
        print("Frame debug - Visible: " .. tostring(WWIconFrame:IsVisible()))
        local width, height = WWIconFrame:GetWidth(), WWIconFrame:GetHeight()
        print("Frame debug - Size: " .. width .. "x" .. height)
    else
        print("ERROR: WWIconFrame failed to create!")
    end
    
    isInitialized = true
end

-- Register slash command
SLASH_WWICON1 = "/wwicon"
SlashCmdList["WWICON"] = WWIcon_SlashCommand

-- Event frame for initialization and talent updates
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    local event = arg1
    local addonName = arg2
    
    print("WWIcon received event: " .. tostring(event) .. " with arg2: " .. tostring(addonName))
    
    if event == "ADDON_LOADED" and addonName == "SpitNoobbutton" then  -- Replace with your actual addon name
        print("ADDON_LOADED event fired for SpitNoobbutton, initializing WWIcon...")
        InitializeWWIcon()
    elseif event == "VARIABLES_LOADED" then
        InitializeWWIcon()
    elseif event == "PLAYER_LOGIN" then
        InitializeWWIcon()
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitializeWWIcon()
    elseif event == "PLAYER_TALENT_UPDATE" then
        -- Update button visibility when talents change
        if WWIconFrame then
            SNB.UpdateSweepingStrikesButton()
            SNB.UpdateSlamPriorityVisibility()
            SNB.UpdateWWIconGUI()  -- Refresh frame size
        end
    end
end)

-- Fallback timer to ensure initialization happens
local fallbackTimer = CreateFrame("Frame")
local timeElapsed = 0
fallbackTimer:SetScript("OnUpdate", function()
    local elapsed = arg1  -- In Lua 5.0, elapsed time is in arg1
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 2 and not isInitialized then  -- Wait 2 seconds, then force init
        InitializeWWIcon()
        fallbackTimer:SetScript("OnUpdate", nil)  -- Stop the timer
    end
end)

-- Also provide manual initialization
function SNB.InitWWIcon()
    InitializeWWIcon()
end

print("WWIcon script loaded. Type /wwicon test to force create frame.")
