local addon, Engine = ...
local L = Engine.L

-- Lua functions
local _G = _G
local ipairs, tinsert, strfind, strlower, tonumber = ipairs, tinsert, strfind, strlower, tonumber

-- WoW API / Variables
local C_CVar_GetCVarInfo = C_CVar.GetCVarInfo
local C_Timer_After = C_Timer.After
local ConsoleGetAllCommands = ConsoleGetAllCommands
local CreateFrame = CreateFrame

local BackdropTemplateMixin = BackdropTemplateMixin
local CreateDataProvider = CreateDataProvider
local CreateScrollBoxListLinearView = CreateScrollBoxListLinearView
local Mixin = Mixin
local ScrollUtil_InitScrollBoxListWithScrollBar = ScrollUtil.InitScrollBoxListWithScrollBar

local Enum_ConsoleCategory_Debug = Enum.ConsoleCategory.Debug
local Enum_ConsoleCategory_Gm = Enum.ConsoleCategory.Gm
local Enum_ConsoleCommandType_Cvar = Enum.ConsoleCommandType.Cvar

-- GLOBALS: CVarExplorerDB

---@class CECore: Frame
local Core = CreateFrame('Frame')
Engine.Core = Core
_G[addon] = Engine

Core:RegisterEvent('PLAYER_ENTERING_WORLD')
Core:SetScript('OnEvent', function(self, event, ...)
    if (event == 'PLAYER_ENTERING_WORLD') then
        local isInitialLogin, isReloadingUi = ...
        self:UnregisterEvent('PLAYER_ENTERING_WORLD')
        self:SetScript('OnEvent', nil)

        if isInitialLogin or isReloadingUi then
            self:Initialize()
        end
    end
end)

