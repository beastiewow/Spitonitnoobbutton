-- Pummel tracking logic
SNB.player_guid = nil
SNB.tracked_guids = {}
SNB.PUMMEL_SPELL_ID = 12555

-- HookScript function for tracking spell cast
function SNB.HookScript(f, script, func)
    local prev = f:GetScript(script)
    f:SetScript(script, function(a1, a2, a3, a4, a5, a6, a7, a8, a9)
        if prev then prev(a1, a2, a3, a4, a5, a6, a7, a8, a9) end
        func(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    end)
end

-- Tracking spell cast
function SNB.PummelEvents()
    if event == "UNIT_CASTEVENT" then
        local _, source = UnitExists(arg1)

        if not source then return end

        for guid, data in pairs(SNB.tracked_guids) do
            if source == guid then
                if arg3 == "START" then
                    SNB.tracked_guids[guid].casting = true
                elseif arg3 == "FAIL" or arg3 == "CAST" then
                    SNB.tracked_guids[guid].casting = false
                end
                break
            end
        end
    end
end

function SNB.PummelUpdate()
    for _, plate in pairs({ WorldFrame:GetChildren() }) do
        local guid = plate:GetName(1)
        if not SNB.tracked_guids[guid] then
            SNB.tracked_guids[guid] = {
                casting = false,
            }
        end
    end
end

function SNB.PummelInit()
    if event == "PLAYER_ENTERING_WORLD" then
        _, SNB.player_guid = UnitExists("player")
        this:SetScript("OnEvent", SNB.PummelEvents)
        this:SetScript("OnUpdate", SNB.PummelUpdate)
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end

local pummelFrame = CreateFrame("Frame")
pummelFrame:SetScript("OnEvent", SNB.PummelInit)
pummelFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pummelFrame:RegisterEvent("UNIT_CASTEVENT")

SLASH_PUMMEL1 = "/pummel"
SlashCmdList["PUMMEL"] = function()
    local target = "target"
    if UnitExists(target) and UnitCanAttack("player", target) then
        local pummelStart, pummelDuration, pummelEnabled = SNB.GetSpellCooldownById(SNB.PUMMEL_SPELL_ID)
        local pummelCooldown = (pummelStart + pummelDuration) - GetTime()

        if pummelCooldown <= 0 then
            for guid, unit in pairs(SNB.tracked_guids) do
                if UnitIsUnit(target, guid) and unit.casting then
                    CastSpellByName("Pummel", target)
                    return
                end
            end
        end
    end
end
