local addonName = select(1, ...);

---@class DatamineDatabase
local Database = select(2, ...);

local UNIT_TYPE_CREATURE = "Creature";

local UNIT_FLAGS = {
    [COMBATLOG_OBJECT_AFFILIATION_MASK] = {
		[COMBATLOG_OBJECT_AFFILIATION_MINE] = "Affiliation: Mine",
		[COMBATLOG_OBJECT_AFFILIATION_PARTY] = "Affiliation: Party",
		[COMBATLOG_OBJECT_AFFILIATION_RAID] = "Affiliation: Raid",
		[COMBATLOG_OBJECT_AFFILIATION_OUTSIDER] = "Affiliation: Outsider",
	},
	[COMBATLOG_OBJECT_REACTION_MASK] = {
		[COMBATLOG_OBJECT_REACTION_FRIENDLY] = "Friendly",
		[COMBATLOG_OBJECT_REACTION_NEUTRAL] = "Neutral",
		[COMBATLOG_OBJECT_REACTION_HOSTILE] = "Hostile",
	},
	[COMBATLOG_OBJECT_CONTROL_MASK] = {
		[COMBATLOG_OBJECT_CONTROL_PLAYER] = "Control: Player",
		[COMBATLOG_OBJECT_CONTROL_NPC] = "Control: NPC",
	},
	[COMBATLOG_OBJECT_TYPE_MASK] = {
		[COMBATLOG_OBJECT_TYPE_PLAYER] = "Type: Player",
		[COMBATLOG_OBJECT_TYPE_NPC] = "Type: NPC",
		[COMBATLOG_OBJECT_TYPE_PET] = "Type: Pet",
		[COMBATLOG_OBJECT_TYPE_GUARDIAN] = "Type: Guardian",
		[COMBATLOG_OBJECT_TYPE_OBJECT] = "Type: Object",
	},
};

local UNIT_FLAGS_ORDER = {
    REACTION = "Reactions"
};

------------

local function DebugAssert(condition, message)
    if not Datamine.Debug then
        return;
    end
    assert(condition, message);
end

------------

local NAME_CACHE = {};

local function AddNameToCache(name, creatureID)
    DebugAssert(name, "Missing creature name");
    if not name then
        return;
    end

    NAME_CACHE[name] = creatureID;
end

local function GetCreatureIDFromNameCache(name)
    return NAME_CACHE[name];
end

------------

local BROADCAST_TEXT_CACHE = {};
local BROADCAST_TEXT_CACHE_LEN = 0;

local function AddBroadcastTextToCache(name, text)
    BROADCAST_TEXT_CACHE[name] = text;
    BROADCAST_TEXT_CACHE_LEN = BROADCAST_TEXT_CACHE_LEN + 1;
end

local function InvalidateBroadcastTextCacheEntry(name)
    BROADCAST_TEXT_CACHE[name] = nil;
    BROADCAST_TEXT_CACHE_LEN = BROADCAST_TEXT_CACHE_LEN - 1;
end

local function GetBroadcastTextFromCache(name)
    return BROADCAST_TEXT_CACHE[name];
end

------------

local EMPTY = {};
local CreatureEntryDefaults = {
    Name = EMPTY,
    Instances = EMPTY,
    Reactions = EMPTY,
    Spells = EMPTY,
    BroadcastText = EMPTY,
};

local CreatureEntryMetatable = {
    __index = function(tbl, key)
        local default = CreatureEntryDefaults[key];
        if default then
            local defaultValue;
            if type(default) == "table" then
                defaultValue = CopyTable(default);
            else
                defaultValue = default;
            end
            rawset(tbl, key, defaultValue);
            return rawget(tbl, key);
        end
    end
};

local function ApplyMetatableToCreatureEntry(tbl)
    setmetatable(tbl, CreatureEntryMetatable);
end

local DefaultDB = {
    Creature = {},
};

local function GetDefaultDB()
    return CopyTable(DefaultDB);
end

local function InitDB()
    if not DatamineData or not DatamineData.Creature then
        DatamineData = GetDefaultDB();
    end

    Database:Init();
end

local function HandleLogout()
    local function RemoveEmptyTables(category)
        for entryKey, entry in pairs(category) do
            if type(entry) == "table" then
                if TableIsEmpty(entry) then
                    category[entryKey] = nil;
                else
                    RemoveEmptyTables(entry);
                end
            end
        end
    end

    do
        local success, result = pcall(RemoveEmptyTables, DatamineData.Creature);
        if not success then
            DatamineData.LastSaveError = result;
        end
    end

    local textCache = DatamineData.BroadcastTextCache;
    if not textCache then
        textCache = {};
    end

    for name, text in pairs(BROADCAST_TEXT_CACHE) do
        if not textCache[name] then
            textCache[name] = {};
        end
        textCache[name][text] = true;
    end

    DatamineData.BroadcastTextCache = textCache;

    if TableIsEmpty(DatamineData.BroadcastTextCache) then
        DatamineData.BroadcastTextCache = nil;
    else
        local success, result = pcall(RemoveEmptyTables, DatamineData.BroadcastTextCache);
        if not success then
            DatamineData.LastSaveError = result;
        end
    end
