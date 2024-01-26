UHQOL = {}
local UHQOLFrame = CreateFrame("Frame")
UHQOLFrame:RegisterEvent("ADDON_LOADED")
local QOL = C_AddOns.GetAddOnMetadata("QualityOfLife", "Title")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

function UHQOL:BuildDB()
    if not UHQOLDB then UHQOLDB = {
        ToggleSkipCinematics = true,
        ToggleAutoLootPlus = true,
        ToggleAutoDelete = true,
        ToggleDrawBackrops = true,
        ToggleCustomizeCharacterPanel = true,
    } end
    for k, v in pairs(UHQOLDB) do
        if UHQOL[k] == nil then
            UHQOL[k] = v
        end
    end
end

function UHQOL:SkipCinematics()
    if UHQOLDB.ToggleSkipCinematics then
        local SkipCinematicsFrame = CreateFrame("Frame")
        SkipCinematicsFrame:RegisterEvent("PLAY_MOVIE")
        SkipCinematicsFrame:RegisterEvent("CINEMATIC_START")
        print(QOL .. ": SkipCinematics |cFF40FF40Loaded|r")
        MovieFrame_PlayMovie = function(...) GameMovieFinished() end
        CinematicFrame:HookScript("OnShow", function(self, ...)	CinematicFrame_CancelCinematic() end)
    end
end

function UHQOL:AutoLootPlus()
    if UHQOLDB.ToggleAutoLootPlus then
        local AutoLootPlus = CreateFrame("Frame")
        AutoLootPlus:RegisterEvent("LOOT_READY")
        print(QOL .. ": AutoLootPlus |cFF40FF40Loaded|r")
        AutoLootPlus:SetScript("OnEvent", function() if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then for i = GetNumLootItems(), 1, -1 do LootSlot(i) end end end)
    end
end

function UHQOL:AutoDelete()
    if UHQOLDB.ToggleAutoDelete then
        print(QOL .. ": AutoDelete |cFF40FF40Loaded|r")
        hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(s) s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING) end)
    end
end

function UHQOL:CustomizeCharacterPanel()
    function UHQOL:SetFont(obj, font, size, style, sR, sG, sB, sA, sX, sY, r, g, b, a)
        if not obj then return end
        if style == 'NONE' or not style then style = '' end
        local shadow = strsub(style, 0, 6) == 'SHADOW'
        if shadow then style = strsub(style, 7) end -- shadow isnt a real style
        obj:SetFont(font, size, style)
        obj:SetShadowColor(sR or 0, sG or 0, sB or 0, sA or (shadow and (style == '' and 1 or 0.6)) or 0)
        obj:SetShadowOffset(sX or (shadow and 1) or 0, sY or (shadow and -1) or 0)
        if r and g and b then
            obj:SetTextColor(r, g, b)
        end
        if a then
            obj:SetAlpha(a)
        end
    end
    if UHQOLDB.ToggleCustomizeCharacterPanel then
        UHQOL:SetFont(CharacterLevelText, "Fonts\\FRIZQT__.ttf", 12, "OUTLINE", 0, 0, 0, 0, 0, 0, nil, nil, nil, nil)
        UHQOL:SetFont(CharacterFrameTitleText, "Fonts\\FRIZQT__.ttf", 12, "OUTLINE", 0, 0, 0, 0, 0, 0, nil, nil, nil, nil)
        UHQOL:SetFont(CharacterStatsPane.ItemLevelCategory.Title, "Fonts\\FRIZQT__.ttf", 12, "OUTLINE", 0, 0, 0, 0, 0, 0, RAID_CLASS_COLORS[select(2, UnitClass("player"))].r, RAID_CLASS_COLORS[select(2, UnitClass("player"))].g, RAID_CLASS_COLORS[select(2, UnitClass("player"))].b, 1.0)
        UHQOL:SetFont(CharacterStatsPane.AttributesCategory.Title, "Fonts\\FRIZQT__.ttf", 12, "OUTLINE", 0, 0, 0, 0, 0, 0, RAID_CLASS_COLORS[select(2, UnitClass("player"))].r, RAID_CLASS_COLORS[select(2, UnitClass("player"))].g, RAID_CLASS_COLORS[select(2, UnitClass("player"))].b, 1.0)
        UHQOL:SetFont(CharacterStatsPane.EnhancementsCategory.Title, "Fonts\\FRIZQT__.ttf", 12, "OUTLINE", 0, 0, 0, 0, 0, 0, RAID_CLASS_COLORS[select(2, UnitClass("player"))].r, RAID_CLASS_COLORS[select(2, UnitClass("player"))].g, RAID_CLASS_COLORS[select(2, UnitClass("player"))].b, 1.0)
    end
