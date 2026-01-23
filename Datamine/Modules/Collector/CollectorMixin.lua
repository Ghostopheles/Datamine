local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local issecretvalue = issecretvalue or function() return false; end;

local function DebugAssert(condition, message)
    if not Datamine.Debug.IsDebugEnabled() then
        return;
    end
    assert(condition, message);
end

---@type DatamineDatabase
local DATABASE;

local EVENTS = {
    CHAT_MSG_MONSTER_SAY = "CHAT_MSG_MONSTER_SAY",
    CHAT_MSG_MONSTER_YELL = "CHAT_MSG_MONSTER_YELL",
    CHAT_MSG_MONSTER_EMOTE = "CHAT_MSG_MONSTER_EMOTE",
    CHAT_MSG_MONSTER_PARTY = "CHAT_MSG_MONSTER_PARTY",
    CHAT_MSG_MONSTER_WHISPER = "CHAT_MSG_MONSTER_WHISPER",

    UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",

    --COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED",

    PLAYER_SOFT_ENEMY_CHANGED = "PLAYER_SOFT_ENEMY_CHANGED",
    PLAYER_SOFT_FRIEND_CHANGED = "PLAYER_SOFT_FRIEND_CHANGED",
    PLAYER_SOFT_INTERACT_CHANGED = "PLAYER_SOFT_INTERACT_CHANGED",
    PLAYER_TARGET_CHANGED = "PLAYER_TARGET_CHANGED",

    NAME_PLATE_UNIT_ADDED = "NAME_PLATE_UNIT_ADDED",
    FORBIDDEN_NAME_PLATE_UNIT_ADDED = "FORBIDDEN_NAME_PLATE_UNIT_ADDED",

    ITEM_TEXT_BEGIN = "ITEM_TEXT_BEGIN",
    ITEM_TEXT_READY = "ITEM_TEXT_READY",
    ITEM_TEXT_CLOSED = "ITEM_TEXT_CLOSED",

    MERCHANT_SHOW = "MERCHANT_SHOW"
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

function DatamineCollectorMixin:UpdateCollectionState()
    self.EnableCollection = Datamine.Settings.ShouldCollectAnyData();
end

function DatamineCollectorMixin:OnAddonLoaded()
    self:UpdateCollectionState();
end

function DatamineCollectorMixin:OnSettingChanged(setting, newValue)
    self:UpdateCollectionState();
end

------------
-- broadcast text handling

function DatamineCollectorMixin:HandleBroadcastText(...)
    local text, name, language, name2 = ...;

    if issecretvalue(text) then
        return;
    end

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
        if issecretvalue(guid) then
            return;
        end

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

local function NextPage()
    RunNextFrame(function() ItemTextNextPage() end);
end

local function PrevPage()
    RunNextFrame(function() ItemTextPrevPage() end);
end

local DEFAULT_PAGE_COUNT = 0; -- since books are not zero-indexed

local _context = {
    text = {},
    guid = nil,
    title = nil,
    singlePage = false,
    pageCount = DEFAULT_PAGE_COUNT,
    doneReading = false,
    doneResetting = false,
    IsDone = function(self) return self.doneReading and self.doneResetting; end
};

local function CreateContext()
    local ctx = CopyTable(_context);
    ctx.guid = UnitGUID("npc");
    ctx.title = ItemTextGetItem();
    ctx.singlePage = not ItemTextHasNextPage();
    return ctx;
end

local function CreatePage(text, pageNumber)
    return {
        Text = text,
        Page = pageNumber
    };
end

local activeContext;
function DatamineCollectorMixin:ITEM_TEXT_BEGIN()
    activeContext = CreateContext();
    ItemTextFrame:SetAlpha(0);
end

function DatamineCollectorMixin:ITEM_TEXT_READY()
    local ctx = activeContext;
    DebugAssert(ctx, "Missing context in ITEM_TEXT_READY event");
    if not ctx then
        return;
    end

    if ctx:IsDone() then
        return;
    end

    if not ctx.doneReading then
        local pageNum = ItemTextGetPage();
        ctx.text[pageNum] = CreatePage(ItemTextGetText(), pageNum);
        if ItemTextHasNextPage() then
            ctx.pageCount = ctx.pageCount + 1;
            NextPage();
        else
            ctx.doneReading = true;
            if ctx.singlePage then
                ctx.doneResetting = true;
                ItemTextFrame:SetAlpha(1);
            end

            PrevPage();
        end
    elseif not ctx.doneResetting then
        ctx.pageCount = ctx.pageCount - 1;
        if ctx.pageCount == DEFAULT_PAGE_COUNT then
            ctx.doneResetting = true;
            ItemTextFrame:SetAlpha(1);
        end
        PrevPage();
    end
end

function DatamineCollectorMixin:ITEM_TEXT_CLOSED()
    if not activeContext then
        return;
    end

    DATABASE:InsertItemText(activeContext);
    activeContext = nil;
end

------------

local function GetErrorTextForMerchantItem(index)
    local tooltipInfo = C_TooltipInfo.GetMerchantItem(index);
    for _, line in ipairs(tooltipInfo.lines) do
        if line.type == Enum.TooltipDataLineType.None then
            if RED_FONT_COLOR:IsRGBEqualTo(line.leftColor) then
                return line.leftText;
            end
        end
    end
end

function DatamineCollectorMixin:MERCHANT_SHOW()
    C_Timer.After(0.15, function()
        self:CollectMerchantData();
    end);
end

function DatamineCollectorMixin:CollectMerchantData()
    if not Datamine.Settings.ShouldCollectVendorData() then
        return;
    end

    local vendorEntry = {
        CreatureID = UnitCreatureID("npc"),
        CreatureName = UnitName("npc"),
        Items = {}
    };

    local numAvailableItems = GetMerchantNumItems();

    for i=1, numAvailableItems do
        local itemID = GetMerchantItemID(i);
        local classID, subclassID = select(6, C_Item.GetItemInfoInstant(itemID));
        local info = C_MerchantFrame.GetItemInfo(i);
        if info.currencyID then
            info.name, info.texture, info.numAvailable = CurrencyContainerUtil.GetCurrencyContainerInfo(info.currencyID, info.numAvailable, info.name, info.texture);
        end

        if info.price and not info.currencyID then
            info.currencyID = -1;
        end

        local cost = {
            CurrencyID = info.currencyID,
            Amount = info.price,
        };

        local numRequiredItems = GetMerchantItemCostInfo(i);
        if numRequiredItems > 0 then
            cost.ItemCost = {};
            for j=1, numRequiredItems do
                local quantity, itemLink = select(2, GetMerchantItemCostItem(i, j));
                if itemLink then
                    local reqItemID = C_Item.GetItemInfoInstant(itemLink);
                    tinsert(cost.ItemCost, {
                        ItemID = reqItemID,
                        Amount = quantity
                    });
                end
            end
        end

        local item = {
            ItemID = itemID,
            ItemName = info.name,
            ItemClass = classID,
            ItemSubClass = subclassID,
            Quantity = info.numAvailable,
            Cost = cost
        };

        if not info.isPurchasable then
            local errorText = GetErrorTextForMerchantItem(i);
            assert(errorText ~= "Retrieving item information", "Attempting to log unloaded item. Please tell Ghost.");
            item.LockReason = errorText;
        end

        tinsert(vendorEntry.Items, item);
    end

    if #vendorEntry.Items == 0 then
        return;
    end

    local uiMapID = C_Map.GetBestMapForUnit("player");
    local x, y, _, mapID = UnitPosition("player");

    if x and y then
        local newUiMapID, mapPos = C_Map.GetMapPosFromWorldPos(mapID, {x=x, y=y}, uiMapID);

        vendorEntry.Position = {
            UiMapID = newUiMapID,
            X = mapPos.x * 100,
            Y = mapPos.y * 100,
        };
    else
        vendorEntry.Position = {
            UiMapID = uiMapID,
        };
    end

    DATABASE:InsertVendorEntry(vendorEntry);
end

------------

Datamine.Collector = {};

function Datamine.Collector.GetAllCreatureEntries()
    return DATABASE:GetAllCreatureEntries();
end