end

local function RegisterDB()
    DatamineCollector:RegisterDatabase(Database);
end

EventUtil.ContinueOnAddOnLoaded(addonName, InitDB);
EventUtil.ContinueOnAddOnLoaded("Datamine", RegisterDB);
EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_LOGOUT", HandleLogout);

local GetLocale = GetLocale or function() return C_CVar.GetCVar("textLocale") end;

------------

---@class TooltipDataManager : Frame
local TooltipDataManager = CreateFrame("Frame");
TooltipDataManager:RegisterEvent("TOOLTIP_DATA_UPDATE");

function TooltipDataManager:OnEvent(event, ...)
    if self[event] then
        self[event](self, ...);
    end
end

function TooltipDataManager:TOOLTIP_DATA_UPDATE(dataInstanceID)
    if dataInstanceID and Database.TooltipInstanceIDCache[dataInstanceID] then
        self:UpdateTooltipData(dataInstanceID);
    end
end

function TooltipDataManager:UpdateTooltipData(dataInstanceID)
    local guid = Database.TooltipInstanceIDCache[dataInstanceID];
    local tooltipData = C_TooltipInfo.GetHyperlink(format("unit:%s", guid));
    Database:UpdateCreatureEntryWithTooltipData(tooltipData);
    Database.TooltipInstanceIDCache[dataInstanceID] = nil;
end

------------

function Database:Init()
    self.DB = CopyTable(DatamineData);
    self.TooltipInstanceIDCache = {};
    self.Patches = {};
    self:ApplyMetatables();
    self:ConvertStringIndicesToNumbers();
    self:LoadOrphanedBroadcastTextIntoCache();
end

function Database:ApplyMetatables()
    if self.Patches.MetatablesApplied then
        return;
    end

    for _, tbl in pairs(self.DB.Creature) do
        ApplyMetatableToCreatureEntry(tbl);
    end

    self.Patches.MetatablesApplied = true;
end

-- everything was being stored as string indices for w/e reason so just converting those to numbers to be less insane
function Database:ConvertStringIndicesToNumbers()
    if self.Patches.StringKeysConverted then
        return;
    end

    local hasChanges = false;
    for creatureID, entry in pairs(self.DB.Creature) do
        if type(creatureID) == "string" then
            if entry.Instances then
                for instanceID in pairs(entry.Instances) do
                    if type(instanceID) == "string" then
                        entry.Instances[instanceID] = nil;
                        entry.Instances[tonumber(instanceID)] = true;
                    end
                end
            end

            self.DB.Creature[creatureID] = nil;
            self.DB.Creature[tonumber(creatureID)] = entry;
            hasChanges = true;
        end
    end

    if hasChanges then
        self:Commit();
    end

    self.Patches.StringKeysConverted = true;
end

function Database:LoadOrphanedBroadcastTextIntoCache()
    if self.DB.BroadcastTextCache then
        for name, lines in pairs(self.DB.BroadcastTextCache) do
            for text in pairs(lines) do
                AddBroadcastTextToCache(name, text);
            end
            self.DB.BroadcastTextCache[name] = nil;
        end
        self:Commit();
    end
end

function Database:GetCreatureEntryDefaults()
    return CopyTable(CreatureEntryDefaults);
end

function Database:Commit()
    DatamineData = self.DB;
end

function Database:Reset(reload)
    DatamineData = GetDefaultDB();
    if reload then
        C_UI.Reload();
    end
end

function Database:CreatureEntryExists(creatureID)
    local entry = self.DB.Creature[creatureID];
    return (type(entry) == "table");
end

function Database:GetCreatureIDByName(name)
    local id = GetCreatureIDFromNameCache(name);
    if not id then
        local locale = GetLocale();
        for creatureID, entry in pairs(self.DB.Creature) do
            if entry.Name[locale] == name then
                id = creatureID;
                break;
            end
        end
    end

    return id;
end

function Database:GetCreatureEntryByID(creatureID)
    return self.DB.Creature[creatureID];
end

---@param creatureID number
---@param data CreatureEntry
function Database:UpdateCreatureEntry(creatureID, data)
    self.DB.Creature[creatureID] = data;

    local locale = GetLocale();
    local name = data.Name[locale];
    AddNameToCache(name, creatureID);
    self:CheckBroadcastTextCache(name);
    self:Commit();
    return data;
