local addon, Engine = ...
local L = Engine.L

---@class CECore: Frame
local Core = CreateFrame('Frame')
Engine.Core = Core
_G[addon] = Engine

Core:RegisterEvent('PLAYER_LOGIN')
Core:SetScript('OnEvent', function(self, event)
    if (event == 'PLAYER_LOGIN') then
        self:UnregisterEvent('PLAYER_LOGIN')
        self:SetScript('OnEvent', nil)
        self:Initialize()
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
    ['lastRenownForMajorFaction2503'] = 'GameProgress',
    ['lastRenownForMajorFaction2507'] = 'GameProgress',
    ['lastRenownForMajorFaction2510'] = 'GameProgress',
    ['lastRenownForMajorFaction2511'] = 'GameProgress',
    ['lastRenownForMajorFaction2564'] = 'GameProgress',
    ['lastRenownForMajorFaction2574'] = 'GameProgress',
    ['lastRenownForMajorFaction2593'] = 'GameProgress',
    ['perksActivitiesCurrentMonth'] = 'GameProgress',
    ['perksActivitiesLastPoints'] = 'GameProgress',
    ['perksActivitiesPendingCompletion'] = 'GameProgress',

    -- Game Tip: CVars that used to show game tips
    ['closedExtraAbiltyTutorials'] = 'GameTip',
    ['closedInfoFrames'] = 'GameTip',
    ['closedInfoFramesAccountWide'] = 'GameTip',
    ['flaggedTutorials'] = 'GameTip',
    ['gameTip'] = 'GameTip',
    ['lastGarrisonMissionTutorial'] = 'GameTip',
    ['lastVoidStorageTutorial'] = 'GameTip',
    ['orderHallMissionTutorial'] = 'GameTip',
    ['seenTimerunningFirstLoginPopup'] = 'GameTip',
    ['shipyardMissionTutorialAreaBuff'] = 'GameTip',
    ['shipyardMissionTutorialBlockade'] = 'GameTip',
    ['shipyardMissionTutorialFirst'] = 'GameTip',
    ['showNPETutorials'] = 'GameTip',
    ['showTokenFrame'] = 'GameTip',
    ['showTutorials'] = 'GameTip',

    -- Time Event: CVars that used to track notified time events
    ['lastAddonVersion'] = 'TimeEvent',
    ['latestSplashScreen'] = 'TimeEvent',
    ['newMythicPlusSeason'] = 'TimeEvent',
    ['newPvpSeason'] = 'TimeEvent',

    -- User Action Frequently: CVars that used to track user actions
    ['advJournalLastOpened'] = 'TrackAction',
    ['auctionHouseDurationDropdown'] = 'TrackAction',
    ['cameraSavedDistance'] = 'TrackAction',
    ['cameraSavedPitch'] = 'TrackAction',
    ['clubFinderPlayerSettings'] = 'TrackAction',
    ['EJDungeonDifficulty'] = 'TrackAction',
    ['EJLootClass'] = 'TrackAction',
    ['EJLootSpec'] = 'TrackAction',
    ['EJRaidDifficulty'] = 'TrackAction',
    ['EJSelectedTier'] = 'TrackAction',
    ['lastCharacterIndex'] = 'TrackAction',
    ['lastSelectedClubId'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec1'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec2'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec3'] = 'TrackAction',
    ['lastTransmogOutfitIDSpec4'] = 'TrackAction',
    ['minimapShapeshiftTracking'] = 'TrackAction',
    ['minimapTrackedInfov3'] = 'TrackAction',
    ['petJournalTab'] = 'TrackAction',
    ['professionsOrderDurationDropdown'] = 'TrackAction',
    ['professionsOrderRecipientDropdown'] = 'TrackAction',

    -- Track Bitwise: CVars that used to track user actions with bitwise operation
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
                    C_CVar.SetCVar(data.name, data.profile)
                    Core:RefreshCVars()
                end,
            },
            {
                text = L['Load Default'],
                onClick = function(button)
                    local data = button:GetParent().data
                    C_CVar.SetCVar(data.name, data.defaultValue)
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
    local window = CreateFrame('Frame', 'CVarExplorerWindow', UIParent, 'PortraitFrameTemplate')
    window:SetFrameStrata('HIGH')
    window:ClearAllPoints()
    window:SetPoint('CENTER')
    window:SetSize(scrollBoxWidth + 30, 600)
    window:Hide()
    Core.window = window

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
    columnDisplay:SetFrameLevel(window:GetFrameLevel())
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

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
end

function Core:RefreshCVars()
    local showLockedFromUser = false
    local showReadOnly = false
    local hideProfileEqual = true
    local hideSpecialCVars = true

    local enableNumberEquals = true

    self.dataProvider:Flush()

    -- debug
    wipe(self.debugList)

    local commands = ConsoleGetAllCommands()
    for _, info in ipairs(commands) do
        if (
            info.commandType == Enum.ConsoleCommandType.Cvar
            and info.category ~= Enum.ConsoleCategory.Debug
            and info.category ~= Enum.ConsoleCategory.Gm
            and not strfind(strlower(info.command), 'debug')
        ) then
            local name = info.command
            local value, defaultValue, isStoredServerAccount, isStoredServerCharacter, isLockedFromUser, _, isReadOnly = C_CVar.GetCVarInfo(name)

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

                -- debug
                tinsert(self.debugList, data)
            end
        end
    end
end

function Core:Initialize()
    CVarExplorerDB = CVarExplorerDB or {}
    CVarExplorerDB.Profiles = CVarExplorerDB.Profiles or {}
    CVarExplorerDB.Profiles.Default = CVarExplorerDB.Profiles.Default or {}
    self.profile = CVarExplorerDB.Profiles.Default

    -- debug
    local playerFullName = UnitName('player') .. '-' .. GetRealmName()
    CVarExplorerDB.DebugList = CVarExplorerDB.DebugList or {}
    CVarExplorerDB.DebugList[playerFullName] = CVarExplorerDB.DebugList[playerFullName] or {}
    self.debugList = CVarExplorerDB.DebugList[playerFullName]

    self.dataProvider = CreateDataProvider()
    self.dataProvider:SetSortComparator(Compare, true)

    self:CreateWindow()
    self:RefreshCVars()

    if (not self.dataProvider:IsEmpty()) then
        self.window:Show()
    end

    SLASH_CVAREXPLORER1, SLASH_CVAREXPLORER2 = '/ce', '/cvarexplorer'
    _G.SlashCmdList.CVAREXPLORER = function()
        Core.window:SetShown(not Core.window:IsShown())
    end
end
