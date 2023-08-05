Datamine.Spell = CreateFrame("Frame");

local moduleName = "SpellData"

local SpellInfoKeys = {
    "Name",
    "Rank",
    "Icon",
    "CastTime",
    "MinRange",
    "MaxRange",
    "SpellID",
    "OriginalIcon",

    --custom values

    "Description",
    "Hyperlink"
};

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
            self:OnSpellDataReceived(spellID, success);
        end
    end
end

function Datamine.Spell:OnSpellDataReceived(spellID, success)
    if success == nil then
        Print("Query for spell " .. spellID .. " failed. Spell does not exist.");
        return;
    elseif success == false then
        Print("Query for spell " .. spellID .. " failed. Spell is forbidden or does not exist.");
        return;
    end

    self:PrettyDumpSpellData(spellID);
end

function Datamine.Spell:PrettyDumpSpellData(spellID)
    local spellData = {GetSpellInfo(spellID)};

    -- remove stupid dumb toxic no-good zero-diggity nil
    spellData[2] = "N/A";

    local castTime = spellData[4];
    if castTime == 0 then
        spellData[4] = "Instant (" .. castTime .. ")";
    else
        spellData[4] = castTime .. " seconds";
    end

    local minRange = spellData[5];
    if minRange > 0 then
        spellData[5] = minRange .. " yards";
    end

    local maxRange = spellData[6];
    if maxRange > 0 then
        spellData[6] = maxRange .. " yards";
    end

    tinsert(spellData, GetSpellDescription(spellID));
    local spellLink, _ = GetSpellLink(spellID);
    tinsert(spellData, spellLink);

    DumpTableWithDisplayKeys("Spell " .. spellID .. "  >> ", spellData);
    self.LastSpell = spellData;
end

function Datamine.Spell:GetOrFetchSpellInfoByID(spellID)
    spellID = tonumber(spellID);
    assert(spellID, "GetOrFetchSpellInfoByID requires a valid spellID.");

    if C_Spell.IsSpellDataCached(spellID) then
        self:OnSpellDataReceived(spellID, true);
        return;
    end

    self.LastRequestedSpellID = spellID;
    self.WaitingForSpellInfo = true;
    C_Spell.RequestLoadSpellData(spellID);
end

Datamine.Spell:Init();

local helpMessage = "Retrieve information about a spell.";
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<spellID>", helpMessage);

Datamine.Slash:RegisterCommand("spell", function(spellID) Datamine.Spell:GetOrFetchSpellInfoByID(tonumber(spellID)) end, helpString);