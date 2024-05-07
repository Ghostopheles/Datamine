local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;
local Settings = Datamine.Settings;

---@type DatamineDatabase
local DATABASE;

local EVENTS = {
    CHAT_MSG_MONSTER_SAY = "CHAT_MSG_MONSTER_SAY",
    CHAT_MSG_MONSTER_YELL = "CHAT_MSG_MONSTER_YELL",
    CHAT_MSG_MONSTER_EMOTE = "CHAT_MSG_MONSTER_EMOTE",
    CHAT_MSG_MONSTER_PARTY = "CHAT_MSG_MONSTER_PARTY",
    CHAT_MSG_MONSTER_WHISPER = "CHAT_MSG_MONSTER_WHISPER",

    UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",

    COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED",

    PLAYER_SOFT_ENEMY_CHANGED = "PLAYER_SOFT_ENEMY_CHANGED",
    PLAYER_SOFT_FRIEND_CHANGED = "PLAYER_SOFT_FRIEND_CHANGED",
    PLAYER_SOFT_INTERACT_CHANGED = "PLAYER_SOFT_INTERACT_CHANGED",
    PLAYER_TARGET_CHANGED = "PLAYER_TARGET_CHANGED",

    NAME_PLATE_UNIT_ADDED = "NAME_PLATE_UNIT_ADDED",
    FORBIDDEN_NAME_PLATE_UNIT_ADDED = "FORBIDDEN_NAME_PLATE_UNIT_ADDED",
};

local PH_PLAYER_NAME = "$PLAYER_NAME$";
local PH_PLAYER_CLASS = "$PLAYER_CLASS$";

local KNOWN_LANGUAGES = nil;
local function InitializeKnownLanguages()
    KNOWN_LANGUAGES = {};
    for i=1, GetNumLanguages() do
        KNOWN_LANGUAGES[GetLanguageByIndex(i)] = true;
    end
end

DatamineCollectorMixin = {};

function DatamineCollectorMixin:OnLoad()
    for event in pairs(EVENTS) do
        if C_EventUtils.IsEventValid(event) then
            self:RegisterEvent(event);
        end
    end

    Registry:RegisterCallback(Events.SETTING_CHANGED, self.OnSettingChanged, self);
    EventUtil.ContinueOnAddOnLoaded("Datamine", function() self:OnAddonLoaded(); end);
end

function DatamineCollectorMixin:OnEvent(event, ...)
    if not self.EnableCollection then
        return;
    end

    if self[event] then
        self[event](self, ...);
    end
end

---@param db DatamineDatabase
function DatamineCollectorMixin:RegisterDatabase(db)
    if not DATABASE then
        DATABASE = db;
        Datamine.Database = db;
    end
end

function DatamineCollectorMixin:OnAddonLoaded()
    self.EnableCollection = Datamine.Settings.GetSetting(Datamine.Setting.CollectCreatureData);
end

function DatamineCollectorMixin:OnSettingChanged(setting, newValue)
    if setting ~= Datamine.Setting.CollectCreatureData then
        return;
    end

    self.EnableCollection = newValue;
end

------------
-- broadcast text handling

function DatamineCollectorMixin:HandleBroadcastText(...)
    local text, name, language, name2 = ...;

    -- replace player name and class with generic identifiers
    local function ReplaceNameAndClass(word)
        if word == GetUnitName("player", false) or word == GetUnitName("player", true) then
            return PH_PLAYER_NAME;
        end
        if word == UnitClass("player") then
            return PH_PLAYER_CLASS;
        end
    end
    text = text:gsub("(%w+-?%w*)", ReplaceNameAndClass);
    if name2 and name2 ~= "" then
        text = text:gsub(name2, PH_PLAYER_NAME);
    end

    if not KNOWN_LANGUAGES then
        InitializeKnownLanguages();
    end

    if (language and language ~= "") and (KNOWN_LANGUAGES and not KNOWN_LANGUAGES[language]) or (not name) then
        return;
    end

    DATABASE:AddBroadcastTextToCreatureEntryByName(name, text);
end