local backdropInfo = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 32,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local specialCVar = {
    -- Third Party: CVars that registered by third-party addons
    ['LibOpenRaidTempCache'] = 'ThirdParty',
    ['LibOpenRaidTempCacheDebug'] = 'ThirdParty',

    -- Game Progress: CVars that used to track game progress
    ['lastRenownForCovenant1'] = 'GameProgress',
    ['lastRenownForCovenant2'] = 'GameProgress',
    ['lastRenownForCovenant3'] = 'GameProgress',
    ['lastRenownForCovenant4'] = 'GameProgress',
    ['lastRenownForDelvesSeason'] = 'GameProgress',
    ['lastRenownForMajorFaction2503'] = 'GameProgress',
    ['lastRenownForMajorFaction2507'] = 'GameProgress',
    ['lastRenownForMajorFaction2510'] = 'GameProgress',
    ['lastRenownForMajorFaction2511'] = 'GameProgress',
    ['lastRenownForMajorFaction2564'] = 'GameProgress',
    ['lastRenownForMajorFaction2570'] = 'GameProgress',
    ['lastRenownForMajorFaction2574'] = 'GameProgress',
    ['lastRenownForMajorFaction2590'] = 'GameProgress',
    ['lastRenownForMajorFaction2593'] = 'GameProgress',
    ['lastRenownForMajorFaction2594'] = 'GameProgress',
    ['lastRenownForMajorFaction2600'] = 'GameProgress',
    ['lastRenownForMajorFaction2653'] = 'GameProgress',
    ['lastRenownForMajorFaction2658'] = 'GameProgress',
    ['lastRenownForMajorFaction2685'] = 'GameProgress',
    ['lastRenownForMajorFaction2688'] = 'GameProgress',
    ['lastRenownForMajorFaction2736'] = 'GameProgress',
    ['perksActivitiesCurrentMonth'] = 'GameProgress',
    ['perksActivitiesLastPoints'] = 'GameProgress',
    ['perksActivitiesPendingCompletion'] = 'GameProgress',

    -- Game Tip: CVars that used to show game tips
    ['accountNeedsTurnStrafeDialog'] = 'GameTip',
    ['addFriendInfoShown'] = 'GameTip',
    ['characterNeedsTurnStrafeDialog'] = 'GameTip',
    ['closedExtraAbiltyTutorials'] = 'GameTip',
    ['closedInfoFrames'] = 'GameTip',
    ['closedInfoFramesAccountWide'] = 'GameTip',
    ['closedRemixArtifactTutorialFrames'] = 'GameTip',
    ['covenantMissionTutorial'] = 'GameTip',
    ['dangerousShipyardMissionWarningAlreadyShown'] = 'GameTip',
    ['flaggedTutorials'] = 'GameTip',
    ['gameTip'] = 'GameTip',
    ['interactKeyWarningTutorial'] = 'GameTip',
    ['lastGarrisonMissionTutorial'] = 'GameTip',
    ['lastVoidStorageTutorial'] = 'GameTip',
    ['orderHallMissionTutorial'] = 'GameTip',
    ['professionAccessorySlotsExampleShown'] = 'GameTip',
    ['professionToolSlotsExampleShown'] = 'GameTip',
    ['seenAlliedRaceUnlocks'] = 'GameTip',
    ['seenAsiaCharacterUpgradePopup'] = 'GameTip',
    ['seenCharacterSelectNavBarCampsHelpTip'] = 'GameTip',
    ['seenCharacterSelectWarbandHelpTip'] = 'GameTip',
    ['seenCharacterUpgradePopup'] = 'GameTip',
    ['seenConfigurationWarnings'] = 'GameTip',
    ['seenExpansionTrialPopup'] = 'GameTip',
    ['seenLevelSquishPopup'] = 'GameTip',
    ['seenRegionalChatDisabled'] = 'GameTip',
    ['seenTimerunningFirstLoginPopup'] = 'GameTip',
    ['shipyardMissionTutorialAreaBuff'] = 'GameTip',
    ['shipyardMissionTutorialBlockade'] = 'GameTip',
    ['shipyardMissionTutorialFirst'] = 'GameTip',
    ['showCreateCharacterRealmConfirmDialog'] = 'GameTip',
    ['showNPETutorials'] = 'GameTip',
    ['showPhotosensitivityWarning'] = 'GameTip',
    ['showTokenFrame'] = 'GameTip',
    ['showTokenFrameHonor'] = 'GameTip',
    ['showTutorials'] = 'GameTip',
    ['soulbindsActivatedTutorial'] = 'GameTip',
    ['soulbindsLandingPageTutorial'] = 'GameTip',
    ['soulbindsViewedTutorial'] = 'GameTip',
    ['talentPointsSpent'] = 'GameTip',

    -- Time Event: CVars that used to track notified time events
    ['highestUnlockedDelvesTier'] = 'TimeEvent',
    ['lastAddonVersion'] = 'TimeEvent',
    ['latestSplashScreen'] = 'TimeEvent',
    ['newDelvesSeason'] = 'TimeEvent',
    ['newMythicPlusSeason'] = 'TimeEvent',
    ['newPvpSeason'] = 'TimeEvent',
    ['splashScreenNormal'] = 'TimeEvent',
    ['splashScreenSeason'] = 'TimeEvent',

    -- Track Action: CVars that used to track user actions
    ['auctionHouseDurationDropdown'] = 'TrackAction',
    ['cameraSavedDistance'] = 'TrackAction',
    ['cameraSavedPitch'] = 'TrackAction',
    ['clubFinderPlayerSettings'] = 'TrackAction',
    ['EJDungeonDifficulty'] = 'TrackAction',
    ['EJLootClass'] = 'TrackAction',
    ['EJLootSpec'] = 'TrackAction',
    ['EJRaidDifficulty'] = 'TrackAction',
    ['EJSelectedTier'] = 'TrackAction',
    ['eventSchedulerLastUpdate'] = 'TrackAction',
    ['garrisonCompleteTalent'] = 'TrackAction',
    ['garrisonCompleteTalentType'] = 'TrackAction',
    ['lastCharacterIndex'] = 'TrackAction',
    ['lastLockedDelvesCompanionAbilities'] = 'TrackAction',
    ['lastSelectedClubId'] = 'TrackAction',
    ['lastSelectedDelvesTier'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec1'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec2'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec3'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec4'] = 'TrackAction',
    ['minimapShapeshiftTracking'] = 'TrackAction',
    ['minimapTrackedInfov4'] = 'TrackAction',
    ['notifiedOfNewMail'] = 'TrackAction',
    ['numCurrencyCategories'] = 'TrackAction',
    ['numReputationHeaders'] = 'TrackAction',
    ['petJournalTab'] = 'TrackAction',
    ['playerColorOverrides'] = 'TrackAction',
    ['professionsOrderDurationDropdown'] = 'TrackAction',
    ['professionsOrderRecipientDropdown'] = 'TrackAction',
    ['videoOptionsVersion'] = 'TrackAction',

    -- Track Action Bitwise: CVars that used to track user actions with bitwise operation
    ['autoQuestPopUps'] = 'TrackActionBitwise',
    ['collapsedCurrencyCategoryDefaults'] = 'TrackActionBitwise',
    ['collapsedReputationHeaderDefaults'] = 'TrackActionBitwise',
    ['currencyCategoriesCollapsed'] = 'TrackActionBitwise',
    ['hardTrackedQuests'] = 'TrackActionBitwise',
    ['hardTrackedWorldQuests'] = 'TrackActionBitwise',
    ['maxLevelSpecsUsed'] = 'TrackActionBitwise',
    ['reputationsCollapsed'] = 'TrackActionBitwise',
    ['toyBoxCollectedFilters'] = 'TrackActionBitwise',
    ['toyBoxExpansionFilters'] = 'TrackActionBitwise',
    ['toyBoxSourceFilters'] = 'TrackActionBitwise',
    ['trackedAchievements'] = 'TrackActionBitwise',
    ['trackedPerksActivities'] = 'TrackActionBitwise',
    ['trackedProfessionRecipes'] = 'TrackActionBitwise',
    ['trackedProfessionRecraftRecipes'] = 'TrackActionBitwise',
    ['trackedQuests'] = 'TrackActionBitwise',
    ['trackedWorldQuests'] = 'TrackActionBitwise',
    ['unlockedExpansionLandingPages'] = 'TrackActionBitwise',
    ['unlockedMajorFactions'] = 'TrackActionBitwise',
    ['wardrobeSetsFilters'] = 'TrackActionBitwise',
    ['wardrobeShowCollected'] = 'TrackActionBitwise',
    ['wardrobeShowUncollected'] = 'TrackActionBitwise',
    ['wardrobeSourceFilters'] = 'TrackActionBitwise',

    -- Internal: Used by game internally
    ['agentUID'] = 'Internal',
    ['CACHE-WGOB-GameObjectsHotfixCount'] = 'Internal',
    ['CACHE-WGOB-GameObjectsRecordCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveHotfixCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveRecordCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveXEffectHotfixCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveXEffectRecordCount'] = 'Internal',
    ['CACHE-WQST-QuestV2HotfixCount'] = 'Internal',
    ['CACHE-WQST-QuestV2RecordCount'] = 'Internal',
    ['engineSurvey'] = 'Internal',
    ['engineSurveyPatch'] = 'Internal',
    ['telemetryWowlabsPackage'] = 'Internal',
    ['telemetryWowPackage'] = 'Internal',

    -- User: Manual ignore
    ['spellActivationOverlayOpacity'] = 'Manual',
}