end

function UHQOL:DrawBackrops()
    if UHQOLDB.ToggleDrawBackrops then
        if not DetailsDamageMeterBackdrop then DetailsDamageMeterBackdrop = CreateFrame("Frame", "DetailsDamageMeterBackdrop", UIParent, "BackdropTemplate") end
        DetailsDamageMeterBackdrop:SetFrameStrata("LOW")
        DetailsDamageMeterBackdrop:SetWidth(227)
        DetailsDamageMeterBackdrop:SetHeight(201)
        DetailsDamageMeterBackdrop:ClearAllPoints()
        DetailsDamageMeterBackdrop:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 10)
        DetailsDamageMeterBackdrop:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", tile = false, tileSize = 0, edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0}})
        DetailsDamageMeterBackdrop:SetBackdropColor(20/255, 20/255, 20/255, 255/255)
        DetailsDamageMeterBackdrop:SetBackdropBorderColor(0, 0, 0, 1)
        DetailsDamageMeterBackdrop:Show()
        if not DetailsHealingMeterBackdrop then DetailsHealingMeterBackdrop = CreateFrame("Frame", "DetailsHealingMeterBackdrop", UIParent, "BackdropTemplate") end
        DetailsHealingMeterBackdrop:SetFrameStrata("LOW")
        DetailsHealingMeterBackdrop:SetWidth(226)
        DetailsHealingMeterBackdrop:SetHeight(201)
        DetailsHealingMeterBackdrop:ClearAllPoints()
        DetailsHealingMeterBackdrop:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -238, 10)
        DetailsHealingMeterBackdrop:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", tile = false, tileSize = 0, edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0}})
        DetailsHealingMeterBackdrop:SetBackdropColor(20/255, 20/255, 20/255, 255/255)
        DetailsHealingMeterBackdrop:SetBackdropBorderColor(0, 0, 0, 1)
        DetailsHealingMeterBackdrop:Show()
    end
end

function UHQOL:BuildOptions()
    local UHQOLOptions = {
        name = QOL,
        handler = UHQOL,
        type = 'group',
        args = {
            ToggleSkipCinematics = {
                name = "Skip Cinematics",
                desc = "Automatically Skips All Cinematics / Movies.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleSkipCinematics = val end,
                get = function(info) return UHQOLDB.ToggleSkipCinematics end
            },
            ToggleAutoLootPlus = {
                name = "Auto Loot Plus",
                desc = "Faster Auto Looting.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoLootPlus = val end,
                get = function(info) return UHQOLDB.ToggleAutoLootPlus end,
            },
            ToggleAutoDelete = {
                name = "Auto Delete",
                desc = "Prefils Delete Box.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoDelete = val end,
                get = function(info) return UHQOLDB.ToggleAutoDelete end
            },
            ToggleDrawBackrops = {
                name = "Draw Backrops",
                desc = "Draws Backdrops For Details Damage Meter & Details Healing Meter.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleDrawBackrops = val end,
                get = function(info) return UHQOLDB.ToggleDrawBackrops end
            },
            ToggleCustomizeCharacterPanel = {
                name = "Customize Character Panel",
                desc = "Customize Character Panel.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleCustomizeCharacterPanel = val end,
                get = function(info) return UHQOLDB.ToggleCustomizeCharacterPanel end
            },
        }
    }
    AC:RegisterOptionsTable("QualityOfLife", UHQOLOptions)
    ACD:AddToBlizOptions("QualityOfLife", QOL)

    SLASH_QUALITYOFLIFE1 = "/qol"
    SLASH_QUALITYOFLIFE2 = "/qualityoflife"
    SlashCmdList["QUALITYOFLIFE"] = function(msg)
        InterfaceOptionsFrame_OpenToCategory(QOL)
        InterfaceOptionsFrame_OpenToCategory(QOL)
    end
end


UHQOLFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "QualityOfLife" then
        UHQOL:BuildDB()
        UHQOL:BuildOptions()
        UHQOL:SkipCinematics()
        UHQOL:AutoLootPlus()
        UHQOL:AutoDelete()
        UHQOL:DrawBackrops()
        UHQOL:CustomizeCharacterPanel()
    end
end)