function DatamineCollectorMixin:CHAT_MSG_MONSTER_SAY(...)
    self:HandleBroadcastText(...);
end

function DatamineCollectorMixin:CHAT_MSG_MONSTER_YELL(...)
    self:HandleBroadcastText(...);
end

function DatamineCollectorMixin:CHAT_MSG_MONSTER_EMOTE(...)
    self:HandleBroadcastText(...);
end

function DatamineCollectorMixin:CHAT_MSG_MONSTER_PARTY(...)
    self:HandleBroadcastText(...);
end

function DatamineCollectorMixin:CHAT_MSG_MONSTER_WHISPER(...)
    self:HandleBroadcastText(...);
end

------------
-- caching

function DatamineCollectorMixin:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = CombatLogGetCurrentEventInfo();
    if sourceGUID and sourceGUID:match("Creature") then
        self:HandleCreatureFromCombatLog(sourceGUID, sourceName, sourceFlags, subEvent);
    end

    if destGUID and destGUID:match("Creature") then
        self:HandleCreatureFromCombatLog(destGUID, destName, destFlags, subEvent, true);
    end
end

local SUBEVENTS_TO_TRACK = {
    RANGE = true,
    SPELL = true,
};

function DatamineCollectorMixin:HandleCreatureFromCombatLog(guid, name, flags, subevent, skipLogSpell)
    name = name ~= "" and name or nil;
    local entry, ID = DATABASE:GetOrCreateCreatureEntryByGUID(guid, name);
    if not entry or not ID then
        return;
    end

    DATABASE:UpdateCreatureEntryWithUnitFlags(ID, flags);

    -- dont wanna add the spell if the creature is the target
    if skipLogSpell then
        return;
    end

    local prefix = strsplit("_", subevent, 2);
    if SUBEVENTS_TO_TRACK[prefix] then
        local spellID = select(12, CombatLogGetCurrentEventInfo());
        if type(spellID) ~= "number" then return end;
        if entry.Spells[spellID] then return end;
        DATABASE:AddCreatureSpell(ID, spellID);
    end
end

------------
-- more ways to capture creatures for the cache

function DatamineCollectorMixin:HandleCreature(guid)
    DATABASE:GetOrCreateCreatureEntryByGUID(guid);
end

function DatamineCollectorMixin:HandlePlayer(unitToken)
    local name = UnitName(unitToken);
    DATABASE:CheckPlayerNameForLackOfParents(name);
end

function DatamineCollectorMixin:HandleCreatureByUnitToken(unitToken)
    if not UnitExists(unitToken) then
        return;
    end

    if UnitIsPlayer(unitToken) then
        self:HandlePlayer(unitToken);
    else
        local guid = UnitGUID(unitToken);
        if guid and guid:match("Creature") then
            self:HandleCreature(guid);
        end
    end
end

function DatamineCollectorMixin:UPDATE_MOUSEOVER_UNIT()
    self:HandleCreatureByUnitToken("mouseover");
end

function DatamineCollectorMixin:PLAYER_SOFT_ENEMY_CHANGED()
    self:HandleCreatureByUnitToken("softenemy");
end

function DatamineCollectorMixin:PLAYER_SOFT_FRIEND_CHANGED()
    self:HandleCreatureByUnitToken("softfriend");
end

function DatamineCollectorMixin:PLAYER_SOFT_INTERACT_CHANGED()
    self:HandleCreatureByUnitToken("softinteract");
end

function DatamineCollectorMixin:PLAYER_TARGET_CHANGED()
    self:HandleCreatureByUnitToken("target");
end

function DatamineCollectorMixin:NAME_PLATE_UNIT_ADDED(unitToken)
    self:HandleCreatureByUnitToken(unitToken);
end

function DatamineCollectorMixin:FORBIDDEN_NAME_PLATE_UNIT_ADDED(unitToken)
    self:HandleCreatureByUnitToken(unitToken);
end

------------

Datamine.Collector = {};

function Datamine.Collector.GetAllCreatureEntries()
    return DATABASE:GetAllCreatureEntries();
end