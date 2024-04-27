Datamine.Spell = CreateFrame("Frame");

local L = Datamine.Strings;
local moduleName = L.SPELL_INFO_MODULE_NAME;

local GetSpellInfo = GetSpellInfo or function(spell)
    local spellInfo = C_Spell.GetSpellInfo(spell);
    if spellInfo then
        return spellInfo.name, 0, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
    end
    return nil;
end
local GetSpellLink = C_Spell and C_Spell.GetSpellLink or GetSpellLink;

Datamine.Spell.SpellInfoKeys = {
    L.SPELL_INFO_KEYS_NAME,
    L.SPELL_INFO_KEYS_RANK,
    L.SPELL_INFO_KEYS_ICON,
    L.SPELL_INFO_KEYS_CASTTIME,
    L.SPELL_INFO_KEYS_MINRANGE,
    L.SPELL_INFO_KEYS_MAXRANGE,
    L.SPELL_INFO_KEYS_SPELLID,
    L.SPELL_INFO_KEYS_ORIGINALICON,

    -- custom values

    L.SPELL_INFO_KEYS_DESCRIPTION,
    L.SPELL_INFO_KEYS_HYPERLINK,
};
local SpellInfoKeys = Datamine.Spell.SpellInfoKeys;

local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local Dump = function(tableTitle, ...)
    Datamine.Dump(moduleName, tableTitle, ...);
end;

local DumpTableWithDisplayKeys = function(tableTitle, ...)
    Datamine.DumpTableWithDisplayKeys(moduleName, tableTitle, SpellInfoKeys, ...);
end;

function Datamine.Spell:Init()
    self.LastRequestedSpellID = nil;
    self.WaitingForSpellInfo = false;

    self:SetScript("OnEvent", self.OnEvent);
    self:RegisterEvent("SPELL_DATA_LOAD_RESULT");
end

function Datamine.Spell:OnEvent(event, ...)
    if self.LastRequestedSpellID and self.WaitingForSpellInfo then
        if event == "SPELL_DATA_LOAD_RESULT" then
            local spellID, success = ...;
            if spellID == self.LastRequestedSpellID then
                self:OnSpellDataReceived(spellID, success);
            end
        end
    end
end

function Datamine.Spell:OnSpellDataReceived(spellID, success)
    if success == nil then
        if self.SpellDataCallback then
            self.SpellDataCallback(false);
            return;
        end

        Print(format(L.FMT_SPELL_INFO_ERR_SPELL_DOES_NOT_EXIST, spellID));
        return;
    elseif success == false then
        if self.SpellDataCallback then
            self.SpellDataCallback(false);
            return;
        end

        Print(format(L.FMT_SPELL_INFO_ERR_SPELL_NOT_FOUND, spellID));
        return;
    end

    local spellData = self:GetFormattedSpellData(spellID);
    if self.SpellDataCallback then
        self.SpellDataCallback(spellData)
    else
        self:PrettyDumpSpellData(spellID, spellData);
    end

    self.SpellDataCallback = nil;
end

function Datamine.Spell:GetFormattedSpellData(spellID)
    local spellData = {GetSpellInfo(spellID)};

    -- remove stupid dumb toxic no-good zero-diggity nil
    spellData[2] = L.GENERIC_NA;

    local castTime = spellData[4];
    if castTime == 0 then
        spellData[4] = format(L.SPELL_INFO_FMT_CAST_INSTANT, castTime);
    else
        spellData[4] = format(L.SPELL_INFO_FMT_CAST_TIME, castTime);
    end

    local minRange = spellData[5];
    if minRange > 0 then
        spellData[5] = format(L.SPELL_INFO_FMT_RANGE, minRange);
    end

    local maxRange = spellData[6];
    if maxRange > 0 then
        spellData[6] = format(L.SPELL_INFO_FMT_RANGE, maxRange);
    end

    tinsert(spellData, GetSpellDescription(spellID));
    local spellLink, _ = GetSpellLink(spellID);
    tinsert(spellData, spellLink);

    return spellData;
end

function Datamine.Spell:PrettyDumpSpellData(spellID, spellData)
    DumpTableWithDisplayKeys(L.GENERIC_SPELL .. " " .. spellID .. "  >> ", spellData);
    self.LastSpell = spellData;
end

function Datamine.Spell:GetOrFetchSpellInfoByID(spellID, callback)
    spellID = tonumber(spellID);
    assert(spellID, "GetOrFetchSpellInfoByID requires a valid spellID.");

    self.SpellDataCallback = callback;

    if C_Spell.IsSpellDataCached(spellID) then
        self:OnSpellDataReceived(spellID, true);
        return;
    end

    self.LastRequestedSpellID = spellID;
    self.WaitingForSpellInfo = true;
    C_Spell.RequestLoadSpellData(spellID);
end

Datamine.Spell:Init();

local helpMessage = L.SLASH_CMD_SPELL_INFO_HELP;
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<spellID>", helpMessage);

Datamine.Slash:RegisterCommand("spell", function(spellID) Datamine.Spell:GetOrFetchSpellInfoByID(tonumber(spellID)) end, helpString, moduleName);