---@class CECVarWindowData
---@field name string
---@field scope string
---@field defaultValue string
---@field profile string
---@field value string

---@class CECVarWindowLine: Frame
---@field isCreated boolean
---@field fields FontString[]
---@field buttons Button[]
---@field data CECVarWindowData

---@class CECVarWindowButtonInfo
---@field text string
---@field onClick fun(button: CECVarWindowLine)

---@class CECVarWindowColumnInfo
---@field title string
---@field width number
---@field attribute string?
---@field buttons CECVarWindowButtonInfo[]?

---@type CECVarWindowColumnInfo[]
local columnInfo = {
    {
        title = L['Name'],
        width = 300,
        attribute = 'name',
    },
    {
        title = L['Scope'],
        width = 100,
        attribute = 'scope',
    },
    {
        title = L['Default Value'],
        width = 100,
        attribute = 'defaultValue',
    },
    {
        title = L['Profile'],
        width = 100,
        attribute = 'profile',
    },
    {
        title = L['Value'],
        width = 100,
        attribute = 'value',
    },
    {
        title = L['Actions'],
        width = 450,
        buttons = {
            {
                text = L['Load Profile'],
                onClick = function(button)
                    local data = button:GetParent().data
                    _G.C_CVar.SetCVar(data.name, data.profile)
                    Core:RefreshCVars()
                end,
            },
            {
                text = L['Load Default'],
                onClick = function(button)
                    local data = button:GetParent().data
                    _G.C_CVar.SetCVar(data.name, data.defaultValue)
                    Core:RefreshCVars()
                end,
            },
            {
                text = L['Save Value'],
                onClick = function(button)
                    local data = button:GetParent().data
                    Core.profile[data.name] = data.value
                    Core:RefreshCVars()
                end,
            },
            {
                text = L['Save Default'],
                onClick = function(button)
                    local data = button:GetParent().data
                    Core.profile[data.name] = data.defaultValue
                    Core:RefreshCVars()
                end,
            },
        },
    },
}

