local DATABASE;
local EVENTS = {
    CHAT_MSG_MONSTER_SAY = "CHAT_MSG_MONSTER_SAY",
    CHAT_MSG_MONSTER_YELL = "CHAT_MSG_MONSTER_YELL",
    CHAT_MSG_MONSTER_EMOTE = "CHAT_MSG_MONSTER_EMOTE",
    CHAT_MSG_MONSTER_PARTY = "CHAT_MSG_MONSTER_PARTY",
    CHAT_MSG_MONSTER_WHISPER = "CHAT_MSG_MONSTER_WHISPER",

    UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",
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
end

function DatamineCollectorMixin:OnEvent(event, ...)
    if self[event] then
        self[event](self, ...);
    end
end

function DatamineCollectorMixin:RegisterDatabase(db)
    if not DATABASE then
        DATABASE = db;
    end
end

------------

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

    if (KNOWN_LANGUAGES and not KNOWN_LANGUAGES[language]) or (not name) then
        return;
    end


    DATABASE:AddBroadcastTextToCreatureEntry(guid, text);
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

function DatamineCollectorMixin:UPDATE_MOUSEOVER_UNIT()
    if not UnitExists("mouseover") then
        return;
    end

    local guid = UnitGUID("mouseover");
end