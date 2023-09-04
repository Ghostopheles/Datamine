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
    Datamine.DumpTableWithDisplayKeys(moduleName, tableTitle, TransmogInfoKeys, ...);
end;

Datamine.Transmog = {};

local LinkPrefix = "transmogData";

function Datamine.Transmog:GetItemIDLink(itemID)
    local pattern = LinkPrefix .. Datamine.Links.SEPARATOR .. itemID;
    return Datamine.Links.GenerateLinkWithCallback(pattern, itemID, Datamine.Item.HandleLink);
end

function Datamine.Transmog:GetAppearanceSourceInfo(appearanceID)
    local sourceInfo = C_TransmogCollection.GetSourceInfo(appearanceID)
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

    Dump("Appearance " .. appearanceID .. "  >> ", outputTable);

    return true;
end

local helpMessage = "Retrieve source info for an appearanceID.";
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<appearanceID>", helpMessage);

Datamine.Slash:RegisterCommand("appearanceinfo", function(appearanceID) Datamine.Transmog:GetAppearanceSourceInfo(appearanceID) end, helpString, moduleName);