---@param frame CECVarWindowLine
---@param data CECVarWindowData
local function Initializer(frame, data)
    if not frame.isCreated then
        Mixin(frame, BackdropTemplateMixin)
        frame:SetSize(Core.scrollBoxWidth, 20)
        frame:SetBackdrop(backdropInfo)
        frame:SetBackdropColor(0, 0, 0, 0.5)

        local offset = 0

        frame.fields = {}
        for i, info in ipairs(columnInfo) do
            if info.attribute then
                local field = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
                field:SetPoint('LEFT', offset + 10, 0)
                field:SetSize(info.width - 20, 20)
                field:SetJustifyH('LEFT')

                offset = offset + info.width
                frame.fields[i] = field
            end
        end

        offset = offset + 10

        frame.buttons = {}
        for _, info in ipairs(columnInfo) do
            if info.buttons then
                for _, buttonInfo in ipairs(info.buttons) do
                    local button = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
                    button:SetText(buttonInfo.text)
                    button:SetPoint('LEFT', offset, 0)
                    button:SetSize(95, 20)
                    button:SetScript('OnClick', buttonInfo.onClick)

                    offset = offset + 100

                    tinsert(frame.buttons, button)
                end
            end
        end

        frame.isCreated = true
    end

    frame.data = data
    for i, info in ipairs(columnInfo) do
        if info.attribute then
            frame.fields[i]:SetText(data[info.attribute])
        end
    end
end

---@param a CECVarWindowData
---@param b CECVarWindowData
local function Compare(a, b)
    return a.name < b.name
end

