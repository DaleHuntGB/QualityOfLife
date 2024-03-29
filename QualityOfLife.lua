UHQOL = {}
local UHQOLFrame = CreateFrame("Frame")
UHQOLFrame:RegisterEvent("ADDON_LOADED")
local QOL = C_AddOns.GetAddOnMetadata("QualityOfLife", "Title")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ElvUI = C_AddOns.IsAddOnLoaded("ElvUI")

function UHQOL:BuildDB()
    if not UHQOLDB then UHQOLDB = {
        ToggleSkipCinematics = true,
        ToggleAutoLootPlus = true,
        ToggleAutoDelete = true,
        ToggleDrawBackrops = true,
        ToggleCustomizeCharacterPanel = true,
        ToggleAutoAcceptInvites = false,
        ToggleAutoAcceptFriends = false,
        ToggleAutoAcceptGuildInvites = false,
        ToggleAutoRepairSellItems = false,
        ToggleStopAutoPlacingSpells = true,
        ToggleHideTalkingHeadFrame = true,
        ToggleRemoveBuffs = true,
        BuffsToRemove = {},
    } end
    for setting, default in pairs(UHQOLDB) do
        if UHQOL[setting] == nil then
            UHQOL[setting] = default
        end
    end
end

function UHQOL:AutoAcceptInvites()
    if UHQOLDB.ToggleAutoAcceptInvites then
        if ElvUI then UHQOLDB.ToggleAutoAcceptInvites = false UHQOLDB.ToggleAutoAcceptFriends = false UHQOLDB.ToggleAutoAcceptGuildInvites = false end
        local function AcceptInvite()
            AcceptGroup()
            for i = 1, STATICPOPUP_NUMDIALOGS do
                local dialog = _G["StaticPopup" .. i]
                if dialog.which == "PARTY_INVITE" then
                    dialog.inviteAccepted = 1
                    break
                end
            end
            StaticPopup_Hide("PARTY_INVITE")
        end
        local AutoAcceptInvitesFrame = CreateFrame("Frame")
        AutoAcceptInvitesFrame:RegisterEvent("PARTY_INVITE_REQUEST")
        AutoAcceptInvitesFrame:SetScript("OnEvent", function(event, playerName)
            local _, numFriends = BNGetNumFriends()
            local _, _, numGuildMembers = GetNumGuildMembers()
            local autoAcceptBNet = UHQOLDB.ToggleAutoAcceptFriends
            local autoAcceptGuild = UHQOLDB.ToggleAutoAcceptGuildInvites
            AutoAcceptInvitesFrame:SetScript("OnEvent", function(event, playerName) 
                if autoAcceptBNet then
                    for i = 1, numFriends do
                        local isBNetFriend = C_BattleNet.GetFriendAccountInfo(i).isBattleTagFriend
                        local characterName = C_BattleNet.GetFriendAccountInfo(i).gameAccountInfo.characterName
                        if isBNetFriend and playerName == characterName then
                            AcceptInvite()
                        end
                    end
                end
                if autoAcceptGuild then
                    print(autoAcceptGuild)
                    for i = 1, numGuildMembers do
                        local characterName = GetGuildRosterInfo(i)
                        if playerName == characterName:gsub("%-.*", "") then
                            AcceptInvite()
                        end
                    end
                end
            end)
        end)
    end
end

function UHQOL:HideTalkingHeadFrame()
    if UHQOLDB.ToggleHideTalkingHeadFrame then
        local THF = CreateFrame("Frame")
        THF:RegisterEvent("TALKINGHEAD_REQUESTED")
        THF:SetScript("OnEvent", function(self, event, ...)
            TalkingHeadFrame:Hide()
        end)
    end
end

function UHQOL:AutoRepairSellItems()
    if UHQOLDB.ToggleAutoRepairSellItems then
        if ElvUI then UHQOLDB.ToggleAutoRepairSellItems = false end 
        local AutoRepairSellItemsFrame = CreateFrame("Frame")
        AutoRepairSellItemsFrame:RegisterEvent("MERCHANT_SHOW")
        AutoRepairSellItemsFrame:SetScript("OnEvent", function(event, ...)
            if CanMerchantRepair() then
                RepairAllItems()
            end
            for container=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
                local slots = C_Container.GetContainerNumSlots(container)
                for slot=1, slots do
                    local info = C_Container.GetContainerItemInfo(container, slot)
                    if info and info.quality == 0 and not info.hasNoValue then
                        C_Container.UseContainerItem(container, slot)
                    end
                end
            end 
        end)
    end
end

function UHQOL:SkipCinematics()
    if UHQOLDB.ToggleSkipCinematics then
        local SkipCinematicsFrame = CreateFrame("Frame")
        SkipCinematicsFrame:RegisterEvent("PLAY_MOVIE")
        SkipCinematicsFrame:RegisterEvent("CINEMATIC_START")
        MovieFrame_PlayMovie = function(...) GameMovieFinished() end
        CinematicFrame:HookScript("OnShow", function(self, ...)	CinematicFrame_CancelCinematic() end)
    end
