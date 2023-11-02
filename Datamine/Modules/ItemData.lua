Datamine.Item = CreateFrame("Frame");

local moduleName = "ItemData";

local ItemInfoKeys = {
    "Name",
    "Hyperlink",
    "Quality",
    "ItemLevel",
    "ItemMinLevel",
    "ItemType",
    "ItemSubType",
    "ItemStackCount",
    "ItemEquipSlot",
    "ItemTexture",
    "SellPrice",
    "ItemClassID",
    "ItemSubclassID",
    "BindType",
    "ExpacID",
    "ItemSetID",
    "IsCraftingReagent",

    -- Some extra custom values

    "IsKeystone",
    "IsSpecificToPlayerClass",
    "IsDressable",
    "IsAnimaItem",
};
Datamine.Item.ItemInfoKeys = ItemInfoKeys;

local ItemBindTypes = {
    [0] = "None",
    [1] = "Bind on Pickup",
    [2] = "Bind on Equip",
    [3] = "Bind on Use",
    [4] = "Bind on Account",
};
Datamine.Item.ItemBindTypes = ItemBindTypes;

local ExpansionNames = {
    [0] = "Classic",
    [1] = "Burning Crusade",
    [2] = "Wrath of the Lich King",
    [3] = "Cataclysm",
    [4] = "Mists of Pandaria",
    [5] = "Warlords of Draenor",
    [6] = "Legion",
    [7] = "Battle for Azeroth",
    [8] = "Shadowlands",
    [9] = "Dragonflight",
    [10] = "The future? wtf item is this??"
};
Datamine.Item.ExpansionNames = ExpansionNames;

local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local Dump = function(tableTitle, ...)
    Datamine.Dump(moduleName, tableTitle, ...);
end;

local DumpTableWithDisplayKeys = function(tableTitle, ...)
    Datamine.DumpTableWithDisplayKeys(moduleName, tableTitle, ItemInfoKeys, ...);
end;

function Datamine.Item:Init()
    self.LastRequestedItemID = nil;
    self.WaitingForItemInfo = false;

    self:SetScript("OnEvent", self.OnEvent);
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function Datamine.Item:OnEvent(event, ...)
    if self.LastRequestedItemID and self.WaitingForItemInfo then
        if event == "GET_ITEM_INFO_RECEIVED" then
            local itemID, success = ...;
            if itemID == self.LastRequestedItemID then
                self:OnItemDataReceived(itemID, success);
            end
        end
    end
end

function Datamine.Item:OnItemDataReceived(itemID, success)
    if success == nil then
        Print("Query for item " .. itemID .. " failed. Item does not exist.");
        return;
    elseif success == false then
        if self.ItemInfoCallback then
            self.ItemInfoCallback(false);
            return;
        end

        Print("Query for item " .. itemID .. " failed. Item is forbidden or does not exist.");
        return;
    end

    local itemData = self:GetFormattedItemData(itemID);
    if self.ItemInfoCallback then
        self.ItemInfoCallback(itemData);
    else
        self:PrettyDumpItemData(itemID, itemData);
    end

    self.ItemInfoCallback = nil;
end

function Datamine.Item:GetFormattedItemData(itemID)
    local itemData = {GetItemInfo(itemID)};

    if not itemData[16] then
        itemData[16] = "";
    end

    -- value -> readable strings
    -- item quality
    local itemQuality = itemData[3];
    local itemQualityString = _G["ITEM_QUALITY"..itemQuality.."_DESC"];
    local itemQualityColor = ITEM_QUALITY_COLORS[itemQuality].hex;
    itemData[3] = itemQualityColor .. itemQualityString .. "|r (" .. itemQuality .. ")";

    --bind type
    local bindType = itemData[14];
    itemData[14] =  ItemBindTypes[bindType] .. " (" .. bindType .. ")";

    --expansion names
    local expansionID = itemData[15];
    itemData[15] = ExpansionNames[expansionID] .. " (" .. expansionID .. ")";

    tinsert(itemData, tostring(C_Item.IsItemKeystoneByID(itemID)));
    tinsert(itemData, tostring(C_Item.IsItemSpecificToPlayerClass(itemID)));
    tinsert(itemData, tostring(C_Item.IsDressableItemByID(itemID)));
    tinsert(itemData, tostring(C_Item.IsAnimaItemByID(itemID)));

    return itemData;
end

function Datamine.Item:PrettyDumpItemData(itemID, itemData)
    DumpTableWithDisplayKeys("Item " .. itemID .. "  >> ", itemData);
end

function Datamine.Item:GetOrFetchItemInfoByID(itemID, callback)
    itemID = tonumber(itemID);
    assert(itemID, "GetOrFetchItemInfoByID requires a valid itemID.");

    self.ItemInfoCallback = callback;

    if C_Item.IsItemDataCachedByID(itemID) then
        self:OnItemDataReceived(itemID, true);
        return;
    end

    self.LastRequestedItemID = itemID;
    self.WaitingForItemInfo = true;
    GetItemInfo(itemID);
end

function Datamine.Item.HandleLink(pattern)
    local _, itemID = strsplit(Datamine.Links.SEPARATOR, pattern);
    Datamine.Item:GetOrFetchItemInfoByID(itemID);
end

Datamine.Item:Init();

local helpMessage = "Retrieve information about an item.";
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemID>", helpMessage);

Datamine.Slash:RegisterCommand("item", function(itemID) Datamine.Item:GetOrFetchItemInfoByID(itemID) end, helpString, moduleName);