end

function Database:NewCreatureEntry()
    local entry = {};
    ApplyMetatableToCreatureEntry(entry);

    return entry;
end

---@param guid WOWGUID
---@return number? creatureID
function Database:GetCreatureIDFromGUID(guid)
    local creatureID = select(6, strsplit("-", guid));
    return tonumber(creatureID);
end

---@param guid string
---@return CreatureEntry creatureEntry
---@return number creatureID
function Database:GetOrCreateCreatureEntryByGUID(guid, name)
    local unitType, _, _, instanceID, _, ID, _ = strsplit("-", guid);
    assert(unitType == UNIT_TYPE_CREATURE, "Invalid Creature GUID provided to :GetOrCreateCreatureEntryByGUID");

    ID = tonumber(ID);
    assert(ID, "Unable to extract ID from creature GUID '" .. guid .. "'");

    if self:CreatureEntryExists(ID) then
        return self:GetCreatureEntryByID(ID), ID;
    end

    local CreatureEntry = self:NewCreatureEntry();
    CreatureEntry.Instances[instanceID] = true;

    if not name then
        local tooltipData = C_TooltipInfo.GetHyperlink(format("unit:%s", guid));
        self.TooltipInstanceIDCache[tooltipData.dataInstanceID] = guid;
        for _, line in pairs(tooltipData.lines) do
            if line.type == Enum.TooltipDataLineType.UnitName then
                name = line.leftText;
                break;
            end
        end
    end

    local locale = GetLocale();
    CreatureEntry.Name[locale] = name;

    return self:UpdateCreatureEntry(ID, CreatureEntry), ID;
end

---@param tooltipData TooltipData
function Database:UpdateCreatureEntryWithTooltipData(tooltipData)
    local creatureID = self:GetCreatureIDFromGUID(tooltipData.guid);
    assert(creatureID, "Unable to extract ID from TOOLTIP_DATA_UPDATE guid");

    local entry = self:GetCreatureEntryByID(creatureID);
    if not entry then
        entry = self:NewCreatureEntry();
    end

    local locale = GetLocale();
    for _, line in pairs(tooltipData.lines) do
        if line.type == Enum.TooltipDataLineType.UnitName then
            entry.Name[locale] = line.leftText;
        end
    end

    self:UpdateCreatureEntry(creatureID, entry);
end

function Database:UpdateCreatureEntryWithUnitFlags(creatureID, unitFlags)
    local entry = self:GetCreatureEntryByID(creatureID);
    if not entry then
        entry = self:NewCreatureEntry();
    end

    for flagType, entryKey in pairs(UNIT_FLAGS_ORDER) do
        local playerFaction, infoTable;
        if flagType == "REACTION" then
            playerFaction = UnitFactionGroup("player");
            infoTable = entry[entryKey];
        end

        if not infoTable or not infoTable[playerFaction] then
            local mask = _G["COMBATLOG_OBJECT_"..flagType.."_MASK"];
            local bitfield = bit.band(unitFlags, mask);
            local info = UNIT_FLAGS[mask][bitfield];

            if infoTable and playerFaction then
                infoTable[playerFaction] = info;
            else
                entry[entryKey] = info;
            end
        end
    end

    self:Commit();
end

function Database:AddCreatureSpell(creatureID, spellID)
    DebugAssert(type(spellID) == "number", "Non-number spellID provided");

    local entry = self:GetCreatureEntryByID(creatureID);
    if not entry then
        entry = self:NewCreatureEntry();
    end

    entry.Spells[spellID] = true;
    self:Commit();
end

---@param name string
---@param text string
---@return boolean success
function Database:AddBroadcastTextToCreatureEntryByName(name, text, cached)
    local creatureID = self:GetCreatureIDByName(name);
    if not creatureID then
        if not cached then
            AddBroadcastTextToCache(name, text);
        end
        return false;
    end

    local entry = self:GetCreatureEntryByID(creatureID);
    if not entry then
        entry = self:NewCreatureEntry();
    end

    local locale = GetLocale();
    if not entry.BroadcastText[locale] then
        entry.BroadcastText[locale] = {};
    end

    if not entry.BroadcastText[locale][text] then
        entry.BroadcastText[locale][text] = true;
        self:Commit();
    end

    return true;
end

function Database:CheckBroadcastTextCache(name)
    if BROADCAST_TEXT_CACHE_LEN < 1 then
        return;
    end

    local text = GetBroadcastTextFromCache(name);
    if text then
        if self:AddBroadcastTextToCreatureEntryByName(name, text, true) then
            InvalidateBroadcastTextCacheEntry(name); -- remove if successful
        end
    end
end

function Database:GetAllCreatureEntries()
    return self.DB.Creature;
end