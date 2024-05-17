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

    -- Track Bitwise: CVars that used to track with bitwise operation
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
---@field Name FontString
---@field Scope FontString
---@field DefaultValue FontString
---@field Profile FontString
---@field Value FontString

---@param frame CECVarWindowLine
---@param data CECVarWindowData
local function Initializer(frame, data)
    if not frame.IsCreated then
        Mixin(frame, BackdropTemplateMixin)
        frame:SetSize(750, 20)
        frame:SetBackdrop(backdropInfo)
        frame:SetBackdropColor(0, 0, 0, 0.5)

        frame.Name = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        frame.Name:SetPoint('LEFT', 1, 0)
        frame.Name:SetSize(200, 20)
        frame.Name:SetJustifyH('LEFT')

        frame.Scope = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        frame.Scope:SetPoint('LEFT', 201, 0)
        frame.Scope:SetSize(100, 20)
        frame.Scope:SetJustifyH('LEFT')

        frame.DefaultValue = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        frame.DefaultValue:SetPoint('LEFT', 301, 0)
        frame.DefaultValue:SetSize(150, 20)
        frame.DefaultValue:SetJustifyH('LEFT')

        frame.Profile = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        frame.Profile:SetPoint('LEFT', 451, 0)
        frame.Profile:SetSize(150, 20)
        frame.Profile:SetJustifyH('LEFT')

        frame.Value = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        frame.Value:SetPoint('LEFT', 601, 0)
        frame.Value:SetSize(150, 20)
        frame.Value:SetJustifyH('LEFT')

        frame.IsCreated = true
    end

    frame.Name:SetText(data.name)
    frame.Scope:SetText(data.scope)
    frame.DefaultValue:SetText(data.defaultValue)
    frame.Profile:SetText(data.profile)
    frame.Value:SetText(data.value)
end

---@param a CECVarWindowData
---@param b CECVarWindowData
local function Compare(a, b)
    return a.name < b.name
end

function Core:CreateWindow()
    ---@class CVarExplorerWindow: Frame
    local window = CreateFrame('Frame', 'CVarExplorerWindow', UIParent, 'PortraitFrameTemplate')
    window:ClearAllPoints()
    window:SetPoint('CENTER')
    window:SetSize(780, 500)

    window.TitleContainer.TitleText:SetText('CVar Explorer')
    window.PortraitContainer.portrait:SetTexture(237162)

    local scrollBox = CreateFrame('Frame', nil, window, 'WowScrollBoxList')
    scrollBox:SetPoint('BOTTOM', 0, 10)
    scrollBox:SetSize(750, 400)

    local scrollBar = CreateFrame('EventFrame', nil, window, 'MinimalScrollBar')
    scrollBar:SetPoint('TOPLEFT', scrollBox, 'TOPRIGHT')
    scrollBar:SetPoint('BOTTOMLEFT', scrollBox, 'BOTTOMRIGHT')

    local scrollView = CreateScrollBoxListLinearView()
    scrollView:SetElementExtent(20)
    scrollView:SetElementInitializer('Frame', Initializer)
    scrollView:SetDataProvider(self.dataProvider)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)

    window.Name = window:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    window.Name:SetPoint('TOPLEFT', scrollBox, 1, 20)
    window.Name:SetSize(200, 20)
    window.Name:SetJustifyH('LEFT')
    window.Name:SetText(L['Name'])

    window.Scope = window:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    window.Scope:SetPoint('TOPLEFT', scrollBox, 201, 20)
    window.Scope:SetSize(100, 20)
    window.Scope:SetJustifyH('LEFT')
    window.Scope:SetText(L['Scope'])

    window.DefaultValue = window:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    window.DefaultValue:SetPoint('TOPLEFT', scrollBox, 301, 20)
    window.DefaultValue:SetSize(150, 20)
    window.DefaultValue:SetJustifyH('LEFT')
    window.DefaultValue:SetText(L['Default Value'])

    window.Profile = window:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    window.Profile:SetPoint('TOPLEFT', scrollBox, 451, 20)
    window.Profile:SetSize(150, 20)
    window.Profile:SetJustifyH('LEFT')
    window.Profile:SetText(L['Profile'])

    window.Value = window:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    window.Value:SetPoint('TOPLEFT', scrollBox, 601, 20)
    window.Value:SetSize(150, 20)
    window.Value:SetJustifyH('LEFT')
    window.Value:SetText(L['Value'])
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
