local addonName, Database = ...;

local UNIT_TYPE_CREATURE = "Creature";

local DefaultDB = {
    Creature = {},
    GameObject = {},
};

local function GetDefaultDB()
    return CopyTable(DefaultDB);
end

local function InitDB()
    if not DatamineData then
        DatamineData = GetDefaultDB();
    end
end

local function RegisterDB()
    DatamineCollector:RegisterDatabase(Database);
end

EventUtil.ContinueOnAddOnLoaded(addonName, InitDB);
EventUtil.ContinueOnAddOnLoaded("Datamine", RegisterDB);

local GetLocale = GetLocale or function() return C_CVar.GetCVar("textLocale") end;

------------

function Database:Init()
    self.DB = CopyTable(DatamineData);
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
    return (type(entry) == "table") and (#entry > 0);
end

function Database:GetCreatureEntryByID(creatureID)
    return self.DB.Creature[creatureID];
end

function Database:GetOrCreateCreatureEntryByGUID(guid)
    local unitType, _, _, instanceID, zoneUID, ID, _ = strsplit("-", guid);
    assert(unitType == UNIT_TYPE_CREATURE, "Invalid Creature GUID provided to :GetOrCreateCreatureEntryByGUID");

    if self:CreatureEntryExists(ID) then
        return self:GetCreatureEntryByID(ID);
    end

    local CreatureEntry = {
        ID = ID,
        Name = {},
        Title = {},
        ZoneUID = zoneUID,
        InstanceID = instanceID,
    };

    do -- some extra info gathering
        local tooltipData = C_TooltipInfo.GetHyperlink(format("unit:%s", guid));
        local locale = GetLocale()
        for _, line in pairs(tooltipData.lines) do
            if line.type == Enum.TooltipDataLineType.UnitName then
                CreatureEntry.Name[locale] = line.leftText;
            elseif line.type == Enum.TooltipDataLineType.None then
                CreatureEntry.Title[locale] = line.leftText;
            end
        end
    end

    self.DB.Creature[ID] = CreatureEntry;
    return self.DB.Creature[ID];
end


function Database:AddBroadcastTextToCreatureEntry(guid, text)
    local entry = self:GetOrCreateCreatureEntryByGUID(guid);
    local broadcastText = entry.BroadcastText or {};
    local locale = GetLocale();

    if not broadcastText[locale] then
        broadcastText[locale] = {};
    end

    tinsert(broadcastText[locale], text);
end