function Core:CreateWindow()
    local scrollBoxWidth = 0
    for _, info in ipairs(columnInfo) do
        scrollBoxWidth = scrollBoxWidth + info.width
    end
    self.scrollBoxWidth = scrollBoxWidth

    ---@class CVarExplorerWindow: Frame
    local window = CreateFrame('Frame', 'CVarExplorerWindow', _G.UIParent, 'PortraitFrameTemplate')
    window:SetFrameStrata('HIGH')
    window:ClearAllPoints()
    window:SetPoint('CENTER')
    window:SetSize(scrollBoxWidth + 30, 600)
    window:Hide()
    self.window = window

    window.TitleContainer.TitleText:SetText('CVar Explorer')
    window.PortraitContainer.portrait:SetTexture(237162)

    local refreshButton = CreateFrame('Button', nil, window, 'UIPanelButtonTemplate')
    refreshButton:ClearAllPoints()
    refreshButton:SetPoint('TOPRIGHT', -30, -30)
    refreshButton:SetSize(100, 20)
    refreshButton:SetText(L['Refresh'])
    refreshButton:SetScript('OnClick', function()
        Core:RefreshCVars()
    end)

    local columnDisplay = CreateFrame('Frame', nil, window, 'ColumnDisplayTemplate')
    columnDisplay:ClearAllPoints()
    columnDisplay:SetPoint('TOPLEFT', 15, -20)
    columnDisplay:SetPoint('TOPRIGHT', -15, -20)
    columnDisplay:SetUsingParentLevel(true)
    columnDisplay:LayoutColumns(columnInfo)

    local scrollBox = CreateFrame('Frame', nil, window, 'WowScrollBoxList')
    scrollBox:SetPoint('TOPLEFT', columnDisplay, 'BOTTOMLEFT')
    scrollBox:SetPoint('BOTTOMRIGHT', window, 'BOTTOMRIGHT', -15, 10)

    local scrollBar = CreateFrame('EventFrame', nil, window, 'MinimalScrollBar')
    scrollBar:SetPoint('TOPLEFT', scrollBox, 'TOPRIGHT')
    scrollBar:SetPoint('BOTTOMLEFT', scrollBox, 'BOTTOMRIGHT')

    local scrollView = CreateScrollBoxListLinearView()
    scrollView:SetElementExtent(20)
    scrollView:SetElementInitializer('Frame', Initializer)
    scrollView:SetDataProvider(self.dataProvider)

    ScrollUtil_InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
end

function Core:RefreshCVars()
    local showLockedFromUser = false
    local showReadOnly = false
    local hideProfileEqual = true
    local hideSpecialCVars = true

    local enableNumberEquals = true

    self.dataProvider:Flush()

    local commands = ConsoleGetAllCommands()
    for _, info in ipairs(commands) do
        if (
            info.commandType == Enum_ConsoleCommandType_Cvar
            and info.category ~= Enum_ConsoleCategory_Debug
            and info.category ~= Enum_ConsoleCategory_Gm
            and not strfind(strlower(info.command), 'debug')
        ) then
            local name = info.command
            local value, defaultValue, isStoredServerAccount, isStoredServerCharacter, isLockedFromUser, _, isReadOnly = C_CVar_GetCVarInfo(name)

            if not self.profile[name] and defaultValue then
                self.profile[name] = defaultValue
            end
            local profileValue = self.profile[name]
            local profileEqual = enableNumberEquals and (tonumber(value) and tonumber(value) == tonumber(profileValue)) or value == profileValue

            if (
                (showLockedFromUser or not isLockedFromUser)
                and (showReadOnly or not isReadOnly)
                and (not hideProfileEqual or not profileEqual)
                and (not hideSpecialCVars or not specialCVar[name])
            ) then
                local data = {
                    name = name,
                    scope = isStoredServerAccount and 'Account' or isStoredServerCharacter and 'Character' or 'None',
                    defaultValue = defaultValue,
                    profile = profileValue,
                    value = value,
                }
                self.dataProvider:Insert(data)
            end
        end
    end
end

function Core:Initialize()
    CVarExplorerDB = CVarExplorerDB or {}
    CVarExplorerDB.Profiles = CVarExplorerDB.Profiles or {}
    CVarExplorerDB.Profiles.Default = CVarExplorerDB.Profiles.Default or {}
    self.profile = CVarExplorerDB.Profiles.Default

    self.dataProvider = CreateDataProvider()
    self.dataProvider:SetSortComparator(Compare, true)
    self:CreateWindow()

    ---@diagnostic disable-next-line: inject-field
    _G.SLASH_CVAREXPLORER1, _G.SLASH_CVAREXPLORER2 = '/ce', '/cvarexplorer'
    _G.SlashCmdList.CVAREXPLORER = function()
        self:RefreshCVars()
        self.window:SetShown(not self.window:IsShown())
    end

    C_Timer_After(10, function()
        self:RefreshCVars()
        if (not self.dataProvider:IsEmpty()) then
            self.window:Show()
        end
    end)
end
