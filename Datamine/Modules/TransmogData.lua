local moduleName = "Transmog";

local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local Dump = function(tableTitle, ...)
    Datamine.Dump(moduleName, tableTitle, ...);
end;

local TransmogInfoKeys = {
    "SourceType",
    "InventoryType",
    "VisualID",
    "IsCollected",
    "SourceID",
    "ItemID",
    "CategoryID",
    "ItemModID"
};

local DumpTableWithDisplayKeys = function(tableTitle, ...)
    Datamine.DumpTableWithDisplayKeys(moduleName, tableTitle, ...);
end;

Datamine.Transmog = {};

local LinkPrefix = "transmogData";
local TryOnPrefix = "tryOn";

function Datamine.Transmog.HandleLink(pattern)
    local prefix, itemModifiedAppearanceID = strsplit(Datamine.Links.SEPARATOR, pattern);
    if prefix == "tryOn" then
        Datamine.ModelView:TryOnByItemModifiedAppearanceID({itemModifiedAppearanceID})
        return;
    end
end

function Datamine.Transmog:GetItemIDLink(itemID)
    local pattern = LinkPrefix .. Datamine.Links.SEPARATOR .. itemID;
    return Datamine.Links.GenerateLinkWithCallback(pattern, itemID, Datamine.Item.HandleLink);
end

function Datamine.Transmog:GetTryOnLink(itemModifiedAppearanceID)
    local pattern = TryOnPrefix .. Datamine.Links.SEPARATOR .. itemModifiedAppearanceID;
    return Datamine.Links.GenerateLinkWithCallback(pattern, "Try On", Datamine.Transmog.HandleLink);
end

function Datamine.Transmog:GetModifiedAppearanceIDsFromAppearanceID(appearanceID)
    local itemModifiedAppearanceIDs = C_TransmogCollection.GetAllAppearanceSources(appearanceID);

    if not itemModifiedAppearanceIDs or #itemModifiedAppearanceIDs < 1 then
        Print("No ItemModifiedAppearances found for ItemAppearance " .. appearanceID .. ".");
        return;
    end

    local linkTable = {}
    local displayKeys = {}

    for i, v in ipairs(itemModifiedAppearanceIDs) do
        local tryOnLink = self:GetTryOnLink(v);

        displayKeys[i] = v;
        linkTable[i] = tryOnLink;
    end

    DumpTableWithDisplayKeys("ItemModifiedAppearances for ItemAppearance " .. appearanceID .. " >>", displayKeys, linkTable, true);
end

function Datamine.Transmog:GetAppearanceSourceInfo(itemModifiedAppearanceID)
    local sourceInfo = C_TransmogCollection.GetSourceInfo(itemModifiedAppearanceID)
    sourceInfo.categoryID = Datamine.GetEnumValueName(Enum.TransmogCollectionType, sourceInfo.categoryID);
    local _, _, _, itemEquipLoc, _ = GetItemInfoInstant(sourceInfo.itemID);
    local outputTable = {};

    outputTable.Name = sourceInfo.name;
    outputTable.ItemID = self:GetItemIDLink(sourceInfo.itemID);

    if sourceInfo.quality then
        outputTable.Quality = Datamine.GetEnumValueName(Enum.ItemQuality, sourceInfo.quality);
    end

    if itemEquipLoc then
        outputTable.InventoryType = itemEquipLoc;
    else
        outputTable.InventoryType = Datamine.GetEnumValueName(Enum.InventoryType, sourceInfo.invType);
    end

    if sourceInfo.useError then
        outputTable.UseError = sourceInfo.useError;
    end

    if sourceInfo.useErrorType then
        outputTable.UseErrorType = Datamine.GetEnumValueName(Enum.TransmogUseErrorType, sourceInfo.useErrorType);
    end

    if sourceInfo.sourceType then
        outputTable.SourceType = _G["TRANSMOG_SOURCE_"..sourceInfo.sourceType];
    end

    if sourceInfo.meetsTransmogPlayerCondition == false then
        outputTable.MeetsTransmogPlayerCondition = sourceInfo.meetsTransmogPlayerCondition;
    end

    outputTable.VisualID = sourceInfo.visualID;
    outputTable.IsCollected = sourceInfo.isCollected;
    outputTable.SourceID = sourceInfo.sourceID;
    outputTable.IsHideVisual = sourceInfo.isHideVisual;
    outputTable.CategoryID = sourceInfo.categoryID;
    outputTable.ItemModID = sourceInfo.itemModID;

    Dump("Appearance " .. itemModifiedAppearanceID .. "  >> ", outputTable);

    return true;
end

do
    local helpMessage = "Retrieve source info for an itemModifiedAppearanceID.";
    local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemModifiedAppearanceID>", helpMessage);

    Datamine.Slash:RegisterCommand("appearanceinfo", function(itemModifiedAppearanceID) Datamine.Transmog:GetAppearanceSourceInfo(itemModifiedAppearanceID) end, helpString, moduleName);
end

do
    local helpMessage = "Retrieve itemModifiedAppearanceIDs for a given itemAppearanceID.";
    local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemAppearanceID>", helpMessage);

    Datamine.Slash:RegisterCommand("appearancemods", function(appearanceID) Datamine.Transmog:GetModifiedAppearanceIDsFromAppearanceID(appearanceID) end, helpString, moduleName);
end