end

function UHQOL:AutoLootPlus()
    if UHQOLDB.ToggleAutoLootPlus then
        local AutoLootPlus = CreateFrame("Frame")
        AutoLootPlus:RegisterEvent("LOOT_READY")
        AutoLootPlus:SetScript("OnEvent", function() if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then for i = GetNumLootItems(), 1, -1 do LootSlot(i) end end end)
    end
end

function UHQOL:AutoDelete()
    if UHQOLDB.ToggleAutoDelete then
        local AutoDelete = CreateFrame("Frame")
        AutoDelete:RegisterEvent("DELETE_ITEM_CONFIRM")
        AutoDelete:SetScript("OnEvent", function(self, event, ...)
            if event == "DELETE_ITEM_CONFIRM" then
                StaticPopup1EditBox:SetText(DELETE_ITEM_CONFIRM_STRING)
            end
        end)
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

function UHQOL:StopAutoPlacingSpells()
    if UHQOLDB.ToggleStopAutoPlacingSpells then
        if GetCVar("AutoPushSpellToActionBar") == 1 then
            SetCVar("AutoPushSpellToActionBar", 0)
        else
            return
        end
    end
end

function UHQOL:RemoveBuffs()
    local BuffsToRemove = {
        ["A Cultivator's Colors"]               = 394005,
        ["Rockin' Mining Gear"]                 = 394006,
        ["Dressed To Kill"]                     = 394011,
        ["Artist's Duds"]                       = 394016,
        ["Spark of Madness"]                    = 394003,
        ["Suited For Smithing"]                 = 388658,
        ["A Looker's Charm"]                    = 394008,
        ["Ready To Build"]                      = 394007,
        ["An Eye For Shine"]                    = 394015,
        ["Sculpting Leather Finery"]            = 394001,
        ["Wrapped Up In Weaving"]               = 391312,
        ["What's Cookin', Good Lookin'?"]       = 391775,
    }
    if UHQOLDB.ToggleRemoveBuffs then
        if not UHQOLDB.BuffsToRemove then UHQOLDB.BuffsToRemove = BuffsToRemove end
        local RemoveBuffsFrame = CreateFrame("Frame")
        RemoveBuffsFrame:RegisterEvent("UNIT_AURA")
        RemoveBuffsFrame:SetScript("OnEvent", function(self, event, ...)
            if event == "UNIT_AURA" then
                local unit = ...
                if unit == "player" then
                    for i = 1, 40 do  -- Check each buff slot
                        local _, _, _, _, _, _, _, _, _, spellID = UnitAura("player", i)
                        for _, buffSpellID in pairs(UHQOLDB.BuffsToRemove) do
                            if spellID == buffSpellID then
                                CancelUnitBuff("player", i)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
end

local function InitializeUHQOL()
    UHQOL:BuildDB()
    UHQOL:BuildOptions()
    UHQOL:SkipCinematics()
    UHQOL:AutoLootPlus()
    UHQOL:AutoDelete()
    UHQOL:DrawBackrops()
    UHQOL:CustomizeCharacterPanel()
    UHQOL:AutoAcceptInvites()
    UHQOL:AutoRepairSellItems()
    UHQOL:StopAutoPlacingSpells()
    UHQOL:HideTalkingHeadFrame()
    UHQOL:RemoveBuffs()
end

function UHQOL:BuildOptions()
    local UHQOLOptions = {
        name = QOL,
        handler = UHQOL,
        type = 'group',
        args = {
            ToggleAutoAcceptInvites = {
                name = "Auto Accept Invites",
                desc = "Automatically Accepts Invites From Friends & Guild Members.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoAcceptInvites = val end,
                get = function(info) return UHQOLDB.ToggleAutoAcceptInvites end,
                width = "full",
                order = 1,
                disabled = function() return ElvUI end
            },
            ToggleAutoAcceptFriends = {
                name = "Auto Accept Friends",
                desc = "Automatically Accepts Invites From Friends.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoAcceptFriends = val end,
                get = function(info) return UHQOLDB.ToggleAutoAcceptFriends end,
                width = "full",
                order = 2,
                disabled = function() return not UHQOLDB.ToggleAutoAcceptInvites end,
            },
            ToggleAutoAcceptGuildInvites = {
                name = "Auto Accept Guild Invites",
                desc = "Automatically Accepts Invites From Guild Members.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoAcceptGuildInvites = val end,
                get = function(info) return UHQOLDB.ToggleAutoAcceptGuildInvites end,
                width = "full",
                order = 3,
                disabled = function() return not UHQOLDB.ToggleAutoAcceptInvites end,
            },
            ToggleAutoDelete = {
                name = "Auto Delete",
                desc = "Prefils Delete Box.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoDelete = val end,
                get = function(info) return UHQOLDB.ToggleAutoDelete end,
                width = "full",
                order = 4,
            },
            ToggleAutoLootPlus = {
                name = "Auto Loot Plus",
                desc = "Faster Auto Looting.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoLootPlus = val end,
                get = function(info) return UHQOLDB.ToggleAutoLootPlus end,
                width = "full",
                order = 5,
            },
            ToggleAutoRepairSellItems = {
                name = "Auto Repair & Sell Items",
                desc = "Automatically Repairs & Sells Items.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleAutoRepairSellItems = val end,
                get = function(info) return UHQOLDB.ToggleAutoRepairSellItems end,
                width = "full",
                order = 6,
                disabled = function() return ElvUI end
            },
            ToggleCustomizeCharacterPanel = {
                name = "Customize Character Panel",
                desc = "Colours Elements, Improves Font Appearance.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleCustomizeCharacterPanel = val end,
                get = function(info) return UHQOLDB.ToggleCustomizeCharacterPanel end,
                width = "full",
                order = 7,
            },
            ToggleDrawBackrops = {
                name = "Draw Backrops",
                desc = "Draws Backdrops For Details Damage Meter & Details Healing Meter.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleDrawBackrops = val end,
                get = function(info) return UHQOLDB.ToggleDrawBackrops end,
                width = "full",
                order = 8,
            },
            ToggleHideTalkingHeadFrame = {
                name = "Hide Talking Head Frame",
                desc = "Hides The Talking Head Frame.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleHideTalkingHeadFrame = val end,
                get = function(info) return UHQOLDB.ToggleHideTalkingHeadFrame end,
                width = "full",
                order = 9,
            },
            ToggleRemoveBuffs = {
                name = "Toggle Remove Buffs",
                desc = "Buffs Being Removed\n- Profession Buffs.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleRemoveBuffs = val end,
                get = function(info) return UHQOLDB.ToggleRemoveBuffs end,
                width = "full",
                order = 10,
            },
            AddBuffToRemove = {
                name = "Add Buff To Remove",
                desc = "Add SpellID To Remove Buff Automatically.",
                type = "input",
                width = 1.9,
                set = function(info, val) 
                    local spellID = tonumber(val)
                    if spellID then
                        local spellName = GetSpellInfo(spellID) or ""
                        UHQOLDB.BuffsToRemove[spellName] = spellID 
                        print("|cFF40FF40Added|r: " .. spellName .. ": |cFF00ADB5" .. spellID .. "|r")
                    end
                end,
                get = function(info) return nil end,
                order = 11,
            },
            RemoveBuff = {
                name = "Remove Buff",
                desc = "Remove SpellID To Stop Buff Being Removed.",
                type = "input",
                width = 1.89,
                set = function(info, val) 
                    local spellID = tonumber(val)
                    if spellID then
                        local spellName = GetSpellInfo(spellID) or ""
                        UHQOLDB.BuffsToRemove[spellName] = nil
                        print("|cFFFF4040Removed|r: " .. spellName .. ": |cFF00ADB5" .. spellID .. "|r")
                    end
                end,
                get = function(info) return nil end,
                order = 12,
            },
            ShowRemovedBuffs = {
                name = "|cFF00ADB5Buffs Being Removed|r",
                desc = "Prints Buffs Currently Being Removed.",
                type = "execute",
                width = "full",
                func = function() for buff, spellID in pairs(UHQOLDB.BuffsToRemove) do print(buff .. ": " .. "|cFF00ADB5" .. spellID .. "|r") end end,
                order = 13,
            },  
            ToggleSkipCinematics = {
                name = "Skip Cinematics",
                desc = "Automatically Skips All Cinematics / Movies Instantly.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleSkipCinematics = val end,
                get = function(info) return UHQOLDB.ToggleSkipCinematics end,
                width = "full",
                order = 14,
            },
            ToggleStopAutoPlacingSpells = {
                name = "Stop Automatically Placing Spells",
                desc = "Stops Automatically Placing Spells.",
                type = "toggle",
                set = function(info, val) UHQOLDB.ToggleStopAutoPlacingSpells = val end,
                get = function(info) return UHQOLDB.ToggleStopAutoPlacingSpells end,
                width = "full",
                order = 15,
            },
            Reload = {
                name = "|cFF00ADB5Save Settings|r",
                type = "execute",
                func = function() ReloadUI() end,
                width = "full",
                order = 100,
            },
        },
    }

    AC:RegisterOptionsTable("QualityOfLife", UHQOLOptions)
    ACD:AddToBlizOptions("QualityOfLife", QOL)
    SLASH_QUALITYOFLIFE1 = "/qol"
    SLASH_QUALITYOFLIFE2 = "/qualityoflife"
    SlashCmdList["QUALITYOFLIFE"] = function(msg)
        InterfaceOptionsFrame_OpenToCategory(QOL)
        InterfaceOptionsFrame_OpenToCategory(QOL)
    end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList.RELOADUI = ReloadUI
end

UHQOLFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "QualityOfLife" then
        InitializeUHQOL()
    end
end)
