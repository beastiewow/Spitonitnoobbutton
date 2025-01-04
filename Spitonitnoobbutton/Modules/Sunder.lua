-- Variable to track when Sunder Armor was last applied
SNB.lastSunderTime = 0

-- Combined function for the Sunder Armor macro with Expose Armor check
function SNB.MacroSunderArmor()
    local currentTime = GetTime()
    local b, c, i
    local hasExposeArmor = false
    local sunderStacks = 0

    for i = 1, 16 do
        b, c = UnitDebuff("target", i)
        if b and strfind(b, "Ability_Warrior_Sunder") then
            sunderStacks = c
            if sunderStacks >= 5 then
                if currentTime >= SNB.lastSunderTime + 3 then
                    SNB.debug_print("Casting Sunder Armor")
                    CastSpellByName("Sunder Armor")
                    SNB.lastSunderTime = currentTime
                end
                return
            end
        elseif b and strfind(b, "Ability_Warrior_Riposte") then
            hasExposeArmor = true
            break
        end
    end

    if not hasExposeArmor and (not sunderStacks or sunderStacks < 5) then
        SNB.debug_print("Casting Sunder Armor")
        CastSpellByName("Sunder Armor")
        SNB.lastSunderTime = currentTime
    end
end

SLASH_SUNDERARMOR1 = "/sunder"
SlashCmdList["SUNDERARMOR"] = SNB.MacroSunderArmor