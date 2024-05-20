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
    ["lastRenownForCovenant1"] = 'GameProgress',
    ["lastRenownForCovenant2"] = 'GameProgress',
    ["lastRenownForCovenant3"] = 'GameProgress',
    ["lastRenownForCovenant4"] = 'GameProgress',
    ["lastRenownForMajorFaction2503"] = 'GameProgress',
    ["lastRenownForMajorFaction2507"] = 'GameProgress',
    ["lastRenownForMajorFaction2510"] = 'GameProgress',
    ["lastRenownForMajorFaction2511"] = 'GameProgress',
    ["lastRenownForMajorFaction2564"] = 'GameProgress',
    ["lastRenownForMajorFaction2574"] = 'GameProgress',
    ["lastRenownForMajorFaction2593"] = 'GameProgress',

    -- Game Tip: CVars that used to show game tips
    ['closedInfoFrames'] = 'GameTip',
    ['closedInfoFramesAccountWide'] = 'GameTip',
    ['engineSurveyPatch'] = 'GameTip',
    ['gameTip'] = 'GameTip',
    ['lastAddonVersion'] = 'GameTip',
    ['latestSplashScreen'] = 'GameTip',
    ['seenTimerunningFirstLoginPopup'] = 'GameTip',

    -- User Action Frequently: CVars that frequently changed by user actions
    ['advJournalLastOpened'] = 'UserActionFrequently',
    ['cameraSavedDistance'] = 'UserActionFrequently',
    ['cameraSavedPitch'] = 'UserActionFrequently',
    ['clubFinderPlayerSettings'] = 'UserActionFrequently',
    ['lastCharacterIndex'] = 'UserActionFrequently',
    ['lastSelectedClubId'] = 'UserActionFrequently',

    -- Track Bitwise: CVars that used to track with bitwise operation
    ['maxLevelSpecsUsed'] = 'TrackBitwise',
    ['trackedAchievements'] = 'TrackBitwise',
    ['trackedPerksActivities'] = 'TrackBitwise',
    ['trackedProfessionRecipes'] = 'TrackBitwise',
    ['trackedProfessionRecraftRecipes'] = 'TrackBitwise',
    ['trackedQuests'] = 'TrackBitwise',
    ['trackedWorldQuests'] = 'TrackBitwise',
    ['unlockedMajorFactions'] = 'TrackBitwise',

    -- Internal: Used by game internally
    ['CACHE-WGOB-GameObjectsHotfixCount'] = 'Internal',
    ['CACHE-WGOB-GameObjectsRecordCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveHotfixCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveRecordCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveXEffectHotfixCount'] = 'Internal',
    ['CACHE-WQST-QuestObjectiveXEffectRecordCount'] = 'Internal',
    ['CACHE-WQST-QuestV2HotfixCount'] = 'Internal',
    ['CACHE-WQST-QuestV2RecordCount'] = 'Internal',
}

---@class CECVarWindowData
---@field name string
---@field scope string
---@field defaultValue string
---@field profile string
---@field value string

---@class CECVarWindowLine: Frame
---@field IsCreated boolean
---@field Fields FontString[]

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
        width = 150,
        attribute = 'defaultValue',
    },
    {
        title = L['Profile'],
        width = 150,
        attribute = 'profile',
    },
    {
        title = L['Value'],
        width = 150,
        attribute = 'value',
    },
    {
        title = L['Actions'],
        width = 200,
    },
}

---@param frame CECVarWindowLine
---@param data CECVarWindowData
local function Initializer(frame, data)
    if not frame.IsCreated then
        Mixin(frame, BackdropTemplateMixin)
        frame:SetSize(750, 20)
        frame:SetBackdrop(backdropInfo)
        frame:SetBackdropColor(0, 0, 0, 0.5)

        local offset = 0
        frame.Fields = {}
        for i, info in ipairs(columnInfo) do
            if info.attribute then
                local field = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
                field:SetPoint('LEFT', offset + 10, 0)
                field:SetSize(info.width - 20, 20)
                field:SetJustifyH('LEFT')

                offset = offset + info.width
                frame.Fields[i] = field
            end
        end

        frame.IsCreated = true
    end

    for i, info in ipairs(columnInfo) do
        if info.attribute then
            frame.Fields[i]:SetText(data[info.attribute])
        end
    end
end

---@param a CECVarWindowData
---@param b CECVarWindowData
local function Compare(a, b)
    return a.name < b.name
end

function Core:CreateWindow()
    local scrollBoxHeight = 400
    local scrollBoxWidth = 0
    for _, info in ipairs(columnInfo) do
        scrollBoxWidth = scrollBoxWidth + info.width
    end

    ---@class CVarExplorerWindow: Frame
    local window = CreateFrame('Frame', 'CVarExplorerWindow', UIParent, 'PortraitFrameTemplate')
    window:ClearAllPoints()
    window:SetPoint('CENTER')
    window:SetSize(scrollBoxWidth + 30, scrollBoxHeight + 100)

    window.TitleContainer.TitleText:SetText('CVar Explorer')
    window.PortraitContainer.portrait:SetTexture(237162)

    local columnDisplay = CreateFrame('Frame', nil, window, 'ColumnDisplayTemplate')
    columnDisplay:ClearAllPoints()
    columnDisplay:SetPoint('TOPLEFT', 15, -30)
    columnDisplay:SetPoint('TOPRIGHT', -15, -30)
    columnDisplay:LayoutColumns(columnInfo)

    local scrollBox = CreateFrame('Frame', nil, window, 'WowScrollBoxList')
    scrollBox:SetPoint('TOPLEFT', columnDisplay, 'BOTTOMLEFT')
    scrollBox:SetSize(scrollBoxWidth, scrollBoxHeight)

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
    local hideSnapshotNotChanged = true
    local hideSpecialCVars = true

    self.dataProvider:Flush()

    -- debug
    wipe(CVarExplorerDB.DebugList)

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
            local profileValue = isStoredServerCharacter and CVarExplorerDB.Profile[self.playerFullName][name] or CVarExplorerDB.Profile.Account[name]
            if (
                (showLockedFromUser or not isLockedFromUser)
                and (showReadOnly or not isReadOnly)
                and (not hideSnapshotNotChanged or value ~= profileValue)
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
                tinsert(CVarExplorerDB.DebugList, data)
            end
        end
    end
end

function Core:Initialize()
    self.playerFullName = UnitName('player') .. '-' .. GetRealmName()

    CVarExplorerDB = CVarExplorerDB or {}
    CVarExplorerDB.Profile = CVarExplorerDB.Profile or {}
    CVarExplorerDB.Profile.Account = CVarExplorerDB.Profile.Account or {}
    CVarExplorerDB.Profile[self.playerFullName] = CVarExplorerDB.Profile[self.playerFullName] or {}

    -- debug
    CVarExplorerDB.DebugList = CVarExplorerDB.DebugList or {}

    self.dataProvider = CreateDataProvider()
    self.dataProvider:SetSortComparator(Compare, true)

    self:CreateWindow()
    self:RefreshCVars()
end
